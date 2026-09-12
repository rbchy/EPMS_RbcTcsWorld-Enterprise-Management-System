# EPMS — Enterprise Payroll Management System

A full-stack payroll platform built from the ground up — a Spring Boot REST API backed by MySQL/JPA, paired with a native JavaFX desktop client — and backed by a **79-test** automated QA suite (unit, service, REST-API/integration, and headless UI automation) wired into a GitHub Actions CI pipeline with Allure reporting.

Where a typical QA-automation portfolio project (e.g. a Selenium/Cucumber harness driving an existing HRM demo) proves *"I can test a system someone else built,"* EPMS proves the other half of the job: **"I can build the system, then design and automate the tests that keep it honest."** See [How this compares to a pure test-automation project](#how-this-compares-to-a-pure-test-automation-project-eg-orangehrm-payroll-automation) below.

**Ranajit B Chowdhury** — QA Automation Engineer & Full-Stack Developer
Test Automation Specialist · Java · Spring Boot · JavaFX · JUnit 5 · TestFX · Mockito

[![GitHub](https://img.shields.io/badge/rbchy-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/rbchy)
[![LinkedIn](https://img.shields.io/badge/rbchy-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/rbchy)

[![CI](https://github.com/rbchy/epms-payroll-management-system/actions/workflows/ci.yml/badge.svg)](https://github.com/rbchy/epms-payroll-management-system/actions/workflows/ci.yml)

> The CI badge above assumes this repo is pushed to `github.com/rbchy/epms-payroll-management-system` — update the URL to match wherever you actually push it.

---

## Tools & Technologies

<p>
  <img src="https://img.shields.io/badge/Java-21-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java 21" />
  <img src="https://img.shields.io/badge/Maven-Multi--Module-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white" alt="Maven" />
  <img src="https://img.shields.io/badge/Spring_Boot-3.5.5-6DB33F?style=for-the-badge&logo=springboot&logoColor=white" alt="Spring Boot" />
  <img src="https://img.shields.io/badge/Spring_Data_JPA-Hibernate_6.6-6DB33F?style=for-the-badge&logo=hibernate&logoColor=white" alt="Spring Data JPA / Hibernate" />
  <img src="https://img.shields.io/badge/MySQL-8.x-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL" />
  <img src="https://img.shields.io/badge/H2-In--Memory_Test_DB-1F4E79?style=for-the-badge&logo=databricks&logoColor=white" alt="H2" />
</p>
<p>
  <img src="https://img.shields.io/badge/JavaFX-21.0.8-orange?style=for-the-badge&logo=java&logoColor=white" alt="JavaFX" />
  <img src="https://img.shields.io/badge/TestFX-4.0.18-3E7BC4?style=for-the-badge&logo=java&logoColor=white" alt="TestFX" />
  <img src="https://img.shields.io/badge/Monocle-Headless_UI-3E7BC4?style=for-the-badge&logo=java&logoColor=white" alt="Monocle" />
  <img src="https://img.shields.io/badge/JUnit_5-Jupiter-25A162?style=for-the-badge&logo=junit5&logoColor=white" alt="JUnit 5" />
  <img src="https://img.shields.io/badge/Mockito-5.14-78C257?style=for-the-badge&logo=java&logoColor=white" alt="Mockito" />
  <img src="https://img.shields.io/badge/MockMvc-Spring_Test-6DB33F?style=for-the-badge&logo=springboot&logoColor=white" alt="MockMvc" />
</p>
<p>
  <img src="https://img.shields.io/badge/Allure_Report-2.35-FF5A5F?style=for-the-badge&logo=qameta&logoColor=white" alt="Allure Report" />
  <img src="https://img.shields.io/badge/GitHub_Actions-CI-2088FF?style=for-the-badge&logo=githubactions&logoColor=white" alt="GitHub Actions" />
  <img src="https://img.shields.io/badge/AspectJ-Weaver-A9225C?style=for-the-badge&logo=java&logoColor=white" alt="AspectJ" />
  <img src="https://img.shields.io/badge/Jackson-JSON-black?style=for-the-badge&logo=json&logoColor=white" alt="Jackson" />
</p>

---

## What EPMS Is

A two-module Maven reactor, both modules pinned to **JDK 21** via `maven-toolchains-plugin`:

| Module | What it is |
|---|---|
| `payroll-backend` | Spring Boot 3.5.5 REST API — employees, payroll calculation/payslips, time clock, W-2s, YTD tax withholding, GL journal/account balances, audit log, BCrypt auth, health check. MySQL in production, H2 in-memory for the `test` profile. |
| `javafx-desktop` | A native JavaFX desktop client consuming that API — login, dashboard, employee CRUD, payroll calculator, time clock — packaged as a standalone app via `jpackage`. |

### Backend REST surface

| Domain | Endpoints | Controller |
|---|---|---|
| Auth | `POST /api/auth/login` | `AuthController` |
| Employees | `GET/POST /api/employees`, `GET/PUT/DELETE /api/employees/{id}`, `PATCH /api/employees/{id}/status` | `EmployeeController` |
| Payroll | `POST /api/payroll/calculate`, `POST /api/payroll/save`, `GET /api/payroll`, `GET /api/payroll/employee/{id}`, `PATCH .../status`, `.../void`, `.../reverse` | `PayrollController` |
| Time Clock | `POST /api/time-entries/clock-in`, `POST /api/time-entries/{id}/clock-out`, `GET /api/time-entries`, `GET /api/time-entries/employee/{id}` | `TimeClockController` |
| W-2 | `GET /api/w2/{employeeId}/{year}`, `GET /api/w2/year/{year}` | `W2Controller` |
| Tax | `GET /api/tax/ytd/{employeeId}`, `GET /api/tax/ytd-all` | `TaxController` |
| Accounting | `GET /api/accounting/journal`, `GET /api/accounting/balances` | `AccountingController` |
| Audit | `GET /api/audit`, `GET /api/audit/entity` | `AuditController` |
| Health | `GET /api/health` | `HealthController` |

Every write path runs through a service layer (`EmployeeService`, `PayrollService`, `TimeClockService`, `AuthService`, `W2Service`, `TaxAccountingService`, `PayrollAccountingService`, `AuditLogService`) backed by 8 Spring Data JPA repositories, and every 4xx-worthy failure — unknown resource, a business-rule conflict (double clock-in, voiding an already-processed payroll), bad credentials, a constraint violation — is normalized by a global `@RestControllerAdvice` (`GlobalExceptionHandler`) into a consistent `{timestamp, status, error, message}` JSON body, instead of leaking a raw 500.

---

## Test Architecture — 79 automated tests, 0 manual steps

Like a mature QA suite, this isn't one style of test bolted on — it's layered, matching each layer of the app to the cheapest test that can catch its bugs.

| Layer | What it proves | Tooling | Count |
|---|---|---|---|
| Unit — payroll math | Gross pay, OT/doubletime, 401(k)/Roth %, tax withholding math is correct in isolation | JUnit 5 | `PayrollCalculatorTest` — 4 |
| Unit — security | Token issuance/validation | JUnit 5 | `TokenServiceTest` — 4 |
| Unit — services (mocked repos) | Business rules in isolation from Spring/DB: clock-in/out state machine, payroll void/reverse rules, W-2/tax aggregation, auth failure paths | JUnit 5 + Mockito | 7 classes — 30 |
| Integration / API (positive + negative) | Full Spring context + real JPA/Hibernate/SQL (H2) through `MockMvc`, asserting real HTTP status codes — including the 404/409/401/400 paths the `GlobalExceptionHandler` produces | JUnit 5 + Spring `MockMvc` + H2 | 9 classes — 29 |
| UI automation (headless) | Every JavaFX screen driven like a real user — clicking, typing, selecting, dismissing validation alerts — with the real screens and a mocked API client | JUnit 5 + TestFX + Monocle | 5 classes — 12 |
| **Total** | | | **79** |

**Backend (67 — `payroll-backend/src/test`)**

| Class | Tests | Class | Tests |
|---|---|---|---|
| `EmployeeApiTest` | 5 | `EmployeeServiceTest` | 6 |
| `PayrollApiTest` | 4 | `PayrollServiceTest` | 5 |
| `TimeClockApiTest` | 4 | `TimeClockServiceTest` | 5 |
| `AuthApiTest` | 3 | `AuthServiceTest` | 4 |
| `W2ApiTest` | 3 | `W2ServiceTest` | 4 |
| `TaxApiTest` | 3 | `TaxAccountingServiceTest` | 4 |
| `AccountingApiTest` | 3 | `PayrollAccountingServiceTest` | 2 |
| `AuditApiTest` | 3 | `TokenServiceTest` | 4 |
| `HealthApiTest` | 1 | `PayrollCalculatorTest` | 4 |

**Desktop UI (12 — `javafx-desktop/src/test`)**

| Class | Tests | Covers |
|---|---|---|
| `LoginViewTest` | 2 | Valid/invalid login |
| `DashboardViewTest` | 3 | Navigation to Employees/Payroll/Time Clock, Back |
| `EmployeeViewTest` | 3 | Table load, add/save with validation, required-field validation alert |
| `PayrollViewTest` | 2 | Calculate → enables Save Payslip; validation when no employee selected |
| `TimeClockViewTest` | 2 | Clock-in flow; error alert when history fails to load |

Positive and negative cases are tagged (`@Tag("positive")` / `@Tag("negative")`) throughout, so either can be filtered and run independently.

---

## CI/CD & Reporting

- **GitHub Actions** (`.github/workflows/ci.yml`) — on every push/PR to `main`/`master`: sets up JDK 21 (Temurin, with Maven's toolchain auto-generated), runs `payroll-backend` then `javafx-desktop` tests headlessly (Monocle — **no Xvfb needed**, even for the JavaFX UI tests), generates the Allure HTML report, publishes a JUnit test-result summary via `mikepenz/action-junit-report`, and uploads both the Allure site and raw results as build artifacts.
- **Allure** — both modules emit `allure-results` (via `allure-jupiter`); merge the two into one folder to see all 79 tests — backend and desktop — in a single report:
  ```bash
  mkdir -p combined-allure-results
  cp payroll-backend/target/allure-results/*  combined-allure-results/
  cp javafx-desktop/target/allure-results/*   combined-allure-results/
  payroll-backend/.allure/allure-2.30.0/bin/allure serve combined-allure-results
  ```
  Or, per module: `mvn allure:serve` (opens immediately) or `mvn allure:report` (writes to `target/site/allure-maven-plugin/index.html`).

---

## Running It Locally

### 1. Database
Install MySQL 8.x and run `database/schema.sql`. (Tests never touch this — they run against an in-memory H2 database under the `test` Spring profile.)

### 2. Configure the backend
`payroll-backend/src/main/resources/application.properties`:
```properties
spring.datasource.password=YOUR_MYSQL_PASSWORD
```

### 3. Build & test everything
```bash
mvn clean test          # from the repo root — runs both modules, 79 tests
```

### 4. Run the backend
```bash
mvn -pl payroll-backend spring-boot:run
```
API: `http://localhost:8080/api/health`. First boot seeds `admin` / `admin123` — **change this before any real use.**

### 5. Run the JavaFX client
```bash
mvn -pl javafx-desktop javafx:run
```

### 6. Package the desktop app
After a successful build, package with `jpackage` using a bundled JDK 21 runtime — see `scripts/package-windows.ps1`.

---

## How This Compares to a Pure Test-Automation Project (e.g. OrangeHRM Payroll Automation)

Both projects are QA/SDET portfolio work from the same author, and they're deliberately complementary rather than duplicates:

| | **EPMS (this repo)** | **OrangeHRM Payroll Automation** |
|---|---|---|
| System under test | A real application **built from scratch** in this same repo (Spring Boot + MySQL + JavaFX) | An existing third-party HRM demo (OrangeHRM) plus a locally stubbed payroll/tax API |
| What it demonstrates | Full-stack delivery *and* the test strategy for it — API design, exception handling, persistence, a desktop UI, and 79 tests across every layer | Pure black-box test-automation craft against a system you don't own or control |
| UI automation | JavaFX desktop via TestFX/Monocle, fully headless | Web UI via Selenium/Cucumber BDD against a live browser |
| API testing | Spring `MockMvc` against the real controllers/services/JPA layer in-process | REST Assured against real HTTP endpoints (in-process app + external demo) |
| Test types covered | Unit → service (mocked) → integration/API → UI, each mapped to its cheapest layer | Smoke, sanity, regression, positive/negative, data-driven, mobile (Appium), performance (JMeter) |
| Language/stack | Java 21, JUnit 5, Mockito, TestFX | Java 11, TestNG, Cucumber, REST Assured, Appium, JMeter |
| CI/reporting | GitHub Actions + Allure (both modules merged into one report) | GitHub Actions + Allure |

Read together, the two repos show the same engineer on both sides of the fence: building the product and the tests for it here, and rigorously automating against someone else's product there.

---

## Reference Payroll Calculation

The payroll calculator screen's demo defaults reproduce a known reference paystub's gross/net figures for regression-checking the math:

- Hourly $18.55 · Regular 40h · Doubletime 8h @ 2× · Extra $3 × 40h · Extra $6 × 8h
- Health $82.34 · Traditional 401(k) 5% + 1% catch-up · Roth 1% + 1% catch-up

> **Note:** the fixed-percentage federal withholding used here is a *demo* stand-in. A real payroll product must compute federal withholding from the applicable IRS/W-4 withholding tables and their effective dates, not a flat percentage.

---

## Project Structure

```
EPMS/
├── payroll-backend/          Spring Boot REST API
│   ├── src/main/java/com/epms/payroll/
│   │   ├── controller/       9 REST controllers
│   │   ├── service/          Business logic (8 services)
│   │   ├── repository/       8 Spring Data JPA repositories
│   │   ├── entity/           JPA entities
│   │   └── exception/        GlobalExceptionHandler + typed exceptions
│   └── src/test/java/com/epms/payroll/
│       ├── integration/      9 MockMvc API test classes (29 tests)
│       ├── service/          7 mocked-service unit test classes (30 tests)
│       └── security/         TokenServiceTest (4 tests)
├── javafx-desktop/           JavaFX client
│   ├── src/main/java/com/epms/desktop/ui/   Login, Dashboard, Employee, Payroll, Time Clock views
│   └── src/test/java/com/epms/desktop/ui/   5 TestFX/Monocle headless UI test classes (12 tests)
├── database/schema.sql
├── scripts/package-windows.ps1
└── .github/workflows/ci.yml
```

---

## License

Personal portfolio / demonstration project. Not licensed for production use as-is — see the withholding-tax note above.
