package com.project.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Fetch active session, do not create one
        HttpSession session = request.getSession(false);
        if (session != null) {
            // Destroy Session
            session.invalidate();
        }
        
        // Redirect to main index page with logout status
        response.sendRedirect("index.jsp?successMsg=Logged out successfully.");
    }
}
