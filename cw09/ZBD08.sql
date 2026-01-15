SET SERVEROUTPUT ON;

------------------- ZADANIE 01 -------------------

CREATE TABLE archiwum_departamentow (
    id NUMBER,
    nazwa VARCHAR2(100),
    data_zamkniecia DATE,
    ostatni_manager VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER depratment_delete
AFTER DELETE ON departments
FOR EACH ROW -- czy trigger jest poziomu wiersza czy polecenia
DECLARE
    v_manager_name VARCHAR2(100);
BEGIN
    IF :OLD.manager_id IS NOT NULL THEN
        SELECT first_name || ' ' || last_name
        INTO v_manager_name
        FROM employees
        WHERE employee_id = :OLD.manager_id;
    ELSE
        v_manager_name := NULL;
    END IF;
    
    INSERT INTO archiwum_departamentow
    VALUES (
        :OLD.department_id,
        :OLD.department_name,
        SYSDATE,
        v_manager_name
    );
END;
/

SELECT * FROM departments;

INSERT INTO departments(department_id, department_name) 
VALUES (4000, 'someName');
DELETE FROM departments WHERE department_id = 4000;

INSERT INTO departments(department_id, department_name, manager_id) 
VALUES (4001, 'someName', 200);
DELETE FROM departments WHERE department_id = 4001;

SELECT * FROM archiwum_departamentow;


------------------- ZADANIE 02 -------------------
--AUTONOMICZNA TRANSAKCJA

CREATE TABLE zlodziej (
    id          int NOT NULL PRIMARY KEY,
    user_name   VARCHAR2(30),
    czas_zmiany DATE
);

CREATE SEQUENCE zlodziej_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER salary_check
BEFORE INSERT OR UPDATE OF salary ON employees
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF :NEW.salary < 2000 OR :NEW.salary > 26000 THEN
        INSERT INTO zlodziej (id, user_name, czas_zmiany)
        VALUES (zlodziej_seq.NEXTVAL, USER, SYSDATE);
    
    COMMIT;
    
    RAISE_APPLICATION_ERROR(-20001,
            'Wynagrodzenie poza dozwolonym zakresem (2000–26000). Zlodziej!'
        );
    END IF;
END;
/

INSERT INTO employees (employee_id, first_name, last_name, salary, job_id)
VALUES (9999, 'Test', 'LowSalary', 1000, 'IT_PROG');

SELECT * FROM zlodziej;


------------------- ZADANIE 03 -------------------

CREATE SEQUENCE employees_seq2
START WITH 1000
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER employees_autoincrement
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF :NEW.employee_id IS NULL THEN
        SELECT employees_seq2.NEXTVAL
        INTO :NEW.employee_id
        FROM dual;
    END IF;
END;
/

INSERT INTO employees (first_name, last_name, email, hire_date, job_id, salary)
VALUES ('Jan', 'Kowalski', 'JKOWAL', SYSDATE, 'IT_PROG', 6000);

SELECT employee_id FROM employees WHERE last_name = 'Kowalski';


------------------- ZADANIE 04 -------------------

SELECT * FROM hr.job_grades;

CREATE TABLE job_grades AS
SELECT * FROM hr.job_grades;


CREATE OR REPLACE TRIGGER block_job_grades
BEFORE INSERT OR UPDATE OR DELETE ON job_grades
BEGIN
    RAISE_APPLICATION_ERROR(
            -20020,
            'Operacje na tabeli JOB_GRADES są zabronione'
        );
END;
/

DELETE FROM job_grades;


------------------- ZADANIE 05 -------------------

CREATE OR REPLACE TRIGGER max_min_salary_lock
BEFORE UPDATE OF min_salary, max_salary ON jobs
FOR EACH ROW
BEGIN
    IF :NEW.min_salary != :OLD.min_salary OR :NEW.max_salary != :OLD.max_salary THEN
        :NEW.min_salary := :OLD.min_salary;
        :NEW.max_salary := :OLD.max_salary;
        RAISE_APPLICATION_ERROR(
            -20021,
            'Nie wolno zmieniać min_salary ani max_salary w tabeli JOBS'
        );
    END IF;
END;
/

SELECT * FROM jobs;

UPDATE jobs
SET min_salary = 1, max_salary = 999999
WHERE job_id = 'IT_PROG';

SELECT min_salary, max_salary FROM jobs WHERE job_id = 'IT_PROG';


------------------- ZADANIE 06 -------------------

-- zrobione powyzej obok kazdego przykladu