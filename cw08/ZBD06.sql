SET SERVEROUTPUT ON;

------------------- ZADANIE 01 -------------------

CREATE OR REPLACE PROCEDURE add_job (
    p_job_id    IN jobs.job_id%TYPE,
    p_job_title IN jobs.job_title%TYPE
) 
IS
BEGIN
    INSERT INTO jobs (job_id, job_title)
    VALUES (p_job_id, p_job_title);
    DBMS_OUTPUT.PUT_LINE('Dodano stanowisko: ' || p_job_id || ' - ' || p_job_title);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;   
/

BEGIN
    add_job('1000', 'Testowe stanowisko');
END;
/

-- dodanie drugi raz 
BEGIN
    add_job('1000', 'Testowe stanowisko');
END;
/
-- output:
-- Inny błąd: ORA-00001: unique constraint (GRABOWSKAK.SYS_C00285229) violated

------------------- ZADANIE 02 -------------------

CREATE OR REPLACE PROCEDURE update_job_title (
    p_job_id    IN jobs.job_id%TYPE,
    p_new_job_title IN jobs.job_title%TYPE
)
IS
    e_no_update EXCEPTION;      -- wlasny wyjatek
BEGIN
    UPDATE jobs
    SET job_title = p_new_job_title
    WHERE job_id = p_job_id;
    
    IF SQL%ROWCOUNT = 0 THEN    -- liczba zaaktualizowanych wierszy
        RAISE e_no_update;      -- rzuc wyjatek
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Zaaktualizowano tytuł stanowiska: ' || p_job_id || ' tytuł: ' || p_new_job_title);
    
EXCEPTION
    WHEN e_no_update THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Nie zaktualizowano żadnego wiersza (nie istnieje job_id = ' || p_job_id || ')');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd');
END;   
/

BEGIN
    update_job_title('BRAK_ID', 'Cokolwiek');
END;
/

------------------- ZADANIE 03 -------------------

CREATE OR REPLACE PROCEDURE delete_job (
    p_job_id    IN jobs.job_id%TYPE
)
IS
    e_no_delete EXCEPTION;      -- wlasny wyjatek
BEGIN
    DELETE FROM jobs
    WHERE job_id = p_job_id;
    
    IF SQL%ROWCOUNT = 0 THEN    -- liczba zaaktualizowanych wierszy
        RAISE e_no_delete;      -- rzuc wyjatek
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Usunieto wiersz z tabeli Jobs: ' || p_job_id);
EXCEPTION
    WHEN e_no_delete THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Nie usunieto żadnego wiersza (nie istnieje job_id = ' || p_job_id || ')');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd');
END;   
/

BEGIN
    delete_job('1000');
END;
/

------------------- ZADANIE 04 -------------------

CREATE OR REPLACE PROCEDURE get_employee_data (
    p_employee_id IN  employees.employee_id%TYPE, -- IN – parametry wejściowe (ustawiane domyślnie)
    p_salary      OUT employees.salary%TYPE, -- OUT – parametry wyjściowe
    p_last_name   OUT employees.last_name%TYPE
)
IS
    e_not_found EXCEPTION;
BEGIN
    SELECT salary, last_name
    INTO p_salary, p_last_name
    FROM employees
    WHERE employee_id = p_employee_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak pracownika o ID = ' || p_employee_id);
        p_salary := NULL;
        p_last_name := NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
/

DECLARE
    v_salary employees.salary%TYPE;
    v_last_name employees.last_name%TYPE;
BEGIN
    get_employee_data(100, v_salary, v_last_name);  
    DBMS_OUTPUT.PUT_LINE('Nazwisko: ' || v_last_name);
    DBMS_OUTPUT.PUT_LINE('Zarobki: ' || v_salary);
END;
/

-- exception
DECLARE
    v_salary employees.salary%TYPE;
    v_last_name employees.last_name%TYPE;
BEGIN
    get_employee_data(300, v_salary, v_last_name);
    DBMS_OUTPUT.PUT_LINE('Nazwisko: ' || v_last_name);
    DBMS_OUTPUT.PUT_LINE('Zarobki: ' || v_salary);
END;
/

-- Brak pracownika o ID = 300
-- Nazwisko: 
-- Zarobki: 

------------------- ZADANIE 05 -------------------

CREATE SEQUENCE employees_seq 
   INCREMENT BY 1 START WITH 207 
   NOCACHE;

