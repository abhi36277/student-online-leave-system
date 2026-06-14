package com.project.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.project.util.DBConnection;
import com.project.model.Student;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String usnOrEmail = request.getParameter("username");
        String password = request.getParameter("password");

        if (usnOrEmail == null || usnOrEmail.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            
            request.setAttribute("errorMsg", "Please enter both credentials.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            request.setAttribute("errorMsg", "Database Server down.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT * FROM student WHERE (usn = ? OR email = ?) AND password = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, usnOrEmail.trim());
            ps.setString(2, usnOrEmail.trim());
            ps.setString(3, password);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                // User validated: Populate Student Bean
                Student student = new Student();
                student.setUsn(rs.getString("usn"));
                student.setName(rs.getString("name"));
                student.setEmail(rs.getString("email"));

                // Create Session
                HttpSession session = request.getSession(true);
                session.setAttribute("user", student);
                session.setAttribute("role", "student");

                // Redirect to Dashboard
                response.sendRedirect("studentDashboard.jsp");
            } else {
                request.setAttribute("errorMsg", "Invalid USN/Email or Password!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMsg", "Database Error: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } finally {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
