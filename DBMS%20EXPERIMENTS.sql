/*
CSA05 - DATABASE MANAGEMENT SYSTEMS LAB
Complete practice script for Experiments 1-23
Platform: MySQL 8.0+
How to use:
1. Open MySQL Workbench / phpMyAdmin.
2. Run this script section by section (not necessarily all at once).
3. For stored routines, keep the DELIMITER commands.
4. Sample output is the result grid returned by the SELECT statements.
5. The sample rows are demonstration data; your lab manual does not provide all table rows.
*/

CREATE DATABASE IF NOT EXISTS CSA05_LAB;
USE CSA05_LAB;

-- =========================================================
-- EXPERIMENT 1: DDL - CREATE, ALTER, DROP, RENAME, TRUNCATE
-- Q1-Q4: Create STUDENT, FACULTY, DEPARTMENT, COURSE
-- =========================================================
DROP TABLE IF EXISTS COURSE;
DROP TABLE IF EXISTS DEPARTMENT;
DROP TABLE IF EXISTS FACULTY;
DROP TABLE IF EXISTS STUDENT;

CREATE TABLE STUDENT (
    RegNo BIGINT PRIMARY KEY,
    Name VARCHAR(15),
    Gender CHAR(1),
    DOB DATE,
    MobileNo VARCHAR(10),
    City VARCHAR(15)
);

CREATE TABLE FACULTY (
    FacNo VARCHAR(4),
    FacName VARCHAR(15),
    Gender CHAR(1),
    DOB DATE,
    DOJ DATE,
    MobileNo VARCHAR(10)
);

CREATE TABLE DEPARTMENT (
    DeptNo VARCHAR(4),
    DeptName VARCHAR(15),
    DeptHead VARCHAR(4)
);

CREATE TABLE COURSE (
    CourseNo VARCHAR(3),
    CourseDesc VARCHAR(30),
    CourseType CHAR(1),
    SemNo CHAR(1),
    HallNo VARCHAR(4),
    FacNo VARCHAR(4)
);

-- Q5: Add Dept column to FACULTY
ALTER TABLE FACULTY ADD Dept VARCHAR(10);

-- Check output
DESCRIBE STUDENT;
DESCRIBE FACULTY;
DESCRIBE DEPARTMENT;
DESCRIBE COURSE;

-- =========================================================
-- EXPERIMENT 2: DDL CONSTRAINTS - PRIMARY, FOREIGN, UNIQUE, CHECK
-- Manual refers to STUDENT2, STUDENT3 and S1Name.
-- =========================================================
DROP TABLE IF EXISTS STUDENT3;
DROP TABLE IF EXISTS STUDENT2;
CREATE TABLE STUDENT2 (
    RegNo BIGINT,
    S1Name VARCHAR(30),
    Gender CHAR(1)
);
ALTER TABLE STUDENT2 ADD PRIMARY KEY (RegNo);
ALTER TABLE STUDENT2 ADD CONSTRAINT uq_student2_s1name UNIQUE (S1Name);

ALTER TABLE FACULTY ADD CONSTRAINT pk_faculty PRIMARY KEY (FacNo);
ALTER TABLE FACULTY ADD CONSTRAINT chk_faculty_gender CHECK (Gender IN ('M','F'));
ALTER TABLE DEPARTMENT ADD CONSTRAINT pk_department PRIMARY KEY (DeptNo);
ALTER TABLE COURSE ADD CONSTRAINT pk_course PRIMARY KEY (CourseNo);
ALTER TABLE COURSE ADD CONSTRAINT chk_course_sem CHECK (SemNo BETWEEN '1' AND '6');

CREATE TABLE STUDENT3 (
    RegNo BIGINT PRIMARY KEY,
    S1Name VARCHAR(30)
);
-- Q6: Add foreign key to RegNo of STUDENT3 referencing STUDENT2
ALTER TABLE STUDENT3
ADD CONSTRAINT fk_student3_student2
FOREIGN KEY (RegNo) REFERENCES STUDENT2(RegNo);

SHOW CREATE TABLE STUDENT2;
SHOW CREATE TABLE STUDENT3;

