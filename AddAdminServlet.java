package com.sani;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import javax.servlet.annotation.WebServlet;

@WebServlet("/AddAdminServlet")
public class AddAdminServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String fullname = request.getParameter("fullname");
        String email    = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(

                 "INSERT INTO users "
               + "(fullname,email,username,password,role) "
               + "VALUES (?,?,?,?, 'admin')")) {

            ps.setString(1, fullname);
            ps.setString(2, email);
            ps.setString(3, username);
            ps.setString(4, password);

            ps.executeUpdate();

            response.sendRedirect(
                    "admin_admins.jsp?msg=success");

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "admin_admins.jsp?msg=error");
        }
    }
}