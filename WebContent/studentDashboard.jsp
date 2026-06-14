<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.Student" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, com.project.util.DBConnection" %>
<%
    // Session Tracking validation
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null || !"student".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("login.jsp?errorMsg=Please log in to access the dashboard.");
        return;
    }
    Student student = (Student) userSession.getAttribute("user");

    // Handle Password Change Form POST
    String postAction = request.getParameter("action");
    String successPasswordMsg = null;
    String errorPasswordMsg = null;
    if ("updatePassword".equals(postAction)) {
        String newPassword = request.getParameter("newPassword");
        if (newPassword != null && newPassword.trim().length() >= 6) {
            Connection passConn = null;
            PreparedStatement passPs = null;
            try {
                passConn = DBConnection.getConnection();
                String updateQuery = "UPDATE student SET password = ? WHERE usn = ?";
                passPs = passConn.prepareStatement(updateQuery);
                passPs.setString(1, newPassword);
                passPs.setString(2, student.getUsn());
                int updated = passPs.executeUpdate();
                if (updated > 0) {
                    successPasswordMsg = "Password updated successfully!";
                } else {
                    errorPasswordMsg = "Failed to update password. Try again.";
                }
            } catch(Exception e) {
                e.printStackTrace();
                errorPasswordMsg = "Database error occurred.";
            } finally {
                if (passPs != null) try { passPs.close(); } catch(Exception e){}
                if (passConn != null) try { passConn.close(); } catch(Exception e){}
            }
        } else {
            errorPasswordMsg = "Password must be at least 6 characters long.";
        }
    }

    // Fetch stats and history from DB
    int totalApplied = 0;
    int approved = 0;
    int pending = 0;
    int rejected = 0;
    int[] monthlyTrends = new int[12];
    
    Connection conn = null;
    PreparedStatement psStats = null;
    PreparedStatement psHistory = null;
    PreparedStatement psTrends = null;
    ResultSet rsStats = null;
    ResultSet rsHistory = null;
    ResultSet rsTrends = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // 1. Fetch counts
        String statsQuery = "SELECT COUNT(*) as total, " +
                             "SUM(CASE WHEN status = 'APPROVED' THEN 1 ELSE 0 END) as approved, " +
                             "SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) as pending, " +
                             "SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END) as rejected " +
                             "FROM leave_request WHERE student_usn = ?";
        psStats = conn.prepareStatement(statsQuery);
        psStats.setString(1, student.getUsn());
        rsStats = psStats.executeQuery();
        if (rsStats.next()) {
            totalApplied = rsStats.getInt("total");
            approved = rsStats.getInt("approved");
            pending = rsStats.getInt("pending");
            rejected = rsStats.getInt("rejected");
        }

        // 2. Fetch monthly trends
        String trendsQuery = "SELECT MONTH(from_date) as m, COUNT(*) as cnt " +
                             "FROM leave_request WHERE student_usn = ? AND YEAR(from_date) = YEAR(CURDATE()) " +
                             "GROUP BY MONTH(from_date)";
        psTrends = conn.prepareStatement(trendsQuery);
        psTrends.setString(1, student.getUsn());
        rsTrends = psTrends.executeQuery();
        while (rsTrends.next()) {
            int m = rsTrends.getInt("m");
            if (m >= 1 && m <= 12) {
                monthlyTrends[m - 1] = rsTrends.getInt("cnt");
            }
        }
    } catch(Exception e) {
        e.printStackTrace();
    }
    
    StringBuilder trendsSb = new StringBuilder();
    for (int i = 0; i < 12; i++) {
        trendsSb.append(monthlyTrends[i]);
        if (i < 11) trendsSb.append(",");
    }
    String studentTrendsStr = trendsSb.toString();
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - Online Leave Portal</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                    <a href="studentDashboard.jsp" class="menu-item active">
                        <span>📊</span> Dashboard
                    </a>
                    <a href="applyLeave.jsp" class="menu-item">
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
                
                <!-- Welcome Card -->
                <div class="glass-card card-primary" style="padding: 28px;">
                    <h2 style="font-size: 22px; font-weight: 700; margin-bottom: 6px; letter-spacing: -0.5px;">Welcome Back, <%= student.getName() %>!</h2>
                    <p style="color: var(--text-secondary); font-size: 14px;">USN: <strong><%= student.getUsn() %></strong> | Email: <strong><%= student.getEmail() %></strong></p>
                </div>

                <!-- Statistics Grid -->
                <section class="stats-grid">
                    <div class="glass-card stat-card">
                        <div class="stat-header">
                            <span class="stat-title">Total Applications</span>
                            <span class="stat-icon icon-blue">📋</span>
                        </div>
                        <span class="stat-value"><%= totalApplied %></span>
                        <div class="stat-footer">
                            <span class="trend-indicator trend-up">↑ 100%</span> applied history
                        </div>
                    </div>
                    
                    <div class="glass-card stat-card">
                        <div class="stat-header">
                            <span class="stat-title">Approved Leaves</span>
                            <span class="stat-icon icon-green">✅</span>
                        </div>
                        <span class="stat-value"><%= approved %></span>
                        <div class="stat-footer">
                            <span class="trend-indicator trend-up">↑ <%= totalApplied > 0 ? (approved * 100 / totalApplied) : 0 %>%</span> approval rate
                        </div>
                    </div>
                    
                    <div class="glass-card stat-card">
                        <div class="stat-header">
                            <span class="stat-title">Pending Requests</span>
                            <span class="stat-icon icon-orange">⏳</span>
                        </div>
                        <span class="stat-value"><%= pending %></span>
                        <div class="stat-footer">
                            Currently under review
                        </div>
                    </div>
                    
                    <div class="glass-card stat-card">
                        <div class="stat-header">
                            <span class="stat-title">Rejected Requests</span>
                            <span class="stat-icon icon-red">❌</span>
                        </div>
                        <span class="stat-value"><%= rejected %></span>
                        <div class="stat-footer">
                            Declined leave applications
                        </div>
                    </div>
                </section>

                <!-- Two Column Dashboard Grid -->
                <div class="dashboard-columns">
                    
                    <!-- Left: Analytics and Table -->
                    <div style="display: flex; flex-direction: column; gap: 30px;">
                        
                        <!-- Analytics Charts -->
                        <div class="glass-card">
                            <h3 class="section-title">Leave Analytics</h3>
                            <div class="analytics-grid">
                                <div class="chart-container">
                                    <canvas id="leaveTrendChart" data-trends="<%= studentTrendsStr %>"></canvas>
                                </div>
                                <div class="chart-container">
                                    <!-- Send Approved/Pending/Rejected counts to chart via attributes -->
                                    <canvas id="leaveDistributionChart" 
                                            data-approved="<%= approved %>" 
                                            data-pending="<%= pending %>" 
                                            data-rejected="<%= rejected %>"></canvas>
                                </div>
                            </div>
                        </div>

                        <!-- Recent Leave History Table -->
                        <div class="glass-card">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                                <h3 class="section-title" style="margin-bottom: 0;">Recent Leave Applications</h3>
                                <a href="leaveStatus.jsp" style="font-size: 13px; color: var(--primary); text-decoration: none; font-weight: 600;">View All →</a>
                            </div>
                            <div class="table-responsive">
                                <table class="custom-table">
                                    <thead>
                                        <tr>
                                            <th>Leave ID</th>
                                            <th>Date Range</th>
                                            <th>Reason</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            try {
                                                String historyQuery = "SELECT leave_id, from_date, to_date, reason, status FROM leave_request WHERE student_usn = ? ORDER BY leave_id DESC LIMIT 4";
                                                psHistory = conn.prepareStatement(historyQuery);
                                                psHistory.setString(1, student.getUsn());
                                                rsHistory = psHistory.executeQuery();
                                                
                                                boolean hasHistory = false;
                                                while (rsHistory.next()) {
                                                    hasHistory = true;
                                                    int id = rsHistory.getInt("leave_id");
                                                    String fromDate = rsHistory.getString("from_date");
                                                    String toDate = rsHistory.getString("to_date");
                                                    String reason = rsHistory.getString("reason");
                                                    String status = rsHistory.getString("status");
                                                    
                                                    String badgeClass = "badge-pending";
                                                    if ("APPROVED".equalsIgnoreCase(status)) badgeClass = "badge-approved";
                                                    else if ("REJECTED".equalsIgnoreCase(status)) badgeClass = "badge-rejected";
                                        %>
                                            <tr>
                                                <td>#<%= id %></td>
                                                <td><%= fromDate %> to <%= toDate %></td>
                                                <td><%= reason.length() > 30 ? reason.substring(0, 27) + "..." : reason %></td>
                                                <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                                            </tr>
                                        <%
                                                }
                                                if (!hasHistory) {
                                        %>
                                            <tr>
                                                <td colspan="4" style="text-align: center; color: var(--text-secondary);">No leave requests found.</td>
                                            </tr>
                                        <%
                                                }
                                            } catch (Exception e) {
                                                e.printStackTrace();
                                            } finally {
                                                if (rsHistory != null) try { rsHistory.close(); } catch (Exception e) {}
                                                if (psHistory != null) try { psHistory.close(); } catch (Exception e) {}
                                                if (rsStats != null) try { rsStats.close(); } catch (Exception e) {}
                                                if (psStats != null) try { psStats.close(); } catch (Exception e) {}
                                                if (rsTrends != null) try { rsTrends.close(); } catch (Exception e) {}
                                                if (psTrends != null) try { psTrends.close(); } catch (Exception e) {}
                                                if (conn != null) try { conn.close(); } catch (Exception e) {}
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                    </div>

                    <!-- Right: Quick Actions & Notification Panel -->
                    <div style="display: flex; flex-direction: column; gap: 30px;">
                        
                        <!-- Quick Actions -->
                        <div class="glass-card">
                            <h3 class="section-title">Quick Actions</h3>
                            <div class="quick-actions-grid">
                                <a href="applyLeave.jsp" class="action-card">
                                    <span class="action-icon">📝</span>
                                    <span class="action-title">Apply Leave</span>
                                </a>
                                <a href="leaveStatus.jsp" class="action-card">
                                    <span class="action-icon">📜</span>
                                    <span class="action-title">View History</span>
                                </a>
                            </div>
                        </div>

                        <!-- Notification Panel -->
                        <div class="glass-card">
                            <h3 class="section-title">Notifications</h3>
                            <div class="notification-list">
                                <%
                                    PreparedStatement psNoti = null;
                                    ResultSet rsNoti = null;
                                    Connection notiConn = null;
                                    try {
                                        notiConn = DBConnection.getConnection();
                                        String notiQuery = "SELECT leave_id, from_date, to_date, status FROM leave_request WHERE student_usn = ? ORDER BY leave_id DESC LIMIT 3";
                                        psNoti = notiConn.prepareStatement(notiQuery);
                                        psNoti.setString(1, student.getUsn());
                                        rsNoti = psNoti.executeQuery();
                                        
                                        boolean hasNoti = false;
                                        while (rsNoti.next()) {
                                            hasNoti = true;
                                            int notiLeaveId = rsNoti.getInt("leave_id");
                                            String notiFrom = rsNoti.getString("from_date");
                                            String notiTo = rsNoti.getString("to_date");
                                            String notiStatus = rsNoti.getString("status");
                                            
                                            String notiText = "";
                                            String notiBulletClass = "noti-bullet";
                                            
                                            if ("APPROVED".equalsIgnoreCase(notiStatus)) {
                                                notiText = "Your leave request #" + notiLeaveId + " (" + notiFrom + " to " + notiTo + ") has been APPROVED.";
                                                notiBulletClass += " noti-success";
                                            } else if ("REJECTED".equalsIgnoreCase(notiStatus)) {
                                                notiText = "Your leave request #" + notiLeaveId + " (" + notiFrom + " to " + notiTo + ") has been REJECTED.";
                                                notiBulletClass += " noti-danger";
                                            } else {
                                                notiText = "Your leave request #" + notiLeaveId + " (" + notiFrom + " to " + notiTo + ") is PENDING review.";
                                                notiBulletClass += " noti-warning";
                                            }
                                %>
                                        <div class="notification-item">
                                            <div class="<%= notiBulletClass %>"></div>
                                            <div class="noti-content">
                                                <span class="noti-text"><%= notiText %></span>
                                                <span class="noti-time">System Update</span>
                                            </div>
                                        </div>
                                <%
                                        }
                                        if (!hasNoti) {
                                %>
                                        <div class="notification-item">
                                            <div class="noti-bullet"></div>
                                            <div class="noti-content">
                                                <span class="noti-text">No recent notifications. Apply for a leave to get started.</span>
                                                <span class="noti-time">Now</span>
                                            </div>
                                        </div>
                                <%
                                        }
                                    } catch(Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        if (rsNoti != null) try { rsNoti.close(); } catch(Exception e){}
                                        if (psNoti != null) try { psNoti.close(); } catch(Exception e){}
                                        if (notiConn != null) try { notiConn.close(); } catch(Exception e){}
                                    }
                                %>
                            </div>
                        </div>
                        
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
            <form method="post" action="studentDashboard.jsp" style="margin-top: 10px;">
                <input type="hidden" name="action" value="updatePassword">
                <div class="form-group">
                    <label for="newPassword">Change Password</label>
                    <input type="password" id="newPassword" name="newPassword" class="form-control" placeholder="Enter new password" required minlength="6">
                </div>
                <button type="submit" class="btn-submit" style="margin-top: 8px;">Update Password</button>
            </form>
        </div>
    </div>

    <!-- Central Script -->
    <script src="js/dashboard.js"></script>

    <!-- Trigger Toast notifications for Password Update -->
    <% if (successPasswordMsg != null) { %>
        <script>
            document.addEventListener("DOMContentLoaded", () => {
                showToast("<%= successPasswordMsg %>", "success");
            });
        </script>
    <% } else if (errorPasswordMsg != null) { %>
        <script>
            document.addEventListener("DOMContentLoaded", () => {
                showToast("<%= errorPasswordMsg %>", "danger");
            });
        </script>
    <% } %>
</body>
</html>