-- =========================================================
-- EXPERIMENT 3: DML - INSERT, SELECT
-- Five related tables used by Experiments 3-9
-- =========================================================
DROP TABLE IF EXISTS ASSESSMENT;
DROP TABLE IF EXISTS REGISTRATION;
-- Keep STUDENT, FACULTY, DEPARTMENT, COURSE created above.

INSERT INTO STUDENT VALUES
(191711342,'Sanjay','M','2007-05-12','9876543210','Salem'),
(191711343,'Kamal','M','2006-08-21','9876543211','Chennai'),
(191711344,'Ayesha','F','2007-01-15','9876543212','Salem'),
(191711345,'Ram','M','2006-11-03','9876543213','Madurai'),
(191711346,'Amisha','F','2007-07-25','9876543214','Coimbatore'),
(191711347,'Harish','M','2006-02-17','9876543215','Salem');

INSERT INTO FACULTY (FacNo,FacName,Gender,DOB,DOJ,MobileNo,Dept) VALUES
('F001','Mohan','M','1965-03-10','2010-06-01','9000000001','CSE'),
('F002','Kamal','M','1975-09-20','2016-07-10','9000000002','ECE'),
('F003','Ratnam','F','1970-04-11','2012-11-01','9000000003','Sales'),
('F004','Priya','F','1980-12-01','2018-02-15','9000000004','ECE');

INSERT INTO DEPARTMENT VALUES
('D001','CSE','F001'),
('D002','ECE','F002'),
('D003','Sales','F003');

INSERT INTO COURSE VALUES
('C001','Programming','P','1','H002','F002'),
('C002','Statistics','T','2','H001','F001'),
('C003','Database','P','3','H003','F003'),
('C004','Networks','T','4','H001','F004');

CREATE TABLE REGISTRATION (
    RegNo BIGINT,
    CourseNo VARCHAR(3),
    PRIMARY KEY (RegNo,CourseNo),
    FOREIGN KEY (RegNo) REFERENCES STUDENT(RegNo),
    FOREIGN KEY (CourseNo) REFERENCES COURSE(CourseNo)
);
CREATE TABLE ASSESSMENT (
    AssessmentID INT AUTO_INCREMENT PRIMARY KEY,
    RegNo BIGINT,
    CourseNo VARCHAR(3),
    Score INT,
    FOREIGN KEY (RegNo) REFERENCES STUDENT(RegNo),
    FOREIGN KEY (CourseNo) REFERENCES COURSE(CourseNo)
);

INSERT INTO REGISTRATION VALUES
(191711342,'C001'),(191711342,'C002'),
(191711343,'C001'),(191711343,'C003'),
(191711344,'C002'),(191711344,'C003'),
(191711345,'C001'),(191711346,'C002');

INSERT INTO ASSESSMENT (RegNo,CourseNo,Score) VALUES
(191711342,'C001',78),(191711342,'C002',85),
(191711343,'C001',65),(191711343,'C003',72),
(191711344,'C002',92),(191711344,'C003',88),
(191711345,'C001',45),(191711346,'C002',55);

-- Q1: Populate all five tables - above INSERT statements.
-- Q2: View all records from the five tables.
SELECT * FROM STUDENT;
SELECT * FROM FACULTY;
SELECT * FROM DEPARTMENT;
SELECT * FROM COURSE;
SELECT * FROM REGISTRATION;

-- =========================================================
-- EXPERIMENT 4: UPDATE, DELETE
-- =========================================================
-- Q1: Update student name whose register number is 191711342.
UPDATE STUDENT SET Name='N Sanjay' WHERE RegNo=191711342;
SELECT RegNo,Name FROM STUDENT WHERE RegNo=191711342;

-- Q2: Delete faculty member who resigned (sample: F004).
DELETE FROM FACULTY WHERE FacNo='F004';
SELECT * FROM FACULTY;

-- Q3: Modify age of faculty named Mohan to 59.
-- DOB is stored, so set DOB to a date that makes the faculty 59 in 2026.
UPDATE FACULTY SET DOB='1967-01-01' WHERE LOWER(FacName)='mohan';
SELECT FacName, TIMESTAMPDIFF(YEAR,DOB,CURDATE()) AS Age FROM FACULTY
WHERE LOWER(FacName)='mohan';

