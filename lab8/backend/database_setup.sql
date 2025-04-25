-- Database creation (if not exists)
CREATE DATABASE IF NOT EXISTS health_info_system;
USE health_info_system;

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS api_enrollment;
DROP TABLE IF EXISTS api_client;
DROP TABLE IF EXISTS api_healthprogram;
DROP TABLE IF EXISTS users_user_groups;
DROP TABLE IF EXISTS users_user_user_permissions;
DROP TABLE IF EXISTS users_user;
DROP TABLE IF EXISTS django_admin_log;
DROP TABLE IF EXISTS django_content_type;
DROP TABLE IF EXISTS auth_permission;
DROP TABLE IF EXISTS auth_group_permissions;
DROP TABLE IF EXISTS auth_group;
DROP TABLE IF EXISTS django_session;
DROP TABLE IF EXISTS django_migrations;

-- Create tables
-- Django required tables will be created by the migrate command
-- We'll just define our custom tables here

-- Health Program table
CREATE TABLE api_healthprogram (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL
);

-- Client table
CREATE TABLE api_client (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(1) NOT NULL,
    phone_number VARCHAR(15) NULL,
    email VARCHAR(254) NULL,
    address TEXT NULL,
    registration_date DATE NOT NULL
);

-- Enrollment (junction table)
CREATE TABLE api_enrollment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_date DATE NOT NULL,
    notes TEXT NULL,
    client_id INT NOT NULL,
    program_id INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES api_client(id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES api_healthprogram(id) ON DELETE CASCADE,
    UNIQUE (client_id, program_id)
);

-- Custom User model
-- Custom User model
CREATE TABLE users_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(128) NOT NULL,
    last_login DATETIME(6) NULL,
    is_superuser TINYINT(1) NOT NULL,
    username VARCHAR(150) NOT NULL,
    first_name VARCHAR(150) NOT NULL,
    last_name VARCHAR(150) NOT NULL,
    is_staff TINYINT(1) NOT NULL,
    is_active TINYINT(1) NOT NULL,
    date_joined DATETIME(6) NOT NULL,
    email VARCHAR(191) NOT NULL UNIQUE,
    is_doctor TINYINT(1) NOT NULL
);

-- Junction tables for User permissions
CREATE TABLE users_user_groups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    UNIQUE (user_id, group_id)
);

CREATE TABLE users_user_user_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    permission_id INT NOT NULL,
    UNIQUE (user_id, permission_id)
);

-- Insert test data

-- Health Programs
INSERT INTO api_healthprogram (name, description, created_at, updated_at) VALUES 
('HIV Testing and Counseling', 'Free HIV testing, counseling and referral services', NOW(), NOW()),
('Tuberculosis Control', 'TB screening, diagnosis, treatment and follow-up care', NOW(), NOW()),
('Malaria Prevention', 'Mosquito net distribution, malaria testing and treatment', NOW(), NOW()),
('Maternal Health', 'Prenatal care, safe delivery services and postnatal follow-up', NOW(), NOW()),
('Child Immunization', 'Routine vaccination for children according to national schedule', NOW(), NOW()),
('Diabetes Management', 'Blood sugar monitoring, medication and lifestyle advice', NOW(), NOW()),
('Hypertension Control', 'Blood pressure monitoring and management', NOW(), NOW());

-- Clients
INSERT INTO api_client (first_name, last_name, date_of_birth, gender, phone_number, email, address, registration_date) VALUES
('John', 'Doe', '1985-03-15', 'M', '123-456-7890', 'john.doe@example.com', '123 Main St, Anytown', CURDATE()),
('Jane', 'Smith', '1990-07-22', 'F', '234-567-8901', 'jane.smith@example.com', '456 Oak Ave, Somewhere', CURDATE()),
('Michael', 'Johnson', '1978-11-30', 'M', '345-678-9012', 'mjohnson@example.com', '789 Pine Rd, Nowhere', CURDATE()),
('Emily', 'Williams', '1992-05-12', 'F', '456-789-0123', 'emilyw@example.com', '321 Cedar Ln, Anywhere', CURDATE()),
('Robert', 'Brown', '1965-09-28', 'M', '567-890-1234', 'rbrown@example.com', '654 Maple Dr, Everywhere', CURDATE()),
('Sarah', 'Jones', '1982-12-03', 'F', '678-901-2345', 'sarahj@example.com', '987 Elm St, Somewhere', CURDATE()),
('David', 'Wilson', '1973-04-17', 'M', '789-012-3456', 'david.wilson@example.com', '135 Walnut Ave, Anytown', CURDATE()),
('Lisa', 'Taylor', '1995-08-09', 'F', '890-123-4567', 'lisa.t@example.com', '246 Birch Rd, Nowhere', CURDATE()),
('James', 'Anderson', '1968-01-25', 'M', '901-234-5678', 'janderson@example.com', '579 Pine St, Anywhere', CURDATE()),
('Jennifer', 'Thomas', '1988-06-14', 'F', '012-345-6789', 'jthomas@example.com', '864 Oak Rd, Everywhere', CURDATE());

