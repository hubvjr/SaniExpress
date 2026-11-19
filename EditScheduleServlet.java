package com.sani;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.sani.DBConnection;

@WebServlet("/EditScheduleServlet")
public class EditScheduleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String scheduleIdStr = request.getParameter("schedule_id");
        String origin = request.getParameter("origin");
        String destination = request.getParameter("destination");
        String driverUsername = request.getParameter("driver_username");
        String busPlateNo = request.getParameter("bus_plate_no");
        String departureTimeStr = request.getParameter("departure_time");
        String arrivalTimeStr = request.getParameter("arrival_time");
        String ticketPriceStr = request.getParameter("ticket_price");
        String availableSeatsStr = request.getParameter("available_seats");

        Connection conn = null;
        PreparedStatement psRouteCheck = null;
        PreparedStatement psRouteInsert = null;
        PreparedStatement psScheduleUpdate = null;
        ResultSet rsRoute = null;

        try {
            int scheduleId = Integer.parseInt(scheduleIdStr);
            double ticketPrice = Double.parseDouble(ticketPriceStr);
            int availableSeats = Integer.parseInt(availableSeatsStr);

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime depLdt = LocalDateTime.parse(departureTimeStr, formatter);
            LocalDateTime arrLdt = LocalDateTime.parse(arrivalTimeStr, formatter);

            Timestamp departureTimestamp = Timestamp.valueOf(depLdt);
            Timestamp arrivalTimestamp = Timestamp.valueOf(arrLdt);

            conn = DBConnection.getConnection();
            int routeId = 0;
            origin = origin.trim();
            destination = destination.trim();

            // 1. Match or Create Route row to fit database constraints
            String checkRouteSql = "SELECT id FROM bus_routes WHERE LOWER(origin) = LOWER(?) AND LOWER(destination) = LOWER(?)";
            psRouteCheck = conn.prepareStatement(checkRouteSql);
            psRouteCheck.setString(1, origin);
            psRouteCheck.setString(2, destination);
            rsRoute = psRouteCheck.executeQuery();

            if (rsRoute.next()) {
                routeId = rsRoute.getInt("id");
            } else {
                String routeName = origin + " - " + destination;
                String insertRouteSql = "INSERT INTO bus_routes (route_name, origin, destination, distance_km) VALUES (?, ?, ?, 0)";
                psRouteInsert = conn.prepareStatement(insertRouteSql, Statement.RETURN_GENERATED_KEYS);
                psRouteInsert.setString(1, routeName);
                psRouteInsert.setString(2, origin);
                psRouteInsert.setString(3, destination);
                psRouteInsert.executeUpdate();
                
                ResultSet rsKeys = psRouteInsert.getGeneratedKeys();
                if (rsKeys.next()) {
                    routeId = rsKeys.getInt(1);
                }
                if (rsKeys != null) rsKeys.close();
            }

            // 2. Perform safe relational update on bus_schedules
            String updateSql = "UPDATE bus_schedules SET route_id = ?, bus_plate_no = ?, driver_username = ?, " +
                               "departure_time = ?, arrival_time = ?, ticket_price = ?, available_seats = ? WHERE id = ?";
            
            psScheduleUpdate = conn.prepareStatement(updateSql);
            psScheduleUpdate.setInt(1, routeId);
            psScheduleUpdate.setString(2, busPlateNo.trim());
            psScheduleUpdate.setString(3, driverUsername.trim());
            psScheduleUpdate.setTimestamp(4, departureTimestamp);
            psScheduleUpdate.setTimestamp(5, arrivalTimestamp);
            psScheduleUpdate.setDouble(6, ticketPrice);
            psScheduleUpdate.setInt(7, availableSeats);
            psScheduleUpdate.setInt(8, scheduleId);

            psScheduleUpdate.executeUpdate();
            response.sendRedirect("admin_schedule.jsp?msg=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_schedule.jsp?msg=error");
        } finally {
            if (rsRoute != null) try { rsRoute.close(); } catch(Exception e) {}
            if (psRouteCheck != null) try { psRouteCheck.close(); } catch(Exception e) {}
            if (psRouteInsert != null) try { psRouteInsert.close(); } catch(Exception e) {}
            if (psScheduleUpdate != null) try { psScheduleUpdate.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
}