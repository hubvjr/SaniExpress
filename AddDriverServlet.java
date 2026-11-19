package com.sani;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class AddDriverServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

       String fullname = request.getParameter("fullname");
String email    = request.getParameter("email");
String username = request.getParameter("username");
String password = request.getParameter("password");

try (Connection conn = DBConnection.getConnection()) {

    // Password validation
    if (password == null ||
        password.length() < 6 ||
        !password.matches(".*[!@#$%&].*")) {

        response.sendRedirect("admin_drivers.jsp?msg=invalidpassword");
        return;
    }

    // Username validation
    PreparedStatement check = conn.prepareStatement(
        "SELECT COUNT(*) FROM users WHERE username = ?"
    );
    check.setString(1, username);

    ResultSet rs = check.executeQuery();

    if (rs.next() && rs.getInt(1) > 0) {
        response.sendRedirect("admin_drivers.jsp?msg=usernameexists");
        return;
    }

    PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO users(fullname,email,username,password,role) VALUES (?,?,?,?, 'admin')"
    );

    ps.setString(1, fullname);
    ps.setString(2, email);
    ps.setString(3, username);
    ps.setString(4, password);

    ps.executeUpdate();

    response.sendRedirect("admin_drivers.jsp?msg=success");

} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("admin_drivers.jsp?msg=error");
}
    }
}
