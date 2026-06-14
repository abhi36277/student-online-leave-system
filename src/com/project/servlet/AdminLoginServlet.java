package com.project.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.project.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            
            request.setAttribute("errorMsg", "Enter both Admin credentials.");
            request.getRequestDispatcher("adminLogin.jsp").forward(request, response);
            return;
        }

        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            request.setAttribute("errorMsg", "Database Server connection failure.");
            request.getRequestDispatcher("adminLogin.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT * FROM admin WHERE username = ? AND password = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                // Credentials Validated
                HttpSession session = request.getSession(true);
                session.setAttribute("adminUser", username.trim());
                session.setAttribute("role", "admin");
                
                response.sendRedirect("adminDashboard.jsp");
            } else {
                request.setAttribute("errorMsg", "Invalid Admin credentials!");
                request.getRequestDispatcher("adminLogin.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMsg", "Database Error: " + e.getMessage());
            request.getRequestDispatcher("adminLogin.jsp").forward(request, response);
        } finally {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
