<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" import="java.sql.*, com.sani.DBConnection" %>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("login.jsp"); return; }
    String managerUsername = (String) session.getAttribute("username");

    String search = request.getParameter("search");
    if (search == null) search = "";

    // Load manager for editing if editId is present
    String editId   = request.getParameter("editId");
    String eFull    = "", eEmail = "", eUser = "";
    if (editId != null && !editId.isEmpty()) {
        try (Connection ec = DBConnection.getConnection();
             PreparedStatement ep = ec.prepareStatement("SELECT * FROM users WHERE id = ? AND role = 'manager'")) {
            ep.setInt(1, Integer.parseInt(editId));
            try (ResultSet er = ep.executeQuery()) {
                if (er.next()) {
                    eFull  = er.getString("fullname")  != null ? er.getString("fullname")  : "";
                    eEmail = er.getString("email")     != null ? er.getString("email")     : "";
                    eUser  = er.getString("username")  != null ? er.getString("username")  : "";
                }
            }
        } catch (Exception ignored) {}
    }
    boolean editMode = editId != null && !editId.isEmpty() && !eUser.isEmpty();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin - Managers</title>
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
        .page-header { padding: 28px 40px 0 40px; }
        .page-header h1 { font-weight: 800; font-size: 28px; color: var(--dark-brown); }
        .page-header p  { font-size: 13px; color: var(--light-text); margin-top: 4px; }
        .alert { margin: 16px 40px 0 40px; padding: 14px 20px; border-radius: 14px; display: flex; align-items: center; gap: 10px; font-size: 13px; font-weight: 600; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error   { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

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
        .btn-cancel { background: #f0e8e6; color: var(--dark-brown); border: none; padding: 13px 25px; border-radius: 14px; font-family: 'Poppins', sans-serif; font-weight: 700; font-size: 13px; cursor: pointer; width: 100%; display: flex; align-items: center; justify-content: center; gap: 8px; margin-top: 10px; text-decoration: none; transition: opacity 0.2s; }
        .btn-cancel:hover { opacity: 0.80; }
        .edit-banner { background: #fff3cd; border: 1px solid #ffc107; border-radius: 14px; padding: 12px 16px; margin-bottom: 18px; font-size: 12px; color: #856404; display: flex; align-items: center; gap: 8px; font-weight: 600; }

        .ledger-container { flex: 1; background: white; border-radius: 24px; padding: 28px; box-shadow: 0 8px 30px rgba(0,0,0,0.06); overflow-x: auto; }
        .ledger-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 18px; }
        .ledger-header h2 { font-size: 18px; color: var(--dark-brown); margin-bottom: 4px; }
        .ledger-header p  { font-size: 12px; color: var(--light-text); }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 11px 14px; font-size: 10px; text-transform: uppercase; color: var(--light-text); border-bottom: 2px solid var(--border-light); white-space: nowrap; }
        td { padding: 14px; font-size: 13px; color: var(--dark-brown); border-bottom: 1px solid var(--border-light); vertical-align: middle; }
        tr:last-child td { border-bottom: none; }
        tr.editing-row { background: #fffbea; }
        .role-badge { padding: 4px 10px; border-radius: 6px; font-size: 10px; font-weight: 700; text-transform: uppercase; }
        .role-manager { background: #cce5ff; color: #004085; }
        .btn-delete { background: #c0392b; color: white; border: none; padding: 6px 12px; border-radius: 8px; cursor: pointer; font-size: 11px; font-weight: 700; text-decoration: none; display: inline-flex; align-items: center; gap: 5px; }
        .btn-edit { background: #2b1c1a; color: white; border: none; padding: 6px 12px; border-radius: 8px; cursor: pointer; font-size: 11px; font-weight: 700; text-decoration: none; display: inline-flex; align-items: center; gap: 5px; }
        .btn-edit:hover { opacity: 0.82; }
        .manager-avatar { width: 34px; height: 34px; border-radius: 10px; background: #f0e8e6; display: inline-flex; align-items: center; justify-content: center; color: var(--dark-brown); margin-right: 8px; }
        .search-btn { padding: 10px 16px; border-radius: 10px; border: none; background: var(--dark-brown); color: white; font-weight: 700; font-size: 12px; cursor: pointer; transition: opacity 0.2s; }
        .search-btn:hover { opacity: 0.85; }
        .action-btns { display: flex; gap: 6px; justify-content: center; }
    </style>
    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>
<nav class="top-nav">
    <div class="nav-left"><span class="bus-logo">🚌</span><span class="brand-name">SANIBUS</span></div>
    <div class="nav-center">
        <a href="admin_home.jsp"            class="nav-btn"><i class="fa-solid fa-file-medical"></i> Leave Approvals</a>
        <a href="admin_schedule.jsp"        class="nav-btn"><i class="fa-solid fa-calendar-days"></i> Schedules</a>
        <a href="admin_routes.jsp"          class="nav-btn"><i class="fa-solid fa-route"></i> Routes</a>
        <a href="admin_bookings.jsp"        class="nav-btn"><i class="fa-solid fa-ticket"></i> Bookings</a>
        <a href="admin_payments.jsp"        class="nav-btn"><i class="fa-solid fa-credit-card"></i> Payments</a>
        <a href="admin_refund_requests.jsp" class="nav-btn"><i class="fa-solid fa-rotate-left"></i> Refunds</a>
        <a href="admin_admins.jsp" class="nav-btn"><i class="fa-solid fa-credit-card"></i> Admins</a>
        <a href="admin_managers.jsp" class="nav-btn active"><i class="fa-solid fa-credit-card"></i> Managers</a>
        <a href="admin_drivers.jsp" class="nav-btn"><i class="fa-solid fa-credit-card"></i> Drivers</a>
    </div>
    <div class="nav-right">
        <div class="user-meta"><span class="user-name"><%= managerUsername %></span><span class="user-role">System Admin</span></div>
        <a href="edit_profile.jsp" class="avatar">
    <i class="fa-regular fa-user"></i>
</a>
        <a href="LogoutServlet" style="color:var(--dark-brown); margin-left:8px; font-size:20px;"><i class="fa-solid fa-arrow-right-from-bracket"></i></a>
    </div>
</nav>

<div class="page-header">
    <h1><i class="fa-solid fa-id-card" style="font-size:22px; margin-right:10px;"></i>Manager Management</h1>
    <p>Register new managers and manage all manager accounts</p>
</div>

<% if ("success".equals(request.getParameter("msg"))) { %>
    <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Manager registered successfully.</div>
<% } else if ("updated".equals(request.getParameter("msg"))) { %>
    <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Manager updated successfully.</div>
<% } else if ("deleted".equals(request.getParameter("msg"))) { %>
    <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Manager account removed.</div>
<% } else if ("error".equals(request.getParameter("msg"))) { %>
    <div class="alert alert-error"><i class="fa-solid fa-circle-xmark"></i> Operation failed. Username may already exist.</div>
<% } %>

<div class="main-layout">
    <aside>
        <div class="form-card">
            <% if (editMode) { %>
                <h2>Edit Manager</h2>
                <p>Update details for this manager account.</p>
                <div class="edit-banner"><i class="fa-solid fa-pen-to-square"></i> Editing: <strong><%= eFull.isEmpty() ? eUser : eFull %></strong></div>
                <form action="EditManagerServlet" method="POST">

<input type="hidden"
       name="id"
       value="<%= editId %>">

<label class="field-label">Full Name</label>
<div class="input-row">
    <i class="fa-solid fa-user"></i>
    <input type="text"
           name="fullname"
           value="<%= eFull %>"
           required>
</div>

<label class="field-label">Email</label>
<div class="input-row">
    <i class="fa-solid fa-envelope"></i>
    <input type="email"
           name="email"
           value="<%= eEmail %>"
           required>
</div>

<label class="field-label">Username</label>
<div class="input-row">
    <i class="fa-solid fa-at"></i>
    <input type="text"
           name="username"
           value="<%= eUser %>"
           required>
</div>

<label class="field-label">
New Password (leave blank to keep current)
</label>

<div class="input-row">
    <i class="fa-solid fa-lock"></i>
    <input type="password"
           name="password">
</div>

<button type="submit"
        class="btn-primary">
    <i class="fa-solid fa-floppy-disk"></i>
    Save Changes
</button>

<a href="admin_managers.jsp"
   class="btn-cancel">
   Cancel
</a>

</form>
            <% } else { %>
                <h2>Register Manager</h2>
                <p>Create a new manager account with login credentials.</p>
                <form action="AddManagerServlet" method="POST">
                    <label class="field-label">Full Name</label>
                    <div class="input-row">
                        <i class="fa-solid fa-user" style="color:var(--light-text);"></i>
                        <input type="text" name="fullname" placeholder="e.g., Ahmad bin Ali" required>
                    </div>
                    <label class="field-label">Email</label>
                    <div class="input-row">
                        <i class="fa-solid fa-envelope" style="color:var(--light-text);"></i>
                        <input type="email" name="email" placeholder="e.g., ahmad@sanibus.com" required>
                    </div>
                    <label class="field-label">Username</label>
                    <div class="input-row">
                        <i class="fa-solid fa-at" style="color:var(--light-text);"></i>
                        <input type="text" name="username" placeholder="e.g., ahmad123" required>
                    </div>
                    <label class="field-label">Password</label>
                    <div class="input-row">
                        <i class="fa-solid fa-lock" style="color:var(--light-text);"></i>
                        <input type="password" name="password" placeholder="Set a password" required>
                    </div>
                    <button type="submit" class="btn-primary"><i class="fa-solid fa-user-plus"></i> Register Manager</button>
                </form>
            <% } %>
        </div>
    </aside>

    <main class="ledger-container">
        <div class="ledger-header">
            <div>
                <h2>All Managers</h2>
                <p>All registered manager accounts in the system</p>
            </div>
            <form method="get" action="admin_managers.jsp" style="display:flex; gap:8px; align-items:center;">
                <input type="text"
                       name="search"
                       value="<%= search %>"
                       placeholder="Search manager..."
                       style="padding:10px 15px; border-radius:10px; border:1px solid #ddd; font-family:'Poppins',sans-serif; font-size:12px; width:200px;">
                <button type="submit" class="search-btn">
                    <i class="fa-solid fa-magnifying-glass"></i>
                </button>
            </form>
        </div>

        <table>
            <thead>
                <tr><th>#</th><th>Manager</th><th>Email</th><th>Username</th><th>Role</th><th style="text-align:center;">Actions</th></tr>
            </thead>
            <tbody>
<%
    boolean hasSearch = search != null && !search.trim().isEmpty();
    String sqlQuery = hasSearch
        ? "SELECT * FROM users WHERE role = 'manager' AND (fullname LIKE ? OR username LIKE ? OR email LIKE ?) ORDER BY id ASC"
        : "SELECT * FROM users WHERE role = 'manager' ORDER BY id ASC";

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
                int    managerId   = rs.getInt("id");
                String managerFull = rs.getString("fullname") != null ? rs.getString("fullname") : rs.getString("username");
                String managerEmail= rs.getString("email")    != null ? rs.getString("email")    : "—";
                String managerUser = rs.getString("username");
                boolean isEditing = editMode && editId.equals(String.valueOf(managerId));
%>
                <tr class="<%= isEditing ? "editing-row" : "" %>">
                    <td style="color:var(--light-text); font-weight:600;"><%= managerId %></td>
                    <td>
                        <div style="display:flex; align-items:center;">
                            <span class="manager-avatar"><i class="fa-solid fa-user"></i></span>
                            <strong><%= managerFull %></strong>
                        </div>
                    </td>
                    <td><%= managerEmail %></td>
                    <td><code style="background:#f5f5f5; padding:3px 8px; border-radius:6px;"><%= managerUser %></code></td>
                    <td><span class="role-badge role-manager">Manager</span></td>
                    <td style="text-align:center;">
                        <div class="action-btns">
                            <a href="admin_managers.jsp?editId=<%= managerId %><%= search.isEmpty() ? "" : "&search=" + search %>"
                               class="btn-edit"><i class="fa-solid fa-pen"></i> Edit</a>
                            <a href="DeleteManagerServlet?id=<%= managerId %>" class="btn-delete"
                               onclick="return confirm('Remove this manager account? Their schedules will be unassigned.');"><i class="fa-solid fa-trash"></i> Remove</a>
                        </div>
                    </td>
                </tr>
<%
            }
            if (!has) {
%>
                <tr><td colspan="6" style="text-align:center; color:var(--light-text); padding:40px;">
                    <i class="fa-solid fa-id-card" style="font-size:28px; display:block; margin-bottom:10px; color:#d8a19a;"></i>
                    <%= hasSearch ? "No managers found matching \"" + search + "\"." : "No managers registered yet." %>
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