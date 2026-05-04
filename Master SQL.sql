-- =====================================================
-- PROJECT: Retail Funnel Analysis using SQL
-- AUTHOR: Shubham Kulkarni
--
-- DESCRIPTION:
-- This file contains all exploratory SQL queries used 
-- to analyze user behavior in an e-commerce dataset.
--
-- NOTE:
-- Queries include multiple approaches, iterations, and 
-- experiments performed during the analysis process.
-- =====================================================


CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;
SHOW DATABASES;
CREATE TABLE users (
    user_id VARCHAR(20) PRIMARY KEY
);
CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(100),
    brand VARCHAR(100),
    price FLOAT
);
CREATE TABLE sessions (
    session_id VARCHAR(20) PRIMARY KEY,
    user_id VARCHAR(20),
    session_length INT,
    interaction_count INT,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
);

CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(20),
    product_id VARCHAR(20),
    event_time DATETIME,
    event_type VARCHAR(50),
    time_spent_sec INT,
    FOREIGN KEY (session_id)
        REFERENCES sessions (session_id),
    FOREIGN KEY (product_id)
        REFERENCES products (product_id)
);

SHOW TABLES;
CREATE TABLE raw_events (
    session_id VARCHAR(20),
    user_id VARCHAR(20),
    timestamp_utc DATETIME,
    event_index INT,
    user_action VARCHAR(50),
    product_id VARCHAR(20),
    category VARCHAR(100),
    brand VARCHAR(100),
    price FLOAT,
    channel VARCHAR(50),
    device_type VARCHAR(50),
    region VARCHAR(50),
    traffic_source VARCHAR(50),
    time_spent_sec INT,
    session_length INT,
    interaction_count INT,
    is_conversion INT,
    drop_off_flag INT
);

CREATE TABLE events_demo (
    session_id VARCHAR(20),
    user_id VARCHAR(20),
    event_time DATETIME,
    event_type VARCHAR(50),
    product_id VARCHAR(20),
    category VARCHAR(50),
    price FLOAT
);

INSERT INTO events_demo VALUES
('S1','U1','2026-01-01 10:00:00','view','P1','Electronics',300),
('S1','U1','2026-01-01 10:01:00','click','P1','Electronics',300),
('S1','U1','2026-01-01 10:02:00','add_to_cart','P1','Electronics',300),
('S1','U1','2026-01-01 10:03:00','purchase','P1','Electronics',300),

('S2','U2','2026-01-01 11:00:00','view','P2','Clothing',80),
('S2','U2','2026-01-01 11:01:00','click','P2','Clothing',80),
('S2','U2','2026-01-01 11:02:00','drop','P2','Clothing',80),

('S3','U3','2026-01-01 12:00:00','view','P3','Electronics',500),
('S3','U3','2026-01-01 12:02:00','click','P3','Electronics',500),
('S3','U3','2026-01-01 12:05:00','add_to_cart','P3','Electronics',500);


-- Task 1: Event Distribution
SELECT 
    event_type, COUNT(*) AS total
FROM
    events_demo
GROUP BY event_type;

-- Task 2: Conversion Funnel

SELECT 
    COUNT(DISTINCT CASE
            WHEN event_type = 'view' THEN session_id
        END) AS views,
    COUNT(DISTINCT CASE
            WHEN event_type = 'click' THEN session_id
        END) AS clicks,
    COUNT(DISTINCT CASE
            WHEN event_type = 'add_to_cart' THEN session_id
        END) AS carts,
    COUNT(DISTINCT CASE
            WHEN event_type = 'purchase' THEN session_id
        END) AS purchases
FROM
    events_demo;


-- Task 3: Revenue

SELECT 
    SUM(price) AS total_revenue
FROM
    events_demo
WHERE
    event_type = 'purchase';

-- Task 4: Drop-off Analysis
SELECT 
    session_id
FROM
    events_demo
GROUP BY session_id
HAVING SUM(event_type = 'purchase') = 0;

-- Task 1: Conversion Rates (Not just counts)

SELECT 
    ROUND(COUNT(DISTINCT CASE
                    WHEN event_type = 'click' THEN session_id
                END) / COUNT(DISTINCT CASE
                    WHEN event_type = 'view' THEN session_id
                END) * 100,
            2) AS view_to_click,
    ROUND(COUNT(DISTINCT CASE
                    WHEN event_type = 'add_to_cart' THEN session_id
                END) / COUNT(DISTINCT CASE
                    WHEN event_type = 'click' THEN session_id
                END) * 100,
            2) AS click_to_cart,
    ROUND(COUNT(DISTINCT CASE
                    WHEN event_type = 'purchase' THEN session_id
                END) / COUNT(DISTINCT CASE
                    WHEN event_type = 'add_to_cart' THEN session_id
                END) * 100,
            2) AS cart_to_purchase
