-- 1. Integralność encji — unikalne i niepuste klucze główne
-- Sprawdzenie czy istnieją zduplikowane klucze główne
SELECT 'Roles' AS tabela, COUNT(*) - COUNT(DISTINCT role_id) AS duplikaty FROM Roles
UNION ALL
SELECT 'Users',       COUNT(*) - COUNT(DISTINCT user_id)       FROM Users
UNION ALL
SELECT 'Categories',  COUNT(*) - COUNT(DISTINCT category_id)   FROM Categories
UNION ALL
SELECT 'Courses',     COUNT(*) - COUNT(DISTINCT course_id)     FROM Courses
UNION ALL
SELECT 'Lessons',     COUNT(*) - COUNT(DISTINCT lesson_id)     FROM Lessons
UNION ALL
SELECT 'Enrollments', COUNT(*) - COUNT(DISTINCT enrollment_id) FROM Enrollments
UNION ALL
SELECT 'Payments',    COUNT(*) - COUNT(DISTINCT payment_id)    FROM Payments
UNION ALL
SELECT 'Quizzes',     COUNT(*) - COUNT(DISTINCT quiz_id)       FROM Quizzes
UNION ALL
SELECT 'Quiz_Attempts',COUNT(*) - COUNT(DISTINCT attempt_id)   FROM Quiz_Attempts
UNION ALL
SELECT 'Certificates', COUNT(*) - COUNT(DISTINCT certificate_id) FROM Certificates;
-- Oczekiwany wynik: 0 duplikatów dla każdej tabeli

-- Sprawdzenie czy klucze główne zawierają wartości NULL
SELECT 'Roles' AS tabela, COUNT(*) AS null_pk FROM Roles WHERE role_id IS NULL
UNION ALL
SELECT 'Users',        COUNT(*) FROM Users        WHERE user_id IS NULL
UNION ALL
SELECT 'Categories',   COUNT(*) FROM Categories   WHERE category_id IS NULL
UNION ALL
SELECT 'Courses',      COUNT(*) FROM Courses       WHERE course_id IS NULL
UNION ALL
SELECT 'Lessons',      COUNT(*) FROM Lessons       WHERE lesson_id IS NULL
UNION ALL
SELECT 'Enrollments',  COUNT(*) FROM Enrollments   WHERE enrollment_id IS NULL
UNION ALL
SELECT 'Payments',     COUNT(*) FROM Payments      WHERE payment_id IS NULL
UNION ALL
SELECT 'Quizzes',      COUNT(*) FROM Quizzes       WHERE quiz_id IS NULL
UNION ALL
SELECT 'Quiz_Attempts',COUNT(*) FROM Quiz_Attempts WHERE attempt_id IS NULL
UNION ALL
SELECT 'Certificates', COUNT(*) FROM Certificates  WHERE certificate_id IS NULL;
-- Oczekiwany wynik: 0 dla każdej tabeli

-- 2. Integralność referencyjna — poprawność kluczy obcych
-- Users -> Roles: czy każdy użytkownik ma przypisaną istniejącą rolę
SELECT COUNT(*) AS zepsute_fk FROM Users
WHERE role_id NOT IN (SELECT role_id FROM Roles);

-- Oczekiwany wynik: 0
-- Courses -> Categories: czy każdy kurs ma istniejącą kategorię
SELECT COUNT(*) AS zepsute_fk FROM Courses
WHERE category_id NOT IN (SELECT category_id FROM Categories);
-- Oczekiwany wynik: 0

-- Courses -> Users: czy każdy kurs ma istniejącego instruktora
SELECT COUNT(*) AS zepsute_fk FROM Courses
WHERE instructor_id NOT IN (SELECT user_id FROM Users);
-- Oczekiwany wynik: 0

-- Lessons -> Courses: czy każda lekcja należy do istniejącego kursu
SELECT COUNT(*) AS zepsute_fk FROM Lessons
WHERE course_id NOT IN (SELECT course_id FROM Courses);
-- Oczekiwany wynik: 0

