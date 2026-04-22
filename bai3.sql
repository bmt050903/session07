CREATE TABLE post (
    post_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT TRUE
);

CREATE TABLE post_like (
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id)
);

-- TẠO 1.000.000 BẢN GHI CHO BẢNG post

INSERT INTO post (user_id, content, tags, created_at, is_public)
SELECT
    (random() * 5000)::INT + 1,
    'Bai viet so ' || gs || ' ve du lich am thuc cong nghe',
    CASE
        WHEN gs % 5 = 0 THEN ARRAY['travel','food']
        WHEN gs % 5 = 1 THEN ARRAY['tech','coding']
        WHEN gs % 5 = 2 THEN ARRAY['music','life']
        WHEN gs % 5 = 3 THEN ARRAY['sport','health']
        ELSE ARRAY['news','daily']
    END,
    NOW() - (gs % 60) * INTERVAL '1 day',
    CASE
        WHEN gs % 10 = 0 THEN FALSE
        ELSE TRUE
    END
FROM generate_series(1,1000000) gs;

Select * from post

--1.Tối ưu hóa truy vấn tìm kiếm bài đăng công khai theo từ khóa:
EXPLAIN ANALYZE
SELECT *
FROM post
WHERE is_public = TRUE
AND LOWER(content) LIKE '%du lich%';

CREATE INDEX idx_post_content_lower
ON post (LOWER(content));

--2.Tối ưu hóa truy vấn lọc bài đăng theo thẻ (tags):
--Tạo GIN Index cho cột tags
--Phân tích hiệu suất bằng EXPLAIN ANALYZE


CREATE INDEX idx_post_tags
ON post USING GIN (tags);


EXPLAIN ANALYZE
SELECT *
FROM post
WHERE tags @> ARRAY['travel'];

--3.Tối ưu hóa truy vấn tìm bài đăng mới trong 7 ngày gần nhất:
CREATE INDEX idx_post_recent_public
ON post (created_at DESC)
WHERE is_public = TRUE;


EXPLAIN ANALYZE
SELECT *
FROM post
WHERE is_public = TRUE
AND created_at >= NOW() - INTERVAL '7 days';

--4.Phân tích chỉ mục tổng hợp (Composite Index):
--Tạo chỉ mục (user_id, created_at DESC)
--Kiểm tra hiệu suất khi người dùng xem “bài đăng gần đây của bạn bè”


CREATE INDEX idx_post_user_recent
ON post (user_id, created_at DESC);


EXPLAIN ANALYZE
SELECT *
FROM post
WHERE user_id = 25
ORDER BY created_at DESC
LIMIT 20;





















