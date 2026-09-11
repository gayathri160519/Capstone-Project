-- Analyzing E-Learning Platform Purchases using MySQL --

-- 1. Create the database and schema. Populate the Schema: --

CREATE DATABASE LearningPlatform;
USE LearningPlatform;

-- Create all three tables in MySQL with appropriate data types and relationships--

-- 1. Table: learners --

CREATE TABLE Learners (
    learner_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- Insert sample data covering at least: --

INSERT INTO Learners (full_name, country) VALUES              -- 4–5 learners --
('Arun Kumar', 'India'),
('Priya Dharshini', 'India'),
('Rahul Dravid', 'India'),
('Shanthi Priya', 'India'),
('Vikram Kumar', 'India');

-- 2. Table: courses --

CREATE TABLE Courses (
course_id INT AUTO_INCREMENT PRIMARY KEY,
course_name VARCHAR(100) NOT NULL,
category VARCHAR(50) NOT NULL,
unit_price decimal(10,2) NOT NULL
);


INSERT INTO Courses (course_name, category, unit_price) VALUES                    -- 4–5 courses --
('SQL Basics', 'Database', 199.99),                                               -- I referred Google --
('Advanced Python', 'Programming', 249.50),
('Data Visualization with Power BI', 'Analytics', 179.00),
('Machine Learning Fundamentals', 'AI', 299.00),
('Cloud Computing with AWS', 'Cloud', 259.75);

-- 3. Table: purchases --

CREATE TABLE Purchases (
purchase_id INT AUTO_INCREMENT PRIMARY KEY,
learner_id INT NOT NULL,
course_id INT NOT NULL,
quantity INT NOT NULL,
purchase_date DATE NOT NULL,
FOREIGN KEY (learner_id) REFERENCES Learners(learner_id),
FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

INSERT INTO Purchases (learner_id, course_id, quantity, purchase_date) VALUES       -- 6–8 purchase records --
(1, 1, 1, '2026-02-01'),
(1, 2, 2, '2025-03-10'),
(2, 3, 1, '2025-04-11'),
(3, 4, 1, '2026-04-01'),
(4, 2, 3, '2025-04-15'),
(4, 5, 1, '2026-05-20'),
(5, 1, 2, '2026-08-18'),
(5, 3, 1, '2026-06-03');

-- 2. Data Exploration Using Joins --

-- Format currency values to 2 decimal places --
-- Use aliases for column names (e.g., AS total_revenue) --
-- Sort results appropriately (e.g., highest total_spent first) --

SELECT l.full_name AS learner_name,                                 -- Used AI to write and fix errors --
FORMAT(SUM(p.quantity * c.unit_price), 2) AS total_revenue          -- l.full name -> Shows learner’s name --
FROM Purchases p
JOIN Learners l ON p.learner_id = l.learner_id                      -- Connects purchases to learners --
JOIN Courses c ON p.course_id = c.course_id                         -- Connects purchases to courses --
GROUP BY l.full_name                                                -- Groups results by learner --
ORDER BY SUM(p.quantity * c.unit_price) DESC;                       -- Sorts by highest spend first -- 

-- Use SQL INNER JOIN, LEFT JOIN, and RIGHT JOIN to --

-- I dont have NULL values so i inserted a NULL record to see how joins works --

INSERT INTO Learners (full_name, country) VALUES ('John Doe', 'USA');  -- learner with no purchases --
INSERT INTO Courses (course_name, category, unit_price)                -- course with no purchases --
VALUES ('Excel for Beginners', 'Productivity', 99.00); 

-- INNER JOIN --

SELECT 
l.full_name AS learner_name,                                    
c.course_name AS course_title,                                -- Shows only learners who actually purchased a course --
c.category AS course_category,
p.quantity,
FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
p.purchase_date
FROM Purchases p
INNER JOIN Learners l ON p.learner_id = l.learner_id
INNER JOIN Courses c ON p.course_id = c.course_id
ORDER BY total_amount DESC;

-- LEFT JOIN --

SELECT                                                           
l.full_name AS learner_name,             -- Shows all learners, even if they didn’t purchase anything. Missing values become NULL --
c.course_name AS course_title,
c.category AS course_category,
p.quantity,
FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
p.purchase_date
FROM Learners l
LEFT JOIN Purchases p ON l.learner_id = p.learner_id
LEFT JOIN Courses c ON p.course_id = c.course_id
ORDER BY learner_name, purchase_date;

-- RIGHT JOIN --

SELECT                                                      -- Shows all courses, even if no learner purchased them --
l.full_name AS learner_name,
c.course_name AS course_title,
c.category AS course_category,
p.quantity,
FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
p.purchase_date
FROM Purchases p
RIGHT JOIN Courses c ON p.course_id = c.course_id
RIGHT JOIN Learners l ON p.learner_id = l.learner_id
ORDER BY course_title, purchase_date;

-- Used AI for JOINS --

-- 3. Analytical Queries --

-- Q1. Display each learner’s total spending (quantity × unit_price) along with their country --

SELECT 
l.full_name AS learner_name,                                  -- Joins all three tables --
l.country,                                                    -- Calculates quantity × unit_price -- 
FORMAT(SUM(p.quantity * c.unit_price), 2) AS total_spent      -- Formats totals → always 2 decimal places --
FROM Purchases p                                              -- Used AS (aliases) → AS learner_name, AS total_spent --
INNER JOIN Learners l ON p.learner_id = l.learner_id          -- DESC - highest spenders appear first -- 
INNER JOIN Courses c ON p.course_id = c.course_id
GROUP BY l.full_name, l.country
ORDER BY SUM(p.quantity * c.unit_price) DESC;

-- Q2. Find the top 3 most purchased courses based on total quantity sold --

SELECT                                                -- Joins Purchases with Courses → links each purchase to its course --
c.course_name AS course_title,                        -- Aggregates quantities → SUM(p.quantity) gives total units sold per course --
c.category AS course_category,                        -- Used aliases → AS course_title, AS course_category, AS total_quantity_sold for clarity --
SUM(p.quantity) AS total_quantity_sold                -- DESC → highest selling courses appear first --
FROM Purchases p                                      -- LIMIT → only the Top 3 courses are shown --
INNER JOIN Courses c ON p.course_id = c.course_id
GROUP BY c.course_name, c.category
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- Q3. Show each course category’s total revenue and the number of unique learners who purchased from that category --

SELECT 
c.category AS course_category,                                -- Joins Purchases with Courses → links each purchase to its course category --
FORMAT(SUM(p.quantity * c.unit_price), 2) AS total_revenue,   -- Calculates revenue → SUM(quantity × unit_price) for each category -- 
COUNT(DISTINCT p.learner_id) AS unique_learners               -- FORMAT totals - ensures 2 decimal places --
FROM Purchases p                                              -- COUNT(DISTINCT learner_id) -- counts unique learners & avoids double-counting the same learner --
INNER JOIN Courses c ON p.course_id = c.course_id             -- DESC → highest revenue categories appear first --
GROUP BY c.category
ORDER BY total_revenue DESC;

-- Q4. List all learners who have purchased courses from more than one category --

SELECT 
l.full_name AS learner_name,                            -- Joins all three tables → links learners, purchases, and courses --
l.country,                                              -- Counts distinct categories → ensures we only count unique course categories per learner --  
COUNT(DISTINCT c.category) AS categories_purchased      -- HAVING → only learners who purchased from more than one category are shown --  
FROM Purchases p                                        -- Used aliases → AS learner_name, AS categories_purchased for clarity --
INNER JOIN Learners l ON p.learner_id = l.learner_id    -- DESC → learners with the most diverse category purchases appear first --
INNER JOIN Courses c ON p.course_id = c.course_id
GROUP BY l.full_name, l.country
HAVING COUNT(DISTINCT c.category) > 1
ORDER BY categories_purchased DESC;
 
-- Q5. Identify courses that have not been purchased at all --

SELECT 
c.course_name AS course_title,                      -- LEFT JOIN → connects Courses with Purchases --
c.category AS course_category,                      -- WHERE p.course_id IS NULL → keeps only courses that have no matching purchase records --
FORMAT(c.unit_price, 2) AS unit_price               -- Displays course name, category, and price --
FROM Courses c                                      -- ORDER BY → alphabetically by course name for easy reading --
LEFT JOIN Purchases p ON c.course_id = p.course_id
WHERE p.course_id IS NULL
ORDER BY c.course_name;


-- Used AI Support to write queries and also corrected the errors --




