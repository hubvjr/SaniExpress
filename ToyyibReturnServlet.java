
package com.sani;

import java.io.IOException;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ToyyibReturnServlet")
public class ToyyibReturnServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String statusId =
                request.getParameter("status_id");

        HttpSession session =
                request.getSession();

        String transactionId =
                (String) session.getAttribute(
                        "bookingTransactionId");

        try {

            Connection con =
                    DBConnection.getConnection();

            if ("1".equals(statusId)) {

                PreparedStatement check =
                        con.prepareStatement(
                        "SELECT COUNT(*) "
                      + "FROM payments "
                      + "WHERE transaction_id=?");

                check.setString(
                        1,
                        transactionId);

                ResultSet rs =
                        check.executeQuery();

                boolean exists = false;

                if (rs.next()) {
                    exists = rs.getInt(1) > 0;
                }

                if (!exists) {

                    Integer userId =
                            (Integer) session.getAttribute(
                                    "userId");

                    String scheduleId =
                            (String) session.getAttribute(
                                    "schedule_id");

                    String amount =
                            (String) session.getAttribute(
                                    "totalAmount");

                    Boolean insurance =
                            (Boolean) session.getAttribute(
                                    "insurance");

                    PreparedStatement insert =
                            con.prepareStatement(

                            "INSERT INTO payments "
                          + "(user_id, schedule_id, amount, "
                          + "payment_method, transaction_id, "
                          + "status, refund_guarantee) "
                          + "VALUES (?,?,?,?,?,?,?)");

                    insert.setInt(
                            1,
                            userId);

                    insert.setInt(
                            2,
                            Integer.parseInt(scheduleId));

                    insert.setDouble(
                            3,
                            Double.parseDouble(amount));

                    insert.setString(
                            4,
                            "ToyyibPay");

                    insert.setString(
                            5,
                            transactionId);

                    insert.setString(
                            6,
                            "Success");

                    insert.setInt(
                            7,
                            insurance != null && insurance
                                    ? 1 : 0);

                    insert.executeUpdate();

                } else {

                    PreparedStatement update =
                            con.prepareStatement(
                            "UPDATE payments "
                          + "SET status='Success' "
                          + "WHERE transaction_id=?");

                    update.setString(
                            1,
                            transactionId);

                    update.executeUpdate();
                }

                response.sendRedirect(
                        "payment_confirmed.jsp?id="
                        + transactionId);

            } else {

                response.sendRedirect(
                        "paymentSelection.jsp?error=failed");
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "paymentSelection.jsp?error=database");
        }
    }
}