-- Enrollments -> Users i Courses
SELECT COUNT(*) AS zepsute_fk_student FROM Enrollments
WHERE student_id NOT IN (SELECT user_id FROM Users);

SELECT COUNT(*) AS zepsute_fk_kurs FROM Enrollments
WHERE course_id NOT IN (SELECT course_id FROM Courses);
-- Oczekiwany wynik: 0 dla obu

-- Payments -> Enrollments
SELECT COUNT(*) AS zepsute_fk FROM Payments
WHERE enrollment_id NOT IN (SELECT enrollment_id FROM Enrollments);
-- Oczekiwany wynik: 0

-- Quizzes -> Courses
SELECT COUNT(*) AS zepsute_fk FROM Quizzes
WHERE course_id NOT IN (SELECT course_id FROM Courses);
-- Oczekiwany wynik: 0

-- Quiz_Attempts -> Quizzes i Users
SELECT COUNT(*) AS zepsute_fk_quiz FROM Quiz_Attempts
WHERE quiz_id NOT IN (SELECT quiz_id FROM Quizzes);

SELECT COUNT(*) AS zepsute_fk_student FROM Quiz_Attempts
WHERE student_id NOT IN (SELECT user_id FROM Users);
-- Oczekiwany wynik: 0 dla obu

-- Certificates -> Enrollments
SELECT COUNT(*) AS zepsute_fk FROM Certificates
WHERE enrollment_id NOT IN (SELECT enrollment_id FROM Enrollments);
-- Oczekiwany wynik: 0

-- 3. Integralność semantyczna — typy, formaty, zakresy
-- Sprawdzenie czy ceny kursów są większe od 0
SELECT COUNT(*) AS niepoprawne_ceny FROM Courses
WHERE price <= 0 OR price IS NULL;
-- Oczekiwany wynik: 0

-- Sprawdzenie czy postęp w zapisach mieści się w zakresie 0-100%
SELECT COUNT(*) AS niepoprawny_postep FROM Enrollments
WHERE progress_pct < 0 OR progress_pct > 100;
-- Oczekiwany wynik: 0

-- Sprawdzenie czy data ukończenia jest późniejsza niż data zapisu
SELECT COUNT(*) AS niepoprawne_daty FROM Enrollments
WHERE completed_at IS NOT NULL AND completed_at < enrolled_at;
-- Oczekiwany wynik: 0

-- Sprawdzenie czy wyniki quizów mieszczą się w zakresie 0-100
SELECT COUNT(*) AS niepoprawne_wyniki FROM Quiz_Attempts
WHERE score < 0 OR score > 100;
-- Oczekiwany wynik: 0

-- Sprawdzenie czy pass_score w quizach mieści się w zakresie 0-100
SELECT COUNT(*) AS niepoprawny_prog FROM Quizzes
WHERE pass_score < 0 OR pass_score > 100;
-- Oczekiwany wynik: 0

-- Sprawdzenie czy pass_score w quizach mieści się w zakresie 0-100
SELECT COUNT(*) AS niepoprawny_prog FROM Quizzes
WHERE pass_score < 0 OR pass_score > 100;
-- Oczekiwany wynik: 0

-- Sprawdzenie czy emaile użytkowników zawierają znak @
SELECT COUNT(*) AS niepoprawne_emaile FROM Users
WHERE email NOT LIKE '%@%';
-- Oczekiwany wynik: 0

-- Sprawdzenie czy kwoty płatności są większe od 0
SELECT COUNT(*) AS niepoprawne_kwoty FROM Payments
WHERE amount <= 0 OR amount IS NULL;
-- Oczekiwany wynik: 0

-- Sprawdzenie unikalności certyfikatów (1:1 z Enrollments)
SELECT COUNT(*) AS duplikaty_certyfikatow
FROM Certificates
GROUP BY enrollment_id
HAVING COUNT(*) > 1;
-- Oczekiwany wynik: brak wierszy