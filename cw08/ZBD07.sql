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

