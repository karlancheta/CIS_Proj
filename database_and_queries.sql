-- Create database
CREATE DATABASE IF NOT EXISTS HEALTHCARE_SYSTEM;
USE HEALTHCARE_SYSTEM;

-- City and State tables
CREATE TABLE IF NOT EXISTS CITY (
	city_id INT PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS STATE (
	state_id INT PRIMARY KEY AUTO_INCREMENT,
    state_name VARCHAR(100)
);

-- Hospital Branch
CREATE TABLE IF NOT EXISTS HOSPITAL_BRANCH (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    branch_street VARCHAR(255) NOT NULL,
	city_id INT NOT NULL,
    state_id INT NOT NULL,
    branch_zipcode VARCHAR(10) NOT NULL,
    FOREIGN KEY (city_id) REFERENCES CITY(city_id),
    FOREIGN KEY (state_id) REFERENCES STATE(state_id)
);

-- Patient
CREATE TABLE IF NOT EXISTS PATIENT (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    street VARCHAR(255) NOT NULL,
	zipcode VARCHAR(10) NOT NULL,
    city_id INT NOT NULL,
    state_id INT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES CITY(city_id),
    FOREIGN KEY (state_id) REFERENCES STATE(state_id)
);

-- Department
CREATE TABLE IF NOT EXISTS DEPARTMENT (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    branch_id INT,
    FOREIGN KEY (branch_id) REFERENCES HOSPITAL_BRANCH(branch_id)
);

-- Specialty
CREATE TABLE IF NOT EXISTS SPECIALTY (
    specialty_id INT PRIMARY KEY AUTO_INCREMENT,
    specialty_name VARCHAR(100) NOT NULL,
    specialty_notes VARCHAR(255)
);

-- Doctor
CREATE TABLE IF NOT EXISTS DOCTOR (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    department_id INT NOT NULL,
    specialty_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES DEPARTMENT(department_id),
    FOREIGN KEY (specialty_id)  REFERENCES SPECIALTY(specialty_id)
);

-- Doctor Specialty (many-to-many)
CREATE TABLE IF NOT EXISTS DOCTOR_SPECIALTY (
	doctor_id INT,
    specialty_id INT,
	PRIMARY KEY (doctor_id, specialty_id),
	FOREIGN KEY (doctor_id) REFERENCES DOCTOR(doctor_id),
    FOREIGN KEY (specialty_id)  REFERENCES SPECIALTY(specialty_id)
);

-- Nurse
CREATE TABLE IF NOT EXISTS NURSE (
    nurse_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES DEPARTMENT(department_id)
);

-- Doctor-Nurse (many-to-many)
CREATE TABLE IF NOT EXISTS DOCTOR_NURSE (
    doctor_id INT,
    nurse_id INT,
    PRIMARY KEY (doctor_id, nurse_id),
    FOREIGN KEY (doctor_id) REFERENCES DOCTOR(doctor_id),
    FOREIGN KEY (nurse_id)  REFERENCES NURSE(nurse_id)
);

-- Room and Bed
CREATE TABLE IF NOT EXISTS ROOM (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_name VARCHAR(50) NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES DEPARTMENT(department_id)
);

CREATE TABLE IF NOT EXISTS BED (
    bed_id INT PRIMARY KEY AUTO_INCREMENT,
    bed_number VARCHAR(20) NOT NULL,
    room_id INT NOT NULL,
    patient_id INT,
    FOREIGN KEY (room_id) REFERENCES ROOM(room_id),
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id)
);

-- Inventory
CREATE TABLE IF NOT EXISTS INVENTORY (
	inventory_id INT PRIMARY KEY AUTO_INCREMENT,
	item_name VARCHAR(100) NOT NULL,
	quantity INT NOT NULL,
	last_updated DATE
);

-- Medication
CREATE TABLE IF NOT EXISTS MEDICATION (
	medication_id INT PRIMARY KEY AUTO_INCREMENT,
    medication_name VARCHAR(100) NOT NULL,
    medication_type VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(50) NOT NULL,
    inventory_id INT NOT NULL,
    FOREIGN KEY (inventory_id) REFERENCES INVENTORY(inventory_id)
);

-- Prescription
CREATE TABLE IF NOT EXISTS PRESCRIPTION (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    medication_id INT NOT NULL,
    doctor_id INT NOT NULL,
    dosage FLOAT NOT NULL,
    dosage_unit VARCHAR(20) NOT NULL,
    frequency VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    refill_total INT,
    refills_used INT,
    refill_date DATE,
    refills_allowed BOOLEAN NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id),
    FOREIGN KEY (doctor_id)  REFERENCES DOCTOR(doctor_id),
    FOREIGN KEY (medication_id) REFERENCES MEDICATION(medication_id)
);

