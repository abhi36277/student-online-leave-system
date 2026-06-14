-- Create Database
CREATE DATABASE IF NOT EXISTS student_leave_db;
USE student_leave_db;

-- 1. Create Student Table
CREATE TABLE IF NOT EXISTS student (
    usn VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL
);

-- 2. Create Admin Table
CREATE TABLE IF NOT EXISTS admin (
    username VARCHAR(50) PRIMARY KEY,
    password VARCHAR(50) NOT NULL
);

-- 3. Create Leave Request Table
CREATE TABLE IF NOT EXISTS leave_request (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    student_usn VARCHAR(20) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    FOREIGN KEY (student_usn) REFERENCES student(usn) ON DELETE CASCADE
);

-- Insert Default Admin Account
INSERT INTO admin (username, password) 
VALUES ('admin', 'admin123')
ON DUPLICATE KEY UPDATE password='admin123';
