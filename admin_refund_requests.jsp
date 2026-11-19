<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.sani.DBConnection" %>

<%
if(session.getAttribute("username")==null){
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Refund Requests</title>
    
    <link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">

    <style>

        body{
    background:#d8a19a;
    font-family:'Poppins',sans-serif;
    margin:0;
    padding:0;
}

        .card{
            background:white;
            border-radius:25px;
            padding:25px;
        }

        table{
            width:100%;
            border-collapse:collapse;
        }

        th{
            background:#2b1c1a;
            color:white;
            padding:12px;
        }

        td{
            padding:12px;
            border-bottom:1px solid #eee;
        }

        .btn-approve{
            background:#27ae60;
            color:white;
            padding:8px 12px;
            text-decoration:none;
            border-radius:8px;
            border:none;
            cursor:pointer;
        }

        .btn-reject{
            background:#e74c3c;
            color:white;
            padding:8px 12px;
            text-decoration:none;
            border-radius:8px;
            border:none;
            cursor:pointer;
        }
        
        .top-nav{
    display:flex;
    justify-content:space-between;
    align-items:center;
    padding:12px 50px;
    background:rgba(255,255,255,.15);
    backdrop-filter:blur(10px);
    border-bottom:1px solid rgba(255,255,255,.1);
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
    border:1px solid rgba(43,28,26,.15);
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

.nav-btn.active{
    background:#2b1c1a;
    color:#fff;
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
    text-transform:uppercase;
}

.user-role{
    font-size:9px;
    color:#8c7673;
}

.avatar-container{
    width:40px;
    height:40px;
    border-radius:10px;
    background:white;
    display:flex;
    justify-content:center;
    align-items:center;
}

    </style>

    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>
    <%
String adminUsername =
(String) session.getAttribute("username");
%>

<nav class="top-nav">
    <div class="nav-left">
        <span class="bus-logo">🚌</span>
        <span class="brand-name">SANIBUS</span>
    </div>

       <div class="nav-center">
        <a href="admin_home.jsp"            class="nav-btn"><i class="fa-solid fa-file-medical"></i> Leave Approvals</a>
        <a href="admin_schedule.jsp"        class="nav-btn"><i class="fa-solid fa-calendar-days"></i> Schedules</a>
        <a href="admin_routes.jsp"          class="nav-btn"><i class="fa-solid fa-route"></i> Routes</a>
        <a href="admin_bookings.jsp"        class="nav-btn"><i class="fa-solid fa-ticket"></i> Bookings</a>
        <a href="admin_payments.jsp"        class="nav-btn"><i class="fa-solid fa-credit-card"></i> Payments</a>
        <a href="admin_refund_requests.jsp" class="nav-btn active"><i class="fa-solid fa-rotate-left"></i> Refunds</a>
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

<div class="card" style="margin:30px;">

<h2>Refund Requests</h2>

<table>

<tr>
    <th>ID</th>
    <th>Transaction</th>
    <th>User</th>
    <th>Seats</th>
    <th>Paid</th>
    <th>Refund</th>
    <th>Status</th>
    <th>Action</th>
</tr>

<%

try(Connection con = DBConnection.getConnection()){

    String sql =
    "SELECT * FROM refund_requests " +
    "ORDER BY request_date DESC";

    PreparedStatement ps =
    con.prepareStatement(sql);

    ResultSet rs =
    ps.executeQuery();

    while(rs.next()){

%>

<tr>

<td>
<%= rs.getInt("id") %>
</td>

<td>
<%= rs.getString("payment_transaction_id") %>
</td>

<td>
<%= rs.getInt("user_id") %>
</td>

<td>
<%= rs.getString("seat_numbers") %>
</td>

<td>
RM <%= rs.getDouble("amount_paid") %>
</td>

<td>
RM <%= rs.getDouble("refund_amount") %>
</td>

<td>
<%= rs.getString("status") %>
</td>

<td>

<%
if("Pending".equals(
rs.getString("status"))){
%>

<form action="RefundApprovalServlet"
      method="post">

<input type="hidden"
       name="refundId"
       value="<%= rs.getInt("id") %>">

<button
name="action"
value="approve"
class="btn-approve">

Approve

</button>

<button
name="action"
value="reject"
class="btn-reject">

Reject

</button>

</form>

<%
}else{
%>

Completed

<%
}
%>

</td>

</tr>

<%
    }
}catch(Exception e){
    e.printStackTrace();
}
%>

</table>

</div>

</body>
</html>