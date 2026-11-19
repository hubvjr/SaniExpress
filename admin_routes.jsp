<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" import="java.sql.*, com.sani.DBConnection" %>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("login.jsp"); return; }
    String adminUsername = (String) session.getAttribute("username");

    String search = request.getParameter("search");
    if (search == null) search = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin - Routes</title>
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
        .main-layout { display: flex; padding: 24px 40px; gap: 28px; align-items: flex-start; }
        .form-card { background: white; border-radius: 24px; padding: 28px; width: 320px; flex-shrink: 0; box-shadow: 0 8px 30px rgba(0,0,0,0.06); }
        .form-card h2 { font-size: 18px; color: var(--dark-brown); margin-bottom: 4px; }
        .form-card p  { font-size: 12px; color: var(--light-text); margin-bottom: 20px; }
        .field-label { font-size: 10px; font-weight: 700; color: var(--light-text); letter-spacing: 1px; text-transform: uppercase; display: block; margin-bottom: 6px; }
        .input-row { background: #f9f6f5; padding: 11px 14px; border-radius: 12px; display: flex; align-items: center; gap: 10px; margin-bottom: 16px; border: 1px solid transparent; transition: border-color 0.2s; }
        .input-row:focus-within { border-color: var(--dark-brown); }
        .input-row input { border: none; background: none; outline: none; width: 100%; font-family: 'Poppins', sans-serif; font-size: 13px; color: var(--dark-brown); }
        .btn-primary { background: var(--dark-brown); color: white; border: none; padding: 13px 25px; border-radius: 14px; font-family: 'Poppins', sans-serif; font-weight: 700; font-size: 13px; cursor: pointer; width: 100%; display: flex; align-items: center; justify-content: center; gap: 8px; transition: opacity 0.2s; }
        .btn-primary:hover { opacity: 0.88; }

        .page-header { padding: 28px 40px 0 40px; }
        .page-header h1 { font-weight: 800; font-size: 28px; color: var(--dark-brown); }
        .page-header p  { font-size: 13px; color: var(--light-text); margin-top: 4px; }

        .alert { margin: 16px 40px 0 40px; padding: 14px 20px; border-radius: 14px; display: flex; align-items: center; gap: 10px; font-size: 13px; font-weight: 600; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error   { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        .ledger-container { flex: 1; background: white; border-radius: 24px; padding: 28px; box-shadow: 0 8px 30px rgba(0,0,0,0.06); overflow-x: auto; }
        .ledger-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 18px; }
        .ledger-header h2 { font-size: 18px; color: var(--dark-brown); margin-bottom: 4px; }
        .ledger-header p  { font-size: 12px; color: var(--light-text); }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 11px 14px; font-size: 10px; text-transform: uppercase; color: var(--light-text); border-bottom: 2px solid var(--border-light); white-space: nowrap; }
        td { padding: 14px; font-size: 13px; color: var(--dark-brown); border-bottom: 1px solid var(--border-light); vertical-align: middle; }
        tr:last-child td { border-bottom: none; }
        .btn-edit   { background: #f39c12; color: white; border: none; padding: 6px 12px; border-radius: 8px; cursor: pointer; font-size: 11px; font-weight: 700; text-decoration: none; display: inline-flex; align-items: center; gap: 5px; margin-right: 5px; }
        .btn-delete { background: #c0392b; color: white; border: none; padding: 6px 12px; border-radius: 8px; cursor: pointer; font-size: 11px; font-weight: 700; text-decoration: none; display: inline-flex; align-items: center; gap: 5px; }
        .search-btn { padding: 10px 16px; border-radius: 10px; border: none; background: var(--dark-brown); color: white; font-weight: 700; font-size: 12px; cursor: pointer; transition: opacity 0.2s; }
        .search-btn:hover { opacity: 0.85; }
    </style>
    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>
<nav class="top-nav">
    <div class="nav-left"><span class="bus-logo">🚌</span><span class="brand-name">SANIBUS</span></div>
       <div class="nav-center">
        <a href="admin_home.jsp"            class="nav-btn"><i class="fa-solid fa-file-medical"></i> Leave Approvals</a>
        <a href="admin_schedule.jsp"        class="nav-btn"><i class="fa-solid fa-calendar-days"></i> Schedules</a>
        <a href="admin_routes.jsp"          class="nav-btn active"><i class="fa-solid fa-route"></i> Routes</a>
        <a href="admin_bookings.jsp"        class="nav-btn"><i class="fa-solid fa-ticket"></i> Bookings</a>
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

<div class="page-header">
    <h1><i class="fa-solid fa-route" style="font-size:22px; margin-right:10px;"></i>Route Management</h1>
    <p>Add and manage bus routes with origin, destination and distance</p>
</div>

<% if ("success".equals(request.getParameter("msg"))) { %>
    <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Route saved successfully.</div>
<% } else if ("deleted".equals(request.getParameter("msg"))) { %>
    <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Route deleted successfully.</div>
<% } else if ("error".equals(request.getParameter("msg"))) { %>
    <div class="alert alert-error"><i class="fa-solid fa-circle-xmark"></i> Operation failed. Please check the fields and try again.</div>
<% } %>

<div class="main-layout">
    <aside>
        <div class="form-card">
            <h2>Add New Route</h2>
            <p>Define a new origin-destination route for scheduling.</p>
            <form action="AddRouteServlet" method="POST">
                <label class="field-label">Route Name</label>
                <div class="input-row">
                    <i class="fa-solid fa-signs-post" style="color:var(--light-text);"></i>
                    <input type="text" name="route_name" placeholder="e.g., KL - Terengganu Express" required>
                </div>
                <label class="field-label">Origin</label>
                <div class="input-row">
                    <i class="fa-solid fa-location-dot" style="color:var(--light-text);"></i>
                    <input type="text" name="origin" placeholder="e.g., Kuala Lumpur" required>
                </div>
                <label class="field-label">Destination</label>
                <div class="input-row">
                    <i class="fa-solid fa-flag-checkered" style="color:var(--light-text);"></i>
                    <input type="text" name="destination" placeholder="e.g., Kuala Terengganu" required>
                </div>
                <label class="field-label">Distance (km)</label>
                <div class="input-row">
                    <i class="fa-solid fa-road" style="color:var(--light-text);"></i>
                    <input type="number" step="0.01" name="distance_km" placeholder="e.g., 490.00">
                </div>
                <button type="submit" class="btn-primary"><i class="fa-solid fa-plus"></i> Add Route</button>
            </form>
        </div>
    </aside>

    <main class="ledger-container">
        <div class="ledger-header">
            <div>
                <h2>All Routes</h2>
                <p>All registered bus routes in the system</p>
            </div>
            <form method="get" action="admin_routes.jsp" style="display:flex; gap:8px; align-items:center;">
                <input type="text"
                       name="search"
                       value="<%= search %>"
                       placeholder="Search routes..."
                       style="padding:10px 15px; border-radius:10px; border:1px solid #ddd; font-family:'Poppins',sans-serif; font-size:12px; width:200px;">
                <button type="submit" class="search-btn">
                    <i class="fa-solid fa-magnifying-glass"></i>
                </button>
            </form>
        </div>

        <table>
            <thead>
                <tr>
                    <th>#</th><th>Route Name</th><th>Origin</th><th>Destination</th><th>Distance</th><th style="text-align:center;">Actions</th>
                </tr>
            </thead>
            <tbody>
<%
    boolean hasSearch = search != null && !search.trim().isEmpty();
    String sqlQuery = hasSearch
        ? "SELECT * FROM bus_routes WHERE route_name LIKE ? OR origin LIKE ? OR destination LIKE ? ORDER BY id ASC"
        : "SELECT * FROM bus_routes ORDER BY id ASC";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sqlQuery)) {

        if (hasSearch) {
            String like = "%" + search.trim() + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
        }

        try (ResultSet rs = ps.executeQuery()) {
            boolean has = false;
            while (rs.next()) {
                has = true;
%>
                <tr>
                    <td style="color:var(--light-text); font-weight:600;"><%= rs.getInt("id") %></td>
                    <td><strong><%= rs.getString("route_name") %></strong></td>
                    <td><i class="fa-solid fa-circle" style="color:#27ae60; font-size:7px; margin-right:6px;"></i><%= rs.getString("origin") %></td>
                    <td><i class="fa-solid fa-circle" style="color:#e74c3c; font-size:7px; margin-right:6px;"></i><%= rs.getString("destination") %></td>
                    <td><%= rs.getString("distance_km") != null ? rs.getString("distance_km") + " km" : "—" %></td>
                    <td style="text-align:center; white-space:nowrap;">
                        <a href="edit_route.jsp?id=<%= rs.getInt("id") %>" class="btn-edit"><i class="fa-solid fa-pen-to-square"></i> Edit</a>
                        <a href="DeleteRouteServlet?id=<%= rs.getInt("id") %>" class="btn-delete"
                           onclick="return confirm('Delete this route? Associated schedules may be affected.');"><i class="fa-solid fa-trash"></i> Delete</a>
                    </td>
                </tr>
<%
            }
            if (!has) {
%>
                <tr><td colspan="6" style="text-align:center; color:var(--light-text); padding:40px;">
                    <i class="fa-solid fa-route" style="font-size:28px; display:block; margin-bottom:10px; color:#d8a19a;"></i>
                    <%= hasSearch ? "No routes found matching \"" + search + "\"." : "No routes registered yet." %>
                </td></tr>
<%
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
            </tbody>
        </table>
    </main>
</div>
</body>
</html>