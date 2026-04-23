CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer(customer_id),
    total_amount DECIMAL(10,2),
    order_date DATE,
    status VARCHAR(20)
);

CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    category VARCHAR(50)
);

CREATE TABLE order_detail (
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES product(product_id),
    quantity INT
);


INSERT INTO customer (full_name, region)
VALUES
('A','Miền Bắc'),
('B','Miền Nam'),
('C','Miền Trung'),
('D','Miền Bắc'),
('E','Miền Nam');

INSERT INTO orders (customer_id, total_amount, order_date, status)
VALUES
(1,1500000,'2026-04-01','Completed'),
(2,2200000,'2026-04-03','Completed'),
(3,1800000,'2026-04-05','Completed'),
(4,3200000,'2026-04-06','Completed'),
(5,2700000,'2026-04-07','Completed');


--1.Tạo View tổng hợp doanh thu theo khu vực:

CREATE VIEW v_revenue_by_region AS
SELECT
    c.region,
    SUM(o.total_amount) AS total_revenue
FROM customer c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.region;


-- Viết truy vấn xem top 3 khu vực có doanh thu cao nhất

SELECT *
FROM v_revenue_by_region
ORDER BY total_revenue DESC
LIMIT 3;

--2.  2. Tạo View phức hợp (Nested View):
--Từ v_revenue_by_region, tạo View mới v_revenue_above_avg chỉ hiển thị khu vực có doanh thu > trung bình toàn quốc

CREATE VIEW v_revenue_above_avg AS
SELECT *
FROM v_revenue_by_region
WHERE total_revenue >
(
    SELECT AVG(total_revenue)
    FROM v_revenue_by_region
);


SELECT * FROM v_revenue_above_avg;

