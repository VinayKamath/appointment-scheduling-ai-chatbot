-- ============================================================
-- Seed data for hospital_appointment_scheduling
-- Run this AFTER hospital_schema.sql has been executed.
--
-- Notes:
-- - Names/contact info are realistic but fictional. Phone
--   numbers use the 555 exchange and emails use @example.com --
--   both are reserved placeholder conventions, not real routes.
-- - Medicine names are real drug names (factual reference data),
--   paired with realistic but generic dosing for sample purposes.
-- - IDs are specified explicitly so foreign keys below resolve
--   predictably; AUTO_INCREMENT will continue correctly from
--   the highest explicit value used.
-- - created_by values in prescription/appointment_note now
--   satisfy real foreign key constraints to doctor.id.
-- ============================================================

USE hospital_appointment_scheduling;

-- ============================================================
-- GENDER
-- ============================================================
INSERT INTO `gender` (`id`, `name`) VALUES
(1, 'Male'),
(2, 'Female'),
(3, 'Non-binary'),
(4, 'Prefer not to say');

-- ============================================================
-- COUNTRY
-- ============================================================
INSERT INTO `country` (`id`, `name`) VALUES
(1, 'United States'),
(2, 'Canada'),
(3, 'United Kingdom'),
(4, 'India'),
(5, 'Mexico'),
(6, 'Germany'),
(7, 'Australia'),
(8, 'France'),
(9, 'Philippines'),
(10, 'Nigeria');

-- ============================================================
-- APPOINTMENT_STATUS
-- ============================================================
INSERT INTO `appointment_status` (`id`, `name`) VALUES
(1, 'Scheduled'),
(2, 'Confirmed'),
(3, 'Checked-In'),
(4, 'Completed'),
(5, 'Cancelled'),
(6, 'No-Show');

-- ============================================================
-- BILL_STATUS
-- ============================================================
INSERT INTO `bill_status` (`id`, `name`) VALUES
(1, 'Pending'),
(2, 'Paid'),
(3, 'Overdue'),
(4, 'Refunded'),
(5, 'Cancelled');

-- ============================================================
-- PAYMENT_METHOD
-- ============================================================
INSERT INTO `payment_method` (`id`, `name`) VALUES
(1, 'Credit Card'),
(2, 'Debit Card'),
(3, 'Cash'),
(4, 'Insurance'),
(5, 'Bank Transfer');

-- ============================================================
-- SPECIALIZATION
-- ============================================================
INSERT INTO `specialization` (`id`, `name`) VALUES
(1, 'Cardiology'),
(2, 'Dermatology'),
(3, 'Pediatrics'),
(4, 'Orthopedics'),
(5, 'Neurology'),
(6, 'General Practice'),
(7, 'Psychiatry'),
(8, 'Gynecology'),
(9, 'Ophthalmology'),
(10, 'Endocrinology');

-- ============================================================
-- DOCTOR
-- ============================================================
INSERT INTO `doctor` (`id`, `first_name`, `last_name`, `gender_id`) VALUES
(1, 'Sarah', 'Mitchell', 2),
(2, 'James', 'Anderson', 1),
(3, 'Priya', 'Sharma', 2),
(4, 'Michael', 'Chen', 1),
(5, 'Emily', 'Rodriguez', 2),
(6, 'David', 'Thompson', 1),
(7, 'Aisha', 'Khan', 2),
(8, 'Robert', 'Walker', 1),
(9, 'Linda', 'Martinez', 2),
(10, 'Kevin', 'Brooks', 1);

-- ============================================================
-- DOCTOR_SPECIALIZATION (junction table)
-- ============================================================
INSERT INTO `doctor_specialization` (`doctor_id`, `specialization_id`) VALUES
(1, 1),   -- Sarah Mitchell - Cardiology
(1, 6),   -- Sarah Mitchell - General Practice
(2, 6),   -- James Anderson - General Practice
(3, 3),   -- Priya Sharma - Pediatrics
(4, 5),   -- Michael Chen - Neurology
(5, 2),   -- Emily Rodriguez - Dermatology
(6, 4),   -- David Thompson - Orthopedics
(7, 7),   -- Aisha Khan - Psychiatry
(8, 9),   -- Robert Walker - Ophthalmology
(9, 8),   -- Linda Martinez - Gynecology
(10, 10); -- Kevin Brooks - Endocrinology

-- ============================================================
-- PATIENTS
-- ============================================================
INSERT INTO `patients`
  (`id`, `first_name`, `last_name`, `gender_id`, `date_of_birth`, `phone_number`, `email_address`, `address_line_1`, `address_line_2`, `state`, `country_id`)
