create database Employee_Performance_Payroll;

use Employee_Performance_Payroll;

-- 1. Drop tables in correct order (child → parent)
DROP TABLE IF EXISTS performance_reviews;
DROP TABLE IF EXISTS salaries;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- 2. Create table: departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- 3. Create table: employees (self-referencing manager_id)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    job_title VARCHAR(100),
    department_id INT,
    manager_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- 4. Create table: salaries
CREATE TABLE salaries (
    salary_id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    salary_amount DECIMAL(10,2) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 5. Create table: performance_reviews
CREATE TABLE performance_reviews (
    review_id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    review_date DATE NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments VARCHAR(500),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

---------------------------
-- 1. Insert into departments
---------------------------
INSERT INTO departments (department_id, department_name) VALUES
(1, 'Human Resources'),
(2, 'Finance'),
(3, 'IT'),
(4, 'Sales');

select * from departments;

---------------------------
-- 2. Insert into employees
-- manager_id is NULL for heads
---------------------------
INSERT INTO employees (employee_id, name, hire_date, job_title, department_id, manager_id) VALUES
(101, 'Amit Sharma', '2018-04-12', 'HR Manager', 1, NULL),
(102, 'Priya Patel', '2019-06-20', 'HR Executive', 1, 101),
(103, 'Ravi Kumar', '2017-03-18', 'Finance Manager', 2, NULL),
(104, 'Sneha Reddy', '2020-01-10', 'Accountant', 2, 103),
(105, 'Karan Singh', '2016-11-05', 'IT Manager', 3, NULL),
(106, 'Megha Roy', '2021-02-14', 'Software Engineer', 3, 105),
(107, 'Sanjay Verma', '2015-09-28', 'Sales Manager', 4, NULL),
(108, 'Neha Gupta', '2022-05-17', 'Sales Executive', 4, 107);

select * from employees;


---------------------------
-- 3. Insert into salaries
---------------------------
INSERT INTO salaries (salary_id, employee_id, salary_amount, from_date, to_date) VALUES
(1, 101, 75000, '2023-01-01', NULL),
(2, 102, 45000, '2023-01-01', NULL),
(3, 103, 80000, '2023-01-01', NULL),
(4, 104, 50000, '2023-01-01', NULL),
(5, 105, 90000, '2023-01-01', NULL),
(6, 106, 65000, '2023-01-01', NULL),
(7, 107, 85000, '2023-01-01', NULL),
(8, 108, 40000, '2023-01-01', NULL);

select * from salaries;

---------------------------
-- 4. Insert into performance_reviews
---------------------------
INSERT INTO performance_reviews (review_id, employee_id, review_date, rating, comments) VALUES
(1, 101, '2024-01-15', 5, 'Excellent leadership.'),
(2, 102, '2024-01-15', 4, 'Good performance overall.'),
(3, 103, '2024-01-20', 5, 'Outstanding financial expertise.'),
(4, 104, '2024-01-20', 3, 'Meets expectations.'),
(5, 105, '2024-01-25', 4, 'Strong technical skills.'),
(6, 106, '2024-01-25', 5, 'Great problem-solving abilities.'),
(7, 107, '2024-01-30', 4, 'Good sales management.'),
(8, 108, '2024-01-30', 3, 'Needs improvement in sales targets.');

select * from  performance_reviews;

use employee_performance_payroll;

select * from employees;

-- Queries to Solve: 

-- 1.List all employees and their managers.
SELECT 
    e.employee_id AS employee_id,
    e.name AS employee_name,
    m.employee_id AS manager_id,
    m.name AS manager_name
FROM 
    employees e
 LEFT JOIN 
    employees m ON e.manager_id = m.employee_id;
    
-- 2.Calculate the average salary per department. 
select * from departments;

SELECT 
    d.department_name,
    AVG(s.salary_amount) AS average_salary
FROM 
    departments d
JOIN 
    employees e ON d.department_id = e.department_id
JOIN 
    salaries s ON e.employee_id = s.employee_id
GROUP BY 
    d.department_name
ORDER BY 
    average_salary DESC;
    
use employee_performance_payroll;

-- Find the employee with the highest current salary.
SELECT e.employee_id,
       e.name,
       s.salary_amount
FROM employees e
JOIN salaries s
    ON e.employee_id = s.employee_id
   ORDER BY s.salary_amount DESC
LIMIT 1;

-- Count the number of employees hired per year.
SELECT 
    YEAR(hire_date) AS hire_year,
    COUNT(*) AS total_employees_hired
FROM employees
GROUP BY YEAR(hire_date)
ORDER BY hire_year;

-- 5.	Identify departments with more than 10 employees.
SELECT 
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS total_employees
FROM departments d
JOIN employees e 
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) > 10;

-- Find employees who have had more than 2 performance reviews.
SELECT 
    e.employee_id,
    e.name,
    COUNT(pr.review_id) AS total_reviews
FROM employees e
JOIN performance_reviews pr
    ON e.employee_id = pr.employee_id
GROUP BY e.employee_id, e.name
HAVING COUNT(pr.review_id) > 2;
 
use employee_performance_payroll;


-- Calculate the total payroll cost per department per month. 
SELECT 
    d.department_name,
    DATE_FORMAT(s.from_date, '%Y-%m') AS payroll_month,
    SUM(s.salary_amount) AS total_payroll
FROM salaries s
JOIN employees e
    ON s.employee_id = e.employee_id
JOIN departments d
    ON e.department_id = d.department_id
WHERE s.to_date IS NULL   -- Only current payroll
GROUP BY d.department_name, DATE_FORMAT(s.from_date, '%Y-%m')
ORDER BY payroll_month, d.department_name;

-- 8.	List employees who have never had a performance review.
SELECT 
    e.employee_id,
    e.name
FROM employees e
LEFT JOIN performance_reviews pr
    ON e.employee_id = pr.employee_id
WHERE pr.employee_id IS NULL;

-- 9.	Find the top 5 employees with the highest performance rating.
SELECT 
    e.employee_id,
    e.name,
    AVG(pr.rating) AS avg_rating
FROM employees e
JOIN performance_reviews pr
    ON e.employee_id = pr.employee_id
GROUP BY e.employee_id, e.name
ORDER BY avg_rating DESC
LIMIT 5;

-- 10.	Identify the average tenure (time employed) of employees by department.
SELECT 
    department_id,
    AVG(DATEDIFF(CURDATE(), hire_date) / 365) AS avg_tenure_years
FROM employees
GROUP BY department_id;
 
 
 