-- Appointment
CREATE TABLE IF NOT EXISTS APPOINTMENT (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id  INT NOT NULL,
    nurse_id INT,
    prescription_id INT,
    surgery_id INT,
    appointment_date DATETIME NOT NULL,
    reason VARCHAR(255),
    appointment_status ENUM ('booked', 'completed', 'cancelled', 'no_show', 'rescheduled') NOT NULL DEFAULT 'booked',
    doctor_notes VARCHAR(255),
    nurse_notes VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id),
    FOREIGN KEY (doctor_id)  REFERENCES DOCTOR(doctor_id),
    FOREIGN KEY (nurse_id)  REFERENCES NURSE(nurse_id),
    FOREIGN KEY (prescription_id) REFERENCES PRESCRIPTION(prescription_id),
    FOREIGN KEY (surgery_id) REFERENCES SURGERY(surgery_id)
);

-- Insurance
CREATE TABLE IF NOT EXISTS INSURANCE (
	insurance_id INT PRIMARY KEY AUTO_INCREMENT,
    provider_name VARCHAR(100) NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    coverage_amount DECIMAL(10,2) NOT NULL,
    coverage_type VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    contact_number VARCHAR(20),
    policy_number VARCHAR(50) NOT NULL,
    copay_amount DECIMAL(10,2),
    deductible DECIMAL(10,2),
    pre_approval_required BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS PATIENT_INSURANCE (
    patient_id INT,
    insurance_id INT,
    PRIMARY KEY (patient_id, insurance_id),
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id),
    FOREIGN KEY (insurance_id) REFERENCES INSURANCE(insurance_id)
);

-- Billing and Payment
CREATE TABLE IF NOT EXISTS BILL (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    insurance_id INT NOT NULL,
    amount_owed DECIMAL(10,2) NOT NULL,
    total_bill DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id),
    FOREIGN KEY (insurance_id) REFERENCES INSURANCE(insurance_id)
);

CREATE TABLE IF NOT EXISTS PAYMENT (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    bill_id INT,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (bill_id) REFERENCES BILL(bill_id)
);

-- Surgery and Equipment
CREATE TABLE IF NOT EXISTS SURGERY (
    surgery_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    bed_id INT NOT NULL,
    surgery_date DATETIME NOT NULL,
    surgery_type VARCHAR(100) NOT NULL,
    surgery_status ENUM('scheduled', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled') NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id),
    FOREIGN KEY (doctor_id)  REFERENCES DOCTOR(doctor_id),
    FOREIGN KEY (bed_id) REFERENCES BED(bed_id)
);

CREATE TABLE IF NOT EXISTS DOCTOR_ASSIGNMENT (
	doctor_assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    surgery_id INT NOT NULL,
    date DATE, 
    time TIME, 
    notes VARCHAR(255),
    FOREIGN KEY (doctor_id) REFERENCES DOCTOR(doctor_id),
    FOREIGN KEY (surgery_id) REFERENCES SURGERY(surgery_id)
);

CREATE TABLE IF NOT EXISTS EQUIPMENT (
    equipment_id INT PRIMARY KEY AUTO_INCREMENT,
    equipment_name VARCHAR(100) NOT NULL,
    equipment_type VARCHAR(50) NOT NULL,
    notes VARCHAR(255),
    availability BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS SURGERY_EQUIPMENT (
    surgery_id INT,
    equipment_id INT,
    PRIMARY KEY (surgery_id, equipment_id),
    FOREIGN KEY (surgery_id)   REFERENCES SURGERY(surgery_id),
    FOREIGN KEY (equipment_id) REFERENCES EQUIPMENT(equipment_id)
);

-- Lab and Test
CREATE TABLE IF NOT EXISTS LAB_TECHNICIAN (
    technician_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    department_id INT NOT NULL,
    branch_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES DEPARTMENT(department_id),
    FOREIGN KEY (branch_id)     REFERENCES HOSPITAL_BRANCH(branch_id)
);

CREATE TABLE IF NOT EXISTS LAB (
    lab_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    technician_id INT NOT NULL,
    lab_test_date DATE NOT NULL,
    notes VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES DOCTOR(doctor_id),
	FOREIGN KEY (technician_id) REFERENCES LAB_TECHNICIAN(technician_id)
);

CREATE TABLE IF NOT EXISTS TEST (
	test_id INT PRIMARY KEY AUTO_INCREMENT,
    test_name VARCHAR(100), 
    is_specialized BOOLEAN 
);

-- Telehealth
CREATE TABLE IF NOT EXISTS TELEHEALTH_SESSION (
    telehealth_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    nurse_id INT NOT NULL,
    prescription_id INT,
	surgery_id INT,
    start_time DATETIME,
    end_time DATETIME,
    doctor_notes VARCHAR(255),
    nurse_notes VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id),
    FOREIGN KEY (doctor_id)  REFERENCES DOCTOR(doctor_id),
    FOREIGN KEY (nurse_id)   REFERENCES NURSE(nurse_id),
    FOREIGN KEY (prescription_id) REFERENCES PRESCRIPTION(prescription_id),
    FOREIGN KEY (surgery_id) REFERENCES SURGERY(surgery_id)
);

-- Feedback
CREATE TABLE IF NOT EXISTS FEEDBACK (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    number_stars INT NOT NULL,
    feedback_date DATE NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES PATIENT(patient_id)
);