-- Q4: Remove all faculty over 65 years.
DELETE FROM FACULTY WHERE TIMESTAMPDIFF(YEAR,DOB,CURDATE()) > 65;
SELECT FacNo,FacName,DOB FROM FACULTY;

-- =========================================================
-- EXPERIMENT 5: WHERE, LIKE / PATTERN MATCHING
-- =========================================================
-- 1. Registration number, name and DOB of all students.
SELECT RegNo,Name,DOB FROM STUDENT;

-- 2. All female students.
SELECT * FROM STUDENT WHERE Gender='F';

-- 3. Students registered for C001.
SELECT s.RegNo,s.Name,r.CourseNo
FROM STUDENT s JOIN REGISTRATION r ON s.RegNo=r.RegNo
WHERE r.CourseNo='C001';

-- 4. Faculty joined before November 2014.
SELECT * FROM FACULTY WHERE DOJ < '2014-11-01';

-- 5. Courses not allotted to hall H001.
SELECT * FROM COURSE WHERE HallNo <> 'H001';

-- 6. Student names ending with 'sh'.
SELECT * FROM STUDENT WHERE Name LIKE '%sh';

-- 7. Student names containing 'sh'.
SELECT * FROM STUDENT WHERE Name LIKE '%sh%';

-- 8. Students in cities containing 'Sal'.
SELECT * FROM STUDENT WHERE City LIKE '%Sal%';

-- 9. Student names not containing six letters.
SELECT * FROM STUDENT WHERE Name NOT LIKE '______';

-- 10. Student names containing 'am'.
SELECT * FROM STUDENT WHERE Name LIKE '%am%';

-- =========================================================
-- EXPERIMENT 6: BETWEEN, IN, AGGREGATE FUNCTIONS
-- =========================================================
-- 1. Type of courses Statistics and Programming.
SELECT CourseDesc,CourseType FROM COURSE
WHERE CourseDesc IN ('Statistics','Programming');

-- 2. Course numbers whose scores are between 50 and 80.
SELECT DISTINCT CourseNo FROM ASSESSMENT WHERE Score BETWEEN 50 AND 80;

-- Aggregate 1: Average mark of C002.
SELECT AVG(Score) AS Average_Mark FROM ASSESSMENT WHERE CourseNo='C002';

-- Aggregate 2: Maximum and minimum mark for C002.
SELECT MAX(Score) AS Maximum_Mark, MIN(Score) AS Minimum_Mark
FROM ASSESSMENT WHERE CourseNo='C002';

-- Aggregate 3: Maximum, minimum and average mark for each course.
SELECT CourseNo,MAX(Score) AS Maximum_Mark,MIN(Score) AS Minimum_Mark,
AVG(Score) AS Average_Mark
FROM ASSESSMENT GROUP BY CourseNo;

-- Aggregate 4: Course names and average mark of each course.
SELECT c.CourseDesc,AVG(a.Score) AS Average_Mark
FROM COURSE c JOIN ASSESSMENT a ON c.CourseNo=a.CourseNo
GROUP BY c.CourseNo,c.CourseDesc;

-- Aggregate 5: Sum of all scores.
SELECT SUM(Score) AS Total_Score FROM ASSESSMENT;

-- Aggregate 6: Number of students registered for each course.
SELECT c.CourseDesc,COUNT(r.RegNo) AS Student_Count
FROM COURSE c LEFT JOIN REGISTRATION r ON c.CourseNo=r.CourseNo
GROUP BY c.CourseNo,c.CourseDesc;

-- Aggregate 7: Number of courses each student registered for.
SELECT s.RegNo,s.Name,COUNT(r.CourseNo) AS Course_Count
FROM STUDENT s LEFT JOIN REGISTRATION r ON s.RegNo=r.RegNo
GROUP BY s.RegNo,s.Name;

-- =========================================================
-- EXPERIMENT 7: GROUP BY, HAVING, ORDER BY
-- =========================================================
-- 1. Course description and number of students registered.
SELECT c.CourseDesc,COUNT(r.RegNo) AS Student_Count
FROM COURSE c LEFT JOIN REGISTRATION r ON c.CourseNo=r.CourseNo
GROUP BY c.CourseNo,c.CourseDesc
HAVING COUNT(r.RegNo) >= 0;

