<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Registration</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <script>
        // Client Side Validation
        function validateForm() {
            var name = document.getElementById("name").value;
            var usn = document.getElementById("usn").value;
            var email = document.getElementById("email").value;
            var password = document.getElementById("password").value;

            if (name.trim() === "" || usn.trim() === "" || email.trim() === "" || password.trim() === "") {
                showToast("All fields must be filled out!", "danger");
                return false;
            }
            if (usn.trim().length < 5) {
                showToast("Please enter a valid USN.", "danger");
                return false;
            }
            var emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
            if (!emailPattern.test(email)) {
                showToast("Please enter a valid email address.", "danger");
                return false;
            }
            if (password.length < 6) {
                showToast("Password must be at least 6 characters long.", "danger");
                return false;
            }
            return true;
        }
    </script>
</head>
<body class="auth-wrapper">

    <div class="glass-card auth-card card-primary">
        <div class="auth-header">
            <h2 class="auth-title">Student Registration</h2>
            <p class="auth-subtitle">Create a new student profile</p>
        </div>
        
        <% 
            String errorMsg = (String) request.getAttribute("errorMsg");
            if (errorMsg != null) {
        %>
            <div class="alert-message alert-error"><%= errorMsg %></div>
        <% } %>

        <form action="RegisterServlet" method="post" onsubmit="return validateForm()">
            <div class="form-group">
                <label for="name">Full Name</label>
                <input type="text" id="name" name="name" class="form-control" required placeholder="e.g. Rahul Kumar">
            </div>
            
            <div class="form-group">
                <label for="usn">USN (University Seat Number)</label>
                <input type="text" id="usn" name="usn" class="form-control" required placeholder="e.g. 1SG24CS001">
            </div>
            
            <div class="form-group">
                <label for="email">College Email ID</label>
                <input type="email" id="email" name="email" class="form-control" required placeholder="e.g. rahul@gmail.com">
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control" required placeholder="Min 6 characters">
            </div>
            
            <button type="submit" class="btn-submit">Register</button>
        </form>
        
        <div class="auth-footer-links">
            Already registered? <a href="login.jsp">Login Here</a>
            <br><br>
            <a href="index.jsp" style="color: var(--text-secondary);">Back to Home</a>
        </div>
    </div>

    <script src="js/dashboard.js"></script>
</body>
</html>
