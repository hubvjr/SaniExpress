<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" import="java.sql.*, com.sani.DBConnection" %>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String adminUsername = (String) session.getAttribute("username");
    String routeId = request.getParameter("id");
    String routeName = "";
    String origin = "";
    String destination = "";
    String distanceKm = "";
    boolean found = false;

    if (routeId == null || routeId.trim().isEmpty()) {
        response.sendRedirect("admin_routes.jsp?msg=error");
        return;
    }

    try (Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM bus_routes WHERE id = ?")) {

        ps.setInt(1, Integer.parseInt(routeId));

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                found = true;
                routeName = rs.getString("route_name") != null ? rs.getString("route_name") : "";
                origin = rs.getString("origin") != null ? rs.getString("origin") : "";
                destination = rs.getString("destination") != null ? rs.getString("destination") : "";
                distanceKm = rs.getString("distance_km") != null ? rs.getString("distance_km") : "";
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("admin_routes.jsp?msg=error");
        return;
    }

    if (!found) {
        response.sendRedirect("admin_routes.jsp?msg=error");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Route</title>
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
        .page-header { padding: 28px 40px 0 40px; }
        .page-header h1 { font-weight: 800; font-size: 28px; color: var(--dark-brown); }
        .page-header p { font-size: 13px; color: var(--light-text); margin-top: 4px; }
        .form-card { background: white; border-radius: 24px; padding: 28px; max-width: 520px; margin: 24px 40px; box-shadow: 0 8px 30px rgba(0,0,0,0.06); }
        .field-label { font-size: 10px; font-weight: 700; color: var(--light-text); letter-spacing: 1px; text-transform: uppercase; display: block; margin-bottom: 6px; }
        .input-row { background: #f9f6f5; padding: 11px 14px; border-radius: 12px; display: flex; align-items: center; gap: 10px; margin-bottom: 16px; border: 1px solid transparent; transition: border-color 0.2s; }
        .input-row:focus-within { border-color: var(--dark-brown); }
        .input-row input { border: none; background: none; outline: none; width: 100%; font-family: 'Poppins', sans-serif; font-size: 13px; color: var(--dark-brown); }
        .actions { display: flex; gap: 10px; margin-top: 8px; }
        .btn-primary, .btn-secondary { border: none; padding: 13px 20px; border-radius: 14px; font-family: 'Poppins', sans-serif; font-weight: 700; font-size: 13px; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 8px; }
        .btn-primary { background: var(--dark-brown); color: white; flex: 1; }
        .btn-secondary { background: #f0e8e6; color: var(--dark-brown); }
    </style>
    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>
<nav class="top-nav">
    <div class="nav-left"><span class="bus-logo">&#x1F68C;</span><span class="brand-name">SANIBUS</span></div>
    <div class="nav-center">
        <a href="admin_home.jsp" class="nav-btn"><i class="fa-solid fa-file-medical"></i> Leave Approvals</a>
        <a href="admin_schedule.jsp" class="nav-btn"><i class="fa-solid fa-calendar-days"></i> Schedules</a>
        <a href="admin_routes.jsp" class="nav-btn active"><i class="fa-solid fa-route"></i> Routes</a>
        <a href="admin_drivers.jsp" class="nav-btn"><i class="fa-solid fa-id-card"></i> Drivers</a>
        <a href="admin_bookings.jsp" class="nav-btn"><i class="fa-solid fa-ticket"></i> Bookings</a>
        <a href="admin_payments.jsp" class="nav-btn"><i class="fa-solid fa-credit-card"></i> Payments</a>
        <a href="admin_refund_requests.jsp" class="nav-btn"><i class="fa-solid fa-rotate-left"></i> Refunds</a>
    </div>
    <div class="nav-right">
        <div class="user-meta"><span class="user-name"><%= adminUsername %></span><span class="user-role">System Admin</span></div>
        <div class="avatar-container"><i class="fa-regular fa-user"></i></div>
        <a href="LogoutServlet" style="color:var(--dark-brown); margin-left:8px; font-size:20px;"><i class="fa-solid fa-arrow-right-from-bracket"></i></a>
    </div>
</nav>

<div class="page-header">
    <h1><i class="fa-solid fa-pen-to-square" style="font-size:22px; margin-right:10px;"></i>Edit Route</h1>
    <p>Update route information used by schedules and driver assignments</p>
</div>

<div class="form-card">
    <form action="EditRouteServlet" method="POST">
        <input type="hidden" name="id" value="<%= routeId %>">

        <label class="field-label">Route Name</label>
        <div class="input-row">
            <i class="fa-solid fa-signs-post" style="color:var(--light-text);"></i>
            <input type="text" name="route_name" value="<%= routeName %>" required>
        </div>

        <label class="field-label">Origin</label>
        <div class="input-row">
            <i class="fa-solid fa-location-dot" style="color:var(--light-text);"></i>
            <input type="text" name="origin" value="<%= origin %>" required>
        </div>

        <label class="field-label">Destination</label>
        <div class="input-row">
            <i class="fa-solid fa-flag-checkered" style="color:var(--light-text);"></i>
            <input type="text" name="destination" value="<%= destination %>" required>
        </div>

        <label class="field-label">Distance (km)</label>
        <div class="input-row">
            <i class="fa-solid fa-road" style="color:var(--light-text);"></i>
            <input type="number" step="0.01" name="distance_km" value="<%= distanceKm %>">
        </div>

        <div class="actions">
            <a href="admin_routes.jsp" class="btn-secondary"><i class="fa-solid fa-arrow-left"></i> Cancel</a>
            <button type="submit" class="btn-primary"><i class="fa-solid fa-floppy-disk"></i> Save Route</button>
        </div>
    </form>
</div>
</body>
</html>
