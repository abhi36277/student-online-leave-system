# Student Online Leave Application System

## Project Overview

The Student Online Leave Application System is a web-based application developed using Java Servlets, JSP, JDBC, MySQL, and Apache Tomcat.

The system allows students to submit leave requests online and enables administrators to review, approve, or reject those requests through a centralized dashboard.

This project eliminates the traditional paper-based leave application process and provides a simple digital solution for leave management.

---

## Features

### Student Module
* Student Registration & Login
* Apply for Leave (with HTML5 automatic calendar toggle)
* View Leave History with color-coded status badges
* Dynamic DB-driven Notification panel
* Profile & Settings modal with password change functionality

### Admin Module
* Admin Login
* Centralized Leave Request Management (Approve/Reject requests)
* College-wide statistics and analytics

### Portal-Wide UX Enhancements
* **Premium UI/UX Design**: Sleek SaaS-like dashboard interface with glassmorphism cards and smooth animations.
* **Light/Dark Theme Switcher**: Sun/Moon toggle next to avatar with persistent user preference using `localStorage`.
* **Interactive Chart.js Analytics**: Animated monthly leave trend line graphs and status distribution doughnut charts.
* **Real-time Clock**: Date & time display updated in the top navigation bar.
* **Responsive Layout**: Fluid media queries supporting full-screen monitors, standard laptops, side-by-side split screens, down to tablet and mobile screens with off-screen toggling sidebar.
* **Toast Status Notifications**: Elegant sliding animations for servlet updates.
* **Animated Logout**: Custom exit hover micro-animations.

---

## Technologies Used

### Frontend

* HTML
* CSS
* JavaScript
* JSP

### Backend

* Java Servlets
* JDBC

### Database

* MySQL

### Server

* Apache Tomcat 9

### Development Tools

* Visual Studio Code
* JDK 25

---

## Project Structure

```text
src/
├── com/project/
│   ├── model/           # Data Models (Student, LeaveRequest)
│   ├── servlet/         # Business Logic Servlets (Login, Register, LeaveServlet)
│   └── util/            # Utilities (DBConnection)

WebContent/
├── css/                 # Premium Dashboard styling (dashboard.css)
├── js/                  # Charts & UX JavaScript (dashboard.js)
├── WEB-INF/             # Web configuration (web.xml) & Libraries (lib/)
└── *.jsp                # View templates (Dashboard, Apply Leave, Login)

init_db.sql              # Database initialization schema
compile_project.ps1      # Java compiler execution script
run_project.ps1          # Main project startup orchestrator
start_mysql.ps1          # Database launcher script
stop_mysql.ps1           # Database shutdown script
```

## Database Setup

1. Install MySQL Server.
2. Create a database.
3. Execute:

```sql
init_db.sql
```

4. Update database credentials in:

```text
src/com/project/util/DBConnection.java
```

---

## Running and Stopping the Project

All commands should be executed from a **PowerShell** terminal window opened inside the project root folder (`D:\SEMESTER4\Adv_Java\Projects\Java Anti`).

### 🚀 Starting the Project
To start both the MySQL database and the Tomcat web application, run the following single launcher command:

```powershell
powershell -ExecutionPolicy Bypass -File .\run_project.ps1
```

Once the terminal prints `Starting Apache Tomcat in this terminal...`, it will launch the application automatically in your default browser at **http://localhost:8080/**.

### 🛑 Stopping the Project
1. **Stop Web Server (Tomcat)**: Press `Ctrl + C` in the PowerShell window running Tomcat (type `Y` and press `Enter` if prompted).
2. **Stop Database (MySQL)**: Run the following shutdown command to close the background MySQL server:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\stop_mysql.ps1
   ```

---

## Main Functionalities

* User Authentication
* Leave Request Submission
* Leave Status Tracking
* Leave Approval Workflow
* Database Connectivity using JDBC
* Session Management

---

## Future Enhancements

* Email Notifications
* Leave Balance Management
* PDF Leave Reports
* Role-Based Access Control
* Attendance Integration

---

## Author

Abhishek Ranjan
Sir M. Visvesvaraya Institute of Technology (Sir MVIT)
---
