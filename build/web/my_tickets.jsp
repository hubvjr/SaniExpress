<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.sani.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<!DOCTYPE html>
<html>
<head>
    <title>My Bookings - SANI</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        .top-nav{
    display:flex;
    justify-content:space-between;
    align-items:center;
    padding:14px 45px;
    background:#d9aba5;
    border-bottom:1px solid rgba(0,0,0,.05);
}

.brand{
    font-size:24px;
    font-weight:800;
    font-style:italic;
    color:#2b1c1a;
}

.nav-links{
    display:flex;
    gap:30px;
    align-items:center;
}

.nav-link{
    text-decoration:none;
    color:#2b1c1a;
    font-weight:700;
    display:flex;
    align-items:center;
    gap:8px;
}

.nav-link.active{
    background:#2b1c1a;
    color:white;
    padding:12px 22px;
    border-radius:14px;
}

.user-area{
    display:flex;
    align-items:center;
    gap:15px;
}

.user-info{
    text-align:right;
}

.user-name{
    font-weight:800;
    color:#2b1c1a;
}

.user-role{
    font-size:10px;
    color:#8a6d69;
    letter-spacing:1px;
}

.avatar{
    width:44px;
    height:44px;
    border-radius:12px;
    background:white;
    display:flex;
    align-items:center;
    justify-content:center;
    font-size:20px;
    color:#2b1c1a;
}

.avatar-link{
    text-decoration:none;
}

.avatar-link:hover .avatar{
    transform:scale(1.05);
    transition:.2s;
}

