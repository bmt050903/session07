CREATE TABLE book (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    author VARCHAR(100),
    genre VARCHAR(50),
    price DECIMAL(10,2),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--tạo 500k bản ghi
INSERT INTO book (title, author, genre, price, description)
SELECT
    'Book ' || gs,
    CASE
        WHEN gs % 10 = 0 THEN 'J.K. Rowling'
        WHEN gs % 10 = 1 THEN 'George Orwell'
        WHEN gs % 10 = 2 THEN 'Haruki Murakami'
        ELSE 'Author ' || gs
    END,
    CASE
        WHEN gs % 5 = 0 THEN 'Fantasy'
        WHEN gs % 5 = 1 THEN 'Science'
        WHEN gs % 5 = 2 THEN 'Drama'
        ELSE 'Novel'
    END,
    ROUND((random()*500)::numeric,2),
    'Description of book ' || gs
FROM generate_series(1,500000) gs;

--1/Tạo các chỉ mục phù hợp để tối ưu truy vấn sau:
SELECT * FROM book WHERE author ILIKE '%Rowling%';

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_book_author_trgm
ON book USING GIN (author gin_trgm_ops);

--------

SELECT * FROM book WHERE genre = 'Fantasy';

CREATE INDEX idx_book_genre
ON book (genre);

--2.So sánh thời gian truy vấn trước và sau khi tạo Index (dùng EXPLAIN ANALYZE)
EXPLAIN ANALYZE
SELECT * FROM book
WHERE author ILIKE '%Rowling%';

EXPLAIN ANALYZE
SELECT * FROM book
WHERE genre = 'Fantasy';

--3.Thử nghiệm các loại chỉ mục khác nhau:
--B-tree cho genre
CREATE INDEX idx_book_genre_btree
ON book USING BTREE (genre);

--GIN cho title hoặc description (phục vụ tìm kiếm full-text)
CREATE INDEX idx_book_search
ON book USING GIN (
    to_tsvector('english', title || ' ' || description)
);

EXPLAIN ANALYZE
SELECT *
FROM book
WHERE to_tsvector('english', title || ' ' || description)
@@ to_tsquery('magic');

--4.Tạo một Clustered Index (sử dụng lệnh CLUSTER) trên bảng book theo cột genre và kiểm tra sự khác biệt trong hiệu suất

CLUSTER book USING idx_book_genre;

EXPLAIN ANALYZE
SELECT *
FROM book
WHERE genre = 'Fantasy';