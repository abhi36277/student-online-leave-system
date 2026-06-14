<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.project.util.DBConnection" %>
<%
    // Session Validation for Admin
    HttpSession adminSession = request.getSession(false);
    if (adminSession == null || adminSession.getAttribute("adminUser") == null || !"admin".equals(adminSession.getAttribute("role"))) {
        response.sendRedirect("adminLogin.jsp?errorMsg=Please log in as an administrator first.");
        return;
    }
    String adminUsername = (String) adminSession.getAttribute("adminUser");

    // Fetch total database stats
    int totalApplied = 0;
    int approved = 0;
    int pending = 0;
    int rejected = 0;
    int studentCount = 0;
    int[] monthlyTrends = new int[12];
    
    Connection conn = null;
    PreparedStatement psStats = null;
    PreparedStatement psStudents = null;
    PreparedStatement psTrends = null;
    ResultSet rsStats = null;
    ResultSet rsStudents = null;
    ResultSet rsTrends = null;
    
    try {
        conn = DBConnection.getConnection();
        
        // 1. Fetch counts
        String statsQuery = "SELECT COUNT(*) as total, " +
                             "SUM(CASE WHEN status = 'APPROVED' THEN 1 ELSE 0 END) as approved, " +
                             "SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) as pending, " +
                             "SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END) as rejected " +
                             "FROM leave_request";
        psStats = conn.prepareStatement(statsQuery);
        rsStats = psStats.executeQuery();
        if (rsStats.next()) {
            totalApplied = rsStats.getInt("total");
            approved = rsStats.getInt("approved");
            pending = rsStats.getInt("pending");
            rejected = rsStats.getInt("rejected");
        }
        
        // 2. Fetch student count
        String studentQuery = "SELECT COUNT(*) as count FROM student";
        psStudents = conn.prepareStatement(studentQuery);
        rsStudents = psStudents.executeQuery();
        if (rsStudents.next()) {
            studentCount = rsStudents.getInt("count");
        }

        // 3. Fetch monthly trends
        String trendsQuery = "SELECT MONTH(from_date) as m, COUNT(*) as cnt " +
                             "FROM leave_request WHERE YEAR(from_date) = YEAR(CURDATE()) " +
                             "GROUP BY MONTH(from_date)";
        psTrends = conn.prepareStatement(trendsQuery);
        rsTrends = psTrends.executeQuery();
        while (rsTrends.next()) {
            int m = rsTrends.getInt("m");
            if (m >= 1 && m <= 12) {
                monthlyTrends[m - 1] = rsTrends.getInt("cnt");
            }
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if (rsStats != null) try { rsStats.close(); } catch(Exception e){}
        if (psStats != null) try { psStats.close(); } catch(Exception e){}
        if (rsStudents != null) try { rsStudents.close(); } catch(Exception e){}
        if (psStudents != null) try { psStudents.close(); } catch(Exception e){}
        if (rsTrends != null) try { rsTrends.close(); } catch(Exception e){}
        if (psTrends != null) try { psTrends.close(); } catch(Exception e){}
    }
    
    StringBuilder trendsSb = new StringBuilder();
    for (int i = 0; i < 12; i++) {
        trendsSb.append(monthlyTrends[i]);
        if (i < 11) trendsSb.append(",");
    }
    String adminTrendsStr = trendsSb.toString();
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Leave Portal</title>
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
                    <span class="menu-title">Admin Controls</span>
                    <a href="adminDashboard.jsp" class="menu-item active">
                        <span>📊</span> Dashboard
                    </a>
                </nav>

                <nav class="menu-group">
                    <span class="menu-title">Admin Account</span>
                    <a href="#" class="menu-item" onclick="openModal('adminProfileModal')">
                        <span>👤</span> Profile
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
                    <input type="text" placeholder="Search system logs...">
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
                    
                    <div class="avatar" title="Administrator">
                        AD
                    </div>
                </div>
            </header>

            <!-- Dashboard Body -->
            <div class="dashboard-body">
                
                <!-- Welcome Banner -->
                <div class="glass-card card-primary" style="padding: 28px;">
                    <h2 style="font-size: 22px; font-weight: 700; margin-bottom: 6px; letter-spacing: -0.5px;">Welcome Back, <%= adminUsername %>!</h2>
                    <p style="color: var(--text-secondary); font-size: 14px;">Administrator Control Center | Total registered students: <strong><%= studentCount %></strong></p>
                </div>

                <% 
                    String successMsg = request.getParameter("successMsg");
                    if (successMsg != null) {
                %>
                    <div class="alert-message alert-success"><%= successMsg %></div>
                <% } %>
                
                <% 
                    String errorMsg = request.getParameter("errorMsg");
                    if (errorMsg != null) {
                %>
                    <div class="alert-message alert-error"><%= errorMsg %></div>
                <% } %>

                <!-- Statistics Grid -->
                <section class="stats-grid">
                    <div class="glass-card stat-card">
                        <div class="stat-header">
                            <span class="stat-title">Total Applications</span>
                            <span class="stat-icon icon-blue">📋</span>
                        </div>
                        <span class="stat-value"><%= totalApplied %></span>
                        <div class="stat-footer">
                            Applied across college
                        </div>
                    </div>
                    
                    <div class="glass-card stat-card">
                        <div class="stat-header">
                            <span class="stat-title">Approved Leaves</span>
                            <span class="stat-icon icon-green">✅</span>
                        </div>
                        <span class="stat-value"><%= approved %></span>
                        <div class="stat-footer">
                            <span class="trend-indicator trend-up">↑ <%= totalApplied > 0 ? (approved * 100 / totalApplied) : 0 %>%</span> approved
                        </div>
                    </div>
                    
                    <div class="glass-card stat-card">
                        <div class="stat-header">
                            <span class="stat-title">Pending Requests</span>
                            <span class="stat-icon icon-orange">⏳</span>
                        </div>
                        <span class="stat-value"><%= pending %></span>
                        <div class="stat-footer">
                            Requires review
                        </div>
                    </div>
                    
                    <div class="glass-card stat-card">
                        <div class="stat-header">
                            <span class="stat-title">Rejected Requests</span>
                            <span class="stat-icon icon-red">❌</span>
                        </div>
                        <span class="stat-value"><%= rejected %></span>
                        <div class="stat-footer">
                            Declined leave requests
                        </div>
                    </div>
                </section>

                <!-- Two Column Dashboard Grid -->
                <div class="dashboard-columns" style="grid-template-columns: 1fr;">
                    
                    <!-- Leave Analytics Panel -->
                    <div class="glass-card">
                        <h3 class="section-title">Leave Request Distribution</h3>
                        <div class="analytics-grid">
                            <div class="chart-container">
                                <canvas id="leaveTrendChart" data-trends="<%= adminTrendsStr %>"></canvas>
                            </div>
                            <div class="chart-container">
                                <canvas id="leaveDistributionChart" 
                                        data-approved="<%= approved %>" 
                                        data-pending="<%= pending %>" 
                                        data-rejected="<%= rejected %>"></canvas>
                            </div>
                        </div>
                    </div>

                    <!-- Pending and Managed Requests Table -->
                    <div class="glass-card">
                        <h3 class="section-title">Leave Applications Management</h3>
                        <div class="table-responsive">
                            <table class="custom-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>USN</th>
                                        <th>Student Name</th>
                                        <th>From Date</th>
                                        <th>To Date</th>
                                        <th>Reason</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        if (conn != null) {
                                            String sql = "SELECT l.leave_id, l.student_usn, s.name, l.from_date, l.to_date, l.reason, l.status " +
                                                         "FROM leave_request l JOIN student s ON l.student_usn = s.usn ORDER BY l.status DESC, l.leave_id DESC";
                                            try (Statement stmt = conn.createStatement()) {
                                                ResultSet rs = stmt.executeQuery(sql);
                                                boolean hasRequests = false;
                                                while (rs.next()) {
                                                    hasRequests = true;
                                                    int leaveId = rs.getInt("leave_id");
                                                    String usn = rs.getString("student_usn");
                                                    String name = rs.getString("name");
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
                                                        <td><%= usn %></td>
                                                        <td><%= name %></td>
                                                        <td><%= fromDate %></td>
                                                        <td><%= toDate %></td>
                                                        <td><%= reason %></td>
                                                        <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                                                        <td>
                                                            <% if ("Pending".equalsIgnoreCase(status)) { %>
                                                                <a href="ApproveLeaveServlet?id=<%= leaveId %>" class="badge badge-approved" style="text-decoration: none;" onclick="return confirm('Approve leave request?')">Approve</a>
                                                                <a href="RejectLeaveServlet?id=<%= leaveId %>" class="badge badge-rejected" style="text-decoration: none;" onclick="return confirm('Reject leave request?')">Reject</a>
                                                            <% } else { %>
                                                                <span style="color: var(--text-secondary); font-size:12px;">Processed</span>
                                                            <% } %>
                                                        </td>
                                                    </tr>
                                    <%
                                                }
                                                if (!hasRequests) {
                                    %>
                                                    <tr>
                                                        <td colspan="8" style="text-align:center; color: var(--text-secondary);">No leave applications on file.</td>
                                                    </tr>
                                    <%
                                                }
                                            } catch (SQLException e) {
                                                out.println("<tr><td colspan='8' style='color:var(--danger);'>Database Error: " + e.getMessage() + "</td></tr>");
                                            }
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Registered Students Table -->
                    <div class="glass-card">
                        <h3 class="section-title">Registered Students</h3>
                        <div class="table-responsive">
                            <table class="custom-table">
                                <thead>
                                    <tr>
                                        <th>USN</th>
                                        <th>Name</th>
                                        <th>Email Address</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        if (conn != null) {
                                            String sql2 = "SELECT usn, name, email FROM student ORDER BY name ASC";
                                            try (Statement stmt2 = conn.createStatement()) {
                                                ResultSet rs2 = stmt2.executeQuery(sql2);
                                                boolean hasStudents = false;
                                                while (rs2.next()) {
                                                    hasStudents = true;
                                                    String sUsn = rs2.getString("usn");
                                                    String sName = rs2.getString("name");
                                                    String sEmail = rs2.getString("email");
                                    %>
                                                    <tr>
                                                        <td><%= sUsn %></td>
                                                        <td><%= sName %></td>
                                                        <td><%= sEmail %></td>
                                                    </tr>
                                    <%
                                                }
                                                if (!hasStudents) {
                                    %>
                                                    <tr>
                                                        <td colspan="3" style="text-align:center; color: var(--text-secondary);">No students registered.</td>
                                                    </tr>
                                    <%
                                                }
                                            } catch (SQLException e) {
                                                out.println("<tr><td colspan='3' style='color:var(--danger);'>Database Error: " + e.getMessage() + "</td></tr>");
                                            } finally {
                                                try {
                                                    if (rsStats != null) rsStats.close();
                                                    if (psStats != null) psStats.close();
                                                    if (rsStudents != null) rsStudents.close();
                                                    if (psStudents != null) psStudents.close();
                                                    conn.close();
                                                } catch (SQLException e) {
                                                    e.printStackTrace();
                                                }
                                            }
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>

            </div>

        </main>
        
    </div>

    <!-- Admin Profile Modal -->
    <div id="adminProfileModal" class="modal">
        <div class="modal-content glass-card card-primary">
            <span class="close-btn" onclick="closeModal('adminProfileModal')">&times;</span>
            <h3 class="section-title">Admin Profile</h3>
            <div style="display: flex; flex-direction: column; gap: 12px; margin-top: 10px;">
                <p><strong>Username:</strong> <%= adminUsername %></p>
                <p><strong>Account Type:</strong> Portal Administrator</p>
                <p><strong>Managed Student Profiles:</strong> <%= studentCount %></p>
            </div>
        </div>
    </div>

    <!-- Central Script -->
    <script src="js/dashboard.js"></script>
</body>
</html>
