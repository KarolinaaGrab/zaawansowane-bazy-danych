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
SELECT * FROM jobs;

DECLARE
    CURSOR c_kraje (p_region_id NUMBER) IS -- kursor z parametrem region_id
        SELECT 
            c.country_name,
            (
                SELECT COUNT(*)
                FROM employees e
                JOIN departments d ON e.department_id = d.department_id
                JOIN locations l ON d.location_id = l.location_id
                WHERE l.country_id = c.country_id
            ) AS liczba_pracownikow
        FROM countries c
        WHERE c.region_id = p_region_id;
    v_kraj   countries.country_name%TYPE;
    v_count  NUMBER;
BEGIN
    OPEN c_kraje(1); -- otwarcie kursora dla regionu Europe = 1
    LOOP
        FETCH c_kraje INTO v_kraj, v_count;
        EXIT WHEN c_kraje%NOTFOUND;
        dbms_output.put_line('Kraj: ' || v_kraj || ', liczba pracownikow: ' || v_count);
    END LOOP;
    CLOSE c_kraje;
END;
/


------------------- ZADANIE 08 -------------------

DECLARE
    CURSOR c_dep50 IS
        SELECT
            e.salary,
            e.last_name
        FROM employees e
        WHERE e.department_id = 50;
    v_last_name employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    OPEN c_dep50;
    LOOP
        FETCH c_dep50 INTO v_salary, v_last_name;
        EXIT WHEN c_dep50%NOTFOUND;
        
        IF v_salary > 3100 THEN
            dbms_output.put_line(v_last_name || ' - nie dawać podwyżki');
        ELSE
            dbms_output.put_line(v_last_name || ' - dać podwyżkę');
        END IF;
    END LOOP;
    CLOSE c_dep50;
END;
/


------------------- ZADANIE 09 -------------------
-- a i b

DECLARE
    -- kursor z parametrami
    CURSOR c_emp(p_min_salary NUMBER, p_max_salary NUMBER, p_name_part VARCHAR2) IS
        SELECT first_name, last_name, salary
        FROM employees
        WHERE salary BETWEEN p_min_salary AND p_max_salary
          AND LOWER(first_name) LIKE '%' || LOWER(p_name_part) || '%';

    v_first_name employees.first_name%TYPE;
    v_last_name  employees.last_name%TYPE;
    v_salary     employees.salary%TYPE;
BEGIN
    -- a) widelki 1000 - 5000 i czesc imienia 'a' lub 'A'
    DBMS_OUTPUT.PUT_LINE('a) Pracownicy z zarobkami 1000-5000 i imieniem zawierającym "a":');
    OPEN c_emp(1000, 5000, 'a');

    LOOP
        FETCH c_emp INTO v_first_name, v_last_name, v_salary;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name || ' | Zarobki: ' || v_salary);
    END LOOP;

    CLOSE c_emp;

    -- b) widelki 5000 - 20000 i czesc imienia 'u' lub 'U'
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'b) Pracownicy z zarobkami 5000-20000 i imieniem zawierającym "u":');
    OPEN c_emp(5000, 20000, 'u');

    LOOP
        FETCH c_emp INTO v_first_name, v_last_name, v_salary;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name || ' | Zarobki: ' || v_salary);
    END LOOP;

    CLOSE c_emp;

END;
/


------------------- ZADANIE 10 -------------------



CREATE TABLE statystyki_menedzerow (
    manager_id NUMBER,
    number_of_subordinates NUMBER,
    salary_difference NUMBER
);

DECLARE
    -- a
    v_manager_id employees.manager_id%TYPE;
    v_count NUMBER;
    
    --b
    v_salary_max NUMBER;
    v_salary_min NUMBER;
    v_salary_diff NUMBER;
    
    CURSOR c_managers IS
        SELECT DISTINCT e.manager_id
        FROM employees e
        WHERE manager_id IS NOT NULL;
BEGIN
    DELETE FROM statystyki_menedzerow;
    FOR rec IN c_managers LOOP
        v_manager_id := rec.manager_id;
        
        -- a
        SELECT COUNT(*)
        INTO v_count
        FROM employees
        WHERE manager_id = v_manager_id;
        --DBMS_OUTPUT.PUT_LINE('Manager ID: ' || v_manager_id ||' -> liczba podwładnych: ' || v_count);
    
        --b
        SELECT MAX(salary)
        INTO v_salary_max
        FROM employees
        WHERE manager_id = v_manager_id;
        
        SELECT MIN(salary)
        INTO v_salary_min
        FROM employees
        WHERE manager_id = v_manager_id;
        
        v_salary_diff := v_salary_max - v_salary_min;
        
        DBMS_OUTPUT.PUT_LINE('Manager ID: ' || v_manager_id ||'  liczba podwładnych: ' || v_count || '  różnica płac: ' || v_salary_diff);
    
        --c
        INSERT INTO statystyki_menedzerow(MANAGER_ID, NUMBER_OF_SUBORDINATES, SALARY_DIFFERENCE)
        VALUES (v_manager_id, v_count, v_salary_diff);
    END LOOP;
END;
/

SELECT * FROM STATYSTYKI_MENEDZEROW;
