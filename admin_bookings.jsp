<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" import="java.sql.*, com.sani.DBConnection" %>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("login.jsp"); return; }
    String adminUsername = (String) session.getAttribute("username");
    String filter = request.getParameter("filter");
    if (filter == null || filter.trim().isEmpty()) filter = "All";

    String search = request.getParameter("search");
    if (search == null) search = "";

    // Stats
    int totalBookings = 0, confirmedCount = 0, cancelledCount = 0;
    try (Connection sc = DBConnection.getConnection()) {
        PreparedStatement sp;
        ResultSet sr;

        sp = sc.prepareStatement("SELECT COUNT(*) FROM booked_seats");
        sr = sp.executeQuery(); if (sr.next()) totalBookings = sr.getInt(1); sr.close(); sp.close();

        sp = sc.prepareStatement("SELECT COUNT(*) FROM booked_seats b INNER JOIN payments p ON b.transaction_id = p.transaction_id WHERE p.status='Success'");
        sr = sp.executeQuery(); if (sr.next()) confirmedCount = sr.getInt(1); sr.close(); sp.close();

        sp = sc.prepareStatement("SELECT COUNT(*) FROM booked_seats b INNER JOIN payments p ON b.transaction_id = p.transaction_id WHERE p.status IS NOT NULL AND p.status <> 'Success'");
        sr = sp.executeQuery(); if (sr.next()) cancelledCount = sr.getInt(1); sr.close(); sp.close();
    } catch (Exception ignored) {}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin - Bookings</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --pink-bg: #d8a19a; --dark-brown: #2b1c1a; --light-text: #8c7673; --border-light: #f0e8e6; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background-color: var(--pink-bg); min-height: 100vh; }
        .top-nav { display: flex; justify-content: space-between; align-items: center; padding: 12px 50px; background: rgba(255,255,255,0.15); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.1); position: sticky; top: 0; z-index: 100; }
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
        .stat-value { font-size: 26px; font-weight: 800; color: var(--dark-brown); }
        .table-container { background: white; border-radius: 20px; overflow: hidden; box-shadow: 0 8px 30px rgba(0,0,0,0.06); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #f9f6f5; padding: 14px 18px; text-align: left; font-size: 10px; font-weight: 700; color: var(--light-text); text-transform: uppercase; border-bottom: 1px solid var(--border-light); white-space: nowrap; }
        td { padding: 16px 18px; font-size: 13px; color: var(--dark-brown); border-bottom: 1px solid var(--border-light); vertical-align: middle; }
        tr:last-child td { border-bottom: none; }
        .status-badge { padding: 5px 12px; border-radius: 8px; font-size: 10px; font-weight: 700; text-transform: uppercase; }
        .status-confirmed { background: #d4edda; color: #155724; }
        .status-pending   { background: #fff3cd; color: #856404; }
        .status-cancelled { background: #f8d7da; color: #721c24; }
        .search-btn { padding: 10px 16px; border-radius: 10px; border: none; background: var(--dark-brown); color: white; font-weight: 700; font-size: 12px; cursor: pointer; transition: 0.2s; }
        .search-btn:hover { opacity: 0.85; }
    </style>
    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>
<nav class="top-nav">
    <div class="nav-left"><span class="bus-logo">&#x1F68C;</span><span class="brand-name">SANIBUS</span></div>
       <div class="nav-center">
        <a href="admin_home.jsp"            class="nav-btn"><i class="fa-solid fa-file-medical"></i> Leave Approvals</a>
        <a href="admin_schedule.jsp"        class="nav-btn"><i class="fa-solid fa-calendar-days"></i> Schedules</a>
        <a href="admin_routes.jsp"          class="nav-btn"><i class="fa-solid fa-route"></i> Routes</a>
        <a href="admin_bookings.jsp"        class="nav-btn active"><i class="fa-solid fa-ticket"></i> Bookings</a>
        <a href="admin_payments.jsp"        class="nav-btn"><i class="fa-solid fa-credit-card"></i> Payments</a>
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
        <h1><i class="fa-solid fa-ticket" style="font-size:22px; margin-right:10px;"></i>Booking Records</h1>
        <div style="display:flex; gap:15px; align-items:center;">

            <form method="get" action="admin_bookings.jsp" style="display:flex; gap:8px; align-items:center;">
                <input type="hidden" name="filter" value="<%= filter %>">
                <input type="text"
                       name="search"
                       value="<%= search %>"
                       placeholder="Search passenger..."
                       style="padding:10px 15px; border-radius:10px; border:1px solid #ddd; width:220px; font-family:'Poppins',sans-serif; font-size:12px;">
                <button type="submit" class="search-btn">
                    <i class="fa-solid fa-magnifying-glass"></i>
                </button>
            </form>

            <div class="filter-buttons">
                <a href="admin_bookings.jsp?filter=All&search=<%= search %>"
                   class="filter-btn <%= "All".equals(filter) ? "active" : "" %>">All</a>
                <a href="admin_bookings.jsp?filter=Confirmed&search=<%= search %>"
                   class="filter-btn <%= "Confirmed".equals(filter) ? "active" : "" %>">Confirmed</a>
                <a href="admin_bookings.jsp?filter=Cancelled&search=<%= search %>"
                   class="filter-btn <%= "Cancelled".equals(filter) ? "active" : "" %>">Cancelled</a>
            </div>

        </div>
    </div>

    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-icon" style="background:#eaf4fb; color:#1a5276;"><i class="fa-solid fa-ticket"></i></div>
            <div><div class="stat-label">Total Bookings</div><div class="stat-value"><%= totalBookings %></div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#d4edda; color:#155724;"><i class="fa-solid fa-circle-check"></i></div>
            <div><div class="stat-label">Confirmed</div><div class="stat-value"><%= confirmedCount %></div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#f8d7da; color:#721c24;"><i class="fa-solid fa-circle-xmark"></i></div>
            <div><div class="stat-label">Cancelled</div><div class="stat-value"><%= cancelledCount %></div></div>
        </div>
    </div>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Passenger</th>
                    <th>Route</th>
                    <th>Departure</th>
                    <th>Seat</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    boolean has = false;
    try {
        conn = DBConnection.getConnection();
        String statusExpr = "CASE WHEN p.status = 'Success' THEN 'Confirmed' " +
                            "WHEN p.status IS NULL THEN 'Pending' ELSE 'Cancelled' END";

        boolean hasSearch = search != null && !search.trim().isEmpty();
        String searchClause = hasSearch ? " AND u.username LIKE ? " : "";

        String sql;
        if ("All".equals(filter)) {
            sql = "SELECT b.id, b.seat_number, b.transaction_id, " +
                  "u.username AS user_username, " +
                  statusExpr + " AS booking_status, " +
                  "r.origin, r.destination, s.departure_time " +
                  "FROM booked_seats b " +
                  "LEFT JOIN bus_schedules s ON b.schedule_id = s.id " +
                  "LEFT JOIN bus_routes r ON s.route_id = r.id " +
                  "LEFT JOIN users u ON b.user_id = u.id " +
                  "LEFT JOIN payments p ON b.transaction_id = p.transaction_id " +
                  "WHERE 1=1 " + searchClause +
                  "ORDER BY b.id DESC";
            ps = conn.prepareStatement(sql);
            if (hasSearch) ps.setString(1, "%" + search.trim() + "%");
        } else {
            sql = "SELECT b.id, b.seat_number, b.transaction_id, " +
                  "u.username AS user_username, " +
                  statusExpr + " AS booking_status, " +
                  "r.origin, r.destination, s.departure_time " +
                  "FROM booked_seats b " +
                  "LEFT JOIN bus_schedules s ON b.schedule_id = s.id " +
                  "LEFT JOIN bus_routes r ON s.route_id = r.id " +
                  "LEFT JOIN users u ON b.user_id = u.id " +
                  "LEFT JOIN payments p ON b.transaction_id = p.transaction_id " +
                  "WHERE (" + statusExpr + ") = ? " + searchClause +
                  "ORDER BY b.id DESC";
            ps = conn.prepareStatement(sql);
            ps.setString(1, filter);
            if (hasSearch) ps.setString(2, "%" + search.trim() + "%");
        }

        rs = ps.executeQuery();
        while (rs.next()) {
            has = true;
            String rowStatus = rs.getString("booking_status");
            if (rowStatus == null) rowStatus = "Pending";
            String badge = "status-pending";
            if ("Confirmed".equalsIgnoreCase(rowStatus)) badge = "status-confirmed";
            else if ("Cancelled".equalsIgnoreCase(rowStatus)) badge = "status-cancelled";

            String orig = rs.getString("origin");
            String dest = rs.getString("destination");
            String routeStr = (orig != null && dest != null) ? orig + " &rarr; " + dest : "&mdash;";

            String dep = rs.getString("departure_time");
            if (dep != null && dep.length() > 16) dep = dep.substring(0, 16);
%>
                <tr>
                    <td style="color:var(--light-text); font-weight:600;">#<%= rs.getInt("id") %></td>
                    <td><strong><%= rs.getString("user_username") != null ? rs.getString("user_username") : "&mdash;" %></strong></td>
                    <td><%= routeStr %></td>
                    <td style="font-size:12px; color:var(--light-text);"><%= dep != null ? dep : "&mdash;" %></td>
                    <td><span style="background:#f5f5f5; padding:4px 10px; border-radius:6px; font-family:monospace; font-weight:700;"><%= rs.getString("seat_number") %></span></td>
                    <td><span class="status-badge <%= badge %>"><%= rowStatus %></span></td>
                </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='6' style='color:red; padding:20px;'>Error: " + e.getMessage() + "</td></tr>");
    } finally {
        if (rs   != null) try { rs.close();   } catch (Exception ignored) {}
        if (ps   != null) try { ps.close();   } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
    if (!has) {
%>
                <tr>
                    <td colspan="6" style="text-align:center; color:var(--light-text); padding:40px;">
                        <i class="fa-solid fa-ticket" style="font-size:28px; display:block; margin-bottom:10px; color:#d8a19a;"></i>
                        No bookings found.
                    </td>
                </tr>
<%  } %>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>