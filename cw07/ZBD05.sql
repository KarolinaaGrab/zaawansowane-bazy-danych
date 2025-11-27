SET SERVEROUTPUT ON;

-- https://www.guru99.com/pl/blocks-pl-sql.html
-- PL/SQL BLOCK
-- DECLARE SECTION (Optional)
--         (Declaration)
-- BEGIN
-- ...
-- EXECUTION SECTION (Mandatory!)
--          (SQL statement)
-- EXCEPTION HANDLING SECTION (Optional)
-- END; (Mandatory)
-- /

-- blok anonimowy nie ma okreslonej nazwy referencyjnej
------------------- ZADANIE 01 -------------------
-- najprostsza mozliwa anonimowa instukcja blokowa
--BEGIN
--    NULL;
--END;

-- Kwalifikowana nazwa kolumny w notacji z kropką lub nazwa poprzednio zadeklarowanej zmiennej musi być określona jako przedrostek atrybutu %TYPE.
-- Typ danych tej kolumny lub zmiennej jest przypisywany do zadeklarowanej zmiennej.
-- Jeśli typ danych kolumny lub zmiennej zmienia się, nie ma potrzeby modyfikowania kodu deklaracji.
-- ex. v_lastname      emp.lastname%TYPE;
DECLARE
    numer_max NUMBER; -- zmienna numer_max
    nowy_department departments.department_name%TYPE := 'EDUCATION'; -- typ pola dla zmiennej z nazwa nowego departamentu
BEGIN
    SELECT MAX(department_id)-- rowna maksymalnemu numerowi departamentu
    INTO numer_max 
    FROM departments; 
    
    INSERT INTO departments (department_id, department_name) -- dodaj do tabeli departament
    VALUES (numer_max + 10, nowy_department); -- departament z nr o 10 wiekszym
END;
/
SELECT * FROM departments;


------------------- ZADANIE 02 -------------------

DECLARE
    numer_max NUMBER; -- zmiennaprzechowujaca maksymalny department_id
    nowy_department departments.department_name%TYPE := 'EDUCATION';
    nowy_id NUMBER;   -- zmienna przechowa ID nowo dodanego departamentu
BEGIN
    -- pobranie maksymalnego ID departamentu
    SELECT MAX(department_id)
    INTO numer_max 
    FROM departments; 
    
    -- wyliczenie nowego ID
    nowy_id := numer_max + 10;
    
    -- dodanie nowego departamentu
    INSERT INTO departments (department_id, department_name)
    VALUES (nowy_id, nowy_department); -- departament z nr o 10 wiekszym
    
    -- aktualizacja location_id na 3000
    UPDATE departments
    SET location_id = 3000
    WHERE department_id = nowy_id;
END;
/

SELECT * FROM departments WHERE department_name = 'EDUCATION';


------------------- ZADANIE 03 -------------------

CREATE TABLE NOWA (
    liczba VARCHAR(50)
);

BEGIN
    FOR i in 1..10
    LOOP
        IF i NOT IN(4, 6) THEN
            INSERT INTO NOWA (liczba)
            VALUES (TO_CHAR(i));
        END IF;
    END LOOP;
END;
/

SELECT * FROM NOWA;


------------------- ZADANIE 04 -------------------
-- %ROWTYPE - odwoluje sie do wszystkich kolumn jednej tabeli
-- wypisywanie na konsoli: dbms_output.put_line();

DECLARE
    v_country countries%ROWTYPE; -- informacje z tabeli Countries w jednej zmiennej typu %ROWTYPE
BEGIN
    SELECT *
    INTO v_country
    FROM countries
    WHERE country_id = 'CA';
    dbms_output.put_line('Nazwa kraju: ' || v_country.country_name);
    dbms_output.put_line('ID kraju: ' || v_country.country_id);
END;
/


------------------- ZADANIE 05 -------------------

SELECT * FROM jobs WHERE LOWER(job_title) LIKE '%manager%';

DECLARE
    v_job jobs%ROWTYPE;
    v_count NUMBER := 0; -- liczba zaaktualizowanych rekordow
BEGIN
   FOR record IN (
   SELECT * FROM jobs WHERE LOWER(job_title) LIKE '%manager%'
   )
   LOOP
        v_job := record; -- przypisz caly rekord do zmiennej
        
        -- aktualizacja min. pensji o 5%
        UPDATE jobs
        SET min_salary = v_job.min_salary * 1.05
        WHERE job_id = v_job.job_id;
        
        v_count := v_count + 1;
    END LOOP;
    dbms_output.put_line('Liczba zaaktualizowanych rekordow: ' || v_count);
END;
/

-- A

BEGIN
    ROLLBACK;
    dbms_output.put_line('Zmiany zostaly cofniete');
END;
/

------------------- ZADANIE 06 -------------------

DECLARE
    v_job jobs%ROWTYPE;
BEGIN
    SELECT *
    INTO v_job
    FROM jobs
    WHERE max_salary = (
        SELECT MAX(max_salary) FROM jobs
    );
    
    dbms_output.put_line('job_id: ' || v_job.job_id);
    dbms_output.put_line('job_title: ' || v_job.job_title);
    dbms_output.put_line('min_salary: ' || v_job.min_salary);
    dbms_output.put_line('max_salary: ' || v_job.max_salary);
END;
/


------------------- ZADANIE 07 -------------------

SELECT * from regions;
SELECT * FROM countries;
SELECT * FROM locations;
SELECT * FROM departments;
SELECT * FROM employees;

--DECLARE
--    CURSOR c_region(NUMBER) IS
--    SELECT c.country_name,
--        SELECT COUNT(*)
--        FROM employees e
--        JOIN departments d ON e.department_id = d.department_id
--        JOIN locations l ON d.location_id = l.location_id
--        JOIN countries c ON c.country_id = l.country_id
--        WHERE 