package com.sani;

import com.sani.DBConnection;

import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;

/**
 * EditLeaveServlet
 *
 * GET  ?leaveId=X  → renders the edit form pre-filled with existing leave data
 * POST             → validates, updates the DB row, redirects back to driver_home.jsp
 *
 * Only Pending leaves belonging to the logged-in driver may be edited.
 */

@MultipartConfig(maxFileSize = 5 * 1024 * 1024)   // 5 MB PDF limit
public class EditLeaveServlet extends HttpServlet {

    // ─────────────────────────────────────────────────────────────────────────
    // GET  –  show pre-filled edit form
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String username = (String) session.getAttribute("username");

        String leaveIdStr = request.getParameter("leaveId");
        if (leaveIdStr == null || leaveIdStr.isBlank()) {
            response.sendRedirect("driver_home.jsp?msg=error");
            return;
        }

        int leaveId;
        try { leaveId = Integer.parseInt(leaveIdStr); }
        catch (NumberFormatException e) {
            response.sendRedirect("driver_home.jsp?msg=error");
            return;
        }

        // Fetch the leave row – must belong to this driver and still be Pending
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT * FROM driver_leaves WHERE id = ? AND driver_username = ? AND status = 'Pending'")) {
            ps.setInt(1, leaveId);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    // Not found, not owned by this driver, or no longer Pending
                    response.sendRedirect("driver_home.jsp?msg=error");
                    return;
                }
                request.setAttribute("leaveId",    rs.getInt("id"));
                request.setAttribute("leaveType",  rs.getString("leave_type"));
                request.setAttribute("startDate",  rs.getString("start_date"));   // yyyy-MM-dd for input[type=date]
                request.setAttribute("endDate",    rs.getString("end_date"));
                request.setAttribute("reason",     rs.getString("reason"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("driver_home.jsp?msg=error");
            return;
        }

        request.setAttribute("username", username);
        request.getRequestDispatcher("edit_leave.jsp").forward(request, response);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST  –  save the updated leave
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String username = (String) session.getAttribute("username");

        String leaveIdStr = request.getParameter("leaveId");
        String leaveType  = request.getParameter("leaveType");
        String startDate  = request.getParameter("startDate");
        String endDate    = request.getParameter("endDate");
        String reason     = request.getParameter("reason");
        if (reason == null) reason = "";

        // Basic validation
        if (leaveIdStr == null || leaveType == null || startDate == null || endDate == null
                || startDate.isBlank() || endDate.isBlank()) {
            response.sendRedirect("driver_home.jsp?msg=error");
            return;
        }

        int leaveId;
        try { leaveId = Integer.parseInt(leaveIdStr); }
        catch (NumberFormatException e) {
            response.sendRedirect("driver_home.jsp?msg=error");
            return;
        }

        // Handle optional PDF upload for Medical leaves
        byte[] pdfBytes = null;
        Part filePart = null;
        try { filePart = request.getPart("leaveProof"); } catch (Exception ignored) {}

        if (filePart != null && filePart.getSize() > 0) {
            try (InputStream is = filePart.getInputStream();
                 ByteArrayOutputStream bos = new ByteArrayOutputStream()) {
                byte[] buf = new byte[4096];
                int read;
                while ((read = is.read(buf)) != -1) bos.write(buf, 0, read);
                pdfBytes = bos.toByteArray();
            }
        }

        // Build UPDATE – only update proof_document if a new file was supplied
        String sql = (pdfBytes != null)
            ? "UPDATE driver_leaves SET leave_type=?, start_date=?, end_date=?, reason=?, proof_document=? " +
              "WHERE id=? AND driver_username=? AND status='Pending'"
            : "UPDATE driver_leaves SET leave_type=?, start_date=?, end_date=?, reason=? " +
              "WHERE id=? AND driver_username=? AND status='Pending'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, leaveType);
            ps.setString(2, startDate);
            ps.setString(3, endDate);
            ps.setString(4, reason.trim());

            if (pdfBytes != null) {
                ps.setBytes (5, pdfBytes);
                ps.setInt   (6, leaveId);
                ps.setString(7, username);
            } else {
                ps.setInt   (5, leaveId);
                ps.setString(6, username);
            }

            int rows = ps.executeUpdate();
            if (rows == 0) {
                // Row not found / not owned / already processed
                response.sendRedirect("driver_home.jsp?msg=error");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("driver_home.jsp?msg=error");
            return;
        }

        response.sendRedirect("driver_home.jsp?msg=updated&tab=leave");
    }
}