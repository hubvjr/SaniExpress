package com.sani;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.ServletException;

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session =
                request.getSession();

        String method =
                request.getParameter("method");

        try {

            if ("FPX".equals(method)) {

                response.sendRedirect(
                        "ToyyibPayServlet");

                return;
            }

            Integer userId =
                    (Integer) session.getAttribute(
                            "userId");

            String transactionId =
                    (String) session.getAttribute(
                            "bookingTransactionId");

            String scheduleId =
                    (String) session.getAttribute(
                            "schedule_id");

            String amount =
                    (String) session.getAttribute(
                            "totalAmount");

            Boolean insurance =
                    (Boolean) session.getAttribute(
                            "insurance");

            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(

"INSERT INTO payments "
+ "(user_id,schedule_id,"
+ "amount,payment_method,"
+ "transaction_id,status,"
+ "refund_guarantee)"
+ "VALUES (?,?,?,?,?,?,?)");

            ps.setInt(1,
                    userId);

            ps.setInt(2,
                    Integer.parseInt(
                            scheduleId));

            ps.setDouble(3,
                    Double.parseDouble(
                            amount));

            ps.setString(4,
                    method);

            ps.setString(5,
                    transactionId);

            ps.setString(6,
                    "Success");

            ps.setInt(7,
                    insurance != null
                    && insurance
                    ? 1 : 0);

            ps.executeUpdate();

            response.sendRedirect(

"payment_confirmed.jsp?id="
+ transactionId);

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
"paymentSelection.jsp?error=payment");
        }
    }
}