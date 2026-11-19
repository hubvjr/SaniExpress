<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" import="java.sql.*, java.util.*, java.text.*, com.sani.DBConnection" %>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");

    String scheduleId    = null;
    String routeName     = null;
    String origin        = null;
    String destination   = null;
    String distanceKm    = null;
    String busPlate      = null;
    String departureTime = null;
    String arrivalTime   = null;
    String ticketPrice   = null;
    String availSeats    = null;
    String schedStatus   = null;

    try (Connection rc = DBConnection.getConnection()) {
        String sql =
            "SELECT bs.id, bs.bus_plate_no, bs.departure_time, bs.arrival_time, " +
            "       bs.ticket_price, bs.available_seats, bs.status, " +
            "       br.route_name, br.origin, br.destination, br.distance_km " +
            "FROM bus_schedules bs " +
            "JOIN bus_routes br ON br.id = bs.route_id " +
            "WHERE bs.driver_username = ? AND bs.status = 'Active' " +
            "ORDER BY bs.departure_time ASC LIMIT 1";
        try (PreparedStatement ps = rc.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    scheduleId    = rs.getString("id");
                    busPlate      = rs.getString("bus_plate_no");
                    departureTime = rs.getString("departure_time");
                    arrivalTime   = rs.getString("arrival_time");
                    ticketPrice   = rs.getString("ticket_price");
                    availSeats    = rs.getString("available_seats");
                    schedStatus   = rs.getString("status");
                    routeName     = rs.getString("route_name");
                    origin        = rs.getString("origin");
                    destination   = rs.getString("destination");
                    distanceKm    = rs.getString("distance_km");
                }
            }
        }
    } catch (Exception ignored) {}

    // Helper: format "yyyy-MM-dd" → "dd/MM/yyyy"
    SimpleDateFormat dbFmt   = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat dispFmt = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Panel - SANI BUS</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.css"/>
    <style>
        :root {
            --pink-bg: #d8a19a;
            --dark-brown: #2b1c1a;
            --white: #ffffff;
            --card-bg: #f5e1de;
            --light-text: #8c7673;
            --border-light: #f0e8e6;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background-color: var(--pink-bg); min-height: 100vh; }

        /* NAV */
        .top-nav { display: flex; justify-content: space-between; align-items: center; padding: 12px 50px; background: rgba(255,255,255,0.15); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.1); }
        .nav-left { display: flex; align-items: center; gap: 10px; }
        .nav-left .bus-logo { background: #fff; padding: 5px 8px; border-radius: 8px; font-size: 18px; }
        .nav-left .brand-name { font-weight: 800; font-style: italic; font-size: 22px; color: var(--dark-brown); }
        .nav-btn { text-decoration: none; color: var(--dark-brown); font-weight: 700; font-size: 12px; padding: 10px 20px; border-radius: 12px; display: flex; align-items: center; gap: 8px; transition: 0.3s; border: 1px solid rgba(43,28,26,0.15); }
        .nav-btn.active { background: var(--dark-brown); color: white; border-color: var(--dark-brown); }
        .nav-right { display: flex; align-items: center; gap: 12px; }
        .user-meta { text-align: right; display: flex; flex-direction: column; }
        .user-name { font-weight: 800; color: var(--dark-brown); font-size: 14px; }
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
        /* LAYOUT */
        .main-content { max-width: 1100px; margin: 0 auto; padding: 30px 40px; }
        .page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 30px; }
        .page-header h1 { font-size: 28px; font-weight: 800; color: var(--dark-brown); }

        /* TABS */
        .tab-buttons { display: flex; gap: 10px; }
        .tab-btn { padding: 10px 22px; border-radius: 12px; font-weight: 700; font-size: 12px; cursor: pointer; transition: 0.3s; text-decoration: none; border: 1px solid rgba(43,28,26,0.15); color: var(--dark-brown); display: flex; align-items: center; gap: 7px; }
        .tab-btn.active { background: var(--dark-brown); color: white; }

        /* LEAVE FORM */
        .leave-form-card { background: white; border-radius: 20px; padding: 35px; box-shadow: 0 8px 30px rgba(0,0,0,0.06); margin-bottom: 35px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 25px; margin-bottom: 25px; }
        .form-group label { font-size: 10px; font-weight: 700; color: var(--light-text); letter-spacing: 1px; text-transform: uppercase; display: block; margin-bottom: 8px; }
        .form-group select, .form-group input[type="date"], .form-group input[type="file"], .form-group textarea { width: 100%; padding: 12px 15px; border: 1px solid var(--border-light); border-radius: 12px; font-family: 'Poppins', sans-serif; font-size: 14px; color: var(--dark-brown); outline: none; background: #fff; }
        .form-reminder { background: #fcf8e3; border-left: 4px solid #f0ad4e; color: #8a6d3b; padding: 12px 15px; margin-bottom: 25px; border-radius: 0 12px 12px 0; font-size: 12px; font-weight: 600; display: flex; align-items: center; gap: 10px; }
        .submit-btn { background: var(--dark-brown); color: white; border: none; padding: 14px 30px; border-radius: 12px; font-weight: 700; font-size: 14px; cursor: pointer; display: flex; align-items: center; gap: 10px; }
        .total-days-box { display: none; background: #eaf4fb; border-left: 4px solid #3498db; padding: 12px 18px; border-radius: 0 12px 12px 0; margin-bottom: 25px; font-size: 13px; font-weight: 700; color: #1a5276; }

        /* LEAVE TABLE */
        .leave-history-table { width: 100%; border-collapse: separate; border-spacing: 0; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.04); }
        .leave-history-table th { background: #f9f6f5; padding: 14px 18px; text-align: left; font-size: 10px; font-weight: 700; color: var(--light-text); text-transform: uppercase; border-bottom: 1px solid var(--border-light); }
        .leave-history-table td { padding: 16px 18px; font-size: 13px; color: var(--dark-brown); border-bottom: 1px solid var(--border-light); }
        .status-badge { padding: 6px 14px; border-radius: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; display: inline-block; }
        .status-pending  { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        .status-approved { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .status-rejected { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .status-cancelled{ background: #e2e3e5; color: #383d41; border: 1px solid #d6d8db; }
        .alert { padding: 12px 20px; border-radius: 12px; margin-bottom: 20px; font-size: 13px; font-weight: 600; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error   { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        /* Action buttons */
        .btn-action { border: none; padding: 6px 12px; border-radius: 8px; font-weight: 700; font-size: 11px; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; text-decoration: none; }
        .btn-edit   { background: #cce5ff; color: #004085; }
        .btn-edit:hover { background: #b8daff; }
        .btn-cancel { background: #f8d7da; color: #721c24; }
        .btn-cancel:hover { background: #f5c6cb; }
        .action-cell { display: flex; gap: 6px; flex-wrap: wrap; align-items: center; }

        /* ROUTE TAB */
        #tab-route { display: none; }
        .route-summary-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
        .route-stat-card { background: white; border-radius: 16px; padding: 20px 22px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .route-stat-card .stat-icon { width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 16px; margin-bottom: 12px; }
        .route-stat-card .stat-label { font-size: 9px; font-weight: 700; color: var(--light-text); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px; }
        .route-stat-card .stat-value { font-size: 15px; font-weight: 800; color: var(--dark-brown); line-height: 1.3; }
        .route-info-banner { background: white; border-radius: 16px; padding: 18px 24px; margin-bottom: 24px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); display: flex; align-items: center; gap: 16px; }
        .route-arrow { display: flex; align-items: center; gap: 12px; flex: 1; flex-wrap: wrap; }
        .route-point { display: flex; flex-direction: column; }
        .route-point-label { font-size: 9px; font-weight: 700; color: var(--light-text); text-transform: uppercase; letter-spacing: 1px; }
        .route-point-name  { font-size: 16px; font-weight: 800; color: var(--dark-brown); }
        .route-arrow-line  { flex: 1; display: flex; align-items: center; gap: 6px; color: var(--light-text); min-width: 60px; }
        .route-arrow-line hr { flex: 1; border: none; border-top: 2px dashed var(--border-light); }
        #routeMap { width: 100%; height: 420px; border-radius: 20px; overflow: hidden; box-shadow: 0 8px 30px rgba(0,0,0,0.1); background: #ede8e7; }
        .map-loading { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 420px; border-radius: 20px; background: white; box-shadow: 0 8px 30px rgba(0,0,0,0.06); color: var(--light-text); font-size: 13px; font-weight: 600; gap: 12px; }
        .spinner { width: 32px; height: 32px; border: 3px solid var(--border-light); border-top-color: var(--dark-brown); border-radius: 50%; animation: spin 0.8s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .no-route-box { background: white; border-radius: 20px; padding: 60px 40px; text-align: center; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .no-route-box i { font-size: 48px; color: var(--border-light); margin-bottom: 16px; display: block; }
        .no-route-box p { color: var(--light-text); font-size: 14px; font-weight: 600; }
    </style>
    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>

<nav class="top-nav">
    <div class="nav-left">
        <span class="bus-logo">&#x1F68C;</span>
        <span class="brand-name">SANIBUS</span>
    </div>
    <div class="nav-center">
        <a href="driver_home.jsp" class="nav-btn active"><i class="fa-solid fa-user"></i> DRIVER PANEL</a>
    </div>
    <div class="nav-right">
        <div class="user-meta">
            <span class="user-name"><%= username %></span>
            <span class="user-role">DRIVER</span>
        </div>
        <a href="edit_profile.jsp" class="avatar">
    <i class="fa-regular fa-user"></i>
</a>
        <a href="LogoutServlet" style="color:var(--dark-brown); margin-left:10px;"><i class="fa-solid fa-arrow-right-from-bracket"></i></a>
    </div>
</nav>

<div class="main-content">

    <div class="page-header">
        <div>
            <h1 id="pageTitle">Emergency &amp; Leave Management</h1>
            <p style="color:var(--light-text); font-size:13px;" id="pageSubtitle">Apply and monitor all leave status allocations</p>
        </div>
        <div class="tab-buttons">
            <a href="javascript:void(0)" class="tab-btn active" id="btnLeave" onclick="switchTab('leave')">
                <i class="fa-solid fa-file-medical"></i> Leave
            </a>
            <a href="javascript:void(0)" class="tab-btn" id="btnRoute" onclick="switchTab('route')">
                <i class="fa-solid fa-route"></i> My Route
            </a>
        </div>
    </div>

    <!-- ═══════════════════ LEAVE TAB ═══════════════════ -->
    <div id="tab-leave">

        <%
            String msg = request.getParameter("msg");
            if ("success".equals(msg)) {
        %>
            <div class="alert alert-success"><i class="fa-solid fa-check-circle"></i> Leave request submitted successfully. Waiting for Admin evaluation.</div>
        <% } else if ("error".equals(msg)) { %>
            <div class="alert alert-error"><i class="fa-solid fa-exclamation-circle"></i> Error processing data parameters. Verify entries and retry.</div>
        <% } else if ("cancelled".equals(msg)) { %>
            <div class="alert alert-success"><i class="fa-solid fa-info-circle"></i> Leave request successfully cancelled.</div>
        <% } else if ("updated".equals(msg)) { %>
            <div class="alert alert-success"><i class="fa-solid fa-check-circle"></i> Leave request updated successfully.</div>
        <% } %>

        <div class="leave-form-card">
            <div class="form-reminder" id="formReminder">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span id="reminderText">Framework Loading...</span>
            </div>
            <form action="DriverLeaveServlet" method="POST" enctype="multipart/form-data" id="leaveForm" onsubmit="return validateLeaveForm()">
                <input type="hidden" name="action" value="submit">
                <div class="form-row">
                    <div class="form-group">
                        <label>LEAVE TYPE</label>
                        <select name="leaveType" id="leaveType" onchange="handleLeaveTypeChange()">
                            <option value="Emergency">Emergency Leave</option>
                            <option value="Annual">Annual Leave</option>
                            <option value="Medical">Medical Leave</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>START DATE</label>
                        <%-- hidden field carries yyyy-MM-dd for the servlet --%>
                        <input type="hidden" name="startDate" id="startDate">
                        <input type="text"   id="startDateDisplay" placeholder="dd/mm/yyyy"
                               autocomplete="off" readonly
                               style="width:100%;padding:12px 15px;border:1px solid var(--border-light);border-radius:12px;font-family:'Poppins',sans-serif;font-size:14px;color:var(--dark-brown);outline:none;background:#fff;cursor:pointer;">
                    </div>
                    <div class="form-group">
                        <label>END DATE</label>
                        <input type="hidden" name="endDate" id="endDate">
                        <input type="text"   id="endDateDisplay" placeholder="dd/mm/yyyy"
                               autocomplete="off" readonly
                               style="width:100%;padding:12px 15px;border:1px solid var(--border-light);border-radius:12px;font-family:'Poppins',sans-serif;font-size:14px;color:var(--dark-brown);outline:none;background:#fff;cursor:pointer;">
                    </div>
                </div>

                <div class="total-days-box" id="totalDaysBox">
                    <i class="fa-solid fa-calendar-days"></i>
                    Total Leave Duration: <span id="totalDaysText">-</span>
                </div>

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:25px; margin-bottom:25px;">
                    <div class="form-group" id="reasonGroup">
                        <label id="reasonLabel">REASON JUSTIFICATION <span style="color:#e74c3c;">*Required</span></label>
                        <textarea name="reason" id="reason" placeholder="Type a contextual explanation for verification..."></textarea>
                    </div>
                    <div class="form-group" id="proofGroup" style="display:none;">
                        <label id="proofLabel">ATTACH PROOF DOCUMENT (PDF ONLY)</label>
                        <input type="file" name="leaveProof" id="leaveProof" accept="application/pdf">
                        <span style="font-size:11px; color:var(--light-text); display:block; margin-top:5px;">Only PDF binary data is parsed.</span>
                    </div>
                </div>
                <button type="submit" class="submit-btn"><i class="fa-solid fa-paper-plane"></i> Submit Application</button>
            </form>
        </div>

        <h2 style="color:var(--dark-brown); font-size:18px; margin-bottom:15px;"><i class="fa-solid fa-history"></i> Personal Leave Track Logs</h2>
        <table class="leave-history-table">
            <thead>
                <tr>
                    <th>Type</th>
                    <th>Start Date</th>
                    <th>End Date</th>
                    <th>Reason / Attached Metadata</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                try (Connection leaveConn = DBConnection.getConnection();
                     PreparedStatement leavePst = leaveConn.prepareStatement(
                         "SELECT * FROM driver_leaves WHERE driver_username = ? ORDER BY created_at DESC")) {
                    leavePst.setString(1, username);
                    try (ResultSet leaveRs = leavePst.executeQuery()) {
                        boolean hasLeaves = false;
                        while (leaveRs.next()) {
                            hasLeaves = true;
                            int    leaveId   = leaveRs.getInt("id");
                            String leaveType = leaveRs.getString("leave_type");
                            String status    = leaveRs.getString("status");
                            String rawStart  = leaveRs.getString("start_date");
                            String rawEnd    = leaveRs.getString("end_date");

                            // Convert dates to dd/MM/yyyy for display
                            String fmtStart = rawStart;
                            String fmtEnd   = rawEnd;
                            try { fmtStart = dispFmt.format(dbFmt.parse(rawStart)); } catch (Exception ignored2) {}
                            try { fmtEnd   = dispFmt.format(dbFmt.parse(rawEnd));   } catch (Exception ignored2) {}

                            String badgeClass = "status-pending";
                            if      ("Approved".equalsIgnoreCase(status))   badgeClass = "status-approved";
                            else if ("Rejected".equalsIgnoreCase(status))   badgeClass = "status-rejected";
                            else if ("Cancelled".equalsIgnoreCase(status))  badgeClass = "status-cancelled";
            %>
                <tr>
                    <td><strong><%= leaveType %></strong></td>
                    <td><%= fmtStart %></td>
                    <td><%= fmtEnd %></td>
                    <td>
                        <% if ("Medical".equalsIgnoreCase(leaveType)) { %>
                            <span style="color:var(--light-text); font-style:italic;"><i class="fa-solid fa-file-pdf"></i> Medical Certificate Attached</span>
                        <% } else if ("Annual".equalsIgnoreCase(leaveType)) { %>
                            <span style="color:var(--light-text); font-style:italic;">&#8212;</span>
                        <% } else { %>
                            <%= leaveRs.getString("reason") %>
                        <% } %>
                    </td>
                    <td><span class="status-badge <%= badgeClass %>"><%= status %></span></td>
                    <td>
                        <% if ("Pending".equalsIgnoreCase(status)) { %>
                            <div class="action-cell">
                                <%-- Edit: GET to EditLeaveServlet → loads edit form --%>
                                <a href="EditLeaveServlet?leaveId=<%= leaveId %>"
                                   class="btn-action btn-edit">
                                    <i class="fa-solid fa-pen"></i> Edit
                                </a>
                                <%-- Cancel --%>
                                <form action="DriverLeaveServlet" method="POST" enctype="multipart/form-data"
                                      style="display:inline;"
                                      onsubmit="return confirm('Cancel this leave request?');">
                                    <input type="hidden" name="action"  value="cancel">
                                    <input type="hidden" name="leaveId" value="<%= leaveId %>">
                                    <button type="submit" class="btn-action btn-cancel">
                                        <i class="fa-solid fa-xmark"></i> Cancel
                                    </button>
                                </form>
                            </div>
                        <% } else { %>
                            <span style="color:var(--light-text); font-size:12px;">Locked</span>
                        <% } %>
                    </td>
                </tr>
            <%
                        }
                        if (!hasLeaves) {
            %>
                <tr><td colspan="6" style="text-align:center; color:var(--light-text); padding:30px;">No historical requests registered.</td></tr>
            <%      }
                    }
                } catch (Exception e) { e.printStackTrace(); }
            %>
            </tbody>
        </table>
    </div><!-- /tab-leave -->


    <!-- ═══════════════════ ROUTE TAB ═══════════════════ -->
    <div id="tab-route">
    <% if (scheduleId == null) { %>
        <div class="no-route-box">
            <i class="fa-solid fa-route"></i>
            <p>No active schedule has been assigned to you yet.<br>Please contact your administrator.</p>
        </div>
    <% } else { %>

        <div class="route-summary-grid">
            <div class="route-stat-card">
                <div class="stat-icon" style="background:#fff3cd;color:#856404;"><i class="fa-solid fa-signs-post"></i></div>
                <div class="stat-label">Route</div>
                <div class="stat-value"><%= routeName %></div>
            </div>
            <div class="route-stat-card">
                <div class="stat-icon" style="background:#d4edda;color:#155724;"><i class="fa-solid fa-bus"></i></div>
                <div class="stat-label">Bus Plate</div>
                <div class="stat-value"><%= busPlate %></div>
            </div>
            <div class="route-stat-card">
                <div class="stat-icon" style="background:#cce5ff;color:#004085;"><i class="fa-solid fa-clock"></i></div>
                <div class="stat-label">Departure</div>
                <div class="stat-value"><%= departureTime %></div>
            </div>
            <div class="route-stat-card">
                <div class="stat-icon" style="background:#f8d7da;color:#721c24;"><i class="fa-solid fa-flag-checkered"></i></div>
                <div class="stat-label">Arrival</div>
                <div class="stat-value"><%= arrivalTime %></div>
            </div>
        </div>

        <div class="route-info-banner">
            <div class="route-arrow">
                <div class="route-point">
                    <span class="route-point-label"><i class="fa-solid fa-circle" style="color:#27ae60; font-size:8px;"></i> Origin</span>
                    <span class="route-point-name"><%= origin %></span>
                </div>
                <div class="route-arrow-line">
                    <hr/><i class="fa-solid fa-bus" style="font-size:18px; color:var(--dark-brown);"></i><hr/>
                </div>
                <div class="route-point">
                    <span class="route-point-label"><i class="fa-solid fa-circle" style="color:#e74c3c; font-size:8px;"></i> Destination</span>
                    <span class="route-point-name"><%= destination %></span>
                </div>
            </div>
            <% if (distanceKm != null) { %>
            <div style="text-align:right; padding-left:20px; border-left:1px solid var(--border-light); flex-shrink:0;">
                <div style="font-size:9px; font-weight:700; color:var(--light-text); text-transform:uppercase; letter-spacing:1px; margin-bottom:4px;">Distance</div>
                <div style="font-size:22px; font-weight:800; color:var(--dark-brown);"><%= distanceKm %> <span style="font-size:12px;">km</span></div>
            </div>
            <% } %>
            <% if (availSeats != null) { %>
            <div style="text-align:right; padding-left:20px; border-left:1px solid var(--border-light); flex-shrink:0;">
                <div style="font-size:9px; font-weight:700; color:var(--light-text); text-transform:uppercase; letter-spacing:1px; margin-bottom:4px;">Seats Available</div>
                <div style="font-size:22px; font-weight:800; color:var(--dark-brown);"><%= availSeats %></div>
            </div>
            <% } %>
        </div>

        <div id="mapWrapper">
            <div class="map-loading" id="mapLoading">
                <div class="spinner"></div>
                <span>Locating route on map&hellip;</span>
            </div>
            <div id="routeMap" style="display:none;"></div>
        </div>

        <script>
            var ORIGIN      = "<%= origin.replace("\"","\\\"") %>";
            var DESTINATION = "<%= destination.replace("\"","\\\"") %>";
            var ROUTE_NAME  = "<%= routeName.replace("\"","\\\"") %>";
        </script>

    <% } %>
    </div><!-- /tab-route -->

</div><!-- /main-content -->

<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
<script>
/* ══════════════ TAB SWITCHING ══════════════ */
function switchTab(name) {
    document.getElementById('tab-leave').style.display = (name === 'leave') ? 'block' : 'none';
    document.getElementById('tab-route').style.display = (name === 'route') ? 'block' : 'none';
    document.getElementById('btnLeave').classList.toggle('active', name === 'leave');
    document.getElementById('btnRoute').classList.toggle('active', name === 'route');
    if (name === 'leave') {
        document.getElementById('pageTitle').textContent    = 'Emergency & Leave Management';
        document.getElementById('pageSubtitle').textContent = 'Apply and monitor all leave status allocations';
    } else {
        document.getElementById('pageTitle').textContent    = 'My Assigned Route';
        document.getElementById('pageSubtitle').textContent = 'View your route details and live map';
        initRouteMap();
    }
}

/* ══════════════ MAP ══════════════ */
var mapInitialised = false;

async function geocode(placeName) {
    var query = encodeURIComponent(placeName + ', Malaysia');
    var url = 'https://nominatim.openstreetmap.org/search?format=json&limit=1&q=' + query;
    var res = await fetch(url, { headers: { 'Accept-Language': 'en' } });
    var data = await res.json();
    if (data && data.length > 0) return { lat: parseFloat(data[0].lat), lng: parseFloat(data[0].lon) };
    return null;
}

async function initRouteMap() {
    if (mapInitialised) return;
    if (typeof ORIGIN === 'undefined') return;
    mapInitialised = true;
    var loading = document.getElementById('mapLoading');
    var mapDiv  = document.getElementById('routeMap');
    try {
        var oGeo = await geocode(ORIGIN);
        var dGeo = await geocode(DESTINATION);
        if (!oGeo || !dGeo) {
            loading.innerHTML = '<i class="fa-solid fa-triangle-exclamation" style="font-size:28px;color:#f0ad4e;"></i><span>Could not locate route on the map.</span>';
            return;
        }
        loading.style.display = 'none';
        mapDiv.style.display  = 'block';
        var map = L.map('routeMap').setView([(oGeo.lat + dGeo.lat) / 2, (oGeo.lng + dGeo.lng) / 2], 9);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>', maxZoom: 18
        }).addTo(map);
        var latlngs = [[oGeo.lat, oGeo.lng], [dGeo.lat, dGeo.lng]];
        L.polyline(latlngs, { color: '#2b1c1a', weight: 5, opacity: 0.8, dashArray: '10 5' }).addTo(map);
        var originIcon = L.divIcon({ className: '', iconAnchor: [0, 12],
            html: '<div style="background:#27ae60;color:white;padding:6px 10px;border-radius:8px;font-family:Poppins,sans-serif;font-size:11px;font-weight:800;white-space:nowrap;box-shadow:0 3px 8px rgba(0,0,0,.25);display:flex;align-items:center;gap:5px;"><i class="fa-solid fa-circle-dot"></i> ' + ORIGIN + '</div>'
        });
        var destIcon = L.divIcon({ className: '', iconAnchor: [0, 12],
            html: '<div style="background:#e74c3c;color:white;padding:6px 10px;border-radius:8px;font-family:Poppins,sans-serif;font-size:11px;font-weight:800;white-space:nowrap;box-shadow:0 3px 8px rgba(0,0,0,.25);display:flex;align-items:center;gap:5px;"><i class="fa-solid fa-flag-checkered"></i> ' + DESTINATION + '</div>'
        });
        L.marker([oGeo.lat, oGeo.lng], { icon: originIcon }).addTo(map).bindPopup('<strong>Origin</strong><br>' + ORIGIN);
        L.marker([dGeo.lat, dGeo.lng], { icon: destIcon  }).addTo(map).bindPopup('<strong>Destination</strong><br>' + DESTINATION);
        map.fitBounds(L.latLngBounds(latlngs), { padding: [50, 50] });
    } catch (err) {
        loading.innerHTML = '<i class="fa-solid fa-wifi" style="font-size:28px;color:#dc3545;"></i><span>Map unavailable. Check your internet connection.</span>';
    }
}

/* ══════════════ LEAVE FORM LOGIC ══════════════ */
var fpStart, fpEnd;   // Flatpickr instances

function recalcDays() {
    var startVal = document.getElementById('startDate').value;
    var endVal   = document.getElementById('endDate').value;
    var box  = document.getElementById('totalDaysBox');
    var text = document.getElementById('totalDaysText');
    if (startVal && endVal) {
        var diff = Math.round((new Date(endVal) - new Date(startVal)) / 86400000) + 1;
        text.textContent = diff + (diff === 1 ? ' day' : ' days');
        box.style.display = 'flex'; box.style.alignItems = 'center'; box.style.gap = '10px';
    } else {
        box.style.display = 'none';
    }
}

function initDatePickers() {
    var today = new Date();

    fpStart = flatpickr('#startDateDisplay', {
        dateFormat:    'd/m/Y',          // display format shown to user
        altInput:      false,
        allowInput:    false,
        minDate:       today,
        disableMobile: true,             // force custom picker on mobile too
        onChange: function(selectedDates, dateStr) {
            // Store yyyy-MM-dd in the hidden field for the servlet
            var d = selectedDates[0];
            if (d) {
                var iso = d.getFullYear() + '-' +
                          String(d.getMonth()+1).padStart(2,'0') + '-' +
                          String(d.getDate()).padStart(2,'0');
                document.getElementById('startDate').value = iso;
                // Update end-date minimum
                if (fpEnd) fpEnd.set('minDate', d);
            } else {
                document.getElementById('startDate').value = '';
            }
            recalcDays();
        }
    });

    fpEnd = flatpickr('#endDateDisplay', {
        dateFormat:    'd/m/Y',
        altInput:      false,
        allowInput:    false,
        minDate:       today,
        disableMobile: true,
        onChange: function(selectedDates, dateStr) {
            var d = selectedDates[0];
            if (d) {
                var iso = d.getFullYear() + '-' +
                          String(d.getMonth()+1).padStart(2,'0') + '-' +
                          String(d.getDate()).padStart(2,'0');
                document.getElementById('endDate').value = iso;
            } else {
                document.getElementById('endDate').value = '';
            }
            recalcDays();
        }
    });
}

// keep old name so validateLeaveForm still works
function calculateDays() { recalcDays(); }

function handleLeaveTypeChange() {
    var leaveType    = document.getElementById('leaveType').value;
    var reasonGroup  = document.getElementById('reasonGroup');
    var proofGroup   = document.getElementById('proofGroup');
    var reminderText = document.getElementById('reminderText');
    var reasonInput  = document.getElementById('reason');
    var fileInput    = document.getElementById('leaveProof');

    if (leaveType === 'Medical') {
        reasonGroup.style.display = 'none'; proofGroup.style.display = 'block';
        reasonInput.value = '';
        document.getElementById('proofLabel').innerHTML = "SUBMIT PROOF (MC PDF) <span style='color:#e74c3c;'>*Required</span>";
        reminderText.innerHTML = "<strong>Medical leaves</strong> require an official Medical Certificate attachment in PDF format.";
    } else if (leaveType === 'Annual') {
        reasonGroup.style.display = 'none'; proofGroup.style.display = 'none';
        reasonInput.value = ''; if (fileInput) fileInput.value = '';
        reminderText.innerHTML = "<strong>Annual leaves</strong> do not require a reason. Select your preferred dates and submit.";
    } else {
        reasonGroup.style.display = 'block'; proofGroup.style.display = 'none';
        if (fileInput) fileInput.value = '';
        document.getElementById('reasonLabel').innerHTML = "REASON JUSTIFICATION <span style='color:#e74c3c;'>*Required</span>";
        reminderText.innerHTML = "<strong>" + leaveType + " leaves</strong> require a detailed reason justification.";
    }
}

function validateLeaveForm() {
    var leaveType   = document.getElementById('leaveType').value;
    var reasonInput = document.getElementById('reason').value.trim();
    var fileInput   = document.getElementById('leaveProof');
    var startVal    = document.getElementById('startDate').value;
    var endVal      = document.getElementById('endDate').value;
    if (!startVal || !endVal) { alert("Please select both a start and end date."); return false; }
    if (endVal < startVal)    { alert("End date cannot be before start date."); return false; }
    if (leaveType === 'Medical' && (!fileInput || fileInput.files.length === 0)) {
        alert("Medical Leave requests require a PDF document upload."); return false;
    }
    if (leaveType === 'Emergency' && reasonInput === '') {
        alert("Please provide a reason justification for your Emergency Leave request."); return false;
    }
    return true;
}

window.addEventListener('DOMContentLoaded', function () {
    initDatePickers();

    var params    = new URLSearchParams(window.location.search);
    var savedType = params.get('leaveType');
    if (savedType) {
        var sel = document.getElementById('leaveType');
        for (var i = 0; i < sel.options.length; i++) {
            if (sel.options[i].value.toLowerCase() === savedType.toLowerCase()) {
                sel.selectedIndex = i; break;
            }
        }
    }
    handleLeaveTypeChange();
    if (params.get('tab') === 'route') switchTab('route');
});
</script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.js"></script>
</body>
</html>