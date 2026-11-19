<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" import="java.sql.*, com.sani.DBConnection" %>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String adminUsername = (String) session.getAttribute("username");
    String filter = request.getParameter("filter");
    if (filter == null || filter.trim().isEmpty())
        filter = "Pending";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Admin Panel - SANI BUS</title>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --pink-bg: #d8a19a;
                --dark-brown: #2b1c1a;
                --white: #ffffff;
                --light-text: #8c7673;
                --border-light: #f0e8e6;
            }
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                font-family: 'Poppins', sans-serif;
                background-color: var(--pink-bg);
                min-height: 100vh;
            }

            /* ── NAVBAR ── */
            .top-nav {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 12px 50px;
                background: rgba(255,255,255,0.15);
                backdrop-filter: blur(10px);
                border-bottom: 1px solid rgba(255,255,255,0.1);
                position: sticky;
                top: 0;
                z-index: 100;
            }
            .nav-left {
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .nav-left .bus-logo {
                background: #fff;
                padding: 5px 8px;
                border-radius: 8px;
                font-size: 18px;
            }
            .nav-left .brand-name {
                font-weight: 800;
                font-style: italic;
                font-size: 22px;
                color: var(--dark-brown);
            }
            .nav-center {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }
            .nav-btn {
                text-decoration: none;
                color: var(--dark-brown);
                font-weight: 700;
                font-size: 11px;
                padding: 9px 16px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                gap: 7px;
                transition: 0.3s;
                border: 1px solid rgba(43,28,26,0.15);
                white-space: nowrap;
            }
            .nav-btn:hover {
                background: rgba(43,28,26,0.08);
            }
            .nav-btn.active {
                background: var(--dark-brown);
                color: white;
                border-color: var(--dark-brown);
            }
            .nav-right {
                display: flex;
                align-items: center;
                gap: 12px;
            }
            .user-meta {
                text-align: right;
                display: flex;
                flex-direction: column;
            }
            .user-name {
                font-weight: 800;
                color: var(--dark-brown);
                font-size: 14px;
                text-transform: uppercase;
            }
            .user-role {
                font-size: 9px;
                font-weight: 600;
                color: var(--light-text);
                text-transform: uppercase;
            }
            .avatar-container {
                background: white;
                width: 40px;
                height: 40px;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: var(--dark-brown);
                box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            }

            /* ── CONTENT ── */
            .main-content {
                max-width: 1200px;
                margin: 0 auto;
                padding: 30px 40px;
            }
            .page-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 30px;
            }
            .page-header h1 {
                font-size: 28px;
                font-weight: 800;
                color: var(--dark-brown);
            }
            .avatar{
                width:44px;
                height:44px;
                border-radius:12px;
                background:#fff;
                display:flex;
                align-items:center;
                justify-content:center;
                text-decoration:none;
                color:#2b1c1a;
            }
            .filter-buttons {
                display: flex;
                gap: 10px;
                background: rgba(255,255,255,0.2);
                padding: 6px;
                border-radius: 14px;
            }
            .filter-btn {
                padding: 8px 18px;
                border-radius: 10px;
                font-weight: 700;
                font-size: 11px;
                text-decoration: none;
                color: var(--dark-brown);
                transition: 0.2s;
            }
            .filter-btn.active {
                background: var(--white);
                box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            }

            .table-container {
                background: white;
                border-radius: 20px;
                overflow: hidden;
                box-shadow: 0 8px 30px rgba(0,0,0,0.06);
            }
            .admin-table {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
            }
            .admin-table th {
                background: #f9f6f5;
                padding: 16px 20px;
                text-align: left;
                font-size: 11px;
                font-weight: 700;
                color: var(--light-text);
                text-transform: uppercase;
                border-bottom: 1px solid var(--border-light);
            }
            .admin-table td {
                padding: 18px 20px;
                font-size: 13px;
                color: var(--dark-brown);
                border-bottom: 1px solid var(--border-light);
            }

            .action-control-btn {
                border: none;
                padding: 8px 14px;
                border-radius: 8px;
                font-size: 12px;
                font-weight: 700;
                cursor: pointer;
                color: white;
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }
            .btn-approve {
                background: #2ecc71;
            }
            .btn-reject {
                background: #e74c3c;
            }
            .status-badge {
                padding: 6px 14px;
                border-radius: 8px;
                font-size: 11px;
                font-weight: 700;
                text-transform: uppercase;
            }
            .status-pending   {
                background: #fff3cd;
                color: #856404;
            }
            .status-approved  {
                background: #d4edda;
                color: #155724;
            }
            .status-rejected  {
                background: #f8d7da;
                color: #721c24;
            }
            .status-cancelled {
                background: #e2e3e5;
                color: #383d41;
            }
            .alert {
                padding: 12px 20px;
                border-radius: 12px;
                margin-bottom: 25px;
                font-size: 13px;
                font-weight: 600;
                background: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
                display: flex;
                align-items: center;
                gap: 8px;
            }
        </style>
        <link rel="stylesheet" href="sani-theme.css">