CREATE OR REPLACE PROCEDURE add_employee (
    p_first_name    IN  employees.first_name%TYPE DEFAULT NULL,
    p_last_name     IN  employees.last_name%TYPE,
    p_email         IN  employees.email%TYPE DEFAULT 'email@example.com',
    p_phone_number  IN  employees.phone_number%TYPE DEFAULT '999.999.9999',
    p_hire_date     IN employees.hire_date%TYPE DEFAULT SYSDATE,
    p_job_id        IN employees.job_id%TYPE DEFAULT 'IT_PROG',
    p_salary        IN employees.salary%TYPE DEFAULT 4800,
    p_manager_id    IN employees.manager_id%TYPE DEFAULT 100,
    p_department_id IN employees.department_id%TYPE DEFAULT 90
)
IS
    e_high_salary EXCEPTION;
BEGIN
    IF p_salary > 20000 THEN -- sprawdza wynagrodzenie
        RAISE e_high_salary;
    END IF;
    
    INSERT INTO employees (
        employee_id,
        first_name,
        last_name,
        email,
        phone_number,
        hire_date,
        job_id,
        salary,
        manager_id,
        department_id
    )
    VALUES (
        employees_seq.NEXTVAL,     -- ID z sekwencji
        p_first_name,
        p_last_name,
        p_email,
        p_phone_number,
        p_hire_date,
        p_job_id,
        p_salary,
        p_manager_id,
        p_department_id
    );

    DBMS_OUTPUT.PUT_LINE('Dodano pracownika: ' || p_last_name);

EXCEPTION
    WHEN e_high_salary THEN
        DBMS_OUTPUT.PUT_LINE('Wynagrodzenie nie może przekraczać 20000. Podano: ' || p_salary);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
/

BEGIN
    add_employee(
        p_first_name => 'Jan',
        p_last_name => 'Nowak',
        p_salary => 15000
    );
END;
/

BEGIN
    add_employee(
        p_first_name => 'Adam',
        p_last_name => 'Kowalski',
        p_salary => 50000
    );
END;
/

------------------- ZADANIE 06 -------------------

CREATE OR REPLACE PROCEDURE get_avg_salary (
    p_manager_id  IN  employees.manager_id%TYPE,
    p_avg_salary  OUT employees.salary%TYPE
)
IS
    e_no_subordinates EXCEPTION;
BEGIN
    -- obliczamy średnie zarobki
    SELECT AVG(salary)
    INTO p_avg_salary
    FROM employees
    WHERE manager_id = p_manager_id;

    -- jeśli brak podwładnych, AVG zwróci NULL → rzuć wyjątek
    IF p_avg_salary IS NULL THEN  
        RAISE e_no_subordinates;
    END IF;

EXCEPTION
    WHEN e_no_subordinates THEN
        DBMS_OUTPUT.PUT_LINE('Ten manager nie ma podwładnych: ' || p_manager_id);
        p_avg_salary := NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
        p_avg_salary := NULL;
END;
/

DECLARE
    v_avg employees.salary%TYPE;
BEGIN
    get_avg_salary(100, v_avg);
    DBMS_OUTPUT.PUT_LINE('Średnie zarobki podwładnych: ' || v_avg);
END;
/

DECLARE
    v_avg employees.salary%TYPE;
BEGIN
    get_avg_salary(9999, v_avg);
    DBMS_OUTPUT.PUT_LINE('Średnie zarobki: ' || v_avg);
END;
/

------------------- ZADANIE 07 -------------------

CREATE OR REPLACE PROCEDURE update_salaries_dept (
    p_department_id IN employees.department_id%TYPE,
    p_percent       IN NUMBER
)
IS
    e_no_department EXCEPTION;    -- własny wyjątek
    PRAGMA EXCEPTION_INIT(e_no_department, -2291);  -- ORA-02291 - nieistniejacy department
BEGIN
    UPDATE employees e
    SET salary = (
        SELECT 
            CASE
                WHEN e.salary * (1 + p_percent/100) < j.min_salary -- new_salary < min_salary
                    THEN j.min_salary
                WHEN e.salary * (1 + p_percent/100) > j.max_salary -- new_salary > max_salary
                    THEN j.max_salary
                ELSE e.salary * (1 + p_percent/100)
            END
        FROM jobs j
        WHERE j.job_id = e.job_id
    )
    WHERE e.department_id = p_department_id;
    DBMS_OUTPUT.PUT_LINE('Zaktualizowano ' || SQL%ROWCOUNT || ' pracowników.');
