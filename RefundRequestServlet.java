package com.sani;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RefundRequestServlet")
public class RefundRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session =
                request.getSession();

        Integer userId =
                (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String transactionId =
                request.getParameter("transaction_id");

        String scheduleId =
                request.getParameter("schedule_id");

        String seatNumbers =
                request.getParameter("seat_numbers");

        String amountPaid =
                request.getParameter("amount_paid");

        String refundAmount =
                request.getParameter("refund_amount");

        String bankHolder =
                request.getParameter("bank_holder_name");

        String bankName =
                request.getParameter("bank_name");

        String bankAccount =
                request.getParameter("bank_account_number");

        try (Connection con =
                     DBConnection.getConnection()) {

            // Verify refund guarantee

            String verifySql =
                    "SELECT refund_guarantee " +
                    "FROM payments " +
                    "WHERE transaction_id=? " +
                    "AND user_id=?";

            PreparedStatement verifyPs =
                    con.prepareStatement(verifySql);

            verifyPs.setString(1, transactionId);
            verifyPs.setInt(2, userId);

            ResultSet verifyRs =
                    verifyPs.executeQuery();

            if (!verifyRs.next()
                    || verifyRs.getInt("refund_guarantee") != 1) {

                response.sendRedirect(
                        "my_tickets.jsp?error=no_refund_guarantee");

                return;
            }

            // Prevent duplicate request

            String duplicateSql =
                    "SELECT id FROM refund_requests " +
                    "WHERE payment_transaction_id=?";

            PreparedStatement duplicatePs =
                    con.prepareStatement(duplicateSql);

            duplicatePs.setString(1, transactionId);

            ResultSet duplicateRs =
                    duplicatePs.executeQuery();

            if (duplicateRs.next()) {

                response.sendRedirect(
                        "my_refunds.jsp");

                return;
            }

            // Insert refund request

            String insertSql =
                    "INSERT INTO refund_requests (" +
                    "payment_transaction_id," +
                    "user_id," +
                    "schedule_id," +
                    "seat_numbers," +
                    "amount_paid," +
                    "refund_amount," +
                    "bank_holder_name," +
                    "bank_name," +
                    "bank_account_number," +
                    "status" +
                    ") VALUES (?,?,?,?,?,?,?,?,?,?)";

            PreparedStatement insertPs =
                    con.prepareStatement(insertSql);

            insertPs.setString(1, transactionId);
            insertPs.setInt(2, userId);
            insertPs.setInt(3,
                    Integer.parseInt(scheduleId));
            insertPs.setString(4, seatNumbers);
            insertPs.setDouble(5,
                    Double.parseDouble(amountPaid));
            insertPs.setDouble(6,
                    Double.parseDouble(refundAmount));
            insertPs.setString(7, bankHolder);
            insertPs.setString(8, bankName);
            insertPs.setString(9, bankAccount);
            insertPs.setString(10, "Pending");

            insertPs.executeUpdate();

            // Release booked seats immediately

            String deleteSeatSql =
                    "DELETE FROM booked_seats " +
                    "WHERE transaction_id=?";

            PreparedStatement seatPs =
                    con.prepareStatement(deleteSeatSql);

            seatPs.setString(1, transactionId);

            seatPs.executeUpdate();

            // Restore available seats immediately

            int seatCount =
                    seatNumbers.split(",").length;

            String restoreSql =
                    "UPDATE bus_schedules " +
                    "SET available_seats = available_seats + ? " +
                    "WHERE id=?";

            PreparedStatement restorePs =
                    con.prepareStatement(restoreSql);

            restorePs.setInt(1, seatCount);

            restorePs.setInt(
                    2,
                    Integer.parseInt(scheduleId));

            restorePs.executeUpdate();

            // Make ticket inactive immediately

            String paymentSql =
                    "UPDATE payments " +
                    "SET status='Refund Pending' " +
                    "WHERE transaction_id=?";

            PreparedStatement paymentPs =
                    con.prepareStatement(paymentSql);

            paymentPs.setString(1, transactionId);

            paymentPs.executeUpdate();

            response.sendRedirect(
                    "my_refunds.jsp");

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "refund_request.jsp?error=1");
        }
    }
}