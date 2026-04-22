CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer(customer_id),
    total_amount DECIMAL(10,2),
    order_date DATE
);

INSERT INTO customer (full_name, email, phone)
VALUES
('A','a@gmail.com','1231'),
('B','b@gmail.com','1232'),
('C','c@gmail.com','1233');

SELECT * FROM customer

INSERT INTO orders (customer_id, total_amount, order_date)
VALUES
(1, 500000, '2026-04-01'),
(2, 1500000, '2026-04-05'),
(3, 2200000, '2026-04-10'),
(1, 1200000, '2026-05-01');

SELECT * FROM orders

--1.Tạo một View tên v_order_summary hiển thị:
--full_name, total_amount, order_date
--(ẩn thông tin email và phone)

CREATE VIEW V_order_summary AS
SELECT
    c.full_name,
    o.total_amount,
    o.order_date
FROM customer c
JOIN orders o
ON c.customer_id = o.customer_id;

--2.Viết truy vấn để xem tất cả dữ liệu từ View
SELECT * FROM V_order_summary;

--3.Tạo 1 view lấy về thông tin của tất cả các đơn hàng với điều kiện total_amount ≥ 1 triệu .
 --Sau đó bạn hãy cập nhật lại thông tin 1 bản ghi trong view đó nhé .

CREATE VIEW V_1M_orders AS
SELECT
    order_id,
    customer_id,
    total_amount,
    order_date
FROM orders
WHERE total_amount >= 1000000;

SELECT * FROM V_1M_orders;

UPDATE V_1M_orders
SET total_amount = 1800000
WHERE order_id = 2;

--4.Tạo một View thứ hai v_monthly_sales thống kê tổng doanh thu mỗi tháng

CREATE VIEW v_monthly_sales AS
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS month,
    SUM(total_amount) AS total_sales
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;


SELECT * FROM v_monthly_sales;

--5.Thử DROP View và ghi chú sự khác biệt giữa DROP VIEW và DROP MATERIALIZED VIEW trong PostgreSQL
DROP VIEW IF EXISTS V_order_summary;
DROP VIEW IF EXISTS V_1M_orders;
DROP VIEW IF EXISTS v_monthly_sales;






