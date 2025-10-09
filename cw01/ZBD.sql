CREATE TABLE REGIONS (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(255)
);

CREATE TABLE COUNTRIES (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(255)
);

ALTER TABLE COUNTRIES
ADD region_id INT;

ALTER TABLE COUNTRIES
ADD CONSTRAINT region_id_fk -- constraint - ograniczenie
FOREIGN KEY (region_id) REFERENCES REGIONS(region_id);

ALTER TABLE COUNTRIES RENAME CONSTRAINT region_id_fk TO fk_region_id;

CREATE TABLE LOCATIONS (
    location_id INT PRIMARY KEY,
    street_address VARCHAR(255),
    postal_code VARCHAR(255),
    city VARCHAR(255),
    state_province VARCHAR(255),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES COUNTRIES(country_id)
);


CREATE TABLE DEPARTMENTS (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(255),
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES LOCATIONS(location_id)
);
-- dodac 1 klucz obcy manager

CREATE TABLE JOBS (
    job_id INT PRIMARY KEY,
    job_title VARCHAR(255)
);


ALTER TABLE JOBS
ADD (
min_salary INT,
max_salary INT
);

CREATE TABLE JOB_HISTORY (
    end_date DATE
);

ALTER TABLE JOB_HISTORY
ADD ( 
job_id INT,
department_id INT
);

ALTER TABLE JOB_HISTORY
ADD (
employee_id INT,
start_date DATE
);

ALTER TABLE JOB_HISTORY
ADD CONSTRAINT pk_job_history
PRIMARY KEY (employee_id, start_date);

ALTER TABLE JOB_HISTORY
ADD (
CONSTRAINT fk_job_id
FOREIGN KEY (job_id) REFERENCES JOBS(job_id),
CONSTRAINT fk_department_id
FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);

CREATE TABLE EMPLOYEES (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(255),
    hire_date VARCHAR(255),
    salary INT,
    commision_pct INT, --zapisywać np. 5% jako 0.05
    manager_id INT,
    job_id INT,
    department_id INT,
    CONSTRAINT  fk_employees_manager
        FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id),
    CONSTRAINT fk_employees_job
        FOREIGN KEY (job_id) REFERENCES JOBS(job_id),
    CONSTRAINT fk_employees_departments
        FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);

ALTER TABLE JOBS
ADD CONSTRAINT check_salary_difference
CHECK (max_salary - min_salary >= 2000);

INSERT ALL
    INTO JOBS (job_id, job_title, min_salary, max_salary) VALUES (1, 'Software Developer', 4000, 7000)
    INTO JOBS (job_id, job_title, min_salary, max_salary) VALUES (2, 'HR Specialist', 3000, 5000)
    INTO JOBS (job_id, job_title, min_salary, max_salary) VALUES (3, 'Project Manager', 3000, 8000)
    INTO JOBS (job_id, job_title, min_salary, max_salary) VALUES (4, 'Help Desk Specialist', 3000, 6000)
SELECT * FROM dual;

INSERT INTO REGIONS (region_id, region_name)
VALUES (1, 'Europe');

INSERT INTO COUNTRIES (country_id, country_name, region_id)
VALUES (1, 'Poland', 1);

INSERT INTO LOCATIONS (location_id, street_address, postal_code, city, state_province, country_id)
VALUES (1, 'Main Street 10', '00-001', 'Warsaw', 'Mazowieckie', 1);

INSERT INTO DEPARTMENTS (department_id, department_name, location_id)
VALUES (1, 'IT Department', 1);

INSERT ALL
    INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, salary, commision_pct, manager_id, job_id, department_id)
    VALUES (1, 'John', 'Smith', 'jsmith@example.com', '555-101-202', '2021-05-10', 8000, NULL, NULL, 3, 1)

    INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, salary, commision_pct, manager_id, job_id, department_id)
    VALUES (2, 'Emily', 'Johnson', 'ejohnson@example.com', '555-101-203', '2022-02-15', 5000, 0.05, 1, 1, 1)

    INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, salary, commision_pct, manager_id, job_id, department_id)
    VALUES (3, 'Sarah', 'Davis', 'sdavis@example.com', '555-101-204', '2023-03-01', 4200, 0.03, 1, 2, 1)

    INTO EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date, salary, commision_pct, manager_id, job_id, department_id)
    VALUES (4, 'Michael', 'Brown', 'mbrown@example.com', '555-101-205', '2024-01-20', 4500, 0.02, 1, 4, 1)
SELECT * FROM dual;

UPDATE EMPLOYEES
SET manager_id = 1
WHERE employee_id IN (2, 3);

SELECT employee_id, first_name, last_name, manager_id
FROM EMPLOYEES
WHERE employee_id IN (1, 2, 3);

UPDATE JOBS
SET min_salary = min_salary + 500,
    max_salary = max_salary + 500
WHERE LOWER(job_title) LIKE '%b%'
    OR LOWER(job_title) LIKE '%s%';
    
SELECT * FROM JOBS;
SELECT * FROM JOBS
WHERE LOWER(job_title) LIKE '%b%'
    OR LOWER(job_title) LIKE '%s%';
    
DELETE FROM JOBS
WHERE max_salary > 9000;

SELECT * FROM JOBS
WHERE max_salary > 9000;

CREATE TABLE DELETE_TEST (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

INSERT INTO DELETE_TEST VALUES (1, 'test1');
INSERT INTO DELETE_TEST VALUES (2, 'test2');

DROP TABLE DELETE_TEST;
show recyclebin;
flashback table "BIN$yFERSBR9TfqzImM7879orQ==$0" to before drop;

SELECT * FROM DELETE_TEST;