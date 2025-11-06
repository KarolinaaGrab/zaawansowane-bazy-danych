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
-- https://docs.oracle.com/cd/B14117_01/server.101/b10759/statements_8004.htm
-- a
---- v_wysokie_pensje z zad1

INSERT INTO v_wysokie_pensje (employee_id, first_name, last_name, email, hire_date, job_id, salary)
VALUES (3001, 'Aleksandra', 'Nowak', 'aleksandran@gmail.com', '08/02/06', 'AD_PRES', 2000);

SELECT * FROM v_wysokie_pensje;
SELECT * FROM employees;

-- Odpowiedź: Można dodać nowego pracownika przez ten widok, mimo że nie ma on pensji wyższej niż 6000

-- v_wysokie_pensje z zad2: tak samo jak w przypadku widoku z zad1

INSERT INTO v_pracownicy_finanse (
    employee_id,
    first_name,
    last_name,
    email,
    hire_date,
    job_id,
    salary
)
VALUES (
    3003,
    'Aleksandra',
    'Nienowak',
    'nie@example.com',
    SYSDATE,
    'AD_PRES',
    15000
);

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

--INSERT INTO v_salary_stats (department_id, department_name, liczba_pracownikow, srednia_pensja, maksymalna_pensja)
--VALUES (999, 'Nowy dział', 5, 7000, 12000);

-- wynik: QL Error: ORA-01779: nie można modyfikować kolumny, która odwzorowuje się do tabeli nie zachowującej kluczyQL Error: ORA-01779: nie można modyfikować kolumny, która odwzorowuje się do tabeli nie zachowującej kluczy
--*Cause:    An attempt was made to insert or update columns of a join view which
--           map to a non-key-preserved table.
--*Action:   Modify the underlying base tables directly.

-- Odpowiedź: Oracle blokuje modyfikacje (Insert, Update, Delete) przez ten widok, ponieważ
-- nie jest w stanie jednoznacznie określić, do którego wiersza w tabelach źródłowych
-- miałby wstawić dane.


------------------- ZADANIE 08 -------------------

--https://dev.mysql.com/doc/refman/8.4/en/view-check-option.html
--WITH CHECK OPTION clause can be given for an updatable view to:
--1) prevent inserts to row for which the WHERE clause in the select_statement is not true.
--2) prevent updates to rows for which the WHERE clause is true but the update would cause it to be not true (it prevents visible rows from being updated to nonvisible rows). 

CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT
    *
FROM
    employees e
WHERE
    e.salary > 12000
WITH CHECK OPTION;
    
SELECT * FROM v_wysokie_pensje;


-- a
---- i.

INSERT INTO v_wysokie_pensje (employee_id, first_name, last_name, email, salary, hire_date, job_id)
VALUES (
    3000, 'Anna', 'Kowalska', 'annak@gmail.com', 7500, '08/02/06', 'AD_PRES'
);

-- SQL Error: ORA-01402: naruszenie klauzuli WHERE dla perspektywy z WITH CHECK OPTION
-- Odpowiedź: Nie można dodać tego użytkownika, ponieważ widok przyjmuje pracowników zarabiających więcej niż 6000


---- ii.

INSERT INTO v_wysokie_pensje (employee_id, first_name, last_name, email, salary, hire_date, job_id)
VALUES (
    3000, 'Anna', 'Kowalska', 'annak@gmail.com', 13000, '08/02/06', 'AD_PRES'
);

SELECT * FROM v_wysokie_pensje;

-- 1 row inserted.
-- Odpowiedź: Dodano takiego pracownika


------------------- ZADANIE 09 -------------------

-- widok zmaterializowany - tabela, która fizycznie przechowuje wyniki zapytania SQL, zamiast generować zapytanie za każdym razem, gdy jest używany
-- W BigQuery zmaterializowane widoki służą do zwiększenia wydajności zapytań poprzez przechowywanie wyników złożonych zapytań, które są często wykonywane.


SELECT
    e.employee_id,
    e.manager_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM
    employees e
LEFT JOIN
    departments d ON e.department_id = d.department_id
WHERE
    e.manager_id IS NULL;
    
    
CREATE MATERIALIZED VIEW v_managerowie
BUILD IMMEDIATE 
REFRESH FORCE
ON DEMAND
AS
SELECT
    e.employee_id,
    e.manager_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM
    employees e
LEFT JOIN
    departments d ON e.department_id = d.department_id
WHERE
    e.manager_id IS NULL;
    
SELECT * FROM v_managerowie;


------------------- ZADANIE 10 -------------------

CREATE OR REPLACE VIEW v_najlepiej_oplacani AS
SELECT *
FROM (
    SELECT *
    FROM employees
    ORDER BY salary DESC
)
WHERE ROWNUM <= 10;

SELECT * FROM v_najlepiej_oplacani;
