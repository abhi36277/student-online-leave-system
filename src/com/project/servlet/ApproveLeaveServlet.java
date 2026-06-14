package com.project.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import com.project.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ApproveLeaveServlet")
public class ApproveLeaveServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("adminLogin.jsp?errorMsg=Unauthorized access.");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect("adminDashboard.jsp?errorMsg=Invalid Request ID.");
            return;
        }

        int leaveId = Integer.parseInt(idStr);
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            response.sendRedirect("adminDashboard.jsp?errorMsg=Database offline.");
            return;
        }

        String sql = "UPDATE leave_request SET status = 'Approved' WHERE leave_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leaveId);
            ps.executeUpdate();
            response.sendRedirect("adminDashboard.jsp?successMsg=Leave approved successfully!");
        } catch (SQLException e) {
            response.sendRedirect("adminDashboard.jsp?errorMsg=SQL Error: " + e.getMessage());
        } finally {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
