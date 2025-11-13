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
    s.price,
    COUNT(*) OVER (PARTITION BY s.product_id, s.sale_date) AS liczba_transakcji_na_dzien,
    SUM(s.quantity * s.price) OVER (PARTITION BY s.product_id, s.sale_date) AS calkowita_sprzedaz_dzienna,
    LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS poprzednia_cena,
    LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS kolejna_cena
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
JOIN products p ON p.product_id = s.product_id;

------------------- ZADANIE 05 -------------------

SELECT
    p.product_name,
    s.price,
    SUM(s.quantity * s.price) OVER (PARTITION BY p.product_id, TO_CHAR(s.sale_date, 'YYYY-MM')) AS zaplacona_suma_miesieczna,
    SUM(s.quantity * s.price) 
        OVER (PARTITION BY p.product_id, TO_CHAR(s.sale_date, 'YYYY-MM')
        ORDER BY s.sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        AS zaplacona_suma_miesieczna_narastajaca
FROM sales s
JOIN products p ON p.product_id = s.product_id;

------------------- ZADANIE 06 -------------------

SELECT
    p.product_name,
    p.product_category,
    TO_CHAR(s22.sale_date, 'MM-DD') AS dzien,
    s22.price AS cena_2022,
    s23.price AS cena_2023,
    (s23.price - s22.price) AS roznica_cen
FROM sales s22
JOIN sales s23
  ON s22.product_id = s23.product_id
  AND TO_CHAR(s22.sale_date, 'MM-DD') = TO_CHAR(s23.sale_date, 'MM-DD')
  AND EXTRACT(YEAR FROM s22.sale_date) = 2022
  AND EXTRACT(YEAR FROM s23.sale_date) = 2023
JOIN products p ON p.product_id = s22.product_id
ORDER BY p.product_name, dzien;

------------------- ZADANIE 07 -------------------

SELECT
    p.product_category,
    p.product_name,
    s.price,
    MIN(s.price) OVER (PARTITION BY p.product_category) as minimalna_cena,
    MAX(s.price) OVER (PARTITION BY p.product_category) as maksymalna_cena,
    (MAX(s.price)  OVER (PARTITION BY p.product_category)
    - MIN(s.price)  OVER (PARTITION BY p.product_category)) as roznica_cen
FROM sales s
JOIN products p ON p.product_id = s.product_id;

------------------- ZADANIE 08 -------------------

-- średnia krocząca - MOVING AVG
-- calculates a mean of a subset of data points within a defined window
-- EX:
--SELECT
--    sale_date,
--    sales_amount,
--    AVG(sales_amount) OVER (
--        ORDER BY sale_date
--        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--    ) AS moving_avg
--FROM sales;

-- rows between N Preceding and M Following
-- includes specified rows before and after the current row

SELECT
    p.product_name,
    AVG(s.price) OVER (
        PARTITION BY s.product_id
        ORDER BY s.sale_date
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
        ) AS srednia_kroczaca
FROM sales s
JOIN products p ON p.product_id = s.product_id;