-- Enrollments (Clients in Programs)
INSERT INTO api_enrollment (client_id, program_id, enrollment_date, notes) VALUES
(1, 2, CURDATE(), 'Regular follow-up needed, history of respiratory issues'),
(1, 6, CURDATE(), 'Type 2 Diabetes, recently diagnosed'),
(2, 4, CURDATE(), 'First pregnancy, due in 3 months'),
(2, 1, CURDATE(), 'Annual testing requested'),
(3, 7, CURDATE(), 'Hypertension Stage 1, on medication'),
(3, 6, CURDATE(), 'Pre-diabetic, diet control recommended'),
(4, 3, CURDATE(), 'Lives in high-risk malaria area'),
(4, 4, CURDATE(), 'Second pregnancy, previous C-section'),
(5, 7, CURDATE(), 'Hypertension Stage 2, needs close monitoring'),
(6, 4, CURDATE(), 'Third pregnancy, normal delivery expected'),
(7, 2, CURDATE(), 'History of TB exposure, preventive treatment'),
(8, 5, CURDATE(), 'First child, regular immunization schedule'),
(9, 6, CURDATE(), 'Type 1 Diabetes, insulin dependent'),
(10, 1, CURDATE(), 'Regular screening requested');

-- Admin user (password: admin123)
INSERT INTO users_user (password, is_superuser, username, first_name, last_name, is_staff, 
                       is_active, date_joined, email, is_doctor, last_login) VALUES
('pbkdf2_sha256$600000$XY01hCn2fClmNSZzFsLLo8$+pKS1ATgTTnJ0nOcExOW17O1pY2TZ3RJJehVXS1/+eY=', 
 1, 'admin', 'Admin', 'User', 1, 1, NOW(), 'admin@example.com', 1, NULL);

-- Doctor users (password: doctor123)
INSERT INTO users_user (password, is_superuser, username, first_name, last_name, is_staff, 
                       is_active, date_joined, email, is_doctor, last_login) VALUES
('pbkdf2_sha256$600000$ZQJrjCjbQrqJ37rPvYu4pP$I30f+xgJ3Z+Y0jEKvSsROqcIFtVHV5bHJ0fCw/K92IM=', 
 0, 'doctor1', 'John', 'Smith', 0, 1, NOW(), 'jsmith@example.com', 1, NULL),
('pbkdf2_sha256$600000$ZQJrjCjbQrqJ37rPvYu4pP$I30f+xgJ3Z+Y0jEKvSsROqcIFtVHV5bHJ0fCw/K92IM=', 
 0, 'doctor2', 'Mary', 'Johnson', 0, 1, NOW(), 'mjohnson@example.com', 1, NULL),
('pbkdf2_sha256$600000$ZQJrjCjbQrqJ37rPvYu4pP$I30f+xgJ3Z+Y0jEKvSsROqcIFtVHV5bHJ0fCw/K92IM=', 
 0, 'doctor3', 'Robert', 'Williams', 0, 1, NOW(), 'rwilliams@example.com', 1, NULL);

-- Non-doctor user (staff member, password: staff123)
INSERT INTO users_user (password, is_superuser, username, first_name, last_name, is_staff, 
                       is_active, date_joined, email, is_doctor, last_login) VALUES
('pbkdf2_sha256$600000$LW1o6lJJRKmWvB7ngBwzaD$uS1xP3gGaP3sAhKuwkJyo/9K1uH7JlUb5y0XyCDvK6I=', 
 0, 'staff1', 'Sarah', 'Davis', 0, 1, NOW(), 'sdavis@example.com', 0, NULL); 