FROM
    events_demo;


-- Task 2: High Intent Users

SELECT 
    user_id, COUNT(*) AS cart_actions
FROM
    events_demo
WHERE
    event_type = 'add_to_cart'
GROUP BY user_id
ORDER BY cart_actions DESC;

-- Task 3: Category Performance

SELECT 
    category,
    COUNT(CASE
        WHEN event_type = 'purchase' THEN 1
    END) AS purchases,
    SUM(CASE
        WHEN event_type = 'purchase' THEN price
        ELSE 0
    END) AS revenue
FROM
    events_demo
GROUP BY category;

-- Task 4: Session Journey

SELECT 
    session_id,
    GROUP_CONCAT(event_type
        ORDER BY event_time) AS journey
FROM
    events_demo
GROUP BY session_id;

-- Which session looks like a perfect conversion journey?
SELECT DISTINCT
    session_id
FROM
    events_demo
WHERE
    session_id NOT IN (SELECT 
            session_id
        FROM
            events_demo
        WHERE
            event_type = 'purchase');

-- Which sessions added to cart but never purchased?”

SELECT DISTINCT
    session_id
FROM
    events_demo
WHERE
    event_type = 'add_to_cart'
        AND session_id NOT IN (SELECT 
            session_id
        FROM
            events_demo
        WHERE
            event_type = 'purchase')

-- Create Products Table

CREATE TABLE products_demo AS SELECT DISTINCT product_id, category, price FROM
    events_demo

-- Create Sessions Table
CREATE TABLE sessions_demo AS SELECT DISTINCT session_id, user_id FROM
    events_demo

-- Which categories generate the most revenue?

SELECT 
    p.category, SUM(e.price) AS revenue
FROM
    events_demo e
        JOIN
    products_demo p ON e.product_id = p.product_id
WHERE
    e.event_type = 'purchase'
GROUP BY p.category

-- Which users actually converted?

SELECT DISTINCT
    s.user_id
FROM
    sessions_demo s
        JOIN
    events_demo e ON s.session_id = e.session_id
WHERE
    e.event_type = 'purchase'

-- Which users never purchased?
SELECT DISTINCT
    s.user_id
FROM
    sessions_demo s
        LEFT JOIN
    events_demo e ON s.session_id = e.session_id
        AND e.event_type = 'purchase'
WHERE
    e.session_id IS NULL

-- Average events per session
SELECT 
    session_id, COUNT(*) AS total_events
FROM
    events_demo
GROUP BY session_id

-- Which sessions are highly engaged but didn’t convert?

SELECT 
    e.session_id,
    COUNT(*) AS total_events
FROM events_demo e
LEFT JOIN (
    SELECT DISTINCT session_id 
    FROM events_demo 
    WHERE event_type = 'purchase'
) p
ON e.session_id = p.session_id
WHERE p.session_id IS NULL
GROUP BY e.session_id
ORDER BY total_events DESC;

-- Users comparing multiple products
SELECT 
    session_id,
    COUNT(DISTINCT product_id) AS products_viewed
FROM events_demo
GROUP BY session_id
HAVING COUNT(DISTINCT product_id) > 1;

-- High activity but no purchase

SELECT 
    session_id,
    COUNT(*) AS total_events
FROM events_demo
WHERE session_id NOT IN (
    SELECT session_id 
    FROM events_demo 
    WHERE event_type = 'purchase'
)
GROUP BY session_id
ORDER BY total_events DESC;

-- Compare conversion likelihood
SELECT 
    event_type,
    COUNT(DISTINCT session_id) AS sessions
FROM events_demo
GROUP BY event_type;

-- Better: sessions with add_to_cart vs purchase

SELECT 
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN session_id END) AS cart_sessions,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN session_id END) AS purchase_sessions
FROM events_demo;


-- Users who added to cart multiple times but never purchased?
SELECT session_id
FROM events_demo
WHERE event_type = 'add_to_cart'
GROUP BY session_id
HAVING COUNT(*) > 1;

SELECT session_id
FROM events_demo
WHERE event_type = 'add_to_cart'
GROUP BY session_id
HAVING COUNT(*) > 1
AND session_id NOT IN (
    SELECT session_id
    FROM events_demo
    WHERE event_type = 'purchase'
);

