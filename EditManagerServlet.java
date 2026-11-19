package com.sani;

import java.io.IOException;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EditManagerServlet")
public class EditManagerServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String id =
                request.getParameter("id");

        String fullname =
                request.getParameter("fullname");

        String email =
                request.getParameter("email");

        String username =
                request.getParameter("username");

        String password =
                request.getParameter("password");

        try(Connection con =
                DBConnection.getConnection()) {

            String sql;

            if(password != null &&
               !password.trim().isEmpty()){

                sql =
                "UPDATE users SET "
                + "fullname=?,email=?,"
                + "username=?,password=? "
                + "WHERE id=? "
                + "AND role='manager'";

                PreparedStatement ps =
                        con.prepareStatement(sql);

                ps.setString(1, fullname);
                ps.setString(2, email);
                ps.setString(3, username);
                ps.setString(4, password);
                ps.setInt(5,
                        Integer.parseInt(id));

                ps.executeUpdate();

            } else {

                sql =
                "UPDATE users SET "
                + "fullname=?,email=?,"
                + "username=? "
                + "WHERE id=? "
                + "AND role='manager'";

                PreparedStatement ps =
                        con.prepareStatement(sql);

                ps.setString(1, fullname);
                ps.setString(2, email);
                ps.setString(3, username);
                ps.setInt(4,
                        Integer.parseInt(id));

                ps.executeUpdate();
            }

            response.sendRedirect(
                    "admin_managers.jsp?msg=updated");

        } catch(Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "admin_managers.jsp?msg=error");
        }
    }
}