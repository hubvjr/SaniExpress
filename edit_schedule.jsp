<%-- 
    Document   : edit_schedule
    Created on : June 4, 2026
    Author     : Satishwaran A/L Jai Sankar
    Description: Modification panel for existing ticket profiles.
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*, java.util.*, com.sani.DBConnection" %>

<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String scheduleIdStr = request.getParameter("id");
    if (scheduleIdStr == null || scheduleIdStr.trim().isEmpty()) {
        response.sendRedirect("admin_schedule.jsp?msg=error");
        return;
    }

    // Variables to hold existing data
    String origin = "";
    String destination = "";
    String busPlate = "";
    String driver = "";
    String depTime = "";
    String arrTime = "";
    double price = 0.0;
    int seats = 0;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT s.*, r.origin, r.destination FROM bus_schedules s " +
                     "INNER JOIN bus_routes r ON s.route_id = r.id WHERE s.id = ?";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(scheduleIdStr));
        rs = ps.executeQuery();

        if (rs.next()) {
            origin = rs.getString("origin");
            destination = rs.getString("destination");
            busPlate = rs.getString("bus_plate_no");
            driver = rs.getString("driver_username");
            
            // Format timestamps for HTML5 datetime-local input (yyyy-MM-ddTHH:mm)
            String depRaw = rs.getString("departure_time");
            String arrRaw = rs.getString("arrival_time");
            if (depRaw != null && depRaw.length() >= 16) depTime = depRaw.substring(0, 10) + "T" + depRaw.substring(11, 16);
            if (arrRaw != null && arrRaw.length() >= 16) arrTime = arrRaw.substring(0, 10) + "T" + arrRaw.substring(11, 16);
            
            price = rs.getDouble("ticket_price");
            seats = rs.getInt("available_seats");
        } else {
            response.sendRedirect("admin_schedule.jsp?msg=error");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("admin_schedule.jsp?msg=error");
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (ps != null) try { ps.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin - Edit Ticket Details</title>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            body {
                background-color: #d8a19a;
                margin: 0;
                padding: 0;
                font-family: 'Poppins', sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100 childhood;
                padding: 40px 0;
            }
            .form-card {
                background: white;
                border-radius: 30px;
                padding: 40px;
                width: 450px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.1);
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
                padding: 14px 25px;
                border-radius: 15px;
                font-weight: bold;
                cursor: pointer;
                width: 100%;
                transition: 0.3s;
                font-size: 15px;
                margin-top: 10px;
            }
            .btn-cancel {
                background: #e74c3c;
                color: white;
                border: none;
                padding: 14px 25px;
                border-radius: 15px;
                font-weight: bold;
                cursor: pointer;
                width: 100%;
                text-decoration: none;
                display: block;
                text-align: center;
                box-sizing: border-box;
                margin-top: 10px;
                font-size: 15px;
                transition: 0.3s;
            }
        </style>
        <link rel="stylesheet" href="sani-theme.css">
</head>
    <body>
        <div class="form-card">
            <h2 style="margin-top: 0; font-size: 24px; color: #2b1c1a;"><i class="fa-solid fa-pen-to-square"></i> Edit Ticket Details</h2>
            <p style="font-size: 13px; color: #8c7673; margin-bottom: 25px;">Modify properties for Schedule ID: <strong>#<%= scheduleIdStr %></strong></p>
            
            <form action="EditScheduleServlet" method="POST">
                <input type="hidden" name="schedule_id" value="<%= scheduleIdStr %>">

                <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">ORIGIN STATION</label>
                <div class="input-row">
                    <input type="text" name="origin" value="<%= origin %>" required>
                </div>

                <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">DESTINATION STATION</label>
                <div class="input-row">
                    <input type="text" name="destination" value="<%= destination %>" required>
                </div>

                <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">ASSIGNED DRIVER</label>
                <div class="input-row">
                    <select name="driver_username" required>
                        <option value="ali" <%= "ali".equals(driver) ? "selected" : "" %>>ali</option>
                    </select>
                </div>

                <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">BUS PLATE REGISTRY NUMBER</label>
                <div class="input-row">
                    <input type="text" name="bus_plate_no" value="<%= busPlate %>" required>
                </div>

                <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">DEPARTURE TIMESTAMP</label>
                <div class="input-row">
                    <input type="datetime-local" name="departure_time" value="<%= depTime %>" required>
                </div>

                <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">ESTIMATED ARRIVAL TIMESTAMP</label>
                <div class="input-row">
                    <input type="datetime-local" name="arrival_time" value="<%= arrTime %>" required>
                </div>

                <div style="display: flex; gap: 15px;">
                    <div style="flex: 1;">
                        <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">TICKET PRICE (MYR)</label>
                        <div class="input-row">
                            <input type="number" step="0.01" name="ticket_price" value="<%= price %>" required>
                        </div>
                    </div>
                    <div style="flex: 1;">
                        <label style="font-size: 10px; font-weight: bold; color: #b5a4a1;">SEATS CAPACITY</label>
                        <div class="input-row">
                            <input type="number" name="available_seats" value="<%= seats %>" required>
                        </div>
                    </div>
                </div>

                <button type="submit" class="btn-primary"><i class="fa-solid fa-floppy-disk"></i> Save Changes</button>
                <a href="admin_schedule.jsp" class="btn-cancel">Cancel</a>
            </form>
        </div>
                        
    </body>
</html>