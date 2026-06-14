package com.project.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import com.project.util.DBConnection;
import com.project.model.Student;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LeaveServlet")
public class LeaveServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?errorMsg=Unauthorized access. Please login first.");
            return;
        }

        Student student = (Student) session.getAttribute("user");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        String reason = request.getParameter("reason");

        if (fromDate == null || fromDate.isEmpty() ||
            toDate == null || toDate.isEmpty() ||
            reason == null || reason.trim().isEmpty()) {
            
            request.setAttribute("errorMsg", "All leave fields are required!");
            request.getRequestDispatcher("applyLeave.jsp").forward(request, response);
            return;
        }

        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            request.setAttribute("errorMsg", "Connection Failed.");
            request.getRequestDispatcher("applyLeave.jsp").forward(request, response);
            return;
        }

        String sql = "INSERT INTO leave_request (student_usn, from_date, to_date, reason, status) VALUES (?, ?, ?, ?, 'Pending')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, student.getUsn());
            ps.setString(2, fromDate);
            ps.setString(3, toDate);
            ps.setString(4, reason.trim());

            int res = ps.executeUpdate();
            if (res > 0) {
                response.sendRedirect("leaveStatus.jsp?successMsg=Leave application submitted successfully!");
            } else {
                request.setAttribute("errorMsg", "Failed to submit application. Try again.");
                request.getRequestDispatcher("applyLeave.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMsg", "Database Error: " + e.getMessage());
            request.getRequestDispatcher("applyLeave.jsp").forward(request, response);
        } finally {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
