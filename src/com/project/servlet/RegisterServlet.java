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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String usn = request.getParameter("usn");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Basic Server Side Validation
        if (name == null || name.trim().isEmpty() ||
            usn == null || usn.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            
            request.setAttribute("errorMsg", "All fields are required!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            request.setAttribute("errorMsg", "Database connection error!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        String sql = "INSERT INTO student (usn, name, email, password) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, usn.trim().toUpperCase());
            ps.setString(2, name.trim());
            ps.setString(3, email.trim().toLowerCase());
            ps.setString(4, password);

            int result = ps.executeUpdate();
            if (result > 0) {
                // Success: Redirect to login
                response.sendRedirect("login.jsp?successMsg=Registration successful! Please login.");
            } else {
                request.setAttribute("errorMsg", "Registration failed. Try again.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            String msg = e.getMessage();
            if (msg.contains("Duplicate entry") || msg.contains("PRIMARY")) {
                request.setAttribute("errorMsg", "Student with this USN/Email already exists.");
            } else {
                request.setAttribute("errorMsg", "Database Error: " + msg);
            }
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } finally {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
