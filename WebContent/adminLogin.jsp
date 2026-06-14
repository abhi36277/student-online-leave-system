<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login</title>
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body class="auth-wrapper">

    <div class="glass-card auth-card card-primary">
        <div class="auth-header">
            <h2 class="auth-title">Admin Login</h2>
            <p class="auth-subtitle">Access the administrator console</p>
        </div>
        
        <% 
            String errorMsg = (String) request.getAttribute("errorMsg");
            if (errorMsg != null) {
        %>
            <div class="alert-message alert-error"><%= errorMsg %></div>
        <% } %>

        <form action="AdminLoginServlet" method="post">
            <div class="form-group">
                <label for="username">Admin Username</label>
                <input type="text" id="username" name="username" class="form-control" required placeholder="Enter Username">
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control" required placeholder="Enter Password">
            </div>
            
            <button type="submit" class="btn-submit">Login as Admin</button>
        </form>
        
        <div class="auth-footer-links">
            <a href="index.jsp" style="color: var(--text-secondary);">Back to Portal Home</a>
        </div>
    </div>

    <script src="js/dashboard.js"></script>
</body>
</html>
