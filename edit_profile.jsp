<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" import="java.sql.*" %>
<%
    // Pastikan pengguna sudah login
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Ambil data sedia ada dari database
    String email = "";
    String phone = "";
    int age = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3307/bus_system", "root", "");
        
        // Query ditambah untuk mengambil phone dan age
        PreparedStatement pst = conn.prepareStatement("SELECT email, phone, age FROM users WHERE username = ?");
        pst.setString(1, username);
        ResultSet rs = pst.executeQuery();
        
        if(rs.next()) { 
            email = rs.getString("email"); 
            phone = rs.getString("phone") != null ? rs.getString("phone") : "";
            age = rs.getInt("age");
        }
        conn.close();
    } catch (Exception e) { 
        e.printStackTrace(); 
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Profile - SANI BUS</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="edit-card">
        <h2>Update Profile</h2>
        <form action="UpdateProfileServlet" method="POST">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="new_username" value="<%= username %>" required>
            </div>
            
            <div class="form-group">
                <label>Email Address</label>
                <input type="email" name="new_email" value="<%= email %>" required>
            </div>

            <div class="form-group">
                <label>Phone Number</label>
                <input type="text" name="new_phone" value="<%= phone %>" placeholder="e.g. 0123456789">
            </div>

            <div class="form-group">
                <label>Age</label>
                <input type="number" name="new_age" value="<%= age > 0 ? age : "" %>" min="1" max="100">
            </div>
        

<button type="submit" class="btn-save">
    SAVE CHANGES
</button>

<button type="button"
        class="btn-delete"
        onclick="confirmDelete()">
    DELETE PROFILE
</button>

<a href="student_home.jsp" class="back-link">
    <i class="fa-solid fa-arrow-left"></i>
    Back to Dashboard
</a>

</form>

</div>

<script>

function confirmDelete(){

    if(confirm(
        "Are you sure you want to permanently delete your account?\n\nThis action cannot be undone.")){

        window.location.href =
        "DeleteProfileServlet";
    }
}

</script>

</body>
</html>