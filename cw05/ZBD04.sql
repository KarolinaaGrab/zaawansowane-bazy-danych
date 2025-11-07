------------------- ZADANIE 01 -------------------

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    RANK() OVER (ORDER BY salary DESC) AS ranking
FROM employees e;

------------------- ZADANIE 02 -------------------

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    SUM(salary) OVER () AS suma_pensji
FROM employees e;

------------------- ZADANIE 03 -------------------

SELECT * FROM hr.sales;
SELECT * FROM hr.products;

CREATE TABLE sales AS SELECT * FROM hr.sales;
CREATE TABLE products AS SELECT * FROM hr.products;

ALTER TABLE sales
ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

ALTER TABLE products
ADD PRIMARY KEY (product_id);

ALTER TABLE sales
ADD FOREIGN KEY (product_id) REFERENCES products(product_id);

SELECT
    e.last_name,
    p.product_name,
    (s.quantity * s.price) AS skumulowana_wartosc_sprzedazy,
    RANK() OVER (ORDER BY (s.quantity * s.price) DESC) AS ranking_sprzedazy
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
JOIN products p ON p.product_id = s.product_id;

------------------- ZADANIE 04 -------------------

SELECT
    e.last_name,
    p.product_name,
    