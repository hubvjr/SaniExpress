package com.sani;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class DeleteRouteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "DELETE FROM bus_routes WHERE id = ?")) {

            ps.setInt(1, Integer.parseInt(idParam));
            ps.executeUpdate();
            response.sendRedirect("admin_routes.jsp?msg=deleted");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_routes.jsp?msg=error");
        }
    }
}
