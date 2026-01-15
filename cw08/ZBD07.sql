SET SERVEROUTPUT ON;

------------------- ZADANIE 01 -------------------

CREATE OR REPLACE FUNCTION get_job_title (
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
END; 
/

-- dwa typy wywolan:
-- blok anonimowy

DECLARE 
	v_title jobs.job_title%TYPE;
BEGIN
	v_title:=get_job_title('AD_PRES');
    DBMS_OUTPUT.PUT_LINE('Stanowisko: ' || v_title);
END;
/

-- it's a dummy table with a single record used for selecting when 
-- you're not actually interested in the data, but instead want the results of some system function in a select statement

SELECT get_job_title('AD_PRES') FROM dual;

SELECT get_job_title('AD_PRES') FROM jobs;


------------------- ZADANIE 02 -------------------
-- nvl - Changing NULL Result to Zero

CREATE OR REPLACE FUNCTION get_yearly_salary  (
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
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Inny błąd: ' || SQLERRM);
END; 
/

SELECT * FROM employees;

DECLARE 
	v_salary employees.salary%TYPE;
BEGIN
	v_salary:=get_yearly_salary(100);
    DBMS_OUTPUT.PUT_LINE('Roczne zarobki: ' || v_salary || ' dla pracownika o id: 100');
END;
/

------------------- ZADANIE 03 -------------------
-- REGEXP_SUBSTR  - extends the functionality of the SUBSTR function by letting you search a string for a regular expression pattern.
-- sluzy do wyciagania czesci tekstu pasujacej do wyrazenia

CREATE OR REPLACE FUNCTION format_phone(
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
END;
/

SELECT phone_number, format_phone(phone_number) AS formatted_phone
FROM (
    SELECT '650.121.2994' AS phone_number FROM dual UNION ALL
    SELECT '011.44.1344.429268' FROM dual UNION ALL
    SELECT '011.44.1644.429263' FROM dual UNION ALL
    SELECT '650.507.9877' FROM dual
);


------------------- ZADANIE 04 -------------------

CREATE OR REPLACE FUNCTION format_text (
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
END;
/

SELECT format_text('abcdef') AS wynik FROM dual
UNION ALL
SELECT format_text('A') FROM dual
UNION ALL
SELECT format_text('ab') FROM dual
UNION ALL
SELECT format_text('hELLOwORLD') FROM dual;


------------------- ZADANIE 05 -------------------
-- lpad - uzupenia z lewej strony znak
-- lpad(expr, len [, pad] )
-- expr: wyrazenie STRING lub BINARY, ktore ma zostac wypelnione
-- len: INTEGER okreslajacy dlugosc ciagu wynikowego
-- pad: (opcjonalne) wyrazenie STRING lub BINARY okreslające dopelnienie


CREATE OR REPLACE FUNCTION pesel_to_date_str(p_pesel IN VARCHAR2)
    RETURN VARCHAR2
IS
    v_year  NUMBER;
    v_month NUMBER;
    v_day   NUMBER;
BEGIN
    -- pobranie year, month, day
    v_year  := SUBSTR(p_pesel, 1, 2);
    v_month := SUBSTR(p_pesel, 3, 2);
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
END;
/

SELECT pesel_to_date_str('02222912345') FROM dual; -- '2002-02-29' (29 luty)

SELECT pesel_to_date_str('99010154321') FROM dual; -- '1999-01-01'


------------------- ZADANIE 06 -------------------

CREATE OR REPLACE FUNCTION country_stats(
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
END;
/

SELECT distinct(country_name) FROM countries; 

SELECT country_stats('Brazil') FROM dual;

SELECT country_stats('United States of America') FROM dual;


------------------- ZADANIE 07 -------------------

--REGEXP_REPLACE(p_phone_number, '[^0-9]', '')
-- wszsytko co nie jest cyfra zamienia na pusty znak

SELECT PHONE_NUMBER FROM employees;

CREATE OR REPLACE FUNCTION generate_access_id(
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
END;
/
    
SELECT generate_access_id('Adam', 'Malysz', '123.456.789') FROM dual;
