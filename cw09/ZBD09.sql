SET SERVEROUTPUT ON;

------------------- ZADANIE 01 -------------------

CREATE OR REPLACE PACKAGE functions_and_procedures AS
    PROCEDURE add_employee (
        p_first_name    IN  employees.first_name%TYPE DEFAULT NULL,
        p_last_name     IN  employees.last_name%TYPE,
        p_email         IN  employees.email%TYPE DEFAULT 'email@example.com',
        p_phone_number  IN  employees.phone_number%TYPE DEFAULT '999.999.9999',
        p_hire_date     IN employees.hire_date%TYPE DEFAULT SYSDATE,
        p_job_id        IN employees.job_id%TYPE DEFAULT 'IT_PROG',
        p_salary        IN employees.salary%TYPE DEFAULT 4800,
        p_manager_id    IN employees.manager_id%TYPE DEFAULT 100,
        p_department_id IN employees.department_id%TYPE DEFAULT 90
    );

    PROCEDURE add_job (
        p_job_id    IN jobs.job_id%TYPE,
        p_job_title IN jobs.job_title%TYPE
    );
    
    PROCEDURE delete_department (
        p_department_id IN departments.department_id%TYPE
    );
    
    PROCEDURE delete_job (
        p_job_id    IN jobs.job_id%TYPE
    );
    
    PROCEDURE get_avg_salary (
        p_manager_id  IN  employees.manager_id%TYPE,
        p_avg_salary  OUT employees.salary%TYPE
    );
    
    PROCEDURE get_employee_data (
        p_employee_id IN  employees.employee_id%TYPE,
        p_salary      OUT employees.salary%TYPE,
        p_last_name   OUT employees.last_name%TYPE
    );
    
    PROCEDURE moving_employee (
        p_employee_id   IN employees.employee_id%TYPE,
        p_new_department_id IN employees.department_id%TYPE
    );
    
    PROCEDURE update_job_title (
        p_job_id    IN jobs.job_id%TYPE,
        p_new_job_title IN jobs.job_title%TYPE
    );
    
    PROCEDURE update_salaries_dept (
        p_department_id IN employees.department_id%TYPE,
        p_percent       IN NUMBER
    );
    
    FUNCTION country_stats(
        p_country_name IN countries.country_name%TYPE)
        RETURN VARCHAR2;
    
    FUNCTION country_stats_func(
        p_country_name IN countries.country_name%TYPE)
        RETURN VARCHAR2;
        
    FUNCTION format_phone(
        p_phone IN VARCHAR2
        )
        RETURN VARCHAR2;
        
    FUNCTION format_text (
        p_text IN VARCHAR2
        )
        RETURN VARCHAR2;
        
    FUNCTION generate_access_id(
        p_first_name IN employees.first_name%TYPE,
        p_last_name IN employees.last_name%TYPE,
        p_phone_number IN employees.phone_number%TYPE
        )
        RETURN VARCHAR2;
    
    FUNCTION get_job_title (
        p_job_id IN jobs.job_id%TYPE
        )
        RETURN jobs.job_title%TYPE;
        
    FUNCTION get_yearly_salary  (
        p_employee_id IN employees.employee_id%TYPE
        )
        RETURN employees.salary%TYPE;
        
    FUNCTION pesel_to_date_str(p_pesel IN VARCHAR2)
        RETURN VARCHAR2;
        
END functions_and_procedures;
/

