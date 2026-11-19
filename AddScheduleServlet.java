package com.sani;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.sani.DBConnection;

@WebServlet("/AddScheduleServlet")
public class AddScheduleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Retrieve parameters
        String origin = request.getParameter("origin");
        String destination = request.getParameter("destination");
        String driverUsername = request.getParameter("driver_username");
        String busPlateNo = request.getParameter("bus_plate_no");
        String departureTimeStr = request.getParameter("departureTime");
        
        Timestamp departure =
        Timestamp.valueOf(
        departureTimeStr.replace("T", " ") + ":00");

Timestamp currentPlus5Hours =
        new Timestamp(
        System.currentTimeMillis()
        + (5 * 60 * 60 * 1000));

if(departure.before(currentPlus5Hours)){

    response.sendRedirect(
        "admin_schedule.jsp?msg=time_error");

    return;
}
        String arrivalTimeStr = request.getParameter("arrival_time");
        String ticketPriceStr = request.getParameter("ticket_price");
        String availableSeatsStr = request.getParameter("available_seats");

        // Basic Validation
        if (origin == null || destination == null || departureTimeStr == null || arrivalTimeStr == null) {
            response.sendRedirect("admin_schedule.jsp?msg=error");
            return;
        }

        Connection conn = null;
        PreparedStatement psRouteCheck = null;
        PreparedStatement psRouteInsert = null;
        PreparedStatement psSchedule = null;
        ResultSet rsRoute = null;

        try {
            conn = DBConnection.getConnection();
            
            // 1. Resolve or Create Route ID
            int routeId = 0;
            String checkRouteSql = "SELECT id FROM bus_routes WHERE LOWER(origin) = LOWER(?) AND LOWER(destination) = LOWER(?)";
            psRouteCheck = conn.prepareStatement(checkRouteSql);
            psRouteCheck.setString(1, origin.trim());
            psRouteCheck.setString(2, destination.trim());
            rsRoute = psRouteCheck.executeQuery();

            if (rsRoute.next()) {
                routeId = rsRoute.getInt("id");
            } else {
                String insertRouteSql = "INSERT INTO bus_routes (route_name, origin, destination) VALUES (?, ?, ?)";
                psRouteInsert = conn.prepareStatement(insertRouteSql, Statement.RETURN_GENERATED_KEYS);
                psRouteInsert.setString(1, origin.trim() + " - " + destination.trim());
                psRouteInsert.setString(2, origin.trim());
                psRouteInsert.setString(3, destination.trim());
                psRouteInsert.executeUpdate();
                
                try (ResultSet rsKeys = psRouteInsert.getGeneratedKeys()) {
                    if (rsKeys.next()) routeId = rsKeys.getInt(1);
                }
            }

            // 2. Insert into bus_schedules
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            Timestamp depTs = Timestamp.valueOf(LocalDateTime.parse(departureTimeStr, formatter));
            Timestamp arrTs = Timestamp.valueOf(LocalDateTime.parse(arrivalTimeStr, formatter));

            String sql = "INSERT INTO bus_schedules (route_id, bus_plate_no, driver_username, departure_time, arrival_time, ticket_price, available_seats, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'Active')";
            
            psSchedule = conn.prepareStatement(sql);
            psSchedule.setInt(1, routeId);
            psSchedule.setString(2, busPlateNo.trim());
            psSchedule.setString(3, driverUsername.trim());
            psSchedule.setTimestamp(4, depTs);
            psSchedule.setTimestamp(5, arrTs);
            psSchedule.setDouble(6, Double.parseDouble(ticketPriceStr));
            psSchedule.setInt(7, Integer.parseInt(availableSeatsStr));

            psSchedule.executeUpdate();
            response.sendRedirect("admin_schedule.jsp?msg=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_schedule.jsp?msg=error");
        } finally {
            // Close resources
            if (rsRoute != null) try { rsRoute.close(); } catch (SQLException e) {}
            if (psRouteCheck != null) try { psRouteCheck.close(); } catch (SQLException e) {}
            if (psRouteInsert != null) try { psRouteInsert.close(); } catch (SQLException e) {}
            if (psSchedule != null) try { psSchedule.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
}