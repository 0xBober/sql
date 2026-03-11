-- ============================================================
-- CyberAcademy Reset & Rebuild Script
-- ============================================================

-- Drop and recreate the entire database
DROP DATABASE IF EXISTS cyberacademy;

CREATE DATABASE cyberacademy
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cyberacademy;

-- ------------------------------------------------------------
-- Tables
-- ------------------------------------------------------------

CREATE TABLE Roles (
    role_id    INT AUTO_INCREMENT PRIMARY KEY,
    role_name  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Users (
    user_id        INT AUTO_INCREMENT PRIMARY KEY,
    role_id        INT NOT NULL,
    first_name     VARCHAR(100) NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    registered_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active      TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id)
        REFERENCES Roles(role_id)
);

CREATE TABLE Categories (
    category_id    INT AUTO_INCREMENT PRIMARY KEY,
    category_name  VARCHAR(100) NOT NULL UNIQUE,
    description    TEXT NULL
);

CREATE TABLE Courses (
    course_id      INT AUTO_INCREMENT PRIMARY KEY,
    category_id    INT NOT NULL,
    instructor_id  INT NOT NULL,
    title          VARCHAR(200) NOT NULL,
    difficulty     ENUM('Beginner','Intermediate','Advanced') NOT NULL,
    price          DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_published   TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT fk_courses_category
        FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    CONSTRAINT fk_courses_instructor
        FOREIGN KEY (instructor_id) REFERENCES Users(user_id)
);

CREATE TABLE Lessons (
    lesson_id     INT AUTO_INCREMENT PRIMARY KEY,
    course_id     INT NOT NULL,
    title         VARCHAR(200) NOT NULL,
    content_url   VARCHAR(500) NULL,
    duration_min  INT NULL,
    lesson_order  INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_lessons_course
        FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

CREATE TABLE Enrollments (
    enrollment_id  INT AUTO_INCREMENT PRIMARY KEY,
    student_id     INT NOT NULL,
    course_id      INT NOT NULL,
    enrolled_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at   DATETIME NULL,
    progress_pct   DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id) REFERENCES Users(user_id),
    CONSTRAINT fk_enrollments_course
        FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    CONSTRAINT uq_enrollment UNIQUE (student_id, course_id)
);

CREATE TABLE Payments (
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id  INT NOT NULL,
    amount         DECIMAL(8,2) NOT NULL,
    payment_date   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    method         ENUM('Card','Transfer','Crypto') NOT NULL,
    status         ENUM('Pending','Completed','Refunded') NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_payments_enrollment
        FOREIGN KEY (enrollment_id) REFERENCES Enrollments(enrollment_id)
);

CREATE TABLE Quizzes (
    quiz_id      INT AUTO_INCREMENT PRIMARY KEY,
    course_id    INT NOT NULL,
    title        VARCHAR(200) NOT NULL,
    pass_score   INT NOT NULL DEFAULT 70,
    max_attempts INT NOT NULL DEFAULT 3,
    CONSTRAINT fk_quizzes_course
        FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

CREATE TABLE Quiz_Attempts (
    attempt_id    INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id       INT NOT NULL,
    student_id    INT NOT NULL,
    score         INT NOT NULL,
    attempted_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    passed        TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT fk_attempts_quiz
        FOREIGN KEY (quiz_id) REFERENCES Quizzes(quiz_id),
    CONSTRAINT fk_attempts_student
        FOREIGN KEY (student_id) REFERENCES Users(user_id)
);

CREATE TABLE Certificates (
    certificate_id    INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id     INT NOT NULL UNIQUE,
    issued_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    certificate_code  VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT fk_certificates_enrollment
        FOREIGN KEY (enrollment_id) REFERENCES Enrollments(enrollment_id)
);

-- ------------------------------------------------------------
-- Views
-- ------------------------------------------------------------

CREATE VIEW vw_active_enrollments AS
SELECT
    e.enrollment_id                             AS EnrollmentID,
    CONCAT(u.first_name, ' ', u.last_name)      AS StudentName,
    c.title                                     AS CourseTitle,
    cat.category_name                           AS Category,
    CONCAT(i.first_name, ' ', i.last_name)      AS InstructorName,
    e.enrolled_at                               AS EnrolledAt,
    e.progress_pct                              AS ProgressPercent
FROM Enrollments e
JOIN Users u        ON e.student_id     = u.user_id
JOIN Courses c      ON e.course_id      = c.course_id
JOIN Categories cat ON c.category_id    = cat.category_id
JOIN Users i        ON c.instructor_id  = i.user_id
WHERE e.completed_at IS NULL
ORDER BY e.enrolled_at DESC;

CREATE VIEW vw_course_performance AS
SELECT
    cat.category_name                       AS Category,
    c.title                                 AS CourseTitle,
    c.difficulty                            AS Difficulty,
    COUNT(DISTINCT e.enrollment_id)         AS TotalEnrollments,
    COUNT(DISTINCT qa.attempt_id)           AS TotalQuizAttempts,
    ROUND(AVG(qa.score), 1)                 AS AvgQuizScore,
    SUM(CASE WHEN qa.passed = 1 THEN 1
             ELSE 0 END)                    AS PassedAttempts
FROM Courses c
JOIN Categories cat     ON c.category_id    = cat.category_id
LEFT JOIN Enrollments e ON c.course_id      = e.course_id
LEFT JOIN Quizzes q     ON c.course_id      = q.course_id
LEFT JOIN Quiz_Attempts qa ON q.quiz_id     = qa.quiz_id
WHERE c.is_published = 1
GROUP BY c.course_id, cat.category_name, c.title, c.difficulty
ORDER BY cat.category_name, AvgQuizScore DESC;

CREATE VIEW vw_monthly_revenue AS
SELECT
    DATE_FORMAT(p.payment_date, '%Y-%m')    AS Month,
    p.method                                AS PaymentMethod,
    COUNT(p.payment_id)                     AS TransactionCount,
    SUM(p.amount)                           AS TotalRevenue,
    ROUND(AVG(p.amount), 2)                 AS AvgTransactionValue,
    MIN(p.amount)                           AS MinPayment,
    MAX(p.amount)                           AS MaxPayment
FROM Payments p
WHERE p.status = 'Completed'
GROUP BY DATE_FORMAT(p.payment_date, '%Y-%m'), p.method
ORDER BY Month DESC, TotalRevenue DESC;

-- ------------------------------------------------------------
-- Verify
-- ------------------------------------------------------------
SHOW TABLES;
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- ============================================================
-- Done! Ready for data.sql import
-- ============================================================
