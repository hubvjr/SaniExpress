package com.sani;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DeleteManagerServlet")
public class DeleteManagerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String id = request.getParameter("id");

        try(Connection con =
                DBConnection.getConnection()) {

            PreparedStatement ps =
                    con.prepareStatement(
                    "DELETE FROM users "
                    + "WHERE id=? "
                    + "AND role='manager'");

            ps.setInt(1,
                    Integer.parseInt(id));

            ps.executeUpdate();

            response.sendRedirect(
                    "admin_managers.jsp?msg=deleted");

        } catch(Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "admin_managers.jsp?msg=error");
        }
    }
}