CREATE OR REPLACE PACKAGE BODY functions_and_procedures AS
    PROCEDURE add_employee (
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
        END add_employee;
        
    PROCEDURE add_job (
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
        END add_job;   
    
    PROCEDURE delete_department (
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
        END delete_department;

    PROCEDURE delete_job (
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
        END delete_job;  
        
    PROCEDURE get_avg_salary (
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
        END get_avg_salary;
        
    PROCEDURE get_employee_data (
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
        END get_employee_data;

    PROCEDURE moving_employee (
            p_employee_id   IN employees.employee_id%TYPE,
            p_new_department_id IN employees.department_id%TYPE
        )
        IS
            e_employee_not_found EXCEPTION;    -- własny wyjątek
            e_department_not_found EXCEPTION;
            PRAGMA EXCEPTION_INIT(e_department_not_found, -2291);
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
        END moving_employee;
        
    PROCEDURE update_job_title (
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
        END update_job_title;  
    
    PROCEDURE update_salaries_dept (
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
                        WHEN e.salary * (1 + p_percent/100) > j.max_salary -- new_salary > min_salary
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
        END update_salaries_dept;

    FUNCTION country_stats(
                p_country_name IN countries.country_name%TYPE)
            RETURN VARCHAR2
        IS
            v_employees_count  NUMBER;
            v_departments_count NUMBER;
            v_county_exists   NUMBER;
        BEGIN
            -- czy istnieje kraj?
            SELECT COUNT(*)
            INTO v_county_exists
            FROM countries
            WHERE country_name = p_country_name;
        
            IF v_county_exists = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Kraj o nazwie ' || p_country_name || 'nie istnieje');
            END IF;
        
            -- liczba departments
            SELECT COUNT(DISTINCT d.department_id)
            INTO v_departments_count
            FROM countries c
            JOIN locations l ON l.country_id = c.country_id
            JOIN departments d ON d.location_id = l.location_id
            WHERE c.country_name = p_country_name;
        
            -- liczba pracowników 
            SELECT COUNT(e.employee_id)
            INTO v_employees_count
            FROM countries c
            JOIN locations l   ON l.country_id = c.country_id
            JOIN departments d ON d.location_id = l.location_id
            JOIN employees e   ON e.department_id = d.department_id
            WHERE c.country_name = p_country_name;
        
            RETURN 'Kraj: ' || p_country_name ||
                   ', Departamenty: ' || v_departments_count ||
                   ', Pracownicy: ' || v_employees_count;
        END country_stats;
        
    FUNCTION country_stats_func(
                p_country_name IN countries.country_name%TYPE)
            RETURN VARCHAR2
        IS
            v_employees_count  NUMBER;
            v_departments_count NUMBER;
            v_county_exists   NUMBER;
        BEGIN
            -- czy istnieje kraj?
            SELECT COUNT(*)
            INTO v_county_exists
            FROM countries
            WHERE country_name = p_country_name;
        
            IF v_county_exists = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Kraj o nazwie ' || p_country_name || 'nie istnieje');
            END IF;
        
            -- liczba departments
            SELECT COUNT(DISTINCT d.department_id)
            INTO v_departments_count
            FROM countries c
            JOIN locations l ON l.country_id = c.country_id
            JOIN departments d ON d.location_id = l.location_id
            WHERE c.country_name = p_country_name;
        
            -- liczba pracowników 
            SELECT COUNT(e.employee_id)
            INTO v_employees_count
            FROM countries c
            JOIN locations l   ON l.country_id = c.country_id
            JOIN departments d ON d.location_id = l.location_id
            JOIN employees e   ON e.department_id = d.department_id
            WHERE c.country_name = p_country_name;
        
            RETURN 'Kraj: ' || p_country_name ||
                   ', Departamenty: ' || v_departments_count ||
                   ', Pracownicy: ' || v_employees_count;
        END country_stats_func;
        
    FUNCTION format_phone(
            p_phone IN VARCHAR2
        )
            RETURN VARCHAR2
        IS
            v_code VARCHAR2(10);     -- numer kierunkowy
            v_rest VARCHAR2(50);     -- reszta numeru
        BEGIN
            -- Sprawdzenie, czy numer zaczyna sie na (011.)
            IF SUBSTR(p_phone,1,4) = '011.' THEN
                v_code := REGEXP_SUBSTR(p_phone, '011\.([0-9]+)\.', 1, 1, NULL, 1); -- wyciagam numer kierunkowy kraju
                v_rest := REGEXP_SUBSTR(p_phone, '011\.[0-9]+\.?(.*)', 1, 1, NULL, 1); -- Reszta numeru
            ELSE
                v_code := SUBSTR(p_phone, 1, INSTR(p_phone, '.') - 1); -- kod = pierwsza część przed pierwszą kropką
                v_rest := SUBSTR(p_phone, INSTR(p_phone, '.') + 1); -- reszta numeru po pierwszej kropce
            END IF;
        
            RETURN '(' ||v_code|| ')' || v_rest;
        END format_phone;
        
    FUNCTION format_text (
            p_text IN VARCHAR2
        )
            RETURN VARCHAR2
        IS
            v_text VARCHAR2(4000);
            v_len  NUMBER;
        BEGIN
            IF p_text IS NULL THEN     -- jesli NULL - NULL
                RETURN NULL;
            END IF;
        
            v_len := LENGTH(p_text);
        
            IF v_len = 1 THEN -- 1 znak - 1 wielka litera
                RETURN UPPER(p_text);
            END IF;
        
            IF v_len = 2 THEN -- 2 znaki - oba wielkie
                RETURN UPPER(SUBSTR(p_text, 1, 1)) ||
                       UPPER(SUBSTR(p_text, 2, 1));
            END IF;
        
            RETURN UPPER(SUBSTR(p_text, 1, 1))    -- pierwsza litera - wielka
                   || LOWER(SUBSTR(p_text, 2, v_len - 2))  -- srodek - male
                   || UPPER(SUBSTR(p_text, v_len, 1));     -- ostatnia litera - wielka
        END format_text;
        
    FUNCTION generate_access_id(
            p_first_name IN employees.first_name%TYPE,
            p_last_name IN employees.last_name%TYPE,
            p_phone_number IN employees.phone_number%TYPE
            )
        RETURN VARCHAR2
    IS
        v_first_three_letters_last_name VARCHAR2(3);
        v_phone_number_part VARCHAR2(4);
        v_first_name_initial   VARCHAR2(1);
    BEGIN
        v_first_three_letters_last_name := UPPER(SUBSTR(p_last_name, 1, 3));
        v_phone_number_part := SUBSTR(REGEXP_REPLACE(p_phone_number, '[^0-9]', ''), -4);
        v_first_name_initial := UPPER(SUBSTR(p_first_name, 1, 1));
    
        RETURN v_first_three_letters_last_name || v_phone_number_part || v_first_name_initial;
    END generate_access_id;
    
    FUNCTION get_job_title (
    p_job_id IN jobs.job_id%TYPE
)
	RETURN jobs.job_title%TYPE IS
            v_title jobs.job_title%TYPE;
        BEGIN
            SELECT job_title
            INTO v_title
            FROM jobs
            WHERE job_id = p_job_id;
        
            RETURN v_title;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Brak stanowiska!');
                RETURN NULL;
        END get_job_title; 
    
    FUNCTION get_yearly_salary  (
            p_employee_id IN employees.employee_id%TYPE
        )
            RETURN employees.salary%TYPE
        IS
            v_yearly_salary employees.salary%TYPE;
            v_commission    employees.commission_pct%TYPE;
            v_salary employees.salary%TYPE;
        BEGIN
            SELECT salary, NVL(commission_pct, 0)
            INTO v_salary, v_commission
            FROM employees
            WHERE employee_id = p_employee_id;
        
            v_yearly_salary := (v_salary * 12) + (v_salary * v_commission * 12);
        
            RETURN v_yearly_salary;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Brak pracownika o tym id: '|| p_employee_id);
                RETURN NULL;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
                RETURN NULL;
        END get_yearly_salary; 
        
    FUNCTION pesel_to_date_str(p_pesel IN VARCHAR2)
            RETURN VARCHAR2
        IS
            v_year  NUMBER;
            v_month NUMBER;
            v_day   NUMBER;
        BEGIN
            -- pobranie year, month, day
            v_year  := SUBSTR(p_pesel, 1, 2);
            v_month := TO_NUMBER(SUBSTR(p_pesel, 3, 2));
            v_day   := SUBSTR(p_pesel, 5, 2);
        
            -- sprawdzenie stulecia
            CASE
                WHEN v_month BETWEEN 81 AND 92 THEN -- 1800 - 1899
                    v_year := 1800 + v_year;
                    v_month := v_month - 80;
                WHEN v_month BETWEEN 1 AND 12 THEN -- 1900 - 1999
                    v_year := 1900 + v_year;
                WHEN v_month BETWEEN 21 AND 32 THEN -- 2000 - 2099
                    v_year := 2000 + v_year;
                    v_month := v_month - 20;
                ELSE
                    RAISE_APPLICATION_ERROR(-20001, 'Błędny miesiąc - musi być z lat 1800 - 2099.');
            END CASE;
        
            RETURN -- dopelniamy zerami
                LPAD(v_year, 4, '0') || '-' ||
                LPAD(v_month, 2, '0') || '-' ||
                LPAD(v_day, 2, '0');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
                RETURN NULL;
        END pesel_to_date_str;
    END functions_and_procedures;
    /

-- uzycie pakietu

DECLARE
    v_avg employees.salary%TYPE;
BEGIN
    functions_and_procedures.get_avg_salary(
        p_manager_id => 100,
        p_avg_salary => v_avg
    );

    DBMS_OUTPUT.PUT_LINE('Średnia pensja: ' || v_avg);
END;
/


------------------- ZADANIE 02 -------------------

CREATE OR REPLACE PACKAGE regions_pkg AS
    
    -- create
    PROCEDURE add_region (
        p_region_id     IN regions.region_id%TYPE,
        p_region_name   IN regions.region_name%TYPE
    );
    
    -- read
    FUNCTION get_region_name (
        p_region_id     IN regions.region_id%TYPE
    ) RETURN regions.region_name%TYPE;
    
    PROCEDURE get_region_by_name (
        p_region_name   IN regions.region_name%TYPE,
        p_region_id     OUT regions.region_id%TYPE
    );
    
    PROCEDURE list_regions;
    
    -- update
    PROCEDURE update_region_name (
        p_region_id     IN regions.region_id%TYPE,
        p_region_name   IN regions.region_name%TYPE
    );
    
    -- delete
    PROCEDURE delete_region (
        p_region_id     IN regions.region_id%TYPE
    );
    
END regions_pkg;
/


CREATE OR REPLACE PACKAGE BODY regions_pkg AS
    
    -- create
    PROCEDURE add_region (
        p_region_id     IN regions.region_id%TYPE,
        p_region_name   IN regions.region_name%TYPE
    ) IS
    BEGIN
        INSERT INTO regions (region_id, region_name)
        VALUES (p_region_id, p_region_name);
        
        DBMS_OUTPUT.PUT_LINE('Dodano region: ' || p_region_name);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Blad: Region o tym ID już istnieje');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Blad: ' || SQLERRM);
    END add_region;
        
    -- read
    FUNCTION get_region_name (
        p_region_id     IN regions.region_id%TYPE
    ) RETURN regions.region_name%TYPE IS
        v_name regions.region_name%TYPE;
    BEGIN
        SELECT region_name
        INTO v_name
        FROM regions
        WHERE region_id = p_region_id;

        RETURN v_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Brak regionu o ID: ' || p_region_id);
            RETURN NULL;
    END get_region_name;
        
    PROCEDURE get_region_by_name (
        p_region_name   IN regions.region_name%TYPE,
        p_region_id     OUT regions.region_id%TYPE
    ) IS
    BEGIN
        SELECT region_id
        INTO p_region_id
        FROM regions
        WHERE region_name = p_region_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono regionu: ' || p_region_name);
            p_region_id := NULL;
    END get_region_by_name;
    
    PROCEDURE list_regions  IS
    BEGIN
        FOR r IN (SELECT region_id, region_name FROM regions ORDER BY region_id) LOOP
            DBMS_OUTPUT.PUT_LINE(r.region_id || ' - ' || r.region_name);
        END LOOP;
    END list_regions;
    
    -- update
    PROCEDURE update_region_name (
        p_region_id     IN regions.region_id%TYPE,
        p_region_name   IN regions.region_name%TYPE
    ) IS
    BEGIN
        UPDATE regions
        SET region_name = p_region_name
        WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono regionu do aktualizacji');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Zaktualizowano region ' || p_region_id);
        END IF;
    END update_region_name;
    
    -- delete
    PROCEDURE delete_region (
        p_region_id     IN regions.region_id%TYPE
    ) IS
    BEGIN
        DELETE FROM regions
        WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono regionu do usuniecia');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Usunieto region ID = ' || p_region_id);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Nie mozna usunac regionu – ma przypisane kraje');
    END delete_region;
    
END regions_pkg;
/

BEGIN
    regions_pkg.list_regions;
END;
/

BEGIN
    regions_pkg.add_region(10, 'TEST_REGION');
END;
/

BEGIN
    regions_pkg.update_region_name(10, 'UPDATED_REGION');
END;
/

BEGIN
    regions_pkg.delete_region(10);
END;
/



------------------- ZADANIE 03 -------------------

CREATE TABLE regions_audit (
    id          NUMBER PRIMARY KEY,
    username    VARCHAR2(30),
    operation   VARCHAR2(30),
    error_msg   VARCHAR2(4000),
    error_date  DATE
);

CREATE SEQUENCE regions_audit_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE PACKAGE regions_pkg AS
    
    -- niestandardowe wyjatki dla:
    e_region_name_exists EXCEPTION;
    e_region_has_countries EXCEPTION;
    
    -- logowanie bledow do tabeli audytowej
    PROCEDURE log_error (
        p_operation IN VARCHAR2,
        p_error_msg IN VARCHAR2
    );
    
    -- create
    PROCEDURE add_region (
        p_region_id     IN regions.region_id%TYPE,
        p_region_name   IN regions.region_name%TYPE
    );
    
    -- read
    FUNCTION get_region_name (
        p_region_id     IN regions.region_id%TYPE
    ) RETURN regions.region_name%TYPE;
    
    PROCEDURE get_region_by_name (
        p_region_name   IN regions.region_name%TYPE,
        p_region_id     OUT regions.region_id%TYPE
    );
    
    PROCEDURE list_regions;
    
    -- update
    PROCEDURE update_region_name (
        p_region_id     IN regions.region_id%TYPE,
        p_region_name   IN regions.region_name%TYPE
    );
    
    -- delete
    PROCEDURE delete_region (
        p_region_id     IN regions.region_id%TYPE
    );
    
END regions_pkg;
/

CREATE OR REPLACE PACKAGE BODY regions_pkg AS
    
    PROCEDURE log_error (
        p_operation IN VARCHAR2,
        p_error_msg IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO regions_audit (
            id, username, operation, error_msg, error_date
        )
        VALUES (
            regions_audit_seq.NEXTVAL,
            USER,
            p_operation,
            p_error_msg,
            SYSDATE
        );
    END log_error;
    
    -- create
    PROCEDURE add_region (
        p_region_id     IN regions.region_id%TYPE,
        p_region_name   IN regions.region_name%TYPE
    ) IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM regions
        WHERE region_name = p_region_name;
        
        IF v_count > 0 THEN
            RAISE e_region_name_exists;
        END IF;
        
        INSERT INTO regions (region_id, region_name)
        VALUES (p_region_id, p_region_name);
        
        DBMS_OUTPUT.PUT_LINE('Dodano region: ' || p_region_name);
    EXCEPTION
        WHEN e_region_name_exists THEN
            log_error('ADD_REGION', 'Region o takiej nazwie juz istnieje: ' || p_region_name);
            DBMS_OUTPUT.PUT_LINE('Blad: Region o takiej nazwie juz istnieje');
        WHEN DUP_VAL_ON_INDEX THEN
            log_error('ADD_REGION', 'Region o tym ID juz istnieje. ID = ' || p_region_id);
            DBMS_OUTPUT.PUT_LINE('Blad: Region o tym ID już istnieje');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Blad: ' || SQLERRM);
    END add_region;
        
    -- read
    FUNCTION get_region_name (
        p_region_id     IN regions.region_id%TYPE
    ) RETURN regions.region_name%TYPE IS
        v_name regions.region_name%TYPE;
    BEGIN
        SELECT region_name
        INTO v_name
        FROM regions
        WHERE region_id = p_region_id;

        RETURN v_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Brak regionu o ID: ' || p_region_id);
            RETURN NULL;
    END get_region_name;
        
    PROCEDURE get_region_by_name (
        p_region_name   IN regions.region_name%TYPE,
        p_region_id     OUT regions.region_id%TYPE
    ) IS
    BEGIN
        SELECT region_id
        INTO p_region_id
        FROM regions
        WHERE region_name = p_region_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono regionu: ' || p_region_name);
            p_region_id := NULL;
    END get_region_by_name;
    
    PROCEDURE list_regions  IS
    BEGIN
        FOR r IN (SELECT region_id, region_name FROM regions ORDER BY region_id) LOOP
            DBMS_OUTPUT.PUT_LINE(r.region_id || ' - ' || r.region_name);
        END LOOP;
    END list_regions;
    
    -- update
    PROCEDURE update_region_name (
        p_region_id     IN regions.region_id%TYPE,
        p_region_name   IN regions.region_name%TYPE
    ) IS
    BEGIN
        UPDATE regions
        SET region_name = p_region_name
        WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono regionu do aktualizacji');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Zaktualizowano region ' || p_region_id);
        END IF;
    END update_region_name;
    
    -- delete
    PROCEDURE delete_region (
        p_region_id     IN regions.region_id%TYPE
    ) IS
        e_child_exists EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_child_exists, -2292);
    BEGIN
        DELETE FROM regions
        WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono regionu do usuniecia');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Usunieto region ID = ' || p_region_id);
        END IF;
    EXCEPTION
        WHEN e_child_exists THEN
            log_error(
                'DELETE_REGION',
                'Region ma przypisane kraje. ID = ' || p_region_id
            );
            DBMS_OUTPUT.PUT_LINE('Nie mozna usunac regionu – ma przypisane kraje');
        WHEN OTHERS THEN
            log_error('DELETE_REGION', SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Inny blad');
    END delete_region;
    
END regions_pkg;
/

-- Blad: Region o takiej nazwie juz istnieje
BEGIN
    regions_pkg.add_region(10, 'Europe');
END;
/

-- Nie mozna usunac regionu – ma przypisane kraje
BEGIN
    regions_pkg.delete_region(2);
END;
/

SELECT * FROM regions_audit;



------------------- ZADANIE 04 -------------------

CREATE OR REPLACE PACKAGE dept_stats_pkg AS

    -- avg pensja w departamencie
    FUNCTION get_avg_salary_by_dept (
        p_department_id IN employees.department_id%TYPE
    ) RETURN NUMBER;

    -- min, max pensja dla stanowiska
    PROCEDURE get_min_max_salary_by_job (
        p_job_id     IN jobs.job_id%TYPE,
        p_min_salary OUT NUMBER,
        p_max_salary OUT NUMBER
    );

    -- raport tekstowy
    PROCEDURE generate_dept_report (
        p_department_id IN employees.department_id%TYPE
    );

END dept_stats_pkg;
/

CREATE OR REPLACE PACKAGE BODY dept_stats_pkg AS

    FUNCTION get_avg_salary_by_dept (
        p_department_id IN employees.department_id%TYPE
    ) RETURN NUMBER
    IS
        v_avg_salary NUMBER;
    BEGIN
        SELECT AVG(salary)
        INTO v_avg_salary
        FROM employees
        WHERE department_id = p_department_id;

        RETURN v_avg_salary;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END get_avg_salary_by_dept;


    PROCEDURE get_min_max_salary_by_job (
        p_job_id     IN jobs.job_id%TYPE,
        p_min_salary OUT NUMBER,
        p_max_salary OUT NUMBER
    )
    IS
    BEGIN
        SELECT MIN(salary), MAX(salary)
        INTO p_min_salary, p_max_salary
        FROM employees
        WHERE job_id = p_job_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_min_salary := NULL;
            p_max_salary := NULL;
        WHEN OTHERS THEN
            p_min_salary := NULL;
            p_max_salary := NULL;
    END get_min_max_salary_by_job;


    PROCEDURE generate_dept_report (
        p_department_id IN employees.department_id%TYPE
    )
    IS
        v_avg NUMBER;
        v_text VARCHAR2(4000);
    BEGIN
        v_avg := get_avg_salary_by_dept(p_department_id);
        
        -- CHR(10) - znak nowej linii
        -- NVL(wartosc, wartosc_zapasowa)
        -- jezeli NULL to - zwraca wartosc zapasowa
        v_text := '--- RAPORT DEPARTAMENTU ' || p_department_id || ' ---' || CHR(10) ||
                  'Srednia pensja: ' || NVL(TO_CHAR(v_avg), 'BRAK DANYCH') || CHR(10);

        DBMS_OUTPUT.PUT_LINE(v_text);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Blad generowania raportu: ' || SQLERRM);
    END generate_dept_report;

END dept_stats_pkg;
/

SELECT * FROM departments;

--- RAPORT DEPARTAMENTU 10 ---
-- Srednia pensja: 4400
BEGIN
    dept_stats_pkg.generate_dept_report(10);
END;
/


--- RAPORT DEPARTAMENTU 280 ---
-- Srednia pensja: BRAK DANYCH

BEGIN
    dept_stats_pkg.generate_dept_report(280);
END;
/



------------------- ZADANIE 05 -------------------

CREATE OR REPLACE PACKAGE data_validation_pkg AS

  -- Automatyczna korekta formatu numerow telefonow
  PROCEDURE fix_phone_numbers;

  -- Masowa aktualizacja pensji dla stanowisk
  PROCEDURE update_salaries_by_job(
      p_job_id   IN jobs.job_id%TYPE,
      p_percent  IN NUMBER
  );

END data_validation_pkg;
/

CREATE OR REPLACE PACKAGE BODY data_validation_pkg AS
    PROCEDURE fix_phone_numbers IS
    BEGIN
    UPDATE employees
    SET phone_number = REGEXP_REPLACE(phone_number, '[^0-9]', '')
    WHERE phone_number IS NOT NULL;
    
    DBMS_OUTPUT.PUT_LINE('Automatyczna korekta formatu numerow telefonow wykonana dla ilosci: ' || SQL%ROWCOUNT);
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad w korekcie numerow telefonow: ' || SQLERRM);
    END fix_phone_numbers;

    PROCEDURE update_salaries_by_job(
          p_job_id   IN jobs.job_id%TYPE,
          p_percent  IN NUMBER
      ) IS
      BEGIN
        UPDATE employees
        SET salary = salary * (1 + p_percent/100)
        WHERE job_id = p_job_id;
    
        DBMS_OUTPUT.PUT_LINE('Zaktualizowano pensje: ' || SQL%ROWCOUNT);
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Blad w update_salaries_by_job: ' || SQLERRM);
      END update_salaries_by_job;

END data_validation_pkg;
/

BEGIN
  data_validation_pkg.fix_phone_numbers;
END;
/

SELECT salary FROM employees WHERE job_id = 'IT_PROG';

-- podwyzka 10%
BEGIN
  data_validation_pkg.update_salaries_by_job('IT_PROG', 10);
END;
/

-- obnizka 10%
BEGIN
  data_validation_pkg.update_salaries_by_job('IT_PROG', -10);
END;
/
