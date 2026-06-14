<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Login</title>
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body class="auth-wrapper">

    <div class="glass-card auth-card card-primary">
        <div class="auth-header">
            <h2 class="auth-title">Student Login</h2>
            <p class="auth-subtitle">Access your student dashboard</p>
        </div>
        
        <!-- Display Dynamic Error Message -->
        <% 
            String errorMsg = (String) request.getAttribute("errorMsg");
            if (errorMsg != null) {
        %>
            <div class="alert-message alert-error"><%= errorMsg %></div>
        <% } %>
        
        <!-- Display Redirect Success Message -->
        <% 
            String successMsg = request.getParameter("successMsg");
            if (successMsg != null) {
        %>
            <div class="alert-message alert-success"><%= successMsg %></div>
        <% } %>

        <form action="LoginServlet" method="post">
            <div class="form-group">
                <label for="username">USN or Email</label>
                <input type="text" id="username" name="username" class="form-control" required placeholder="Enter USN or Email">
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control" required placeholder="Enter password">
            </div>
            
            <button type="submit" class="btn-submit">Login</button>
        </form>
        
        <div class="auth-footer-links">
            Don't have an account? <a href="register.jsp">Register Here</a>
            <br><br>
            <a href="index.jsp" style="color: var(--text-secondary);">Back to Home</a>
        </div>
    </div>

    <script src="js/dashboard.js"></script>
</body>
</html>
