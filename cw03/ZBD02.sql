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
    

------- 5

SELECT
    department_id,
    SUM(salary) AS suma_zarobkow,
    ROUND(AVG(salary)) AS srednia_zarobkow
FROM
    employees
GROUP BY
    department_id
HAVING
    MIN(salary) > 5000;

    
------- 6


SELECT
    last_name,
    e.department_id,
    e.job_id
FROM
    employees e
LEFT JOIN
    departments d ON e.department_id = d.department_id
LEFT JOIN
    locations l ON d.location_id = l.location_id AND l.city = 'Toronto';
    
    
------- 7

SELECT
    a.first_name || ' ' || a.last_name AS pracownik,
    b.first_name || ' ' || b.last_name AS wspolpracownik
FROM
    employees a,
    employees b
WHERE
    a.first_name = 'Jennifer'
    AND a.employee_id <> b.employee_id
    AND a.department_id = b.department_id
ORDER BY
    a.first_name;
    
    
------- 8

SELECT
    d.department_id,
    d.department_name
FROM
    departments d
LEFT JOIN
    employees e ON d.department_id = e.department_id
WHERE
    e.employee_id IS NULL;
    
------- 9

SELECT * FROM hr.job_grades;

SELECT
    e.first_name || ' ' || e.last_name AS pracownik,
    e.job_id,
    d.department_name,
    e.salary,
    jg.grade
FROM
    employees e
LEFT JOIN
    departments d ON d.department_id = e.department_id
JOIN
    hr.job_grades jg ON e.salary BETWEEN jg.min_salary AND jg.max_salary; -- it only joins the job_grades row where the salary fits the range

------- 10

SELECT
    first_name || ' ' || last_name AS pracownik,
    salary
FROM
    employees e
WHERE
    e.salary > (SELECT AVG(salary) FROM employees);

SELECT AVG(salary) FROM employees;

------- 11

SELECT
    a.employee_id,
    a.first_name || ' ' || a.last_name AS pracownik
FROM
    employees a,
    employees b
WHERE
    a.employee_id <> b.employee_id
    AND a.department_id = b.department_id
    AND b.last_name LIKE '%u%';
    
------- 12

SELECT
    first_name || ' ' || last_name AS pracownik,
    hire_date,
    ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS liczba_miesiecy
FROM
    employees e
WHERE
    MONTHS_BETWEEN(SYSDATE, hire_date) > (SELECT AVG(MONTHS_BETWEEN(SYSDATE, hire_date)) FROM employees)
ORDER BY
    liczba_miesiecy DESC;
        
------- 13

SELECT
    d.department_name,
    COUNT(e.employee_id) AS liczba_pracownikow,
    ROUND(AVG(e.salary)) AS srednie_wynagrodzenie
FROM
    departments d
LEFT JOIN
    employees e ON d.department_id  = e.department_id
GROUP BY
    d.department_name
ORDER BY
    liczba_pracownikow DESC;
        
------- 14

SELECT
    e.first_name || ' ' || e.last_name AS pracownik
FROM
    employees e
WHERE
    e. salary < (SELECT MIN(e.salary)
                 FROM employees e
                 LEFT JOIN departments d
                 ON e.department_id = d.department_id
                 WHERE d.department_name = 'IT');
                         
------- 15

SELECT
    d.department_name
FROM
    departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
      AND e.salary > (SELECT AVG(salary) FROM employees)
);

                         
------- 16

SELECT
    e.job_id,
    ROUND(AVG(e.salary), 2) AS srednie_wynagrodzenie
FROM
    employees e
GROUP BY
    e.job_id
ORDER BY
    AVG(e.salary) DESC
FETCH FIRST 5 ROWS ONLY;

                         
------- 17

SELECT
    r.region_id,
    r.region_name,
    COUNT(DISTINCT c.country_id) AS liczba_krajow,
    COUNT(e.employee_id) AS liczba_pracownikow
FROM 
    regions r
LEFT JOIN
    countries c ON r.region_id = c.region_id
LEFT JOIN
    locations l ON l.country_id = c.country_id
LEFT JOIN
    departments d ON d.location_id = l.location_id
LEFT JOIN
    employees e ON e.department_id = d.department_id
GROUP BY
    r.region_id, r.region_name;


------- 18

SELECT
    e.first_name || ' ' || e.last_name AS pracownik,
    m.first_name || ' ' || m.last_name AS menedzer,
    e.salary AS pensja_pracownika,
    m.salary AS pensja_menedzera
FROM
    employees e
JOIN
    employees m ON e.manager_id = m.employee_id
WHERE
    e.salary > m.salary
ORDER BY
    e.salary DESC;


------- 19

SELECT
    EXTRACT(MONTH FROM hire_date) AS miesiac,
    COUNT(*) AS liczba_pracownikow
FROM
    employees
GROUP BY
    EXTRACT(MONTH FROM hire_date)
ORDER BY
    miesiac;


------- 20

SELECT
    d.department_name,
    ROUND(AVG(e.salary), 2) AS srednia_pensja
FROM
    departments d
JOIN
    employees e ON d.department_id = e.department_id
GROUP BY
    d.department_name
ORDER BY
    AVG(e.salary) DESC
FETCH FIRST 3 ROWS ONLY;