VALUES
(1,  'Maria',   'Garcia',   2, '1985-03-14', '(502) 555-0142', 'maria.garcia@example.com',   '123 Maple Street',  'Apt 4B', 'Indiana',        1),
(2,  'John',    'Smith',    1, '1978-11-02', '(812) 555-0198', 'john.smith@example.com',     '456 Oak Avenue',    NULL,     'Kentucky',       1),
(3,  'Wei',     'Zhang',    1, '1990-06-23', '(415) 555-0173', 'wei.zhang@example.com',      '789 Pine Road',     NULL,     'California',     1),
(4,  'Fatima',  'Al-Sayed', 2, '1995-01-09', '(917) 555-0211', 'fatima.alsayed@example.com', '321 Birch Lane',    'Unit 2', 'New York',       1),
(5,  'Carlos',  'Mendoza',  1, '1982-09-30', '(713) 555-0256', 'carlos.mendoza@example.com', '654 Cedar Street',  NULL,     'Texas',          1),
(6,  'Aisha',   'Brown',    2, '2000-04-18', '(614) 555-0289', 'aisha.brown@example.com',    '987 Elm Street',    NULL,     'Ohio',           1),
(7,  'Daniel',  'Kim',      1, '1988-12-05', '(206) 555-0317', 'daniel.kim@example.com',     '159 Willow Drive',  'Apt 7',  'Washington',     1),
(8,  'Sophia',  'Rossi',    2, '1993-07-21', '(617) 555-0344', 'sophia.rossi@example.com',   '753 Spruce Court',  NULL,     'Massachusetts',  1),
(9,  'Ahmed',   'Hassan',   1, '1975-02-28', '(312) 555-0378', 'ahmed.hassan@example.com',   '852 Aspen Way',     NULL,     'Illinois',       1),
(10, 'Olivia',  'Johnson',  2, '2002-10-11', '(404) 555-0402', 'olivia.johnson@example.com', '147 Magnolia Blvd', 'Suite 3','Georgia',        1),
(11, 'Liam',    'Walsh',    1, '1968-05-16', '(303) 555-0436', 'liam.walsh@example.com',     '963 Sycamore St',   NULL,     'Colorado',       1),
(12, 'Priya',   'Patel',    2, '1998-08-08', '(602) 555-0461', 'priya.patel@example.com',    '258 Redwood Ave',   NULL,     'Arizona',        1),
(13, 'Marcus',  'Williams', 1, '1980-03-25', '(901) 555-0489', 'marcus.williams@example.com','741 Poplar Lane',   'Apt 12', 'Tennessee',      1),
(14, 'Grace',   'Lee',      2, '1991-11-30', '(503) 555-0517', 'grace.lee@example.com',      '369 Chestnut Dr',   NULL,     'Oregon',         1),
(15, 'Jordan',  'Reyes',    3, '1996-06-14', '(702) 555-0543', 'jordan.reyes@example.com',   '482 Walnut Ct',     NULL,     'Nevada',         1),
(16, 'Emma',    'Foster',   2, '2018-09-12', '(615) 555-0578', 'foster.family@example.com',  '276 Hickory Ave',   NULL,     'Tennessee',      1);

-- ============================================================
-- APPOINTMENTS
-- ============================================================
INSERT INTO `appointments`
  (`id`, `patient_id`, `doctor_id`, `appointment_datetime`, `status_id`, `reason`)
VALUES
(1,  1,  1,  '2026-01-15 09:30:00', 4, 'Routine cardiac checkup'),
(2,  2,  2,  '2026-02-03 10:00:00', 4, 'Annual physical exam'),
(3,  3,  5,  '2026-02-10 13:15:00', 4, 'Skin rash evaluation'),
(4,  4,  7,  '2026-02-18 11:00:00', 4, 'Anxiety follow-up'),
(5,  5,  4,  '2026-03-05 11:00:00', 4, 'Migraine evaluation'),
(6,  6,  9,  '2026-03-12 14:30:00', 4, 'Annual wellness exam'),
(7,  7,  8,  '2026-03-20 09:00:00', 6, 'Vision check'),
(8,  8,  10, '2026-04-02 15:00:00', 4, 'Thyroid level review'),
(9,  9,  6,  '2026-04-10 10:30:00', 4, 'Knee pain assessment'),
(10, 10, 2,  '2026-04-18 09:45:00', 5, 'General consultation'),
(11, 11, 1,  '2026-05-01 08:30:00', 4, 'Hypertension follow-up'),
(12, 12, 5,  '2026-05-12 14:15:00', 4, 'Acne treatment follow-up'),
(13, 13, 4,  '2026-05-15 13:00:00', 4, 'Headache evaluation'),
(14, 14, 9,  '2026-05-22 11:30:00', 3, 'Prenatal checkup'),
(15, 15, 7,  '2026-06-05 16:00:00', 4, 'Medication management'),
(16, 1,  1,  '2026-06-25 09:30:00', 1, 'Cardiac follow-up'),
(17, 2,  2,  '2026-06-28 10:00:00', 2, 'Lab results review'),
(18, 6,  8,  '2026-07-02 14:00:00', 1, 'Annual eye exam'),
(19, 9,  6,  '2026-07-08 11:00:00', 2, 'Post-surgery follow-up'),
(20, 13, 10, '2026-07-15 10:00:00', 1, 'Diabetes management check'),
(21, 16, 3,  '2026-06-10 09:00:00', 4, 'Wellness checkup');