-- 2. Number of courses each student registered for.
SELECT s.Name,COUNT(r.CourseNo) AS Course_Count
FROM STUDENT s LEFT JOIN REGISTRATION r ON s.RegNo=r.RegNo
GROUP BY s.RegNo,s.Name;

-- 3. Name, gender, mobile in ascending RegNo.
SELECT Name,Gender,MobileNo FROM STUDENT ORDER BY RegNo ASC;

-- 4. Faculty members, older faculty first.
SELECT FacName,DOB,TIMESTAMPDIFF(YEAR,DOB,CURDATE()) AS Age
FROM FACULTY ORDER BY DOB ASC;

-- =========================================================
-- EXPERIMENT 8: SUBQUERY AND CORRELATED SUBQUERY
-- =========================================================
-- 1. Students' scores greater than the average score.
SELECT s.Name,a.CourseNo,a.Score
FROM ASSESSMENT a JOIN STUDENT s ON a.RegNo=s.RegNo
WHERE a.Score > (SELECT AVG(Score) FROM ASSESSMENT);

-- 2. Students who have written more than one assessment test.
SELECT s.RegNo,s.Name
FROM STUDENT s
WHERE (SELECT COUNT(*) FROM ASSESSMENT a WHERE a.RegNo=s.RegNo) > 1;

-- 3. Faculty who joined recently and when.
SELECT FacName,DOJ FROM FACULTY
WHERE DOJ=(SELECT MAX(DOJ) FROM FACULTY);

-- 4. Course and assessment scores greater than the average score of that course.
SELECT c.CourseDesc,a.CourseNo,a.Score
FROM ASSESSMENT a JOIN COURSE c ON a.CourseNo=c.CourseNo
WHERE a.Score > (
    SELECT AVG(a2.Score) FROM ASSESSMENT a2
    WHERE a2.CourseNo=a.CourseNo
);

-- =========================================================
-- EXPERIMENT 9: JOINS - EQUI / INNER / OUTER
-- =========================================================
-- 1. Departments where faculty members are working.
SELECT DISTINCT d.DeptNo,d.DeptName
FROM DEPARTMENT d JOIN FACULTY f ON d.DeptName=f.Dept;

-- 2. Students who have no score in any course; show student name and course number.
SELECT s.Name,r.CourseNo
FROM STUDENT s
LEFT JOIN REGISTRATION r ON s.RegNo=r.RegNo
LEFT JOIN ASSESSMENT a ON s.RegNo=a.RegNo AND r.CourseNo=a.CourseNo
WHERE a.AssessmentID IS NULL;

-- 3. Course names taken by faculty in ECE department whose name is Kamal.
SELECT DISTINCT c.CourseDesc
FROM FACULTY f
JOIN COURSE c ON c.FacNo=f.FacNo
WHERE f.Dept='ECE' AND f.FacName='Kamal';

-- =========================================================
-- EXPERIMENT 10: VIEW AND INDEX
-- employee1 table for the manual's employee questions
-- =========================================================
DROP VIEW IF EXISTS v1;
DROP TABLE IF EXISTS employees1;
CREATE TABLE employees1 (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    salary DECIMAL(10,2)
);
INSERT INTO employees1 VALUES
(1,'John','Smith',120000),(2,'Mary','Jones',150000),
(3,'David','Brown',160000),(10,'Sanjay','Kumar',145500),
(11,'Anita','Rao',175000);

-- View Q1: Create v1 with employee_id and salary.
CREATE VIEW v1 AS SELECT employee_id,salary FROM employees1;
SELECT * FROM v1;

-- View Q2: Insert and delete through v1.
INSERT INTO v1(employee_id,salary) VALUES (20,90000);
SELECT * FROM v1;
DELETE FROM v1 WHERE employee_id=20;
SELECT * FROM v1;

-- Index Q1: Index salary; list first names with salary above 145000; drop index.
CREATE INDEX index1 ON employees1(salary);
SELECT first_name FROM employees1 WHERE salary > 145000;
DROP INDEX index1 ON employees1;

