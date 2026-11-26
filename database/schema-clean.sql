CREATE DATABASE IF NOT EXISTS sims_clean CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sims_clean;

CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin','teacher','student','parent') NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE students (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_no VARCHAR(32) NOT NULL UNIQUE,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    birth_date DATE,
    email VARCHAR(190),
    phone VARCHAR(32),
    status ENUM('Active','Inactive','Graduated','Transferred') NOT NULL DEFAULT 'Active',
    account_id INT UNSIGNED UNIQUE,
    parent_id INT UNSIGNED,
    FOREIGN KEY (account_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE classes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    school_year VARCHAR(9) NOT NULL,
    room VARCHAR(40),
    teacher_id INT UNSIGNED,
    UNIQUE (name, school_year),
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE enrollments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    class_id INT UNSIGNED NOT NULL,
    enrolled_on DATE NOT NULL,
    status ENUM('Enrolled','Completed','Withdrawn') NOT NULL DEFAULT 'Enrolled',
    UNIQUE (student_id, class_id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE RESTRICT
);

CREATE TABLE attendance (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT UNSIGNED NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present','Late','Absent','Excused') NOT NULL,
    notes VARCHAR(240),
    UNIQUE (enrollment_id, attendance_date),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE
);

CREATE TABLE grades (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT UNSIGNED NOT NULL,
    subject VARCHAR(100) NOT NULL,
    term ENUM('Quarter 1','Quarter 2','Quarter 3','Quarter 4') NOT NULL,
    score DECIMAL(5,2) NOT NULL CHECK (score BETWEEN 0 AND 100),
    remarks VARCHAR(240),
    UNIQUE (enrollment_id, subject, term),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE
);

CREATE TABLE timetable (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id INT UNSIGNED NOT NULL,
    title VARCHAR(120) NOT NULL,
    kind ENUM('Class','Exam') NOT NULL,
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    room VARCHAR(40) NOT NULL,
    CHECK (ends_at > starts_at),
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
);

CREATE TABLE fees (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    description VARCHAR(120) NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    paid DECIMAL(10,2) NOT NULL DEFAULT 0,
    due_date DATE NOT NULL,
    CHECK (paid >= 0 AND paid <= amount),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

CREATE TABLE announcements (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(120) NOT NULL,
    body TEXT NOT NULL,
    audience ENUM('All','Teachers','Students','Parents') NOT NULL DEFAULT 'All',
    published_on DATE NOT NULL
);
