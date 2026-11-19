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
import javax.servlet.http.HttpSession;

@WebServlet("/ProcessBookingServlet")
public class ProcessBookingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String scheduleId = request.getParameter("schedule_id");
        String qtyStr = request.getParameter("qty");
        String insuranceStr = request.getParameter("insurance");
        String selectedSeats = request.getParameter("selected_seats");
        String totalPriceStr = request.getParameter("total_price");

        try {

            int qty = (qtyStr != null && !qtyStr.isEmpty())
                    ? Integer.parseInt(qtyStr)
                    : 1;

            boolean hasInsurance =
                    Boolean.parseBoolean(insuranceStr);

            double totalPayable =
                    Double.parseDouble(totalPriceStr);

            Connection conn = DBConnection.getConnection();

            if (conn == null) {
                response.sendRedirect("error.jsp");
                return;
            }

            conn.setAutoCommit(false);

            // =========================
            // Update Available Seats
            // =========================
            String updateScheduleSql =
                    "UPDATE bus_schedules "
                    + "SET available_seats = available_seats - ? "
                    + "WHERE id = ?";

            try (PreparedStatement pstUpdate =
                    conn.prepareStatement(updateScheduleSql)) {

                pstUpdate.setInt(1, qty);
                pstUpdate.setInt(2,
                        Integer.parseInt(scheduleId));

                pstUpdate.executeUpdate();
            }

            // =========================
            // Insert Booked Seats
            // =========================
            if (selectedSeats != null
                    && !selectedSeats.trim().isEmpty()) {
HttpSession session = request.getSession();

Integer userId =
(Integer) session.getAttribute("userId");

if(userId == null){
    response.sendRedirect("login.jsp");
    return;
}


String transactionId =
"SANI-" + System.currentTimeMillis();

session.setAttribute(
        "bookingTransactionId",
        transactionId);
System.out.println(
    "BOOKING TX = "
    + transactionId);


                String[] seatsArray =
                        selectedSeats.split(",");

                String insertSeatSql =
"INSERT INTO booked_seats " +
"(schedule_id, seat_number, user_id, transaction_id) " +
"VALUES (?, ?, ?, ?)";

                try (PreparedStatement pstSeat =
                        conn.prepareStatement(insertSeatSql)) {

                    for (String seat : seatsArray) {

                       pstSeat.setInt(1,
Integer.parseInt(scheduleId));

pstSeat.setString(2,
seat.trim());

pstSeat.setInt(3,
userId);

pstSeat.setString(4,
transactionId);

pstSeat.addBatch();
                    }

                    pstSeat.executeBatch();
                }
            }

            // =========================
            // Get Route Information
            // =========================
            String routeOrigin = "";
            String routeDestination = "";

            String routeSql =
                    "SELECT br.origin, br.destination "
                    + "FROM bus_schedules bs "
                    + "INNER JOIN bus_routes br "
                    + "ON bs.route_id = br.id "
                    + "WHERE bs.id=?";

            try (PreparedStatement pst =
                    conn.prepareStatement(routeSql)) {

                pst.setInt(1,
                        Integer.parseInt(scheduleId));

                ResultSet rs = pst.executeQuery();

                if (rs.next()) {

                    routeOrigin =
                            rs.getString("origin");

                    routeDestination =
                            rs.getString("destination");
                }
            }

            conn.commit();

            // =========================
            // Save Session Data
            // =========================
            

            HttpSession session = request.getSession();


session.setAttribute(
        "schedule_id",
        scheduleId);

session.setAttribute(
        "totalAmount",
        String.format("%.2f", totalPayable));

session.setAttribute(
        "seats",
        selectedSeats);

session.setAttribute(
        "insurance",
        hasInsurance);

session.setAttribute(
        "bookingQty",
        qty);

session.setAttribute(
        "fromLocation",
        routeOrigin);

session.setAttribute(
        "toLocation",
        routeDestination);


response.sendRedirect(
        "paymentSelection.jsp");

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "paymentSelection.jsp?error=database_error");
        }
    }
}