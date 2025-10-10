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

-- locations
CREATE TABLE locations AS SELECT * FROM hr.locations;

ALTER TABLE locations
ADD PRIMARY KEY (location_id);

-- departments
CREATE TABLE departments AS SELECT * FROM hr.departments;

ALTER TABLE departments
ADD PRIMARY KEY (department_id);

-- jobs
CREATE TABLE jobs AS SELECT * FROM hr.jobs;

ALTER TABLE jobs
ADD PRIMARY KEY (job_id);

-- job_history
CREATE TABLE job_history AS SELECT * FROM hr.job_history;

ALTER TABLE job_history
ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);

ALTER TABLE job_history
ADD FOREIGN KEY (department_id) REFERENCES department(department_id);
 -------- dodac tu 2 klucze glowne
 
-- employees
CREATE TABLE employees AS SELECT * FROM hr.employees;

ALTER TABLE employees
ADD PRIMARY KEY (employee_id);

ALTER TABLE employees
ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);

ALTER TABLE employees
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

