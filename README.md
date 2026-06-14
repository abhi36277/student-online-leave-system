# Student Online Leave Application System

## Project Overview

The Student Online Leave Application System is a web-based application developed using Java Servlets, JSP, JDBC, MySQL, and Apache Tomcat.

The system allows students to submit leave requests online and enables administrators to review, approve, or reject those requests through a centralized dashboard.

This project eliminates the traditional paper-based leave application process and provides a simple digital solution for leave management.

---

## Features

### Student Module

* Student Registration
* Student Login
* Apply for Leave
* View Leave History
* Track Leave Status
* Logout

### Admin Module

* Admin Login
* View All Leave Requests
* Approve Leave Requests
* Reject Leave Requests
* Monitor Leave Records

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
├── com.project.model
├── com.project.servlet
└── com.project.util

WebContent/
├── css/
├── js/
├── WEB-INF/
└── *.jsp

init_db.sql
run_project.ps1
compile_project.ps1
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

## Running the Project

### Compile

```powershell
.\compile_project.ps1
```

### Run

```powershell
.\run_project.ps1
```

### Open Browser

```text
http://localhost:8080
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
* Mobile Responsive Design
* PDF Leave Reports
* Role-Based Access Control
* Attendance Integration

---

## Author

Abhishek Ranjan
Sir M. Visvesvaraya Institute of Technology (Sir MVIT)
---