SELECT session_id, COUNT(*) AS cart_count
FROM events_demo
WHERE event_type = 'add_to_cart'
GROUP BY session_id;

INSERT INTO events_demo VALUES
('S4','U4','2026-01-01 13:00:00','view','P4','Electronics',200),
('S4','U4','2026-01-01 13:01:00','add_to_cart','P4','Electronics',200),
('S4','U4','2026-01-01 13:02:00','add_to_cart','P4','Electronics',200);

-- Check if price is the issue
SELECT product_id, COUNT(*) AS cart_attempts
FROM events_demo
WHERE event_type = 'add_to_cart'
GROUP BY product_id
ORDER BY cart_attempts DESC;

-- Check if users are comparing products
SELECT session_id, COUNT(DISTINCT product_id) AS products_viewed
FROM events_demo
GROUP BY session_id
HAVING COUNT(DISTINCT product_id) > 1;

-- Revenue per user

SELECT 
    s.user_id,
    SUM(e.price) AS revenue
FROM events_demo e
JOIN sessions_demo s 
    ON e.session_id = s.session_id
WHERE e.event_type = 'purchase'
GROUP BY s.user_id;

-- Users who never purchased

SELECT DISTINCT s.user_id
FROM sessions_demo s
LEFT JOIN events_demo e 
    ON s.session_id = e.session_id 
    AND e.event_type = 'purchase'
WHERE e.session_id IS NULL;

-- Sessions with more than 2 actions

SELECT session_id, COUNT(*) AS total_events
FROM events_demo
GROUP BY session_id
HAVING COUNT(*) > 2;

-- Which users had high activity (>2 events) but never purchased?

SELECT e.session_id
FROM events_demo e
GROUP BY e.session_id
HAVING COUNT(*) > 2
AND e.session_id NOT IN (
    SELECT session_id
    FROM events_demo
    WHERE event_type = 'purchase'
);

SELECT DISTINCT s.user_id
FROM sessions_demo s
JOIN (
    SELECT session_id
    FROM events_demo
    GROUP BY session_id
    HAVING COUNT(*) > 2
    AND session_id NOT IN (
        SELECT session_id
        FROM events_demo
        WHERE event_type = 'purchase'
    )
) e
ON s.session_id = e.session_id;


-- Rank users by revenue

SELECT 
    s.user_id,
    SUM(e.price) AS revenue,
    RANK() OVER (ORDER BY SUM(e.price) DESC) AS rank_user
FROM events_demo e
JOIN sessions_demo s 
    ON e.session_id = s.session_id
WHERE e.event_type = 'purchase'
GROUP BY s.user_id;

-- Dense rank (clean ranking)

SELECT 
    s.user_id,
    SUM(e.price) AS revenue,
    DENSE_RANK() OVER (ORDER BY SUM(e.price) DESC) AS dense_rank_user
FROM events_demo e
JOIN sessions_demo s 
    ON e.session_id = s.session_id
WHERE e.event_type = 'purchase'
GROUP BY s.user_id;


-- Partition

SELECT 
    p.category,
    s.user_id,
    SUM(e.price) AS revenue,
    RANK() OVER (
        PARTITION BY p.category 
        ORDER BY SUM(e.price) DESC
    ) AS category_rank
FROM events_demo e
JOIN sessions_demo s 
    ON e.session_id = s.session_id
JOIN products_demo p 
    ON e.product_id = p.product_id
WHERE e.event_type = 'purchase'
GROUP BY p.category, s.user_id;

-- TOP 1 User Per Category

SELECT *
FROM (
    SELECT 
        p.category,
        s.user_id,
        SUM(e.price) AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY p.category 
            ORDER BY SUM(e.price) DESC
        ) AS row_num
    FROM events_demo e
    JOIN sessions_demo s 
        ON e.session_id = s.session_id
    JOIN products_demo p 
        ON e.product_id = p.product_id
    WHERE e.event_type = 'purchase'
    GROUP BY p.category, s.user_id
) ranked
WHERE row_num = 1;

-- Latest event per session

SELECT *
FROM (
    SELECT 
        session_id,
        user_id,
        event_type,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY session_id
            ORDER BY event_time DESC
        ) AS rn
    FROM events_demo
) t
WHERE rn = 1;



-- =====================================================
-- KEY LEARNINGS
-- =====================================================

-- 1. Add-to-cart is the strongest indicator of user intent
-- 2. Major drop-off occurs before purchase stage
-- 3. High-activity sessions without purchase indicate decision friction



