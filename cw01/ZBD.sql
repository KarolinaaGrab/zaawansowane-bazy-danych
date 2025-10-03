CREATE TABLE REGIONS (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(255)
);

CREATE TABLE COUNTRIES (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(255)
);

--dodac klucz obcy

CREATE TABLE LOCATIONS (
    location_id INT PRIMARY KEY,
    street_address VARCHAR(255),
    postal_code VARCHAR(255),
    city VARCHAR(255),
    state_province VARCHAR(255)
);

--dodac klucz obcy

CREATE TABLE DEPARTMENTS (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(255)
);

-- 2 zmienne dodac

CREATE TABLE JOBS (
    job_id INT PRIMARY KEY,
    job_title VARCHAR(255)
);

-- 2 zmienne dodac

CREATE TABLE JOB_HISTORY (
    end_date DATE
);

-- klucz obcy jest kluczem głownym wraz z start_date
-- klucz obcy do job_id, department_id

CREATE TABLE EMPLOYEES (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(255),
    hire_date VARCHAR(255),
    salary INT,
    commision_pct INT --zapisywać np. 5% jako 0.05
);

-- klcuz obcy do job_id, manager_id, department_id