-- Index Q2: Index employee_id; show first name for employee_id 10.
CREATE INDEX index1 ON employees1(employee_id);
SELECT first_name FROM employees1 WHERE employee_id=10;
-- Keep index1 or remove it:
DROP INDEX index1 ON employees1;

-- =========================================================
-- EXPERIMENT 11: AUTO_INCREMENT
-- =========================================================
DROP TABLE IF EXISTS DBMS_Stud;
CREATE TABLE DBMS_Stud (
    RegNo INT AUTO_INCREMENT PRIMARY KEY,
    StudName VARCHAR(40),
    Department VARCHAR(10)
);
-- Q1: Populate register number automatically.
INSERT INTO DBMS_Stud(StudName,Department) VALUES
('Arun','CSE'),('Bala','ECE'),('Sanjay','ECE');
SELECT * FROM DBMS_Stud;

-- Q2: Manually populate register number.
INSERT INTO DBMS_Stud(RegNo,StudName,Department)
VALUES (100,'Kavin','CSE');
SELECT * FROM DBMS_Stud;

-- Q3: Drop AUTO_INCREMENT.
ALTER TABLE DBMS_Stud MODIFY RegNo INT NOT NULL;
SHOW CREATE TABLE DBMS_Stud;

-- =========================================================
-- EXPERIMENT 12: WHILE AND REPEAT
-- =========================================================
DROP FUNCTION IF EXISTS build_while_string;
DELIMITER $$
CREATE FUNCTION build_while_string()
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE x INT DEFAULT 1;
    DECLARE result_text VARCHAR(200) DEFAULT '';
    WHILE x <= 5 DO
        SET result_text = CONCAT(result_text, x, ' ');
        SET x = x + 1;
    END WHILE;
    RETURN result_text;
END$$
DELIMITER ;
-- Program 1 output
SELECT build_while_string() AS While_Result;

DROP FUNCTION IF EXISTS repeat_until_income;
DELIMITER $$
CREATE FUNCTION repeat_until_income()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE income INT DEFAULT 1000;
    REPEAT
        SET income = income + 1000;
    UNTIL income >= 4000
    END REPEAT;
    RETURN income;
END$$
DELIMITER ;
-- Program 2 output
SELECT repeat_until_income() AS Final_Income;

