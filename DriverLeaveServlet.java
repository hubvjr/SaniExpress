package com.sani;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Types;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;


@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB limit for MC PDFs
    maxRequestSize = 1024 * 1024 * 50     // 50MB total request limit
)
public class DriverLeaveServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // Enforce UTF-8 Encoding for incoming multipart data form values
        request.setCharacterEncoding("UTF-8");
        
        String username = (String) request.getSession().getAttribute("username");
        if (username == null) { 
            response.sendRedirect("login.jsp"); 
            return; 
        }

        // Standard request.getParameter works perfectly with @MultipartConfig 
        // as long as it's called before processing binary Parts.
        String action = request.getParameter("action");

        if ("submit".equals(action)) {
            String leaveType = request.getParameter("leaveType");
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            String reason = request.getParameter("reason");

            InputStream fileInputStream = null;
            Part filePart = null;

            try {
                // Only attempt to extract the document stream if it's a Medical Leave
                if ("Medical".equalsIgnoreCase(leaveType)) {
                    filePart = request.getPart("leaveProof");
                    if (filePart != null && filePart.getSize() > 0) {
                        fileInputStream = filePart.getInputStream();
                    }
                }
            } catch (Exception e) {
                System.err.println("Error reading multi-part file binary payload: " + e.getMessage());
            }

            String sql = "INSERT INTO driver_leaves (driver_username, leave_type, start_date, end_date, reason, leave_proof, status) VALUES (?, ?, ?, ?, ?, ?, 'Pending')";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, username);
                ps.setString(2, leaveType);
                ps.setString(3, startDate);
                ps.setString(4, endDate);
                
                // Set text justification descriptive parameters based on leave selection context
                if ("Medical".equalsIgnoreCase(leaveType)) {
                    ps.setString(5, "Medical Certificate Attached");
                } else {
                    ps.setString(5, (reason != null) ? reason.trim() : "");
                }
                
                // Safe handling of binary blobs within the database connectivity layer
                if ("Medical".equalsIgnoreCase(leaveType) && fileInputStream != null) {
                    ps.setBlob(6, fileInputStream);
                } else {
                    ps.setNull(6, Types.BLOB);
                }

                ps.executeUpdate();
               response.sendRedirect("driver_home.jsp?msg=success&leaveType=" + leaveType);
                
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("driver_home.jsp?tab=leave&msg=error");
            } finally {
                if (fileInputStream != null) { 
                    try { fileInputStream.close(); } catch (IOException ignore) {} 
                }
            }
            
        } else if ("cancel".equals(action)) {
            String leaveId = request.getParameter("leaveId");
            String sql = "UPDATE driver_leaves SET status = 'Cancelled' WHERE id = ? AND driver_username = ? AND status = 'Pending'";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, Integer.parseInt(leaveId));
                ps.setString(2, username);
                ps.executeUpdate();
                response.sendRedirect("driver_home.jsp?tab=leave&msg=cancelled");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("driver_home.jsp?tab=leave&msg=error");
            }
        }
    }
}