.logout{
    color:#8a6d69;
    font-size:22px;
}
        body { background-color: #d8a19a; font-family: 'Poppins', sans-serif; margin: 0; padding: 0; }
        
        /* Navbar Design */
        .navbar { background: rgba(255, 255, 255, 0.1); padding: 20px 50px; display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 24px; font-weight: 800; color: #2b1c1a; text-transform: uppercase; letter-spacing: 1px; }
        .nav-links { display: flex; gap: 20px; align-items: center; }
        .nav-btn { background: #2b1c1a; color: white; padding: 10px 20px; border-radius: 12px; text-decoration: none; font-weight: 600; font-size: 14px; display: flex; align-items: center; gap: 8px; }
        .user-profile { display: flex; align-items: center; gap: 10px; background: white; padding: 8px 15px; border-radius: 20px; font-weight: 700; color: #2b1c1a; font-size: 14px; }

        .container { max-width: 1000px; margin: 40px auto; padding: 0 20px; }
        .ticket-card{width:100%;}
        .page-header { margin-bottom: 30px; color: #2b1c1a; }
        .page-header h1 { margin: 0; font-size: 36px; font-weight: 800; text-transform: uppercase; }
        .page-header p { margin: 5px 0 0 0; color: #5a4542; font-size: 14px; font-weight: 600; text-transform: uppercase; }

        /* Ticket Cards */
        .ticket-card{
    background:white;
    border-radius:20px;
    padding:25px;
    margin-bottom:20px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    box-shadow:0 8px 25px rgba(0,0,0,0.05);
    border-left:8px solid #2b1c1a;
    width:100%;
    box-sizing:border-box;
    position:relative;
}
.ticket-card{
    display:flex;
    justify-content:space-between;
    align-items:center;
    width:100%;
    margin-bottom:20px;
    clear:both;
}
        .ticket-card.completed { border-left-color: #7a6e6c; opacity: 0.85; }
        
        .route-info h3 { margin: 0 0 5px 0; font-size: 20px; color: #2b1c1a; text-transform: uppercase; }
        .route-info p { margin: 4px 0; color: #666; font-size: 14px; }
        .route-info i { color: #2b1c1a; width: 20px; }

        .status-section{
    min-width:180px;
    display:flex;
    flex-direction:column;
    align-items:flex-end;
    justify-content:center;
    gap:10px;
}
        
        /* Badges */
        .badge { padding: 6px 14px; border-radius: 20px; font-size: 12px; font-weight: 700; text-transform: uppercase; display: inline-flex; align-items: center; gap: 5px; }
        .badge.active { background: #e8f5e9; color: #2e7d32; }
        .badge.completed { background: #eee; color: #616161; }

        .btn-pass { background: #2b1c1a; color: white; padding: 10px 18px; border-radius: 8px; text-decoration: none; font-size: 13px; font-weight: 700; transition: 0.3s; }
        .btn-pass:hover { background: #4a3532; }
        .btn-disabled { background: #ccc; color: #666; padding: 10px 18px; border-radius: 8px; font-size: 13px; font-weight: 700; cursor: not-allowed; text-decoration: none; display: inline-block; }

        /* Empty State */
        .empty-state { background: rgba(255, 255, 255, 0.5); border: 3px dashed rgba(43, 28, 26, 0.2); border-radius: 30px; padding: 60px 20px; text-align: center; color: #2b1c1a; }
        .empty-state i { font-size: 60px; color: rgba(43, 28, 26, 0.3); margin-bottom: 15px; }
        .empty-state h3 { margin: 0 0 10px 0; font-size: 18px; font-weight: 700; text-transform: uppercase; }
        .btn-book { background: #2b1c1a; color: white; padding: 12px 25px; border-radius: 12px; text-decoration: none; font-weight: 700; display: inline-block; margin-top: 15px; font-size: 14px; }
    </style>
    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>

    <%
String username =
(String)session.getAttribute("username");
%>

<nav class="top-nav">

    <div class="brand">
        SANIBUS EXPRESS
    </div>

    <div class="nav-links">

        <a href="student_home.jsp"
           class="nav-link">
            <i class="fa-solid fa-house"></i>
            DASHBOARD
        </a>

        <a href="my_tickets.jsp"
           class="nav-link active">
            <i class="fa-solid fa-ticket"></i>
            MY BOOKINGS
        </a>

        <a href="my_refunds.jsp"
           class="nav-link">
            <i class="fa-solid fa-money-bill-transfer"></i>
            My Refunds
        </a>

    </div>

    <div class="user-area">

        <div class="user-info">
            <div class="user-name">
                <%= username %>
            </div>
            <div class="user-role">
                PASSENGER
            </div>
        </div>

        <a href="edit_profile.jsp" class="avatar-link">
    <div class="avatar">
        <i class="fa-regular fa-user"></i>
    </div>
</a>

        <a href="LogoutServlet"
           class="logout">
            <i class="fa-solid fa-arrow-right-from-bracket"></i>
        </a>

    </div>

</nav>
    <%
        // CRITICAL FIX: Extract user session token BEFORE initializing database parameters
       Integer currentUserId = null;

if(session != null && session.getAttribute("userId") != null){
    currentUserId = (Integer) session.getAttribute("userId");
}

String currentUsername =
(session != null && session.getAttribute("username") != null)
? (String) session.getAttribute("username")
: "Guest";
    %>

    
    <div class="container">
        <div class="page-header">
            <h1>My Bookings</h1>
            <p>Your travel history and active reservations</p>
        </div>

        <%
            boolean hasTickets = false;
            
            // 1. Setup a unified date-time formatter matching your SQL formats
            SimpleDateFormat combinedDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            
            // 2. Capture the exact timestamp of right now
            java.util.Date currentSystemTime = new java.util.Date();

          String sql =
"SELECT p.transaction_id, p.amount, "
+ "p.refund_guarantee, p.status, "
+ "GROUP_CONCAT(DISTINCT bs2.seat_number "
+ "ORDER BY bs2.seat_number "
+ "SEPARATOR ', ') AS seats, "
+ "br.origin, br.destination, "
+ "bs.departure_time, bs.arrival_time, "
+ "bs.bus_plate_no "
+ "FROM payments p "
+ "INNER JOIN bus_schedules bs "
+ "ON p.schedule_id = bs.id "
+ "INNER JOIN bus_routes br "
+ "ON bs.route_id = br.id "
+ "LEFT JOIN booked_seats bs2 "
+ "ON p.transaction_id = bs2.transaction_id "
+ "WHERE p.user_id=? "
+ "GROUP BY p.transaction_id, "
+ "p.amount, p.refund_guarantee, "
+ "p.status, br.origin, br.destination, "
+ "bs.departure_time, bs.arrival_time, "
+ "bs.bus_plate_no "
+ "ORDER BY bs.departure_time DESC";

            try (Connection con = DBConnection.getConnection()) {
                if (con != null && currentUserId != null) {
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, currentUserId);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                hasTickets = true;
                                String txId = rs.getString("transaction_id");
                                String travelDateStr =
rs.getTimestamp("departure_time")
.toString()
.substring(0,10);   
                                String departureTimeStr =
rs.getTimestamp("departure_time")
.toString()
.substring(11,19);
                                
                                String origin = rs.getString("origin");
                                String destination = rs.getString("destination");
                                String busName = rs.getString("bus_plate_no");
  String seatNumbers =
        rs.getString("seats");

if(seatNumbers == null
        || seatNumbers.trim().isEmpty()){

    seatNumbers = "N/A";
}

boolean refundGuarantee =
rs.getInt("refund_guarantee") == 1;

String paymentStatus =
rs.getString("status");
                                String displayTime = departureTimeStr.substring(0, 5); 
                                
                                // 3. Combine date and time strings into a single timestamp text
                                String tripDateTimeRaw = travelDateStr + " " + departureTimeStr;
                                java.util.Date tripCombinedDateTime = combinedDateTimeFormat.parse(tripDateTimeRaw);
                                
                                // 4. Check if the exact trip timestamp has already passed right now
                                boolean isPast = tripCombinedDateTime.before(currentSystemTime);
        %>
                                <div class="ticket-card <%= isPast ? "completed" : "" %>">
                                    <div class="route-info">
                                        <h3><%= origin %> &rarr; <%= destination %></h3>
                                        <p><i class="fa-solid fa-calendar"></i> <strong>Date:</strong> <%= travelDateStr %></p>
                                        <p><i class="fa-solid fa-clock"></i> <strong>Departure:</strong> <%= displayTime %></p>
                                        <p><i class="fa-solid fa-bus"></i> <strong>Bus Service:</strong> SANI EXPRESS (<%= busName %>)</p>
                                        <p><i class="fa-solid fa-receipt"></i> <strong>Tx ID:</strong> <span style="font-family: monospace;"><%= txId %></span></p>
                                      
                                        <p>
                                           
    <i class="fa-solid fa-chair"></i>
    <strong>Seat:</strong>
    <span style="color:#e32626;font-weight:700;">
        <%= seatNumbers %>
    </span>
</p>  
                                    
</div>
                                                             
                                  
<div class="status-section">

<% if (isPast
    || "Refund Pending".equals(paymentStatus)
    || "Refund Approved".equals(paymentStatus)
    || "Refund Completed".equals(paymentStatus)) { %>

    <span class="badge completed">
        <i class="fa-solid fa-circle-check"></i>
        Pass Inactive
    </span>

    <span class="btn-disabled">
        Boarding Pass Disabled
    </span>

<% } else { %>

    <span class="badge active">
        <i class="fa-solid fa-circle-dot"></i>
        Active
    </span>

    <a href="payment_confirmed.jsp?id=<%= txId %>"
       class="btn-pass">
       <i class="fa-solid fa-qrcode"></i>
       Boarding Pass
    </a>

    <% if(refundGuarantee){ %>

        <a href="refund_request.jsp?tx=<%= txId %>"
           class="btn-pass"
           style="background:#c0392b;">
           <i class="fa-solid fa-money-bill-transfer"></i>
           Refund
        </a>

    <% } %>

<% } %>

</div> <!-- status-section -->

</div> <!-- ticket-card -->

   

        <%
                            }
                        }
                    }
                }
            } catch (Exception e) {
                out.println("<div style='color:red; font-weight:bold;'>Error processing logs: " + e.getMessage() + "</div>");
            }

            if (!hasTickets) {
        %>
                <div class="empty-state">
                    <i class="fa-solid fa-ticket-simple"></i>
                    <h3>You haven't made any bookings yet.</h3>
                    <p style="margin: 0; color: #5a4542; font-size: 14px;">Any active or historic trips will update here down the line.</p>
                    <a href="student_home.jsp" class="btn-book">BOOK A TRIP</a>
                </div>
        <%
            }
        %>
    </div>

</body>
</html>