-- ============================================================
-- PATIENT_BILL
-- ============================================================
INSERT INTO `patient_bill`
  (`id`, `appointment_id`, `amount`, `bill_status_id`, `payment_method_id`, `bill_paid_datetime`)
VALUES
(1,  1,  250.00, 2, 4, '2026-01-20 10:00:00'),
(2,  2,  120.00, 2, 1, '2026-02-04 09:15:00'),
(3,  3,  175.00, 2, 4, '2026-02-12 11:00:00'),
(4,  4,  200.00, 1, NULL, NULL),
(5,  5,  300.00, 2, 4, '2026-03-10 14:00:00'),
(6,  6,  180.00, 2, 2, '2026-03-15 10:30:00'),
(7,  8,  220.00, 3, NULL, NULL),
(8,  9,  280.00, 2, 4, '2026-04-15 09:00:00'),
(9,  11, 250.00, 2, 4, '2026-05-05 13:00:00'),
(10, 12, 150.00, 2, 3, '2026-05-18 16:00:00'),
(11, 13, 300.00, 2, 5, '2026-05-20 10:00:00'),
(12, 14, 190.00, 1, NULL, NULL),
(13, 15, 200.00, 2, 4, '2026-06-08 11:00:00'),
(14, 21, 110.00, 2, 1, '2026-06-12 10:00:00');

-- ============================================================
-- PRESCRIPTION
-- ============================================================
INSERT INTO `prescription`
  (`id`, `prescribed_appointment_id`, `medicine_name`, `dosage`, `frequency`, `instruction`, `created_by`)
VALUES
(1,  1,  'Atorvastatin',              '20mg',               'Once daily',                 'Take in the evening with food', 1),
(2,  2,  'Vitamin D3',                '2000 IU',            'Once daily',                 'Take with breakfast', 2),
(3,  4,  'Sertraline',                '50mg',               'Once daily',                 'Take in the morning', 7),
(4,  5,  'Sumatriptan',               '50mg',               'As needed, max 2 per day',   'Take at onset of migraine symptoms', 4),
(5,  8,  'Levothyroxine',             '75mcg',              'Once daily',                 'Take on an empty stomach in the morning', 10),
(6,  9,  'Ibuprofen',                 '400mg',              'Three times daily as needed','Take with food to avoid stomach upset', 6),
(7,  11, 'Lisinopril',                '10mg',               'Once daily',                 'Take at the same time each day', 1),
(8,  12, 'Doxycycline',               '100mg',              'Twice daily',                'Take with a full glass of water', 5),
(9,  13, 'Naproxen',                  '500mg',              'Twice daily as needed',      'Take with food', 4),
(10, 15, 'Bupropion',                 '150mg',              'Once daily',                 'Take in the morning', 7),
(11, 21, 'Children''s Multivitamin',  'One chewable tablet','Once daily',                 'Take with breakfast', 3);

-- ============================================================
-- APPOINTMENT_NOTE
-- ============================================================
INSERT INTO `appointment_note`
  (`id`, `appointment_id`, `notes`, `created_by`)
VALUES
(1, 1,  'Patient reports occasional chest tightness during exercise. EKG normal. Recommended follow-up in 6 months.', 1),
(2, 5,  'Patient experiencing migraines 2-3 times per month. Prescribed Sumatriptan for acute episodes. Discussed trigger avoidance.', 4),
(3, 9,  'Mild swelling in right knee, likely overuse. Recommended rest, ice, and physical therapy referral.', 6),
(4, 14, 'Routine prenatal visit, 20 weeks gestation. Vitals stable, fetal heartbeat normal.', 9),
(5, 15, 'Patient reports improved mood on current medication regimen. Continue current dosage, follow-up in 4 weeks.', 7),
(6, 21, 'Growth and development on track for age. No concerns noted at this visit.', 3);