</head>
    <body>

        <!-- ══════════════ NAVBAR ══════════════ -->
        <nav class="top-nav">
            <div class="nav-left">
                <span class="bus-logo">🚌</span>
                <span class="brand-name">SANIBUS</span>
            </div>
            <div class="nav-center">
                <a href="admin_home.jsp"            class="nav-btn active"><i class="fa-solid fa-file-medical"></i> Leave Approvals</a>
                <a href="admin_schedule.jsp"        class="nav-btn"><i class="fa-solid fa-calendar-days"></i> Schedules</a>
                <a href="admin_routes.jsp"          class="nav-btn"><i class="fa-solid fa-route"></i> Routes</a>
                <a href="admin_bookings.jsp"        class="nav-btn"><i class="fa-solid fa-ticket"></i> Bookings</a>
                <a href="admin_payments.jsp"        class="nav-btn"><i class="fa-solid fa-credit-card"></i> Payments</a>
                <a href="admin_refund_requests.jsp" class="nav-btn"><i class="fa-solid fa-rotate-left"></i> Refunds</a>
                <a href="admin_admins.jsp" class="nav-btn"><i class="fa-solid fa-credit-card"></i> Admins</a>
                <a href="admin_managers.jsp" class="nav-btn"><i class="fa-solid fa-credit-card"></i> Managers</a>
                <a href="admin_drivers.jsp" class="nav-btn"><i class="fa-solid fa-credit-card"></i> Drivers</a>
            </div>
            <div class="nav-right">
                <div class="user-meta">
                    <span class="user-name"><%= adminUsername%></span>
                    <span class="user-role">Manager</span>
                </div>
                <a href="edit_profile.jsp" class="avatar">
                    <i class="fa-regular fa-user"></i>
                </a>
                <a href="LogoutServlet" style="color:var(--dark-brown); margin-left:8px; font-size:20px;" title="Logout">
                    <i class="fa-solid fa-arrow-right-from-bracket"></i>
                </a>
            </div>
        </nav>

        <!-- ══════════════ MAIN ══════════════ -->
        <div class="main-content">
            <div class="page-header">
                <h1>Leave Requests Matrix</h1>
                <div class="filter-buttons">
                    <a href="admin_home.jsp?filter=Pending"  class="filter-btn <%= "Pending".equals(filter) ? "active" : ""%>">Pending</a>
                    <a href="admin_home.jsp?filter=Approved" class="filter-btn <%= "Approved".equals(filter) ? "active" : ""%>">Approved</a>
                    <a href="admin_home.jsp?filter=Rejected" class="filter-btn <%= "Rejected".equals(filter) ? "active" : ""%>">Rejected</a>
                    <a href="admin_home.jsp?filter=All"      class="filter-btn <%= "All".equals(filter) ? "active" : ""%>">All Records</a>
                </div>
            </div>

            <% if (request.getParameter("msg") != null && !"error".equals(request.getParameter("msg"))) { %>
            <div class="alert"><i class="fa-solid fa-circle-check"></i> Database record status state updated safely.</div>
            <% } %>

            <div class="table-container">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Driver</th>
                            <th>Type</th>
                            <th>Start</th>
                            <th>End</th>
                            <th>Reasoning Document Reference</th>
                            <th>Status</th>
                            <th>Management Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "All".equals(filter)
                                        ? "SELECT * FROM driver_leaves ORDER BY created_at DESC"
                                        : "SELECT * FROM driver_leaves WHERE status = ? ORDER BY created_at DESC";
                                try (PreparedStatement pst = conn.prepareStatement(sql)) {
                                    if (!"All".equals(filter)) {
                                        pst.setString(1, filter);
                                    }
                                    try (ResultSet rs = pst.executeQuery()) {
                                        boolean hasData = false;
                                        while (rs.next()) {
                                            hasData = true;
                                            int leaveId = rs.getInt("id");
                                            String status = rs.getString("status");
                                            String type = rs.getString("leave_type");
                                            Blob proof = rs.getBlob("leave_proof");
                                            String badge = "status-pending";
                                            if ("Approved".equalsIgnoreCase(status))
                                                badge = "status-approved";
                                            else if ("Rejected".equalsIgnoreCase(status))
                                                badge = "status-rejected";
                                            else if ("Cancelled".equalsIgnoreCase(status))
                                                badge = "status-cancelled";
                        %>
                        <tr>
                            <td><strong><%= rs.getString("driver_username")%></strong></td>
                            <td><%= type%></td>
                            <td><%= rs.getString("start_date")%></td>
                            <td><%= rs.getString("end_date")%></td>
                            <td>
                                <% if ("Medical".equalsIgnoreCase(type) && proof != null && proof.length() > 0) {%>
                                <a href="ViewProofServlet?id=<%= leaveId%>" target="_blank" style="color:#2980b9; font-weight:600;">
                                    <i class="fa-solid fa-file-pdf"></i> Stream MC PDF
                                </a>
                                <% } else {%>
                                <%= rs.getString("reason")%>
                                <% }%>
                            </td>
                            <td><span class="status-badge <%= badge%>"><%= status%></span></td>
                            <td>
                                <% if ("Pending".equalsIgnoreCase(status)) {%>
                                <div style="display:flex; gap:5px;">
                                    <form action="AdminLeaveApprovalServlet" method="POST">
                                        <input type="hidden" name="leaveId" value="<%= leaveId%>">
                                        <input type="hidden" name="statusAction" value="Approve">
                                        <button type="submit" class="action-control-btn btn-approve" onclick="return confirm('Approve this leave request?');">
                                            <i class="fa-solid fa-check"></i> Approve
                                        </button>
                                    </form>
                                    <form action="AdminLeaveApprovalServlet" method="POST">
                                        <input type="hidden" name="leaveId" value="<%= leaveId%>">
                                        <input type="hidden" name="statusAction" value="Reject">
                                        <button type="submit" class="action-control-btn btn-reject" onclick="return confirm('Reject this leave request?');">
                                            <i class="fa-solid fa-xmark"></i> Reject
                                        </button>
                                    </form>
                                </div>
                                <% } else { %>
                                <span style="color:var(--light-text); font-size:12px;">—</span>
                                <% } %>
                            </td>
                        </tr>
                        <%
                            }
                            if (!hasData) {
                        %>
                        <tr>
                            <td colspan="7" style="text-align:center; color:var(--light-text); padding:40px;">
                                <i class="fa-solid fa-file-circle-xmark" style="font-size:28px; display:block; margin-bottom:10px; color:#d8a19a;"></i>
                                No leave rows found matching constraints.
                            </td>
                        </tr>
                        <%
                                        }
                                    }
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

    </body>
</html>
