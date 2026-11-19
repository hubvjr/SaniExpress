package com.sani;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RefundApprovalServlet")
public class RefundApprovalServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String refundId =
                request.getParameter("refundId");

        String action =
                request.getParameter("action");

        try(Connection con =
                DBConnection.getConnection()){

            String fetchSql =
            "SELECT * FROM refund_requests " +
            "WHERE id=?";

            PreparedStatement fetchPs =
                    con.prepareStatement(fetchSql);

            fetchPs.setInt(
                    1,
                    Integer.parseInt(refundId));

            ResultSet rs =
                    fetchPs.executeQuery();

            if(rs.next()){

                String transactionId =
                rs.getString(
                        "payment_transaction_id");

                int scheduleId =
                rs.getInt(
                        "schedule_id");

                String seats =
                rs.getString(
                        "seat_numbers");

                if("approve".equals(action)){

                    // update refund request

                    String approveSql =
                    "UPDATE refund_requests " +
                    "SET status='Approved'," +
                    "approval_date=NOW() " +
                    "WHERE id=?";

                    PreparedStatement approvePs =
                            con.prepareStatement(
                                    approveSql);

                    approvePs.setInt(
                            1,
                            Integer.parseInt(refundId));

                    approvePs.executeUpdate();

                    // payment status

                    String paymentSql =
                    "UPDATE payments " +
                    "SET status='Refund Approved' " +
                    "WHERE transaction_id=?";

                    PreparedStatement paymentPs =
                            con.prepareStatement(
                                    paymentSql);

                    paymentPs.setString(
                            1,
                            transactionId);

                    paymentPs.executeUpdate();

                    // delete booked seats

                    String deleteSeatSql =
                    "DELETE FROM booked_seats " +
                    "WHERE transaction_id=?";

                    PreparedStatement seatPs =
                            con.prepareStatement(
                                    deleteSeatSql);

                    seatPs.setString(
                            1,
                            transactionId);

                    seatPs.executeUpdate();

                    // restore seats

                    int seatCount =
                    seats.split(",").length;

                    String restoreSql =
                    "UPDATE bus_schedules " +
                    "SET available_seats=" +
                    "available_seats + ? " +
                    "WHERE id=?";

                    PreparedStatement restorePs =
                            con.prepareStatement(
                                    restoreSql);

                    restorePs.setInt(
                            1,
                            seatCount);

                    restorePs.setInt(
                            2,
                            scheduleId);

                    restorePs.executeUpdate();

                }else{

                    String rejectSql =
                    "UPDATE refund_requests " +
                    "SET status='Rejected' " +
                    "WHERE id=?";

                    PreparedStatement rejectPs =
                            con.prepareStatement(
                                    rejectSql);

                    rejectPs.setInt(
                            1,
                            Integer.parseInt(refundId));

                    rejectPs.executeUpdate();

                    String paymentSql =
                    "UPDATE payments " +
                    "SET status='Active' " +
                    "WHERE transaction_id=?";

                    PreparedStatement paymentPs =
                            con.prepareStatement(
                                    paymentSql);

                    paymentPs.setString(
                            1,
                            transactionId);

                    paymentPs.executeUpdate();
                }
            }

            response.sendRedirect(
                    "admin_refund_requests.jsp");

        }catch(Exception e){

            e.printStackTrace();

            response.sendRedirect(
                    "admin_refund_requests.jsp");
        }
    }
}