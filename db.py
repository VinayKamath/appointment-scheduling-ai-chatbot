import os
from contextlib import contextmanager

from dotenv import load_dotenv
from mysql.connector import Error, pooling

load_dotenv()  

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "database": os.getenv("DB_NAME", "hospital_appointment_scheduling"),
}

connection_pool = pooling.MySQLConnectionPool(
    pool_name="scheduling_pool",
    pool_size=5,
    **DB_CONFIG,
)


@contextmanager
def get_cursor(dictionary: bool = True, commit: bool = False):
    conn = connection_pool.get_connection()
    cursor = conn.cursor(dictionary=dictionary)
    try:
        yield cursor
        if commit:
            conn.commit()
    except Error:
        conn.rollback()
        raise
    finally:
        cursor.close()
        conn.close()  


def get_booked_times(doctor_id: int, date: str):
    """Returns the appointment_datetime values already booked for a doctor on a given date (YYYY-MM-DD)."""
    query = """
        SELECT appointment_datetime
        FROM appointments
        WHERE doctor_id = %s
          AND DATE(appointment_datetime) = %s
          AND status_id != (SELECT id FROM appointment_status WHERE name = 'Cancelled')
    """
    with get_cursor() as cursor:
        cursor.execute(query, (doctor_id, date))
        return [row["appointment_datetime"] for row in cursor.fetchall()]


def book_appointment(patient_id: int, doctor_id: int, appointment_datetime: str, reason: str):
    """Creates a new appointment with status 'Scheduled' and returns the new appointment_id."""
    query = """
        INSERT INTO appointments (patient_id, doctor_id, appointment_datetime, status_id, reason)
        VALUES (%s, %s, %s, (SELECT id FROM appointment_status WHERE name = 'Scheduled'), %s)
    """
    with get_cursor(commit=True) as cursor:
        cursor.execute(query, (patient_id, doctor_id, appointment_datetime, reason))
        return cursor.lastrowid


def get_patient_appointments(patient_id: int):
    """Returns all appointments for a patient, most recent first, with doctor name and status joined in."""
    query = """
        SELECT a.id, a.appointment_datetime, a.reason, s.name AS status,
               d.first_name AS doctor_first_name, d.last_name AS doctor_last_name
        FROM appointments a
        JOIN appointment_status s ON a.status_id = s.id
        JOIN doctor d ON a.doctor_id = d.id
        WHERE a.patient_id = %s
        ORDER BY a.appointment_datetime DESC
    """
    with get_cursor() as cursor:
        cursor.execute(query, (patient_id,))
        return cursor.fetchall()


def cancel_appointment(appointment_id: int):
    """Sets an appointment's status to 'Cancelled'. Returns 1 if it found and updated a row, 0 otherwise."""
    query = """
        UPDATE appointments
        SET status_id = (SELECT id FROM appointment_status WHERE name = 'Cancelled')
        WHERE id = %s
    """
    with get_cursor(commit=True) as cursor:
        cursor.execute(query, (appointment_id,))
        return cursor.rowcount


if __name__ == "__main__":
    # print("Appointments for patient_id 1:")
    # for appt in get_patient_appointments(1):
    #     print(appt)

    for time in get_booked_times(1, '2026-01-15'):
        print(time)

        