package com.project.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Database URL, Username, and Password
    private static final String URL = "jdbc:mysql://localhost:3306/student_leave_db?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASSWORD = ""; // Update this with your MySQL password

    public static Connection getConnection() {
        Connection conn = null;
        try {
            // Load MySQL Driver class
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Establish Connection
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL Driver not found: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Connection failed: " + e.getMessage());
        }
        return conn;
    }
}
