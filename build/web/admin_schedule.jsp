<%-- 
    Document   : admin_schedule
    Created on : May 1, 2026
    Author     : Satishwaran A/L Jai Sankar
    Description: Ticket Schedule Creation Engine and Management Ledger Panel.
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*, java.util.*, com.sani.DBConnection" %>

<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%
String adminUsername =
(String)session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin - Schedule Management</title>
        <link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            .top-nav{
    display:flex;
    justify-content:space-between;
    align-items:center;
    padding:12px 50px;
    background:rgba(255,255,255,0.15);
    backdrop-filter:blur(10px);
    border-bottom:1px solid rgba(255,255,255,0.1);
    position:sticky;
    top:0;
    z-index:100;
}

.nav-left{
    display:flex;
    align-items:center;
    gap:10px;
}

.bus-logo{
    background:#fff;
    padding:5px 8px;
    border-radius:8px;
    font-size:18px;
}

.brand-name{
    font-weight:800;
    font-style:italic;
    font-size:22px;
    color:#2b1c1a;
}

.nav-center{
    display:flex;
    gap:8px;
    flex-wrap:wrap;
}

.nav-btn{
    text-decoration:none;
    color:#2b1c1a;
    font-weight:700;
    font-size:11px;
    padding:9px 16px;
    border-radius:12px;
    display:flex;
    align-items:center;
    gap:7px;
    border:1px solid rgba(43,28,26,0.15);
}

.nav-btn:hover{
    background:rgba(43,28,26,0.08);
}

.nav-btn.active{
    background:#2b1c1a;
    color:white;
}

.nav-right{
    display:flex;
    align-items:center;
    gap:12px;
}

.user-meta{
    text-align:right;
}

.user-name{
    display:block;
    font-weight:800;
    color:#2b1c1a;
    font-size:14px;
    text-transform:uppercase;
}

.user-role{
    font-size:9px;
    color:#8c7673;
    text-transform:uppercase;
}

