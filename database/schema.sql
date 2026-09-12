CREATE DATABASE IF NOT EXISTS epms_payroll CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE epms_payroll;
CREATE TABLE IF NOT EXISTS users (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(100) NOT NULL UNIQUE, password_hash VARCHAR(255) NOT NULL,
 role VARCHAR(40) NOT NULL, active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS employees (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, employee_number VARCHAR(50) NOT NULL UNIQUE, first_name VARCHAR(100) NOT NULL,
 middle_name VARCHAR(100), last_name VARCHAR(100) NOT NULL, email VARCHAR(150), phone VARCHAR(50), address VARCHAR(255),
 city VARCHAR(100), state VARCHAR(50), zip_code VARCHAR(20), department VARCHAR(100), job_title VARCHAR(100),
 hire_date DATE, employment_status VARCHAR(30) DEFAULT 'ACTIVE', pay_type VARCHAR(30) DEFAULT 'HOURLY',
 hourly_rate DECIMAL(12,2) DEFAULT 0, pay_frequency VARCHAR(30) DEFAULT 'WEEKLY', filing_status VARCHAR(50) DEFAULT 'MARRIED_FILING_JOINTLY',
 traditional_401k_pct DECIMAL(6,3) DEFAULT 0, roth_pct DECIMAL(6,3) DEFAULT 0, traditional_catch_up_pct DECIMAL(6,3) DEFAULT 0,
 roth_catch_up_pct DECIMAL(6,3) DEFAULT 0, health_deduction DECIMAL(12,2) DEFAULT 0, active BOOLEAN DEFAULT TRUE
);
CREATE TABLE IF NOT EXISTS payrolls (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, employee_id BIGINT NOT NULL, period_beginning DATE, period_ending DATE, pay_date DATE,
 regular_hours DECIMAL(14,2), doubletime_hours DECIMAL(14,2), extra_hours1 DECIMAL(14,2), extra_hours2 DECIMAL(14,2),
 regular_rate DECIMAL(14,2), doubletime_rate DECIMAL(14,2), extra_rate1 DECIMAL(14,2), extra_rate2 DECIMAL(14,2),
 regular_pay DECIMAL(14,2), doubletime_pay DECIMAL(14,2), extra_pay1 DECIMAL(14,2), extra_pay2 DECIMAL(14,2), gross_pay DECIMAL(14,2),
 federal_taxable_wages DECIMAL(14,2), federal_tax DECIMAL(14,2), social_security_tax DECIMAL(14,2), medicare_tax DECIMAL(14,2),
 pa_tax DECIMAL(14,2), local_tax DECIMAL(14,2), lst DECIMAL(14,2), pa_sui DECIMAL(14,2), health DECIMAL(14,2),
 traditional_401k DECIMAL(14,2), roth DECIMAL(14,2), traditional_catch_up DECIMAL(14,2), roth_catch_up DECIMAL(14,2),
 employer_match DECIMAL(14,2), net_pay DECIMAL(14,2), status VARCHAR(30) DEFAULT 'CALCULATED',
 CONSTRAINT fk_payroll_employee FOREIGN KEY(employee_id) REFERENCES employees(id)
);
CREATE TABLE IF NOT EXISTS time_entries (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, employee_id BIGINT NOT NULL, work_date DATE NOT NULL, clock_in DATETIME,
 clock_out DATETIME, break_minutes INT DEFAULT 0, regular_hours DECIMAL(10,2) DEFAULT 0, overtime_hours DECIMAL(10,2) DEFAULT 0,
 doubletime_hours DECIMAL(10,2) DEFAULT 0, status VARCHAR(30) DEFAULT 'OPEN', FOREIGN KEY(employee_id) REFERENCES employees(id)
);
