DROP DATABASE IF EXISTS hospital_appointment_scheduling;
CREATE DATABASE hospital_appointment_scheduling;
USE hospital_appointment_scheduling;

CREATE TABLE `gender` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `country` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `appointment_status` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `bill_status` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `payment_method` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `specialization` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `doctor` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `gender_id` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_doctor_gender`
    FOREIGN KEY (`gender_id`) REFERENCES `gender` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `patients` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `gender_id` INT,
  `date_of_birth` DATETIME,
  `phone_number` VARCHAR(20),
  `email_address` VARCHAR(255),
  `address_line_1` VARCHAR(255),
  `address_line_2` VARCHAR(255),
  `state` VARCHAR(255),
  `country_id` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_patients_gender`
    FOREIGN KEY (`gender_id`) REFERENCES `gender` (`id`),
  CONSTRAINT `fk_patients_country`
    FOREIGN KEY (`country_id`) REFERENCES `country` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `appointments` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `patient_id` INT NOT NULL,
  `doctor_id` INT NOT NULL,
  `appointment_datetime` TIMESTAMP NULL DEFAULT NULL,
  `status_id` INT,
  `reason` VARCHAR(255),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_appointments_patient`
    FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`),
  CONSTRAINT `fk_appointments_doctor`
    FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`),
  CONSTRAINT `fk_appointments_status`
    FOREIGN KEY (`status_id`) REFERENCES `appointment_status` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `patient_bill` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `appointment_id` INT NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `bill_status_id` INT,
  `payment_method_id` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `bill_paid_datetime` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_patient_bill_appointment`
    FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`),
  CONSTRAINT `fk_patient_bill_status`
    FOREIGN KEY (`bill_status_id`) REFERENCES `bill_status` (`id`),
  CONSTRAINT `fk_patient_bill_payment_method`
    FOREIGN KEY (`payment_method_id`) REFERENCES `payment_method` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `prescription` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `prescribed_appointment_id` INT NOT NULL,
  `medicine_name` VARCHAR(255) NOT NULL,
  `dosage` VARCHAR(255),
  `frequency` VARCHAR(255),
  `instruction` VARCHAR(255),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `created_by` INT,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_prescription_appointment`
    FOREIGN KEY (`prescribed_appointment_id`) REFERENCES `appointments` (`id`),
  CONSTRAINT `fk_prescription_doctor`
    FOREIGN KEY (`created_by`) REFERENCES `doctor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `appointment_note` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `appointment_id` INT NOT NULL,
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `created_by` INT,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_appointment_note_appointment`
    FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`),
  CONSTRAINT `fk_appointment_note_doctor`
    FOREIGN KEY (`created_by`) REFERENCES `doctor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `doctor_specialization` (
  `doctor_id` INT NOT NULL,
  `specialization_id` INT NOT NULL,
  PRIMARY KEY (`doctor_id`, `specialization_id`),
  CONSTRAINT `fk_doctor_specialization_doctor`
    FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`),
  CONSTRAINT `fk_doctor_specialization_specialization`
    FOREIGN KEY (`specialization_id`) REFERENCES `specialization` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