.avatar-container{
    width:40px;
    height:40px;
    border-radius:10px;
    background:white;
    display:flex;
    justify-content:center;
    align-items:center;
    color:#2b1c1a;
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
            :root {
                --light-text: #8c7673;
            }
            body {
                background-color: #d8a19a;
                margin: 0;
                padding: 0;
                font-family: 'Poppins', sans-serif;
            }
            .main-layout {
                display: flex;
                padding: 25px 40px;
                gap: 30px;
            }
            .form-card {
                background: white;
                border-radius: 30px;
                padding: 30px;
                width: 340px;
                box-shadow: 0 10px 20px rgba(0,0,0,0.05);
            }
            .ledger-container {
                flex: 1;
                background: white;
                border-radius: 30px;
                padding: 30px;
                box-shadow: 0 10px 20px rgba(0,0,0,0.05);
            }
            .input-row {
                background: #f9f9f9;
                padding: 12px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                gap: 10px;
                margin-top: 8px;
                margin-bottom: 15px;
            }
            .input-row input, .input-row select {
                border: none;
                background: none;
                outline: none;
                width: 100%;
                font-family: 'Poppins', sans-serif;
                font-size: 14px;
            }
            .btn-primary {
                background: #2b1c1a;
                color: white;
                border: none;
                padding: 12px 25px;
                border-radius: 15px;
                font-weight: bold;
                cursor: pointer;
                width: 100%;
                transition: 0.3s;
            }
            .error-alert {
                background-color: #f8d7da;
                color: #721c24;
                padding: 15px 25px;
                border-radius: 15px;
                margin: 20px 40px 0 40px;
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 14px;
                font-weight: 600;
            }
            .success-alert {
                background-color: #d4edda;
                color: #155724;
                padding: 15px 25px;
                border-radius: 15px;
                margin: 20px 40px 0 40px;
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 14px;
                font-weight: 600;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
            }
            th {
                text-align: left;
                padding: 12px;
                font-size: 11px;
                text-transform: uppercase;
                color: var(--light-text);
                border-bottom: 2px solid #eee;
            }
            td {
                padding: 15px 12px;
                font-size: 14px;
                color: #2b1c1a;
                border-bottom: 1px solid #eee;
                vertical-align: middle;
            }
            .btn-action-edit {
                background: #f39c12;
                color: white;
                border: none;
                padding: 6px 12px;
                border-radius: 8px;
                cursor: pointer;
                font-size: 12px;
                font-weight: bold;
                text-decoration: none;
                display: inline-block;
                margin-right: 5px;
            }
            .btn-action-delete {
                background: #c0392b;
                color: white;
                border: none;
                padding: 6px 12px;
                border-radius: 8px;
                cursor: pointer;
                font-size: 12px;
                font-weight: bold;
                text-decoration: none;
                display: inline-block;
            }
        </style>
        <link rel="stylesheet" href="sani-theme.css">
</head>
    <body>

<nav class="top-nav">

    <div class="nav-left">
        <span class="bus-logo">🚌</span>
        <span class="brand-name">SANIBUS</span>
    </div>

       <div class="nav-center">
        <a href="admin_home.jsp"            class="nav-btn"><i class="fa-solid fa-file-medical"></i> Leave Approvals</a>
        <a href="admin_schedule.jsp"        class="nav-btn active"><i class="fa-solid fa-calendar-days"></i> Schedules</a>
        <a href="admin_routes.jsp"          class="nav-btn"><i class="fa-solid fa-route"></i> Routes</a>
        <a href="admin_bookings.jsp"        class="nav-btn"><i class="fa-solid fa-ticket"></i> Bookings</a>
        <a href="admin_payments.jsp"        class="nav-btn"><i class="fa-solid fa-credit-card"></i> Payments</a>
        <a href="admin_refund_requests.jsp" class="nav-btn"><i class="fa-solid fa-rotate-left"></i> Refunds</a>
        <a href="admin_admins.jsp" class="nav-btn "><i class="fa-solid fa-credit-card"></i> Admins</a>
        <a href="admin_managers.jsp" class="nav-btn"><i class="fa-solid fa-credit-card"></i> Managers</a>
        <a href="admin_drivers.jsp" class="nav-btn"><i class="fa-solid fa-credit-card"></i> Drivers</a>
    </div>

    <div class="nav-right">

        <div class="user-meta">
            <span class="user-name">
                <%= adminUsername %>
            </span>
            <span class="user-role">
                SYSTEM ADMIN
            </span>
        </div>

        <a href="edit_profile.jsp" class="avatar">
    <i class="fa-regular fa-user"></i>
</a>
           

        <a href="LogoutServlet"
           style="color:#2b1c1a;font-size:20px;">
            <i class="fa-solid fa-arrow-right-from-bracket"></i>
        </a>

    </div>

</nav>

       <h1 style="font-weight: 800; font-size: 32px; padding: 20px 40px 0 40px; margin: 0; color: #2b1c1a;">Bus Schedule & Routing Core</h1>

        <% if ("error".equals(request.getParameter("msg"))) { %>

<div class="error-alert">
    <i class="fa-solid fa-circle-xmark"></i>
    Failed to process transaction.
</div>

<% } else if ("time_error".equals(request.getParameter("msg"))) { %>

<div class="error-alert">
    <i class="fa-solid fa-clock"></i>
    Schedule must be created at least 5 hours before departure time.
</div>

<% } else if ("success".equals(request.getParameter("msg"))) { %>

<div class="success-alert">
    <i class="fa-solid fa-circle-check"></i>
    Ticket schedule created successfully!
</div>

<% } %>

        <div class="main-layout">
            <aside>
                <div class="form-card">
                    <h2 style="margin-top: 0; font-size: 20px; color: #2b1c1a;">Create Ticket Run</h2>
                    <p style="font-size: 12px; color: var(--light-text); margin-bottom: 20px;">Configure ticket pricing options and assign dynamic schedules.</p>
                    
                    <form action="AddScheduleServlet" method="POST">
                        <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">ORIGIN STATION</label>
                        <div class="input-row">
                            <input type="text" name="origin" placeholder="e.g., Kuala Lumpur" required>
                        </div>

                        <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">DESTINATION STATION</label>
                        <div class="input-row">
                            <input type="text" name="destination" placeholder="e.g., Kuala Terengganu" required>
                        </div>

                        <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">ASSIGN AVAILABLE DRIVER</label>
                        <div class="input-row">
                            <select name="driver_username" required>
    <option value="">Select Driver</option>

    <%
        try (
            Connection driverConn = DBConnection.getConnection();
            PreparedStatement driverPs =
                driverConn.prepareStatement(
                    "SELECT username, fullname FROM users WHERE role='driver' ORDER BY fullname ASC");
            ResultSet driverRs = driverPs.executeQuery()
        ) {

            while(driverRs.next()) {
    %>

       <option value="<%= driverRs.getString("username") %>">
    <%= driverRs.getString("fullname") != null
            ? driverRs.getString("fullname")
            : driverRs.getString("username") %>
</option>

    <%
            }
        } catch(Exception ex) {
            ex.printStackTrace();
        }
    %>

</select>
                        </div>

                        <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">BUS PLATE REGISTRY NUMBER</label>
                        <div class="input-row">
                            <input type="text" name="bus_plate_no" placeholder="e.g., SAB 4812 X" required>
                        </div>

                        <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">DEPARTURE TIMESTAMP</label>
                        <div class="input-row">
                           <input type="datetime-local"
       name="departureTime"
       id="departureTime"
       required>
                        </div>

                        <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">ESTIMATED ARRIVAL TIMESTAMP</label>
                        <div class="input-row">
                            <input type="datetime-local" name="arrival_time" id="arrival_time" required>
                        </div>

                        <div style="display: flex; gap: 15px;">
                            <div style="flex: 1;">
                                <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">TICKET PRICE (MYR)</label>
                                <div class="input-row">
                                    <input type="number" step="0.01" name="ticket_price" placeholder="0.00" required>
                                </div>
                            </div>
                            <div style="flex: 1;">
                                <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">MAX CAPACITY</label>
                                <div class="input-row">
                                    <input type="number" name="available_seats" value="55" required>
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="btn-primary"><i class="fa-solid fa-ticket"></i> Create Ticket Schedule</button>
                    </form>
                </div>
            </aside>

            <main class="ledger-container">
                <h2 style="margin-top: 0; font-size: 20px; color: #2b1c1a;">Ticket Details</h2>
                
                <table>
                    <thead>
                        <tr>
                            <th>Route Target</th>
                            <th>Bus Plate</th>
                            <th>Assigned Driver</th>
                            <th>Departure / Arrival Windows</th>
                            <th>Price</th>
                            <th>Capacity Status</th>
                            <th>TRIP STATUS</th>
                            <th style="text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            boolean structuralData = false;

                            try {
                                conn = DBConnection.getConnection();
                                // Querying fields via explicit Table INNER JOIN to pull Origin and Destination properties
                                String sql = "SELECT s.*, r.origin, r.destination FROM bus_schedules s " +
                                             "INNER JOIN bus_routes r ON s.route_id = r.id " +
                                             "ORDER BY s.departure_time ASC";
                                ps = conn.prepareStatement(sql);
                                rs = ps.executeQuery();

                                while (rs.next()) {
                                    structuralData = true;
                                    int scheduleId = rs.getInt("id"); 
                                    String originLoc = rs.getString("origin");
                                    String destLoc = rs.getString("destination");
                                    String routeDisplay = originLoc + " ➔ " + destLoc;
                                    
                                    String depTimeRaw = rs.getString("departure_time");
                                    String arrTimeRaw = rs.getString("arrival_time");
                                    String depTime = depTimeRaw != null && depTimeRaw.length() >= 16 ? depTimeRaw.substring(0,16) : depTimeRaw;
                                    String arrTime = arrTimeRaw != null && arrTimeRaw.length() >= 16 ? arrTimeRaw.substring(0,16) : arrTimeRaw;
                                    
                                    Timestamp departure =
        rs.getTimestamp("departure_time");

Timestamp arrival =
        rs.getTimestamp("arrival_time");

Timestamp now =
        new Timestamp(
                System.currentTimeMillis());

String tripStatus;
String statusColor;

if (now.after(arrival)) {

    tripStatus = "Trip Completed";
    statusColor = "#6c757d";

} else if (now.after(departure)
        && now.before(arrival)) {

    tripStatus = "In Progress";
    statusColor = "#0d6efd";

} else {

    tripStatus = "Upcoming";
    statusColor = "#28a745";
}
                        %>
                        
                                    <tr>
                                        <td><strong><%= routeDisplay %></strong></td>
                                        <td><span style="background: #f5f5f5; padding: 4px 8px; border-radius: 6px; font-family: monospace; font-weight: bold;"><%= rs.getString("bus_plate_no") %></span></td>
                                        <td><i class="fa-regular fa-user"></i> <%= rs.getString("driver_username") %></td>
                                        <td>
                                            <small style="color: #2b1c1a; font-weight: 600;"><i class="fa-solid fa-circle" style="font-size:6px; color:#2ecc71; vertical-align:middle; margin-right:4px;"></i>DEP: <%= depTime %></small><br>
                                            <small style="color: var(--light-text);"><i class="fa-solid fa-circle" style="font-size:6px; color:#e74c3c; vertical-align:middle; margin-right:4px;"></i>ARR: <%= arrTime %></small>
                                        </td>
                                        <td><strong>RM<%= String.format("%.2f", rs.getDouble("ticket_price")) %></strong></td>
                                        <td>
                                            <span style="color: <%= (rs.getInt("available_seats") > 0) ? "#2ecc71" : "#c0392b" %>; font-weight: 600;">
                                                <%= rs.getInt("available_seats") %> Seats Available
                                            </span>
                                        </td>
                                        <td>
    <span style="
          background:<%= statusColor %>;
          color:white;
          padding:6px 12px;
          border-radius:15px;
          font-size:12px;
          font-weight:600;">

        <%= tripStatus %>

    </span>
</td>
                                        <td style="text-align: center; white-space: nowrap;">
                                            <a href="edit_schedule.jsp?id=<%= scheduleId %>" class="btn-action-edit">
                                                <i class="fa-solid fa-pen-to-square"></i> Edit
                                            </a>
                                            <a href="DeleteScheduleServlet?id=<%= scheduleId %>" class="btn-action-delete" onclick="return confirm('Are you sure you want to delete this ticket schedule?');">
                                                <i class="fa-solid fa-trash"></i> Delete
                                            </a>
                                        </td>
                                    </tr>
                        <%
                                }
                                
                                if (!structuralData) {
                        %>
                                    <tr>
                                        <td colspan="7" style="text-align:center; color:var(--light-text); padding:40px;">
                                            <i class="fa-solid fa-ticket" style="font-size: 30px; margin-bottom: 10px; display: block; color: #d8a19a;"></i>
                                            No active ticket schedules are currently listed for passengers.
                                        </td>
                                    </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='7' style='color:red;'>Ledger Compilation Error: " + e.getMessage() + "</td></tr>");
                            } finally {
                                if (rs != null) try { rs.close(); } catch(Exception e) {}
                                if (ps != null) try { ps.close(); } catch(Exception e) {}
                                if (conn != null) try { conn.close(); } catch(Exception e) {}
                            }
                        %>
                    </tbody>
                </table>
            </main>
        </div>
                   <script>

window.onload = function () {

    let now = new Date();

    // Add 5 hours
    now.setHours(now.getHours() + 5);

    let year = now.getFullYear();
    let month = String(now.getMonth() + 1).padStart(2, '0');
    let day = String(now.getDate()).padStart(2, '0');
    let hours = String(now.getHours()).padStart(2, '0');
    let minutes = String(now.getMinutes()).padStart(2, '0');

    let minDateTime =
        year + "-" +
        month + "-" +
        day + "T" +
        hours + ":" +
        minutes;

    document.getElementById("departureTime")
            .setAttribute("min", minDateTime);

    document.getElementById("arrival_time")
            .setAttribute("min", minDateTime);
};

</script>
    </body>
</html>