-- =========================================================
-- EXPERIMENT 13: CASE AND LOOP
-- =========================================================
DROP FUNCTION IF EXISTS get_income_level;
DELIMITER $$
CREATE FUNCTION get_income_level(monthly_value INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE income_level VARCHAR(20);
    CASE
        WHEN monthly_value <= 4000 THEN SET income_level='Low Income';
        WHEN monthly_value <= 5000 THEN SET income_level='Avg Income';
        ELSE SET income_level='High Income';
    END CASE;
    RETURN income_level;
END$$
DELIMITER ;
-- Program 1 output
SELECT get_income_level(3500) AS Income_Level_1,
       get_income_level(4500) AS Income_Level_2,
       get_income_level(6000) AS Income_Level_3;

DROP PROCEDURE IF EXISTS income_loop;
DELIMITER $$
CREATE PROCEDURE income_loop()
BEGIN
    DECLARE income INT DEFAULT 1000;
    income_label: LOOP
        SET income=income+1000;
        IF income < 4000 THEN
            ITERATE income_label;
        END IF;
        LEAVE income_label;
    END LOOP;
    SELECT income AS Final_Income;
END$$
DELIMITER ;
-- Program 2 output
CALL income_loop();

-- =========================================================
-- EXPERIMENT 14: TCL - COMMIT, SAVEPOINT, ROLLBACK
-- =========================================================
DROP TABLE IF EXISTS Class;
CREATE TABLE Class (
    name VARCHAR(30),
    id INT PRIMARY KEY
) ENGINE=InnoDB;
INSERT INTO Class VALUES ('alpha',1),('beta',2),('charlie',3),('delta',4),('echo',5);
COMMIT;
START TRANSACTION;
UPDATE Class SET name='bravo' WHERE id=5;
SAVEPOINT A;
INSERT INTO Class VALUES ('uppal',6);
SAVEPOINT B;
INSERT INTO Class VALUES ('balu',7);
SAVEPOINT C;
SELECT * FROM Class;
ROLLBACK TO B;
SELECT * FROM Class;
ROLLBACK;
SELECT * FROM Class;

-- =========================================================
-- EXPERIMENT 15: DCL - GRANT, REVOKE
-- Run as MySQL administrator. Change username/password if needed.
-- =========================================================
-- CREATE USER IF NOT EXISTS 'labuser'@'localhost' IDENTIFIED BY 'Lab@123';
-- GRANT CREATE SESSION ON *.* TO 'labuser'@'localhost'; -- Oracle-style command in manual;
-- MySQL equivalent is to grant required privileges, e.g.:
-- GRANT CREATE, SELECT, INSERT, UPDATE, DELETE ON CSA05_LAB.* TO 'labuser'@'localhost';
-- REVOKE CREATE, INSERT, UPDATE, DELETE ON CSA05_LAB.* FROM 'labuser'@'localhost';
-- SHOW GRANTS FOR 'labuser'@'localhost';

-- =========================================================
-- EXPERIMENT 16: STORED PROCEDURES
-- =========================================================
DROP TABLE IF EXISTS student_info;
CREATE TABLE student_info (
    id INT PRIMARY KEY,
    student_name VARCHAR(40),
    department VARCHAR(10)
);
INSERT INTO student_info VALUES (1,'Arun','CSE'),(2,'Sanjay','ECE'),(3,'Meena','CSE');

DROP PROCEDURE IF EXISTS GetStudentInfo;
DELIMITER $$
CREATE PROCEDURE GetStudentInfo()
BEGIN
    SELECT * FROM student_info;
END$$
DELIMITER ;
-- Problem 1 output
CALL GetStudentInfo();

-- Problem 2: Customer level procedure using credit limit.
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customerNumber INT PRIMARY KEY,
    customerName VARCHAR(50),
    creditLimit DECIMAL(10,2)
);
INSERT INTO customers VALUES
(101,'Alpha Stores',75000),(102,'Beta Traders',25000),(103,'Gamma Shop',5000);

DROP PROCEDURE IF EXISTS GetCustomerLevel;
DELIMITER $$
CREATE PROCEDURE GetCustomerLevel(
    IN p_customerNumber INT,
    OUT p_customerLevel VARCHAR(20)
)
BEGIN
    DECLARE v_creditLimit DECIMAL(10,2);
    SELECT creditLimit INTO v_creditLimit
    FROM customers WHERE customerNumber=p_customerNumber;
    IF v_creditLimit > 50000 THEN
        SET p_customerLevel='PLATINUM';
    ELSEIF v_creditLimit >= 10000 THEN
        SET p_customerLevel='GOLD';
    ELSE
        SET p_customerLevel='SILVER';
    END IF;
END$$
DELIMITER ;
CALL GetCustomerLevel(101,@level);
SELECT @level AS Customer_Level;

