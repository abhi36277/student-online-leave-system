<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.project.model.Student" %>
<%@ page import="com.project.util.DBConnection" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null || !"student".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("login.jsp?errorMsg=Unauthorized access.");
        return;
    }
    Student student = (Student) userSession.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave History - Online Leave Portal</title>
    <link rel="stylesheet" href="css/dashboard.css">
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
                    <a href="applyLeave.jsp" class="menu-item">
                        <span>📝</span> Apply Leave
                    </a>
                    <a href="leaveStatus.jsp" class="menu-item active">
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
                
                <div class="glass-card">
                    <h2 class="section-title" style="font-size: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 12px; margin-bottom: 24px;">My Leave Applications</h2>
                    
                    <% 
                        String successMsg = request.getParameter("successMsg");
                        if (successMsg != null) {
                    %>
                        <div class="alert-message alert-success"><%= successMsg %></div>
                    <% } %>

                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Leave ID</th>
                                    <th>From Date</th>
                                    <th>To Date</th>
                                    <th>Reason for Leave</th>
                                    <th>Approval Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    Connection conn = DBConnection.getConnection();
                                    if (conn != null) {
                                        String sql = "SELECT * FROM leave_request WHERE student_usn = ? ORDER BY leave_id DESC";
                                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                            ps.setString(1, student.getUsn());
                                            ResultSet rs = ps.executeQuery();
                                            boolean hasRecords = false;
                                            
                                            while (rs.next()) {
                                                hasRecords = true;
                                                int leaveId = rs.getInt("leave_id");
                                                String fromDate = rs.getString("from_date");
                                                String toDate = rs.getString("to_date");
                                                String reason = rs.getString("reason");
                                                String status = rs.getString("status");
                                                
                                                String badgeClass = "badge-pending";
                                                if ("APPROVED".equalsIgnoreCase(status)) badgeClass = "badge-approved";
                                                else if ("REJECTED".equalsIgnoreCase(status)) badgeClass = "badge-rejected";
                                %>
                                                <tr>
                                                    <td>#<%= leaveId %></td>
                                                    <td><%= fromDate %></td>
                                                    <td><%= toDate %></td>
                                                    <td><%= reason %></td>
                                                    <td>
                                                        <span class="badge <%= badgeClass %>"><%= status %></span>
                                                    </td>
                                                </tr>
                                <%
                                            }
                                            if (!hasRecords) {
                                %>
                                                <tr>
                                                    <td colspan="5" style="text-align: center; color: var(--text-secondary);">No leave applications found.</td>
                                                </tr>
                                <%
                                            }
                                        } catch (SQLException e) {
                                            out.println("<tr><td colspan='5' style='color:var(--danger);'>Database Error: " + e.getMessage() + "</td></tr>");
                                        } finally {
                                            conn.close();
                                        }
                                    } else {
                                        out.println("<tr><td colspan='5' style='color:var(--danger);'>Database connection down.</td></tr>");
                                    }
                                %>
                            </tbody>
                        </table>
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
