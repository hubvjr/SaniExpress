<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.sani.DBConnection" %>

<%
    String txId = request.getParameter("tx");

    String origin = "";
    String destination = "";
    String seats = "";
    double amountPaid = 0.0;
    double refundAmount = 0.0;
    int scheduleId = 0;

    try(Connection con = DBConnection.getConnection()){

        String sql =
        "SELECT p.schedule_id,p.amount," +
        "br.origin,br.destination," +
        "GROUP_CONCAT(bs.seat_number) seats " +
        "FROM payments p " +
        "INNER JOIN bus_schedules b ON p.schedule_id=b.id " +
        "INNER JOIN bus_routes br ON b.route_id=br.id " +
        "LEFT JOIN booked_seats bs ON p.transaction_id=bs.transaction_id " +
        "WHERE p.transaction_id=? " +
        "GROUP BY p.transaction_id";

        PreparedStatement ps =
        con.prepareStatement(sql);

        ps.setString(1,txId);

        ResultSet rs = ps.executeQuery();

        if(rs.next()){

            scheduleId =
            rs.getInt("schedule_id");

            amountPaid =
            rs.getDouble("amount");

            refundAmount =
            amountPaid * 0.90;

            origin =
            rs.getString("origin");

            destination =
            rs.getString("destination");

            seats =
            rs.getString("seats");
        }

    }catch(Exception e){
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Refund Request</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">

    <style>
        body{
            background:#d8a19a;
            font-family:'Poppins',sans-serif;
        }

        .card{
            width:700px;
            margin:40px auto;
            background:white;
            border-radius:25px;
            padding:30px;
        }

        .row{
            margin-bottom:15px;
        }

        label{
            display:block;
            font-size:13px;
            font-weight:700;
            margin-bottom:5px;
        }

        input{
            width:100%;
            padding:12px;
            border-radius:10px;
            border:1px solid #ddd;
        }

        .info-box{
            background:#f8f8f8;
            padding:15px;
            border-radius:15px;
            margin-bottom:20px;
        }

        .btn{
            background:#2b1c1a;
            color:white;
            border:none;
            width:100%;
            padding:15px;
            border-radius:12px;
            font-weight:700;
            cursor:pointer;
        }
    </style>
    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>

<div class="card">

    <h2>Refund Request</h2>

    <div class="info-box">

        <p><strong>Route:</strong>
            <%= origin %> → <%= destination %>
        </p>

        <p><strong>Seat:</strong>
            <%= seats %>
        </p>

        <p><strong>Amount Paid:</strong>
            RM <%= String.format("%.2f",amountPaid) %>
        </p>

        <p style="color:red;">
            <strong>
                Refund Amount (90%):
                RM <%= String.format("%.2f",refundAmount) %>
            </strong>
        </p>

    </div>

    <form action="RefundRequestServlet" method="post">

        <input type="hidden"
               name="transaction_id"
               value="<%= txId %>">

        <input type="hidden"
               name="schedule_id"
               value="<%= scheduleId %>">

        <input type="hidden"
               name="amount_paid"
               value="<%= amountPaid %>">

        <input type="hidden"
               name="refund_amount"
               value="<%= refundAmount %>">

        <input type="hidden"
               name="seat_numbers"
               value="<%= seats %>">

        <div class="row">
            <label>Bank Holder Name</label>
            <input type="text"
                   name="bank_holder_name"
                   required>
        </div>

        <div class="row">
            <label>Bank Name</label>
            <input type="text"
                   name="bank_name"
                   required>
        </div>

        <div class="row">
            <label>Bank Account Number</label>
            <input type="text"
                   name="bank_account_number"
                   required>
        </div>

        <button class="btn">
            Submit Refund Request
        </button>

    </form>

</div>

</body>
</html>