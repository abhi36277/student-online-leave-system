<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Online Leave Application System</title>
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body class="welcome-container">

    <div class="welcome-card">
        <div class="welcome-logo">🚀</div>
        <h1 class="welcome-title">Online Leave Portal</h1>
        <p class="welcome-subtitle">Advanced Java Mini Project (4th Semester)</p>
        
        <%
            String successMsg = request.getParameter("successMsg");
            if (successMsg != null) {
        %>
            <div class="alert-message alert-success">
                <%= successMsg %>
            </div>
        <% } %>

        <div class="portal-links">
            <a href="login.jsp" class="btn-portal btn-student">
                <span>👨‍🎓</span> Student Portal
            </a>
            <a href="adminLogin.jsp" class="btn-portal btn-admin">
                <span>🛡️</span> Admin / Faculty Portal
            </a>
        </div>
        
        <div class="welcome-footer">
            Developed with Java Servlets, JSP & MySQL
        </div>
    </div>

    <script src="js/dashboard.js"></script>
</body>
</html>
