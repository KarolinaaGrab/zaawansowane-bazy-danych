------------------- ZADANIE 01 -------------------

SELECT 'DROP TABLE "' || table_name || '" CASCADE CONSTRAINTS;' AS drop_statement
FROM user_tables;

-- user_tables - data directory view, lists all tables owned by the currently logged user
-- || - string concatenation operator
-- table_name - the name of each table from user_tables
-- 'text' - literal text

-- then I copied the output:
DROP TABLE "DEPARTMENTS" CASCADE CONSTRAINTS;
DROP TABLE "DELETE_TEST" CASCADE CONSTRAINTS;
DROP TABLE "JOBS" CASCADE CONSTRAINTS;
DROP TABLE "LOCATIONS" CASCADE CONSTRAINTS;
DROP TABLE "EMPLOYEES" CASCADE CONSTRAINTS;
DROP TABLE "COUNTRIES" CASCADE CONSTRAINTS;
DROP TABLE "REGIONS" CASCADE CONSTRAINTS;
DROP TABLE "JOB_HISTORY" CASCADE CONSTRAINTS;

------------------- ZADANIE 02 -------------------

-- regions
CREATE TABLE regions AS SELECT * FROM hr.regions;

ALTER TABLE regions
ADD PRIMARY KEY (region_id);


-- countries
CREATE TABLE countries AS SELECT * FROM hr.countries;

ALTER TABLE countries
ADD PRIMARY KEY (country_id);

ALTER TABLE countries
ADD FOREIGN KEY (region_id) REFERENCES regions(region_id);

-- locations
CREATE TABLE locations AS SELECT * FROM hr.locations;

ALTER TABLE locations
ADD PRIMARY KEY (location_id);

ALTER TABLE locations
ADD FOREIGN KEY (country_id) REFERENCES countries(country_id);


-- departments
CREATE TABLE departments AS SELECT * FROM hr.departments;

ALTER TABLE departments
ADD PRIMARY KEY (department_id);

ALTER TABLE departments
ADD FOREIGN KEY (location_id) REFERENCES locations(location_id);

ALTER TABLE departments
ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);


-- jobs
CREATE TABLE jobs AS SELECT * FROM hr.jobs;

ALTER TABLE jobs
ADD PRIMARY KEY (job_id);


-- job_history
CREATE TABLE job_history AS SELECT * FROM hr.job_history;

ALTER TABLE job_history
ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);

ALTER TABLE job_history
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE job_history
ADD PRIMARY KEY (employee_id, start_date);

ALTER TABLE job_history
ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
 

-- employees
CREATE TABLE employees AS SELECT * FROM hr.employees;

ALTER TABLE employees
ADD PRIMARY KEY (employee_id);

ALTER TABLE employees
ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);

ALTER TABLE employees
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE employees
ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);


------------------- ZADANIE 02 -------------------

------- 1

CREATE VIEW salary_between_2000_and_7000 AS
SELECT last_name || ' ' || salary AS wynagrodzenie
FROM employees
WHERE department_id IN (20, 50) AND salary BETWEEN 2000 AND 7000
ORDER BY last_name;

SELECT * FROM salary_between_2000_and_7000;

------- 2

CREATE OR REPLACE VIEW year_start_2005 AS
SELECT 
    hire_date || ' ' || last_name || ' ' || &column AS info
FROM 
    employees
WHERE 
    manager_id IS NOT NULL AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY 
    &column;
    
SELECT * FROM year_start_2005;
--     f.ex. employee_id
--pyta przy tworzeniu widoku o input, potem juz nie

SELECT 
    hire_date || ' ' || last_name || ' ' || &column AS info
FROM 
    employees
WHERE 
    manager_id IS NOT NULL AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY 
    &column;
    
--pyta za kazdym razem

------- 3

SELECT * FROM hr.employees;

CREATE OR REPLACE VIEW third_letter_e AS
SELECT
    first_name ||  ' ' || last_name AS full_name,
    salary,
    phone_number
FROM
    employees
WHERE
    last_name LIKE '__%e%' AND LOWER(first_name) LIKE '%' || LOWER('&input') || '%'
ORDER BY 1 DESC, 2 ASC;
-- input: an

SELECT * FROM third_letter_e;

SELECT
    first_name ||  ' ' || last_name AS full_name,
    salary,
    phone_number
FROM
    employees
WHERE
    last_name LIKE '__%e%' AND LOWER(first_name) LIKE '%' || LOWER('&input') || '%'
ORDER BY full_name DESC, salary ASC;


------- 4

SELECT
    first_name || ' ' || last_name AS full_name,
    ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS number_of_months,
    CASE
        WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) < 150 THEN salary * 0.10
        WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) BETWEEN 150 AND 199 THEN salary * 0.20
        ELSE salary * 0.30
    END AS extra_salary
FROM
    employees
ORDER BY
    number_of_months;
