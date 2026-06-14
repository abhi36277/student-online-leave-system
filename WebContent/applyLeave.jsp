<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.Student" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null || !"student".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("login.jsp?errorMsg=Unauthorized. Please log in.");
        return;
    }
    Student student = (Student) userSession.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply Leave - Online Leave Portal</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <script>
        // Check date logic
        function checkDates() {
            var from = new Date(document.getElementById("fromDate").value);
            var to = new Date(document.getElementById("toDate").value);
            var today = new Date();
            today.setHours(0,0,0,0);

            if (from < today) {
                showToast("From date cannot be in the past!", "danger");
                return false;
            }
            if (from > to) {
                showToast("From date cannot be greater than To date!", "danger");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>

    <div class="app-container">
        
        <!-- Left Sidebar -->
        <aside class="sidebar">
            <div class="sidebar-top">
                <div class="brand-section">
                    <div class="brand-logo">LP</div>
                    <span class="brand-name">LeavePortal</span>
                </div>
                
                <nav class="menu-group">
                    <span class="menu-title">Main Menu</span>
                    <a href="studentDashboard.jsp" class="menu-item">
                        <span>📊</span> Dashboard
                    </a>
                    <a href="applyLeave.jsp" class="menu-item active">
                        <span>📝</span> Apply Leave
                    </a>
                    <a href="leaveStatus.jsp" class="menu-item">
                        <span>📜</span> Leave History
                    </a>
                </nav>

                <nav class="menu-group">
                    <span class="menu-title">Account</span>
                    <a href="#" class="menu-item" onclick="openModal('profileModal')">
                        <span>👤</span> Profile
                    </a>
                    <a href="#" class="menu-item" onclick="openModal('settingsModal')">
                        <span>⚙️</span> Settings
                    </a>
                </nav>
            </div>
            
            <div class="sidebar-footer">
                <a href="LogoutServlet" class="menu-item logout-btn">
                    <span>🚪</span> Logout
                </a>
            </div>
        </aside>

        <!-- Main Content Area -->
        <main class="main-content">
            
            <!-- Top Navbar -->
            <header class="navbar">
                <button class="menu-toggle" id="mobile-menu-toggle" aria-label="Toggle Menu">
                    <span></span>
                    <span></span>
                    <span></span>
                </button>
                <div class="search-box">
                    <span>🔍</span>
                    <input type="text" placeholder="Search dashboard...">
                </div>
                
                <div class="navbar-right">
                    <div class="time-display" id="current-time">Loading date & time...</div>
                    
                    <!-- Dark/Light Toggle Switch -->
                    <div class="theme-switch-wrapper">
                        <span class="theme-icon">☀️</span>
                        <label class="theme-switch" for="checkbox">
                            <input type="checkbox" id="checkbox" />
                            <div class="slider"></div>
                        </label>
                        <span class="theme-icon">🌙</span>
                    </div>
                    
                    <div class="avatar" title="<%= student.getName() %>">
                        <%= student.getName().substring(0, Math.min(2, student.getName().length())).toUpperCase() %>
                    </div>
                </div>
            </header>

            <!-- Dashboard Body -->
            <div class="dashboard-body">
                
                <div style="max-width: 650px; margin: 0 auto; width: 100%;">
                    
                    <div class="glass-card card-primary">
                        <h2 class="section-title" style="font-size: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 12px; margin-bottom: 24px;">New Leave Application</h2>

                        <% 
                            String errorMsg = (String) request.getAttribute("errorMsg");
                            if (errorMsg != null) {
                        %>
                            <div class="alert-message alert-error"><%= errorMsg %></div>
                        <% } %>

                        <form action="LeaveServlet" method="post" onsubmit="return checkDates()">
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="fromDate">Leave Starting Date (From)</label>
                                    <input type="date" id="fromDate" name="fromDate" class="form-control" required onclick="this.showPicker()">
                                </div>
                                
                                <div class="form-group">
                                    <label for="toDate">Leave Ending Date (To)</label>
                                    <input type="date" id="toDate" name="toDate" class="form-control" required onclick="this.showPicker()">
                                </div>
                            </div>
                            
                            <!-- Additional Leave Type dropdown matching the prompt -->
                            <div class="form-group">
                                <label for="leaveType">Leave Type</label>
                                <select id="leaveType" name="leaveType" class="form-control">
                                    <option value="Sick Leave">Sick Leave</option>
                                    <option value="Casual Leave">Casual Leave</option>
                                    <option value="Personal Leave">Personal Leave</option>
                                    <option value="Official Duty">Official Duty</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="reason">Reason for Leave</label>
                                <textarea id="reason" name="reason" class="form-control" rows="4" required placeholder="Provide clear reason for leave application..."></textarea>
                            </div>
                            
                            <!-- Upload Supporting Document file picker matching prompt -->
                            <div class="form-group">
                                <label>Upload Supporting Document (Optional)</label>
                                <div class="file-upload-wrapper">
                                    <span class="action-icon" style="font-size: 20px; display: block; margin-bottom: 4px;">📂</span>
                                    <span class="file-upload-text">Click or drag file to upload certificate/document</span>
                                    <input type="file" id="document" name="document">
                                </div>
                            </div>
                            
                            <button type="submit" class="btn-submit" style="margin-top: 10px;">Submit Application</button>
                        </form>
                    </div>
                    
                </div>

            </div>

        </main>
        
    </div>

    <!-- Profile Modal -->
    <div id="profileModal" class="modal">
        <div class="modal-content glass-card card-primary">
            <span class="close-btn" onclick="closeModal('profileModal')">&times;</span>
            <h3 class="section-title">My Profile</h3>
            <div style="display: flex; flex-direction: column; gap: 12px; margin-top: 10px;">
                <p><strong>Name:</strong> <%= student.getName() %></p>
                <p><strong>USN:</strong> <%= student.getUsn() %></p>
                <p><strong>Email:</strong> <%= student.getEmail() %></p>
                <p><strong>Account Type:</strong> Student Profile</p>
            </div>
        </div>
    </div>

    <!-- Settings Modal -->
    <div id="settingsModal" class="modal">
        <div class="modal-content glass-card card-primary">
            <span class="close-btn" onclick="closeModal('settingsModal')">&times;</span>
            <h3 class="section-title">Account Settings</h3>
            <div style="margin-top: 10px;">
                <p style="color: var(--text-secondary); font-size: 13px; margin-bottom: 10px;">To update your account settings or password, please do so from the main dashboard home page.</p>
                <a href="studentDashboard.jsp" class="btn-submit" style="display: block; text-decoration: none; text-align: center;">Go to Dashboard Home</a>
            </div>
        </div>
    </div>

    <!-- Central Script -->
    <script src="js/dashboard.js"></script>
</body>
</html>
