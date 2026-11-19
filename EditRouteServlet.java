package com.sani;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/EditRouteServlet")
public class EditRouteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        String routeName = request.getParameter("route_name");
        String origin = request.getParameter("origin");
        String destination = request.getParameter("destination");
        String distanceStr = request.getParameter("distance_km");

        if (idStr == null || routeName == null || origin == null || destination == null
                || idStr.trim().isEmpty()
                || routeName.trim().isEmpty()
                || origin.trim().isEmpty()
                || destination.trim().isEmpty()) {

            response.sendRedirect("admin_routes.jsp?msg=error");
            return;
        }

        int routeId;
        double distanceKm = 0;
        try {
            routeId = Integer.parseInt(idStr.trim());
            if (distanceStr != null && !distanceStr.trim().isEmpty()) {
                distanceKm = Double.parseDouble(distanceStr.trim());
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("admin_routes.jsp?msg=error");
            return;
        }

        String sql = "UPDATE bus_routes "
                + "SET route_name = ?, origin = ?, destination = ?, distance_km = ? "
                + "WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, routeName.trim());
            ps.setString(2, origin.trim());
            ps.setString(3, destination.trim());
            ps.setDouble(4, distanceKm);
            ps.setInt(5, routeId);
            ps.executeUpdate();

            response.sendRedirect("admin_routes.jsp?msg=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_routes.jsp?msg=error");
        }
    }
}
