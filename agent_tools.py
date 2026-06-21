import re
from datetime import datetime, timedelta
from typing import List, Optional

from langchain_core.tools import tool

from db import (
    get_cursor,
    book_appointment as _book_appointment,
    get_patient_appointments as _get_patient_appointments,
    cancel_appointment as _cancel_appointment,
    get_booked_times,
)

CLINIC_OPEN_HOUR = 9
CLINIC_CLOSE_HOUR = 17
SLOT_LENGTH_MINUTES = 30


@tool
def find_patient(phone_number: str, date_of_birth: str) -> dict:
    """
    Look up a patient by phone number and date of birth (YYYY-MM-DD).
    ALWAYS call this first and get a confirmed match before doing anything
    else involving a specific patient -- this is the identity verification
    step and must not be skipped. If no match is found, ask the patient
    whether they'd like to register as a new patient.
    """
    digits_only = re.sub(r"\D", "", phone_number)  # strips formatting so "415-555-0173" and "(415) 555-0173" match the same way
    query = """
        SELECT id, first_name, last_name
        FROM patients
        WHERE REGEXP_REPLACE(phone_number, '[^0-9]', '') = %s AND date_of_birth = %s
    """
    with get_cursor() as cursor:
        cursor.execute(query, (digits_only, date_of_birth))
        result = cursor.fetchone()
    if not result:
        return {"found": False, "message": "No patient record matches that phone number and date of birth."}
    return {
        "found": True,
        "patient_id": result["id"],
        "name": f"{result['first_name']} {result['last_name']}",
    }


def _get_lookup_id(table: str, name: Optional[str]):
    """
    Internal helper -- looks up the id for a name in a small lookup table
    (gender, country). Checks a small alias map first (e.g. "USA" ->
    "United States", since patients won't always type the exact value
    stored in the table), then falls back to a case-insensitive match.
    `table` must always be a hardcoded string from code, never a value
    passed in from the agent/user, since it's interpolated directly into
    the query; `name` is the only piece that comes from outside, and it
    stays parameterized.
    """
    if not name:
        return None
    normalized = LOOKUP_ALIASES.get(table, {}).get(name.strip().lower(), name)
    query = f"SELECT id FROM {table} WHERE LOWER(name) = LOWER(%s)"
    with get_cursor() as cursor:
        cursor.execute(query, (normalized,))
        result = cursor.fetchone()
    return result["id"] if result else None


LOOKUP_ALIASES = {
    "country": {
        "usa": "United States",
        "us": "United States",
        "u.s.": "United States",
        "u.s.a.": "United States",
        "united states of america": "United States",
        "america": "United States",
        "uk": "United Kingdom",
        "u.k.": "United Kingdom",
        "britain": "United Kingdom",
        "great britain": "United Kingdom",
    },
    "gender": {
        "m": "Male",
        "man": "Male",
        "f": "Female",
        "woman": "Female",
        "non binary": "Non-binary",
        "nonbinary": "Non-binary",
        "enby": "Non-binary",
    },
}


