<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" import="java.sql.*, com.sani.DBConnection" %>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("login.jsp"); return; }
    String adminUsername = (String) session.getAttribute("username");
    String filter = request.getParameter("filter");
    if (filter == null || filter.trim().isEmpty()) filter = "All";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin - Payments</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --pink-bg: #d8a19a; --dark-brown: #2b1c1a; --light-text: #8c7673; --border-light: #f0e8e6; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background-color: var(--pink-bg); min-height: 100vh; }
        .top-nav { display: flex; justify-content: space-between; align-items: center; padding: 12px 50px; background: rgba(255,255,255,0.15); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.1); position: sticky; top: 0; z-index: 100; }
        .nav-left { display: flex; align-items: center; gap: 10px; }
        .nav-left .bus-logo { background: #fff; padding: 5px 8px; border-radius: 8px; font-size: 18px; }
        .nav-left .brand-name { font-weight: 800; font-style: italic; font-size: 22px; color: var(--dark-brown); }
        .nav-center { display: flex; gap: 8px; flex-wrap: wrap; }
        .nav-btn { text-decoration: none; color: var(--dark-brown); font-weight: 700; font-size: 11px; padding: 9px 16px; border-radius: 12px; display: flex; align-items: center; gap: 7px; transition: 0.3s; border: 1px solid rgba(43,28,26,0.15); white-space: nowrap; }
        .nav-btn:hover { background: rgba(43,28,26,0.08); }
        .nav-btn.active { background: var(--dark-brown); color: white; border-color: var(--dark-brown); }
        .nav-right { display: flex; align-items: center; gap: 12px; }
        .user-meta { text-align: right; }
        .user-name { font-weight: 800; color: var(--dark-brown); font-size: 14px; text-transform: uppercase; display: block; }
        .user-role { font-size: 9px; font-weight: 600; color: var(--light-text); text-transform: uppercase; }
        .avatar-container { background: white; width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; color: var(--dark-brown); }
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
        .main-content { max-width: 1200px; margin: 0 auto; padding: 30px 40px; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; }
        .page-header h1 { font-size: 28px; font-weight: 800; color: var(--dark-brown); }
        .filter-buttons { display: flex; gap: 10px; background: rgba(255,255,255,0.2); padding: 6px; border-radius: 14px; }
        .filter-btn { padding: 8px 18px; border-radius: 10px; font-weight: 700; font-size: 11px; text-decoration: none; color: var(--dark-brown); transition: 0.2s; }
        .filter-btn.active { background: white; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }

        .stats-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px; }
        .stat-card { background: white; border-radius: 16px; padding: 20px 22px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); display: flex; align-items: center; gap: 16px; }
        .stat-icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
        .stat-label { font-size: 10px; font-weight: 700; color: var(--light-text); text-transform: uppercase; letter-spacing: 1px; }
        .stat-value { font-size: 22px; font-weight: 800; color: var(--dark-brown); }

        .table-container { background: white; border-radius: 20px; overflow: hidden; box-shadow: 0 8px 30px rgba(0,0,0,0.06); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #f9f6f5; padding: 14px 18px; text-align: left; font-size: 10px; font-weight: 700; color: var(--light-text); text-transform: uppercase; border-bottom: 1px solid var(--border-light); white-space: nowrap; }
        td { padding: 16px 18px; font-size: 13px; color: var(--dark-brown); border-bottom: 1px solid var(--border-light); vertical-align: middle; }
        tr:last-child td { border-bottom: none; }
        .status-badge { padding: 5px 12px; border-radius: 8px; font-size: 10px; font-weight: 700; text-transform: uppercase; }
        .status-success  { background: #d4edda; color: #155724; }
        .status-pending  { background: #fff3cd; color: #856404; }
        .status-failed   { background: #f8d7da; color: #721c24; }
        .status-refunded { background: #e2e3e5; color: #383d41; }
    </style>
    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>
<nav class="top-nav">
    <div class="nav-left"><span class="bus-logo">🚌</span><span class="brand-name">SANIBUS</span></div>
       <div class="nav-center">
        <a href="admin_home.jsp"            class="nav-btn"><i class="fa-solid fa-file-medical"></i> Leave Approvals</a>
        <a href="admin_schedule.jsp"        class="nav-btn"><i class="fa-solid fa-calendar-days"></i> Schedules</a>
        <a href="admin_routes.jsp"          class="nav-btn"><i class="fa-solid fa-route"></i> Routes</a>
        <a href="admin_bookings.jsp"        class="nav-btn"><i class="fa-solid fa-ticket"></i> Bookings</a>
        <a href="admin_payments.jsp"        class="nav-btn active"><i class="fa-solid fa-credit-card"></i> Payments</a>
        <a href="admin_refund_requests.jsp" class="nav-btn"><i class="fa-solid fa-rotate-left"></i> Refunds</a>
        <a href="admin_admins.jsp" class="nav-btn "><i class="fa-solid fa-credit-card"></i> Admins</a>
        <a href="admin_managers.jsp" class="nav-btn"><i class="fa-solid fa-credit-card"></i> Managers</a>
        <a href="admin_drivers.jsp" class="nav-btn"><i class="fa-solid fa-credit-card"></i> Drivers</a>
    </div>
    <div class="nav-right">
        <div class="user-meta"><span class="user-name"><%= adminUsername %></span><span class="user-role">System Admin</span></div>
       <a href="edit_profile.jsp" class="avatar">
    <i class="fa-regular fa-user"></i>
</a>
        <a href="LogoutServlet" style="color:var(--dark-brown); margin-left:8px; font-size:20px;"><i class="fa-solid fa-arrow-right-from-bracket"></i></a>
    </div>
</nav>

<div class="main-content">
    <div class="page-header">
        <h1><i class="fa-solid fa-credit-card" style="font-size:22px; margin-right:10px;"></i>Payment Records</h1>
        <div class="filter-buttons">
            <a href="admin_payments.jsp?filter=All"      class="filter-btn <%= "All".equals(filter)      ? "active" : "" %>">All</a>
            <a href="admin_payments.jsp?filter=Success"  class="filter-btn <%= "Success".equals(filter)  ? "active" : "" %>">Success</a>
            <a href="admin_payments.jsp?filter=Pending"  class="filter-btn <%= "Pending".equals(filter)  ? "active" : "" %>">Pending</a>
            <a href="admin_payments.jsp?filter=Failed"   class="filter-btn <%= "Failed".equals(filter)   ? "active" : "" %>">Failed</a>
            <a href="admin_payments.jsp?filter=Refunded" class="filter-btn <%= "Refunded".equals(filter) ? "active" : "" %>">Refunded</a>
        </div>
    </div>

    <%
        int totalPay = 0; double totalRevenue = 0;
        try (Connection sc = DBConnection.getConnection()) {
            try (PreparedStatement sp = sc.prepareStatement("SELECT COUNT(*), COALESCE(SUM(amount),0) FROM payments WHERE status='Success'"); ResultSet sr = sp.executeQuery()) {
                if(sr.next()) { totalPay = sr.getInt(1); totalRevenue = sr.getDouble(2); }
            }
        } catch (Exception ignored) {}
    %>
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-icon" style="background:#d4edda; color:#155724;"><i class="fa-solid fa-circle-check"></i></div>
            <div><div class="stat-label">Successful Payments</div><div class="stat-value"><%= totalPay %></div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fff3cd; color:#856404;"><i class="fa-solid fa-malaysian-ringgit-sign"></i></div>
            <div><div class="stat-label">Total Revenue</div><div class="stat-value">RM <%= String.format("%.2f", totalRevenue) %></div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#cce5ff; color:#004085;"><i class="fa-solid fa-chart-line"></i></div>
            <div><div class="stat-label">Avg per Transaction</div><div class="stat-value">RM <%= totalPay > 0 ? String.format("%.2f", totalRevenue/totalPay) : "0.00" %></div></div>
        </div>
    </div>

    <div class="table-container">
        <table>
            <thead>
                <tr><th>#</th><th>User</th><th>Booking Ref</th><th>Amount</th><th>Method</th><th>Paid At</th><th>Status</th></tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "All".equals(filter)
                        ? "SELECT p.id, p.amount, p.payment_method, p.transaction_id, p.status, u.username AS user_username, NULL AS paid_at FROM payments p LEFT JOIN users u ON p.user_id = u.id ORDER BY p.id DESC"
                        : "SELECT p.id, p.amount, p.payment_method, p.transaction_id, p.status, u.username AS user_username, NULL AS paid_at FROM payments p LEFT JOIN users u ON p.user_id = u.id WHERE p.status = ? ORDER BY p.id DESC";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        if (!"All".equals(filter)) ps.setString(1, filter);
                        try (ResultSet rs = ps.executeQuery()) {
                            boolean has = false;
                            while (rs.next()) {
                                has = true;
                                String status = rs.getString("status");
                                String badge = "status-pending";
                                if ("Success".equalsIgnoreCase(status))  badge = "status-success";
                                else if ("Failed".equalsIgnoreCase(status))   badge = "status-failed";
                                else if (status != null && status.startsWith("Refund")) badge = "status-refunded";
                                String paidAt = rs.getString("paid_at");
                                if (paidAt != null && paidAt.length() >= 16) paidAt = paidAt.substring(0,16);
            %>
                <tr>
                    <td style="color:var(--light-text); font-weight:600;">#<%= rs.getInt("id") %></td>
                    <td><strong><%= rs.getString("user_username") != null ? rs.getString("user_username") : "—" %></strong></td>
                    <td><span style="background:#f5f5f5; padding:3px 8px; border-radius:6px; font-family:monospace; font-size:12px;"><%= rs.getString("transaction_id") != null ? rs.getString("transaction_id") : "—" %></span></td>
                    <td><strong style="color:#27ae60;">RM <%= String.format("%.2f", rs.getDouble("amount")) %></strong></td>
                    <td><%= rs.getString("payment_method") != null ? rs.getString("payment_method") : "—" %></td>
                    <td style="color:var(--light-text); font-size:12px;"><%= paidAt != null ? paidAt : "—" %></td>
                    <td><span class="status-badge <%= badge %>"><%= status %></span></td>
                </tr>
            <%      }
                    if (!has) { %>
                <tr><td colspan="7" style="text-align:center; color:var(--light-text); padding:40px;">
                    <i class="fa-solid fa-credit-card" style="font-size:28px; display:block; margin-bottom:10px; color:#d8a19a;"></i>No payment records found.
                </td></tr>
            <% } } } } catch (Exception e) { e.printStackTrace(); } %>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
