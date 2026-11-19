<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.sani.DBConnection" %>

<%
Integer userId =
(Integer) session.getAttribute("userId");

if(userId == null){
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>

<title>My Refunds</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">

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
body{
    background:#d8a19a;
    font-family:'Poppins',sans-serif;
}

.container{
    width:1000px;
    margin:30px auto;
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

.pending{
    color:#f39c12;
    font-weight:bold;
}

.approved{
    color:#3498db;
    font-weight:bold;
}

.rejected{
    color:#e74c3c;
    font-weight:bold;
}

.completed{
    color:#27ae60;
    font-weight:bold;
}

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
           class="nav-link ">
            <i class="fa-solid fa-ticket"></i>
            MY BOOKINGS
        </a>

        <a href="my_refunds.jsp"
           class="nav-link active">
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

<div class="container">

<div class="card">

<h2>My Refund Requests</h2>

<table>

<tr>

<th>ID</th>
<th>Transaction</th>
<th>Seats</th>
<th>Amount Paid</th>
<th>Refund Amount</th>
<th>Status</th>

</tr>

<%

try(Connection con =
DBConnection.getConnection()){

    String sql =
    "SELECT * FROM refund_requests " +
    "WHERE user_id=? " +
    "ORDER BY request_date DESC";

    PreparedStatement ps =
    con.prepareStatement(sql);

    ps.setInt(1,userId);

    ResultSet rs =
    ps.executeQuery();

    while(rs.next()){

        String displayStatus =
        rs.getString("status");

        Timestamp approvalDate =
        rs.getTimestamp("approval_date");

        if("Approved".equals(displayStatus)
                && approvalDate != null){

            long diff =
            System.currentTimeMillis()
            -
            approvalDate.getTime();

            long days =
            diff / (1000 * 60 * 60 * 24);

            if(days >= 3){

                displayStatus =
                "Completed";

                String updateSql =
                "UPDATE refund_requests " +
                "SET status='Completed'," +
                "completed_date=NOW() " +
                "WHERE id=?";

                PreparedStatement updatePs =
                con.prepareStatement(updateSql);

                updatePs.setInt(
                1,
                rs.getInt("id"));

                updatePs.executeUpdate();

                String paymentSql =
                "UPDATE payments " +
                "SET status='Refund Completed' " +
                "WHERE transaction_id=?";

                PreparedStatement paymentPs =
                con.prepareStatement(paymentSql);

                paymentPs.setString(
                1,
                rs.getString(
                "payment_transaction_id"));

                paymentPs.executeUpdate();
            }
        }

%>

<tr>

<td>
<%= rs.getInt("id") %>
</td>

<td>
<%= rs.getString(
"payment_transaction_id") %>
</td>

<td>
<%= rs.getString(
"seat_numbers") %>
</td>

<td>
RM
<%= rs.getDouble(
"amount_paid") %>
</td>

<td>
RM
<%= rs.getDouble(
"refund_amount") %>
</td>

<td>

<%

if("Pending".equals(displayStatus)){
%>

<span class="pending">
Refund Request Pending
</span>

<%
}
else if("Approved".equals(displayStatus)){
%>

<span class="approved">
Refund Approved
<br>
Refund will be completed
within 3 working days
</span>

<%
}
else if("Rejected".equals(displayStatus)){
%>

<span class="rejected">
Refund Rejected
</span>

<%
}
else{
%>

<span class="completed">
Refund Completed
</span>

<%
}
%>

</td>

</tr>

<%
    }
}
catch(Exception e){
    e.printStackTrace();
}
%>

</table>

<br>

<a href="my_tickets.jsp"
   class="nav-link"></a>

<a href="my_refunds.jsp"
   class="nav-link active"></a>

</div>

</div>

</body>
</html>