EXCEPTION
    WHEN e_no_department THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Department_ID = ' || p_department_id || ' nie istnieje (ORA-02291).');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
/

BEGIN
    update_salaries_dept(50, 10);   -- +10% w departamencie 50
END;
/

BEGIN
    update_salaries_dept(50, 10000);   -- +200% w departamencie 50
END;
/

SELECT first_name, last_name, salary -- ucinane do max
FROM employees
WHERE department_id = 50;

------------------- ZADANIE 08 -------------------

CREATE OR REPLACE PROCEDURE moving_employee (
    p_employee_id   IN employees.employee_id%TYPE,
    p_new_department_id IN employees.department_id%TYPE
)
IS
    e_employee_not_found EXCEPTION;    -- wlasny wyjatek
    e_department_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_department_not_found, -2291); -- blad ORA-02291
    v_count NUMBER;
BEGIN
    -- Sprawdzenie czy pracownik istnieje
    SELECT COUNT(*)
    INTO v_count -- wynik do v_count
    FROM employees
    WHERE employee_id = p_employee_id;

    IF v_count = 0 THEN -- jesli liczba rekordow = 0, to pracownik nie istnieje
        RAISE e_employee_not_found; -- rzuc wyjatek
    END IF;
    
    UPDATE employees
    SET department_id = p_new_department_id
    WHERE employee_id = p_employee_id;

    DBMS_OUTPUT.PUT_LINE('Pracownik ' || p_employee_id ||
                         ' przeniesiony do departamentu ' || p_new_department_id);

EXCEPTION
    WHEN e_employee_not_found THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Pracownik o ID ' || p_employee_id || ' nie istnieje.');
    WHEN e_department_not_found THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Departament ' || p_new_department_id || ' nie istnieje (ORA-02291).');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
/

BEGIN -- zmiana z department_id = 90 do 50
    moving_employee(100, 50);
END;
/

------------------- ZADANIE 09 -------------------

CREATE OR REPLACE PROCEDURE delete_department (
    p_department_id IN departments.department_id%TYPE
)
IS
BEGIN
    DELETE FROM departments -- proba usuniecia wiersza
    WHERE department_id = p_department_id; -- nie zadziala gdy sa pracownicy (foreign key)

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nie usunięto żadnego departamentu. Być może nie istnieje.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Departament ' || p_department_id || ' został usunięty.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd przy usuwaniu departamentu: ' || SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE moving_employee(
    p_employee_id        IN employees.employee_id%TYPE,
    p_new_department_id  IN employees.department_id%TYPE
)
IS
    v_count NUMBER;                       -- potrzebna zmienna!
    e_no_employee   EXCEPTION;
    e_no_department EXCEPTION;
BEGIN
    -- sprawdzenie czy istnieje nowy departament
    SELECT COUNT(*) INTO v_count
    FROM departments
    WHERE department_id = p_new_department_id;

    IF v_count = 0 THEN
        RAISE e_no_department;
    END IF;

    -- sprawdzenie czy pracownik istnieje
    SELECT COUNT(*) INTO v_count
    FROM employees
    WHERE employee_id = p_employee_id;

    IF v_count = 0 THEN
        RAISE e_no_employee;
    END IF;

    -- aktualizacja pracownika
    UPDATE employees
    SET department_id = p_new_department_id
    WHERE employee_id = p_employee_id;

    DBMS_OUTPUT.PUT_LINE('Pracownik ' || p_employee_id ||
                         ' przeniesiony do departamentu ' || p_new_department_id);

EXCEPTION
    WHEN e_no_employee THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Nie istnieje pracownik o ID ' || p_employee_id);
    WHEN e_no_department THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Nie istnieje departament o ID ' || p_new_department_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END;
/

BEGIN -- nie ma takiego departamentu
    delete_department(9999);
END;
/

-- stworzenie pustego department do usuniecia
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (3000, 'test', NULL, 1700);

BEGIN -- usuniecie pustego
    delete_department(3000);
END;
/

-- dodanie do department employee
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (3001, 'test', NULL, 1700);

BEGIN
    moving_employee(207, 3001);
END;
/

SELECT employee_id, last_name, department_id
FROM employees
WHERE employee_id = 207;

BEGIN -- nie ma takiego departamentu
    delete_department(3001);
END;
/