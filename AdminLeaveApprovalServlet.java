package com.sani;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AdminLeaveApprovalServlet")
public class AdminLeaveApprovalServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (request.getSession().getAttribute("username") == null) { response.sendRedirect("login.jsp"); return; }

        String leaveId = request.getParameter("leaveId");
        String statusAction = request.getParameter("statusAction");
        String targetStatus = "Approve".equalsIgnoreCase(statusAction) ? "Approved" : "Rejected";

        String sql = "UPDATE driver_leaves SET status = ? WHERE id = ? AND status = 'Pending'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, targetStatus);
            ps.setInt(2, Integer.parseInt(leaveId));
            ps.executeUpdate();
            
            response.sendRedirect("admin_home.jsp?filter=Pending&msg=updated");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_home.jsp?filter=Pending&msg=error");
        }
    }
}