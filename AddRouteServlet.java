package com.sani;

import javax.servlet.annotation.WebServlet;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/AddRouteServlet")
public class AddRouteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String routeName   = request.getParameter("route_name");
        String origin      = request.getParameter("origin");
        String destination = request.getParameter("destination");
        String distanceStr = request.getParameter("distance_km");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "INSERT INTO bus_routes (route_name, origin, destination, distance_km) VALUES (?, ?, ?, ?)")) {

            ps.setString(1, routeName);
            ps.setString(2, origin);
            ps.setString(3, destination);

            if (distanceStr != null && !distanceStr.trim().isEmpty()) {
                ps.setDouble(4, Double.parseDouble(distanceStr));
            } else {
                ps.setNull(4, java.sql.Types.DECIMAL);
            }

            ps.executeUpdate();
            response.sendRedirect("admin_routes.jsp?msg=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_routes.jsp?msg=error");
        }
    }
}