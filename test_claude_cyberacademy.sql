-- ==========================================================
-- CyberAcademy - Procedura Testowania Integralności Bazy
-- Uruchomienie: CALL TestujIntegralnosc();
-- ==========================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS TestujIntegralnosc$$

CREATE PROCEDURE TestujIntegralnosc()
BEGIN
    -- ── Zmienne dla wyników testów ─────────────────────────
    DECLARE v_wynik     INT DEFAULT 0;
    DECLARE v_passed    INT DEFAULT 0;
    DECLARE v_failed    INT DEFAULT 0;

    -- ══════════════════════════════════════════════════════
    -- BLOK 1: INTEGRALNOŚĆ ENCJI
    -- Czy klucze główne są unikalne i niepuste?
    -- ══════════════════════════════════════════════════════
    SELECT '══════════════════════════════════════════' AS '';
    SELECT '  BLOK 1: INTEGRALNOŚĆ ENCJI              ' AS '';
    SELECT '══════════════════════════════════════════' AS '';

    -- Test 1: Duplikaty PK - Roles
    SELECT COUNT(*) - COUNT(DISTINCT role_id) INTO v_wynik FROM Roles;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 1  | Roles - duplikaty PK          | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 1  | Roles - duplikaty PK          | ❌ FAILED (', v_wynik, ' duplikatów)') AS wynik;
    END IF;

    -- Test 2: Duplikaty PK - Users
    SELECT COUNT(*) - COUNT(DISTINCT user_id) INTO v_wynik FROM Users;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 2  | Users - duplikaty PK          | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 2  | Users - duplikaty PK          | ❌ FAILED (', v_wynik, ' duplikatów)') AS wynik;
    END IF;

    -- Test 3: Duplikaty PK - Courses
    SELECT COUNT(*) - COUNT(DISTINCT course_id) INTO v_wynik FROM Courses;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 3  | Courses - duplikaty PK        | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 3  | Courses - duplikaty PK        | ❌ FAILED (', v_wynik, ' duplikatów)') AS wynik;
    END IF;

    -- Test 4: Duplikaty PK - Enrollments
    SELECT COUNT(*) - COUNT(DISTINCT enrollment_id) INTO v_wynik FROM Enrollments;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 4  | Enrollments - duplikaty PK    | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 4  | Enrollments - duplikaty PK    | ❌ FAILED (', v_wynik, ' duplikatów)') AS wynik;
    END IF;

    -- Test 5: Duplikaty PK - Payments
    SELECT COUNT(*) - COUNT(DISTINCT payment_id) INTO v_wynik FROM Payments;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 5  | Payments - duplikaty PK       | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 5  | Payments - duplikaty PK       | ❌ FAILED (', v_wynik, ' duplikatów)') AS wynik;
    END IF;

    -- Test 6: Duplikaty PK - Certificates
    SELECT COUNT(*) - COUNT(DISTINCT certificate_id) INTO v_wynik FROM Certificates;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 6  | Certificates - duplikaty PK   | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 6  | Certificates - duplikaty PK   | ❌ FAILED (', v_wynik, ' duplikatów)') AS wynik;
    END IF;

    -- Test 7: Duplikaty PK - Quizzes
    SELECT COUNT(*) - COUNT(DISTINCT quiz_id) INTO v_wynik FROM Quizzes;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 7  | Quizzes - duplikaty PK        | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 7  | Quizzes - duplikaty PK        | ❌ FAILED (', v_wynik, ' duplikatów)') AS wynik;
    END IF;

    -- Test 8: Duplikaty PK - Quiz_Attempts
    SELECT COUNT(*) - COUNT(DISTINCT attempt_id) INTO v_wynik FROM Quiz_Attempts;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 8  | Quiz_Attempts - duplikaty PK  | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 8  | Quiz_Attempts - duplikaty PK  | ❌ FAILED (', v_wynik, ' duplikatów)') AS wynik;
    END IF;

    -- Test 9: Unikalność certyfikatów (1:1 z Enrollments)
    SELECT COUNT(*) INTO v_wynik FROM (
        SELECT enrollment_id FROM Certificates
        GROUP BY enrollment_id HAVING COUNT(*) > 1
    ) AS duplikaty;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 9  | Certificates - unikalność 1:1 | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 9  | Certificates - unikalność 1:1 | ❌ FAILED (', v_wynik, ' naruszeń)') AS wynik;
    END IF;

    -- ══════════════════════════════════════════════════════
    -- BLOK 2: INTEGRALNOŚĆ REFERENCYJNA
    -- Czy klucze obce wskazują na istniejące rekordy?
    -- ══════════════════════════════════════════════════════
    SELECT '══════════════════════════════════════════' AS '';
    SELECT '  BLOK 2: INTEGRALNOŚĆ REFERENCYJNA       ' AS '';
    SELECT '══════════════════════════════════════════' AS '';

    -- Test 10: Users.role_id -> Roles
    SELECT COUNT(*) INTO v_wynik FROM Users
    WHERE role_id NOT IN (SELECT role_id FROM Roles);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 10 | Users.role_id -> Roles        | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 10 | Users.role_id -> Roles        | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 11: Courses.category_id -> Categories
    SELECT COUNT(*) INTO v_wynik FROM Courses
    WHERE category_id NOT IN (SELECT category_id FROM Categories);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 11 | Courses.category_id -> Categ. | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 11 | Courses.category_id -> Categ. | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 12: Courses.instructor_id -> Users
    SELECT COUNT(*) INTO v_wynik FROM Courses
    WHERE instructor_id NOT IN (SELECT user_id FROM Users);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 12 | Courses.instructor_id -> Users| ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 12 | Courses.instructor_id -> Users| ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 13: Lessons.course_id -> Courses
    SELECT COUNT(*) INTO v_wynik FROM Lessons
    WHERE course_id NOT IN (SELECT course_id FROM Courses);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 13 | Lessons.course_id -> Courses  | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 13 | Lessons.course_id -> Courses  | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 14: Enrollments.student_id -> Users
    SELECT COUNT(*) INTO v_wynik FROM Enrollments
    WHERE student_id NOT IN (SELECT user_id FROM Users);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 14 | Enrollments.student_id->Users | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 14 | Enrollments.student_id->Users | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 15: Enrollments.course_id -> Courses
    SELECT COUNT(*) INTO v_wynik FROM Enrollments
    WHERE course_id NOT IN (SELECT course_id FROM Courses);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 15 | Enrollments.course_id->Courses| ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 15 | Enrollments.course_id->Courses| ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 16: Payments.enrollment_id -> Enrollments
    SELECT COUNT(*) INTO v_wynik FROM Payments
    WHERE enrollment_id NOT IN (SELECT enrollment_id FROM Enrollments);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 16 | Payments.enrollment_id->Enr.  | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 16 | Payments.enrollment_id->Enr.  | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 17: Quizzes.course_id -> Courses
    SELECT COUNT(*) INTO v_wynik FROM Quizzes
    WHERE course_id NOT IN (SELECT course_id FROM Courses);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 17 | Quizzes.course_id -> Courses  | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 17 | Quizzes.course_id -> Courses  | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 18: Quiz_Attempts.quiz_id -> Quizzes
    SELECT COUNT(*) INTO v_wynik FROM Quiz_Attempts
    WHERE quiz_id NOT IN (SELECT quiz_id FROM Quizzes);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 18 | Quiz_Attempts.quiz_id->Quizzes| ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 18 | Quiz_Attempts.quiz_id->Quizzes| ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 19: Quiz_Attempts.student_id -> Users
    SELECT COUNT(*) INTO v_wynik FROM Quiz_Attempts
    WHERE student_id NOT IN (SELECT user_id FROM Users);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 19 | Quiz_Attempts.student_id->Users| ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 19 | Quiz_Attempts.student_id->Users| ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 20: Certificates.enrollment_id -> Enrollments
    SELECT COUNT(*) INTO v_wynik FROM Certificates
    WHERE enrollment_id NOT IN (SELECT enrollment_id FROM Enrollments);
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 20 | Certificates.enrollment_id->Enr| ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 20 | Certificates.enrollment_id->Enr| ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- ══════════════════════════════════════════════════════
    -- BLOK 3: INTEGRALNOŚĆ SEMANTYCZNA
    -- Czy wartości są logicznie poprawne?
    -- ══════════════════════════════════════════════════════
    SELECT '══════════════════════════════════════════' AS '';
    SELECT '  BLOK 3: INTEGRALNOŚĆ SEMANTYCZNA        ' AS '';
    SELECT '══════════════════════════════════════════' AS '';

    -- Test 21: Ceny kursów > 0
    SELECT COUNT(*) INTO v_wynik FROM Courses
    WHERE price <= 0 OR price IS NULL;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 21 | Courses - ceny > 0            | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 21 | Courses - ceny > 0            | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 22: Postęp w zakresie 0-100%
    SELECT COUNT(*) INTO v_wynik FROM Enrollments
    WHERE progress_pct < 0 OR progress_pct > 100;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 22 | Enrollments - postęp 0-100%   | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 22 | Enrollments - postęp 0-100%   | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 23: completed_at >= enrolled_at
    SELECT COUNT(*) INTO v_wynik FROM Enrollments
    WHERE completed_at IS NOT NULL AND completed_at < enrolled_at;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 23 | Enrollments - daty poprawne   | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 23 | Enrollments - daty poprawne   | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 24: Wyniki quizów w zakresie 0-100
    SELECT COUNT(*) INTO v_wynik FROM Quiz_Attempts
    WHERE score < 0 OR score > 100;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 24 | Quiz_Attempts - wyniki 0-100  | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 24 | Quiz_Attempts - wyniki 0-100  | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 25: pass_score w zakresie 0-100
    SELECT COUNT(*) INTO v_wynik FROM Quizzes
    WHERE pass_score < 0 OR pass_score > 100;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 25 | Quizzes - pass_score 0-100    | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 25 | Quizzes - pass_score 0-100    | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 26: Emaile zawierają znak @
    SELECT COUNT(*) INTO v_wynik FROM Users
    WHERE email NOT LIKE '%@%';
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 26 | Users - format emaili         | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 26 | Users - format emaili         | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 27: Kwoty płatności > 0
    SELECT COUNT(*) INTO v_wynik FROM Payments
    WHERE amount <= 0 OR amount IS NULL;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 27 | Payments - kwoty > 0          | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 27 | Payments - kwoty > 0          | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 28: lesson_order >= 1
    SELECT COUNT(*) INTO v_wynik FROM Lessons
    WHERE lesson_order < 1 OR lesson_order IS NULL;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 28 | Lessons - kolejność >= 1      | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 28 | Lessons - kolejność >= 1      | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 29: max_attempts >= 1
    SELECT COUNT(*) INTO v_wynik FROM Quizzes
    WHERE max_attempts < 1 OR max_attempts IS NULL;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 29 | Quizzes - max_attempts >= 1   | ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 29 | Quizzes - max_attempts >= 1   | ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- Test 30: Instruktorzy mają rolę Instructor (role_id = 2)
    SELECT COUNT(*) INTO v_wynik FROM Courses c
    JOIN Users u ON c.instructor_id = u.user_id
    WHERE u.role_id != 2;
    IF v_wynik = 0 THEN
        SET v_passed = v_passed + 1;
        SELECT 'Test 30 | Courses - instruktor ma rolę 2| ✅ PASSED' AS wynik;
    ELSE
        SET v_failed = v_failed + 1;
        SELECT CONCAT('Test 30 | Courses - instruktor ma rolę 2| ❌ FAILED (', v_wynik, ' rekordów)') AS wynik;
    END IF;

    -- ══════════════════════════════════════════════════════
    -- PODSUMOWANIE
    -- ══════════════════════════════════════════════════════
    SELECT '══════════════════════════════════════════' AS '';
    SELECT '  PODSUMOWANIE TESTÓW                      ' AS '';
    SELECT '══════════════════════════════════════════' AS '';
    SELECT
        30              AS wszystkich_testow,
        v_passed        AS passed,
        v_failed        AS failed,
        CASE
            WHEN v_failed = 0 THEN '✅ WSZYSTKIE TESTY ZALICZONE'
            ELSE CONCAT('❌ ', v_failed, ' TEST(Y) NIEZALICZONE')
        END             AS status;

END$$

DELIMITER ;

-- ==========================================================
-- Uruchomienie procedury:
-- ==========================================================
CALL TestujIntegralnosc();