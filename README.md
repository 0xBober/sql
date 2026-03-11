# 🛡️ CyberAcademy — Relational Database Project

A fully designed and implemented relational database for a cybersecurity-focused e-learning platform. Built as part of a university database course, the project covers the full lifecycle — from ERD design and schema implementation to realistic data population, views, and automated integrity testing.

---

## 📋 Table of Contents

- [About the Project](#about-the-project)
- [Database Schema](#database-schema)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Views](#views)
- [Integrity Testing](#integrity-testing)
- [Normal Forms](#normal-forms)

---

## 📖 About the Project

CyberAcademy is a fictional online learning platform specializing in cybersecurity courses — covering topics such as Ethical Hacking, Web Security, Cryptography, Malware Analysis, Reverse Engineering, and more.

The database is designed to handle:
- User management with role-based access (Admin, Instructor, Student)
- Course catalog with categories and difficulty levels
- Student enrollments, progress tracking and certificates
- Payment processing with multiple methods and statuses
- Quiz system with configurable attempts and pass scores
- Analytical views for revenue, performance and enrollment monitoring

---

## 🗄️ Database Schema

The database consists of **10 tables** organized in a relational structure:

| Table | Description |
|-------|-------------|
| `Roles` | User roles — Admin, Instructor, Student |
| `Users` | All platform users regardless of role |
| `Categories` | Course categories (e.g. Ethical Hacking, Web Security) |
| `Courses` | Course catalog with difficulty, price and instructor |
| `Lessons` | Individual lessons belonging to courses |
| `Enrollments` | Student-course relationships with progress tracking |
| `Payments` | Payment transactions linked to enrollments |
| `Quizzes` | Quizzes assigned to courses with pass score config |
| `Quiz_Attempts` | Individual quiz attempts with scores and results |
| `Certificates` | Certificates issued upon course completion |

### Entity Relationships

```
Roles ──< Users ──< Enrollments >── Courses >── Categories
                         │               │
                         ▼               ├──< Lessons
                     Payments            └──< Quizzes ──< Quiz_Attempts
                         │
                    Certificates
```

- **1:N** — Roles → Users, Courses → Lessons, Courses → Quizzes, Enrollments → Payments
- **N:M** — Users ↔ Courses (via Enrollments), Users ↔ Quizzes (via Quiz_Attempts)
- **1:1** — Enrollments → Certificates

---

## 🛠️ Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| MariaDB | 11.8.3 | Database server |
| MySQL Workbench | 8.0.46 CE | GUI client & ERD design |
| Debian GNU/Linux | 6.12.73 | Server OS (VM) |
| VMware Workstation Pro | 25H2 | Virtualization |

---

## 📁 Project Structure

```
sql/
├── schema.sql                    # Database reset & rebuild script
├── data.sql                      # Realistic sample data (all 10 tables)
├── test_cyberacademy.sql         # Individual integrity test queries
└── test_claude_cyberacademy.sql  # Automated test procedure (30 tests)
```

---

## 🚀 Getting Started

### Prerequisites
- MariaDB or MySQL server running
- A SQL client (MySQL Workbench, DBeaver, or CLI)

### Setup

**1. Clone the repository:**
```bash
git clone https://github.com/0xBober/sql.git
cd sql
```

**2. Run the schema script** (creates and rebuilds the database):
```bash
mysql -u root -p < schema.sql
```

**3. Populate with sample data:**
```bash
mysql -u root -p < data.sql
```

**4. Verify everything is working:**
```bash
mysql -u root -p
```
```sql
USE cyberacademy;
SHOW TABLES;
SELECT COUNT(*) FROM Users;
```

---

## 📊 Views

Three analytical views are included:

### `vw_active_enrollments`
Lists all currently active (in-progress) enrollments with student name, course title, category, instructor and progress percentage.
```sql
SELECT * FROM vw_active_enrollments;
```

### `vw_course_performance`
Aggregated course statistics — total enrollments, quiz attempts, average quiz score and passed attempts per course.
```sql
SELECT * FROM vw_course_performance;
```

### `vw_monthly_revenue`
Monthly revenue breakdown by payment method, including transaction count, total revenue, average, min and max transaction values. Only completed payments are included.
```sql
SELECT * FROM vw_monthly_revenue;
```

---

## 🧪 Integrity Testing

Two test files are provided to verify database integrity:

### Option 1 — Individual queries (`test_cyberacademy.sql`)
A collection of standalone SQL queries grouped by integrity type:
- **Entity integrity** — duplicate and NULL primary key checks
- **Referential integrity** — foreign key validation across all tables
- **Semantic integrity** — value range and format checks

### Option 2 — Automated procedure (`test_claude_cyberacademy.sql`)
A stored procedure `TestujIntegralnosc()` that runs all **30 tests** automatically and reports ✅ PASSED / ❌ FAILED for each one, plus a final summary.

> 💡 This procedure was written with the assistance of **Claude AI (Anthropic)**.

**To run via CLI** (assuming `cyberacademy` is the active database):

```sql
-- Import the procedure
SOURCE test_claude_cyberacademy.sql;

-- Run all tests
CALL TestujIntegralnosc();
```

Expected output:
```
Test 1  | Roles - duplikaty PK          | ✅ PASSED
Test 2  | Users - duplikaty PK          | ✅ PASSED
...
Test 30 | Courses - instruktor ma rolę 2| ✅ PASSED

| wszystkich_testow | passed | failed | status                      |
| 30                | 30     | 0      | ✅ WSZYSTKIE TESTY ZALICZONE |
```

---

## 📐 Normal Forms

The database is fully compliant with **Third Normal Form (3NF)**:

- **1NF** ✅ — All columns store atomic values, every table has a defined primary key
- **2NF** ✅ — All non-key columns depend on the entire primary key (no partial dependencies)
- **3NF** ✅ — No transitive dependencies between non-key columns (e.g. `category_name` lives in `Categories`, not in `Courses`)

---

## 📦 Sample Data Summary

| Table | Records |
|-------|---------|
| Roles | 3 |
| Users | 58 (3 admins, 5 instructors, 50 students) |
| Categories | 10 |
| Courses | 20 |
| Lessons | ~93 |
| Enrollments | 159 |
| Payments | 192 |
| Quizzes | 36 |
| Quiz_Attempts | 121 |
| Certificates | 46 |

---

*Project developed as part of a university database design course.*