-- =========================================================
-- EXPERIMENT 17: FUNCTIONS AND RECURSIVE PROCEDURE
-- =========================================================
DROP FUNCTION IF EXISTS CustomerLevel;
DELIMITER $$
CREATE FUNCTION CustomerLevel(p_creditLimit DECIMAL(10,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE customer_level VARCHAR(20);
    IF p_creditLimit > 50000 THEN
        SET customer_level='PLATINUM';
    ELSEIF p_creditLimit >= 10000 AND p_creditLimit <= 50000 THEN
        SET customer_level='GOLD';
    ELSE
        SET customer_level='SILVER';
    END IF;
    RETURN customer_level;
END$$
DELIMITER ;
-- Problem 1 output
SELECT customerNumber,customerName,creditLimit,
       CustomerLevel(creditLimit) AS Customer_Level
FROM customers;

-- Problem 2: Recursive factorial procedure.
SET SESSION max_sp_recursion_depth=255;
DROP PROCEDURE IF EXISTS compute_factorial;
DELIMITER $$
CREATE PROCEDURE compute_factorial(IN n INT, OUT result BIGINT)
BEGIN
    IF n < 0 THEN
        SET result=NULL;
    ELSEIF n <= 1 THEN
        SET result=1;
    ELSE
        CALL compute_factorial(n-1,@previous_factorial);
        SET result=n*@previous_factorial;
    END IF;
END$$
DELIMITER ;
CALL compute_factorial(5,@fact);
SELECT @fact AS Factorial_5;

-- =========================================================
-- EXPERIMENT 18: CURSOR - BUILD EMPLOYEE EMAIL LIST
-- =========================================================
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    id INT PRIMARY KEY,
    Name VARCHAR(100),
    email VARCHAR(100)
);
INSERT INTO employees VALUES
(1,'Harry Potter','pharry@warnerbros.com'),
(2,'Clark Kent','kclark@dccomics.com'),
(3,'Tony Stark','stony@marvel.com');

DROP PROCEDURE IF EXISTS build_email_list;
DELIMITER $$
CREATE PROCEDURE build_email_list(INOUT email_list VARCHAR(4000))
BEGIN
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_email VARCHAR(100) DEFAULT '';
    DECLARE email_cursor CURSOR FOR SELECT email FROM employees ORDER BY id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished=1;
    OPEN email_cursor;
    get_email: LOOP
        FETCH email_cursor INTO v_email;
        IF v_finished=1 THEN
            LEAVE get_email;
        END IF;
        SET email_list=CONCAT(email_list,IF(email_list='','',';'),v_email);
    END LOOP;
    CLOSE email_cursor;
END$$
DELIMITER ;
SET @email_list='';
CALL build_email_list(@email_list);
SELECT @email_list AS Employee_Email_List;

-- =========================================================
-- EXPERIMENT 19: TRIGGER - AUDIT UPDATE CHANGES
-- =========================================================
DROP TABLE IF EXISTS EMPLOYEES_AUDIT;
DROP TABLE IF EXISTS employees_trigger_demo;
CREATE TABLE employees_trigger_demo (
    ID INT PRIMARY KEY,
    Name VARCHAR(50),
    Email VARCHAR(100)
);
CREATE TABLE EMPLOYEES_AUDIT (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    ID INT,
    OldName VARCHAR(50),
    NewName VARCHAR(50),
    OldEmail VARCHAR(100),
    NewEmail VARCHAR(100),
    ChangedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO employees_trigger_demo VALUES
(1,'Arun','arun@example.com'),(2,'Meena','meena@example.com');

DROP TRIGGER IF EXISTS before_employee_update;
DELIMITER $$
CREATE TRIGGER before_employee_update
BEFORE UPDATE ON employees_trigger_demo
FOR EACH ROW
BEGIN
    INSERT INTO EMPLOYEES_AUDIT(ID,OldName,NewName,OldEmail,NewEmail)
    VALUES(OLD.ID,OLD.Name,NEW.Name,OLD.Email,NEW.Email);
END$$
DELIMITER ;
-- Update to fire trigger, then inspect audit table.
UPDATE employees_trigger_demo
SET Name='Arun Kumar',Email='arunk@example.com'
WHERE ID=1;
SELECT * FROM EMPLOYEES_AUDIT;

-- =========================================================
-- EXPERIMENT 20: STRING FUNCTIONS - REPLACE, REPEAT, REVERSE,
-- RIGHT, LEFT, RPAD, LPAD (+ ASCII, BIN, OCT listed in manual)
-- =========================================================
SELECT
 REPLACE('DATABASE','BASE','STORE') AS Replace_Result,
 REPEAT('SQL ',3) AS Repeat_Result,
 REVERSE('MYSQL') AS Reverse_Result,
 RIGHT('DATABASE',4) AS Right_Result,
 LEFT('DATABASE',4) AS Left_Result,
 RPAD('SQL',6,'*') AS Rpad_Result,
 LPAD('SQL',6,'*') AS Lpad_Result,
 ASCII('A') AS Ascii_Result,
 BIN(10) AS Binary_Result,
 OCT(10) AS Octal_Result;

-- =========================================================
-- EXPERIMENT 21: STRING FUNCTIONS - SPACE, SUBSTR, UPPER,
-- LOWER, TRIM, LENGTH (+ related functions listed in manual)
-- =========================================================
SELECT
 CONCAT('A',SPACE(3),'B') AS Space_Result,
 SUBSTRING('DATABASE',2,4) AS Substring_Result,
 SUBSTR('DATABASE',2,4) AS Substr_Result,
 UPPER('database') AS Upper_Result,
 LOWER('DATABASE') AS Lower_Result,
 TRIM('   SQL LAB   ') AS Trim_Result,
 RTRIM('SQL   ') AS Rtrim_Result,
 LTRIM('   SQL') AS Ltrim_Result,
 LENGTH('DATABASE') AS Length_Result,
 BIT_LENGTH('SQL') AS Bit_Length_Result,
 CHAR_LENGTH('DATABASE') AS Char_Length_Result,
 CONCAT('SQL',' ','LAB') AS Concat_Result,
 INSTR('DATABASE','BASE') AS Instr_Result,
 LOCATE('BASE','DATABASE') AS Locate_Result,
 MID('DATABASE',2,4) AS Mid_Result,
 POSITION('BASE' IN 'DATABASE') AS Position_Result;

-- =========================================================
-- EXPERIMENT 22: PHP + MYSQL CONNECTIVITY
-- This experiment is a PHP program in the manual, not SQL-only.
-- SQL setup to run first; then connect from PHP using mysqli.
-- =========================================================
CREATE DATABASE IF NOT EXISTS mydb;
USE mydb;
DROP TABLE IF EXISTS emp;
CREATE TABLE emp (
    id INT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    empsalary INT NOT NULL
);
INSERT INTO emp(id,name,empsalary) VALUES (312,'RANA',200000);
SELECT * FROM emp;
UPDATE emp SET empsalary=9000000 WHERE id=312;
SELECT * FROM emp;
DELETE FROM emp WHERE id=312;
SELECT * FROM emp;
-- PHP mysqli connection sample (save as dbms_connect.php):
-- <?php
-- $conn = mysqli_connect("localhost", "root", "YOUR_PASSWORD", "mydb");
-- if (!$conn) { die("Connection failed: " . mysqli_connect_error()); }
-- echo "Connected successfully";
-- $result = mysqli_query($conn, "SELECT * FROM emp");
-- while ($row = mysqli_fetch_assoc($result)) { print_r($row); }
-- mysqli_close($conn);
-- ?>

-- =========================================================
-- EXPERIMENT 23: TRAIN TICKET RESERVATION SYSTEM
-- Manual's project is Python + SQLite. SQL below is SQLite syntax,
-- to run in DB Browser for SQLite / Python sqlite3, NOT MySQL.
-- =========================================================
-- SQLite version:
-- CREATE TABLE IF NOT EXISTS train_details (
--   train_no INTEGER PRIMARY KEY,
--   train_name TEXT,
--   source TEXT,
--   destination TEXT,
--   departure_time TEXT
-- );
-- CREATE TABLE IF NOT EXISTS passenger_details (
--   passenger_id INTEGER PRIMARY KEY AUTOINCREMENT,
--   login_id TEXT,
--   passenger_name TEXT,
--   age INTEGER,
--   gender TEXT,
--   source TEXT,
--   destination TEXT,
--   journey_date TEXT,
--   travel_class TEXT,
--   train_no INTEGER,
--   FOREIGN KEY(train_no) REFERENCES train_details(train_no)
-- );
-- INSERT INTO train_details VALUES
-- (101,'Chennai Express','Chennai','New Delhi','06:00'),
-- (102,'Southern Express','Howrah','Ajmer','08:30');
-- INSERT INTO passenger_details
-- (login_id,passenger_name,age,gender,source,destination,journey_date,travel_class,train_no)
-- VALUES ('sanjay01','Sanjay',19,'M','Chennai','New Delhi','2026-12-01','3A',101);
-- SELECT * FROM train_details;
-- SELECT * FROM passenger_details;
-- SELECT * FROM passenger_details WHERE login_id='sanjay01';
-- DELETE FROM passenger_details WHERE login_id='sanjay01';
-- SELECT * FROM passenger_details;