@tool
def create_patient(
    first_name: str,
    last_name: str,
    date_of_birth: str,
    phone_number: str,
    email_address: Optional[str] = None,
    address_line_1: Optional[str] = None,
    address_line_2: Optional[str] = None,
    state: Optional[str] = None,
    gender: Optional[str] = None,
    country: Optional[str] = None,
) -> dict:
    """
    Registers a new patient. Only call this after find_patient has
    confirmed no existing record matches, and after reading back the
    collected details (full name, date of birth, phone number) to the
    patient for confirmation. date_of_birth must be 'YYYY-MM-DD'. gender
    and country are optional plain text values (e.g. 'Female',
    'United States') -- matching to internal ids happens automatically,
    and if a value doesn't match anything on file it's just left blank
    rather than failing the registration.
    """
    digits_only = re.sub(r"\D", "", phone_number)

    # Guards against creating a duplicate if the agent skipped find_patient
    # or the patient already has a record under this phone + DOB.
    existing_query = """
        SELECT id, first_name, last_name FROM patients
        WHERE REGEXP_REPLACE(phone_number, '[^0-9]', '') = %s AND date_of_birth = %s
    """
    with get_cursor() as cursor:
        cursor.execute(existing_query, (digits_only, date_of_birth))
        existing = cursor.fetchone()
    if existing:
        return {
            "created": False,
            "patient_id": existing["id"],
            "message": f"A patient record already exists for {existing['first_name']} {existing['last_name']} with this phone number and date of birth.",
        }

    gender_id = _get_lookup_id("gender", gender)
    country_id = _get_lookup_id("country", country)

    unresolved = []
    if gender and not gender_id:
        unresolved.append(f"gender ('{gender}' not recognized)")
    if country and not country_id:
        unresolved.append(f"country ('{country}' not recognized)")

    insert_query = """
        INSERT INTO patients
            (first_name, last_name, gender_id, date_of_birth, phone_number,
             email_address, address_line_1, address_line_2, state, country_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    with get_cursor(commit=True) as cursor:
        cursor.execute(
            insert_query,
            (first_name, last_name, gender_id, date_of_birth, phone_number,
             email_address, address_line_1, address_line_2, state, country_id),
        )
        new_id = cursor.lastrowid

    result = {"created": True, "patient_id": new_id, "name": f"{first_name} {last_name}"}
    if unresolved:
        result["note"] = f"Saved, but could not match: {', '.join(unresolved)}. These were left blank rather than guessed."
    return result


@tool
def list_doctors_by_specialization(specialization: str) -> List[dict]:
    """
    Lists doctors matching a specialization (e.g. 'Cardiology', 'Pediatrics',
    'Dermatology'). Use this when the patient describes a need but hasn't
    named a specific doctor.
    """
    query = """
        SELECT d.id, d.first_name, d.last_name
        FROM doctor d
        JOIN doctor_specialization ds ON d.id = ds.doctor_id
        JOIN specialization s ON ds.specialization_id = s.id
        WHERE s.name = %s
    """
    with get_cursor() as cursor:
        cursor.execute(query, (specialization,))
        return cursor.fetchall()


@tool
def get_available_slots(doctor_id: int, date: str) -> List[str]:
    """
    Returns a list of open appointment times (24-hour HH:MM) for a given
    doctor on a given date (YYYY-MM-DD), based on a 9 AM-5 PM clinic day
    in 30-minute increments minus whatever that doctor already has booked.
    """
    booked = get_booked_times(doctor_id, date)
    booked_times = {dt.strftime("%H:%M") for dt in booked}

    slots = []
    current = datetime.strptime(f"{date} {CLINIC_OPEN_HOUR}:00", "%Y-%m-%d %H:%M")
    end = datetime.strptime(f"{date} {CLINIC_CLOSE_HOUR}:00", "%Y-%m-%d %H:%M")
    while current < end:
        time_str = current.strftime("%H:%M")
        if time_str not in booked_times:
            slots.append(time_str)
        current += timedelta(minutes=SLOT_LENGTH_MINUTES)
    return slots


@tool
def book_appointment(patient_id: int, doctor_id: int, appointment_datetime: str, reason: str) -> dict:
    """
    Books a new appointment. appointment_datetime must be 'YYYY-MM-DD HH:MM:SS'.
    Only call this after find_patient has confirmed identity AND you have
    read back the doctor, date, and time to the patient for confirmation.
    """
    new_id = _book_appointment(patient_id, doctor_id, appointment_datetime, reason)
    return {"success": True, "appointment_id": new_id}


@tool
def get_patient_appointments(patient_id: int) -> List[dict]:
    """Returns all appointments (past and upcoming) for a given patient_id, most recent first."""
    return _get_patient_appointments(patient_id)


@tool
def reschedule_appointment(appointment_id: int, new_datetime: str) -> dict:
    """
    Moves an existing appointment to a new date/time ('YYYY-MM-DD HH:MM:SS').
    Check get_available_slots for the new time before calling this, and
    confirm the change with the patient first.
    """
    query = "UPDATE appointments SET appointment_datetime = %s WHERE id = %s"
    with get_cursor(commit=True) as cursor:
        cursor.execute(query, (new_datetime, appointment_id))
        if cursor.rowcount:
            return {"success": True, "message": "Appointment rescheduled."}
        return {"success": False, "message": "No appointment found with that id."}


@tool
def cancel_appointment(appointment_id: int) -> dict:
    """Cancels an appointment by its appointment_id. Confirm with the patient before calling this."""
    rows_updated = _cancel_appointment(appointment_id)
    if rows_updated:
        return {"success": True, "message": "Appointment cancelled."}
    return {"success": False, "message": "No appointment found with that id."}


SCHEDULING_TOOLS = [
    find_patient,
    create_patient,
    list_doctors_by_specialization,
    get_available_slots,
    book_appointment,
    get_patient_appointments,
    reschedule_appointment,
    cancel_appointment,
]