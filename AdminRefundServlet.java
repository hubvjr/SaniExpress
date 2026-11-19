package com.sani;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class AdminRefundServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String refundIdParam = request.getParameter("refundId");
        String action        = request.getParameter("action"); // "Approve" or "Reject"

        if (refundIdParam == null || action == null) {
            response.sendRedirect("admin_refund_requests.jsp?msg=error");
            return;
        }

        String newStatus = "Approve".equalsIgnoreCase(action) ? "Approved" : "Rejected";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE refund_requests SET status = ? WHERE id = ?")) {

            ps.setString(1, newStatus);
            ps.setInt(2, Integer.parseInt(refundIdParam));
            ps.executeUpdate();
            response.sendRedirect("admin_refund_requests.jsp?msg=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_refund_requests.jsp?msg=error");
        }
    }
}
