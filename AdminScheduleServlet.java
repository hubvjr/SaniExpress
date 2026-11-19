package com.sani;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AdminScheduleServlet")
public class AdminScheduleServlet extends HttpServlet {

   @Override
protected void doPost(HttpServletRequest request,
        HttpServletResponse response)
        throws ServletException, IOException {

    if (request.getSession().getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    try {

        String origin =
                request.getParameter("origin");

        String destination =
                request.getParameter("destination");

        String busPlateNo =
                request.getParameter("bus_plate_no");

        String driverUsername =
                request.getParameter("driver_username");

        String departureInput =
                request.getParameter("departureTime");

        String arrivalInput =
                request.getParameter("arrivalTime");

        String ticketPrice =
                request.getParameter("ticket_price");

        String availableSeats =
                request.getParameter("available_seats");


        // ============================
        // Date & Time Validation
        // ============================

        java.time.format.DateTimeFormatter formatter =
                java.time.format.DateTimeFormatter
                        .ofPattern("yyyy-MM-dd'T'HH:mm");

        java.time.LocalDateTime departureDateTime =
                java.time.LocalDateTime.parse(
                        departureInput,
                        formatter);

        java.time.LocalDateTime arrivalDateTime =
                java.time.LocalDateTime.parse(
                        arrivalInput,
                        formatter);

        java.time.LocalDateTime now =
                java.time.LocalDateTime.now();


        // Cannot create past trips
        if (departureDateTime.isBefore(now)) {

            response.sendRedirect(
                    "admin_schedule.jsp?msg=past_trip");

            return;
        }


        // Must be at least 7 hours ahead
        long hoursDifference =
                java.time.temporal.ChronoUnit.HOURS
                        .between(
                                now,
                                departureDateTime);

        if (hoursDifference < 7) {

            response.sendRedirect(
                    "admin_schedule.jsp?msg=less_than_7_hours");

            return;
        }


        // Arrival must be after departure
        if (!arrivalDateTime.isAfter(
                departureDateTime)) {

            response.sendRedirect(
                    "admin_schedule.jsp?msg=invalid_arrival");

            return;
        }


        String departureTime =
                departureInput.replace("T", " ");

        String arrivalTime =
                arrivalInput.replace("T", " ");


        String conflictCheckSql =
                "SELECT COUNT(*) "
                + "FROM driver_leaves "
                + "WHERE driver_username=? "
                + "AND LOWER(status)='approved' "
                + "AND ? <= end_date "
                + "AND ? >= start_date";


        String insertScheduleSql =
                "INSERT INTO bus_schedules "
                + "(origin, destination, "
                + "bus_plate_no, driver_username, "
                + "departure_time, arrival_time, "
                + "ticket_price, available_seats, "
                + "status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, "
                + "'Active')";


        try (Connection con =
                     DBConnection.getConnection()) {


            // Check driver leave conflict
            try (PreparedStatement checkPs =
                         con.prepareStatement(
                                 conflictCheckSql)) {

                checkPs.setString(
                        1,
                        driverUsername);

                checkPs.setString(
                        2,
                        departureTime);

                checkPs.setString(
                        3,
                        arrivalTime);

                ResultSet rs =
                        checkPs.executeQuery();

                if (rs.next()
                        && rs.getInt(1) > 0) {

                    response.sendRedirect(
                            "admin_schedule.jsp?msg=leave_conflict");

                    return;
                }
            }


            // Insert schedule
            try (PreparedStatement ps =
                         con.prepareStatement(
                                 insertScheduleSql)) {

                ps.setString(
                        1,
                        origin.trim());

                ps.setString(
                        2,
                        destination.trim());

                ps.setString(
                        3,
                        busPlateNo.trim()
                                .toUpperCase());

                ps.setString(
                        4,
                        driverUsername);

                ps.setString(
                        5,
                        departureTime);

                ps.setString(
                        6,
                        arrivalTime);

                ps.setDouble(
                        7,
                        Double.parseDouble(
                                ticketPrice));

                ps.setInt(
                        8,
                        Integer.parseInt(
                                availableSeats));

                ps.executeUpdate();
            }


            response.sendRedirect(
                    "admin_schedule.jsp?msg=success");
        }

    } catch (Exception e) {

        e.printStackTrace();

        response.sendRedirect(
                "admin_schedule.jsp?msg=error");
    }
}
}