package com.sani;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;


public class EditDriverServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id       = request.getParameter("id");
        String fullname = request.getParameter("fullname");
        String email    = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Basic validation
        if (id == null || id.trim().isEmpty() ||
            fullname == null || fullname.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            username == null || username.trim().isEmpty()) {
            response.sendRedirect("admin_drivers.jsp?msg=error");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            boolean changePassword = password != null && !password.trim().isEmpty();

            String sql = changePassword
                ? "UPDATE users SET fullname = ?, email = ?, username = ?, password = ? WHERE id = ? AND role = 'driver'"
                : "UPDATE users SET fullname = ?, email = ?, username = ? WHERE id = ? AND role = 'driver'";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, fullname.trim());
                ps.setString(2, email.trim());
                ps.setString(3, username.trim());
                if (changePassword) {
                    ps.setString(4, password.trim()); // plain text — hash here if your app uses hashing
                    ps.setInt(5, Integer.parseInt(id));
                } else {
                    ps.setInt(4, Integer.parseInt(id));
                }
                ps.executeUpdate();
            }

            response.sendRedirect("admin_drivers.jsp?msg=updated");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_drivers.jsp?msg=error");
        }
    }
}