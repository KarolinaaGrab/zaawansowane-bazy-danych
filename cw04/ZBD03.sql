------------------- ZADANIE 01 -------------------

CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT
    *
FROM
    employees e
WHERE
    e.salary > 6000;
    
SELECT * FROM v_wysokie_pensje;


------------------- ZADANIE 02 -------------------

CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT
    *
FROM
    employees e
WHERE
    e.salary > 12000;
    
SELECT * FROM v_wysokie_pensje;


------------------- ZADANIE 03 -------------------

DROP VIEW v_wysokie_pensje;


------------------- ZADANIE 04 -------------------

CREATE OR REPLACE VIEW v_pracownicy_finanse AS
SELECT
    e.employee_id,
    e.last_name,
    e.first_name
FROM
    employees e
LEFT JOIN
    departments d
ON
    e.department_id = d.department_id
WHERE
    d.department_name = 'Finance';
    
SELECT * FROM v_pracownicy_finanse;


------------------- ZADANIE 05 -------------------

CREATE OR REPLACE VIEW v_pracownicy_zarobki_5000_12000 AS
SELECT
    e.employee_id,
    e.last_name,
    e.first_name,
    e.salary,
    e.job_id,
    e.email,
    e.hire_date
FROM
    employees e
WHERE
    salary BETWEEN 5000 AND 12000;
    
SELECT * FROM v_pracownicy_zarobki_5000_12000;


------------------- ZADANIE 06 -------------------

-- a
-- b
-- c


------------------- ZADANIE 07 -------------------

CREATE OR REPLACE VIEW v_salary_stats AS
SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS liczba_pracownikow,
    ROUND(AVG(e.salary)) AS srednia_pensja,
    MAX(e.salary) AS maksymalna_pensja
FROM
    departments d
LEFT JOIN
    employees e
ON
    e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) >= 4;

-- a

SELECT * FROM v_salary_stats;

--INSERT INTO v_salary_stats
--(department_id, department
