
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>SANI SCHEDULING SYSTEM</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>

        <%
            String lang = request.getParameter("lang");
            if (lang == null) {
                lang = "en"; 
            }

            // 2. Pemetaan Teks mengikut Bahasa (BM / BI)
            String welcomeTitle = lang.equals("bm") ? "Selamat Datang ke Sani Scheduling Bus." : "Welcome to Sani Scheduling Bus.";
            String welcomeSub   = lang.equals("bm") ? "Pengangkutan dipercayai untuk semua." : "Reliable transport for everyone.";
            String loginTitle   = lang.equals("bm") ? "LOG MASUK" : "LOG IN";
            String portalAccess = lang.equals("bm") ? "AKSES PORTAL" : "PORTAL ACCESS";
            
            // Label Borang Input
            String lblUser      = lang.equals("bm") ? "NAMA PENGGUNA" : "USERNAME";
            String lblPass      = lang.equals("bm") ? "KATA LALUAN" : "PASSWORD";
            String lblRole      = lang.equals("bm") ? "PERANAN" : "ROLE";
            String btnLogin     = lang.equals("bm") ? "Log masuk" : "Log in";
            
            // Pautan Bawah (Links)
            String txtNew       = lang.equals("bm") ? "Baru di sini?" : "New here?";
            String txtSignup    = lang.equals("bm") ? "DAFTAR" : "SIGN UP";
            String txtForgot    = lang.equals("bm") ? "Lupa kata laluan?" : "Forgot password?";
            String txtReset     = lang.equals("bm") ? "RESET DI SINI" : "CLICK HERE?";

            // Pilihan Peranan (Dropdown Options)
            String rolePass     = lang.equals("bm") ? "Penumpang" : "Passenger";
            String roleDriver   = lang.equals("bm") ? "Pemandu" : "Driver";
            String roleAdmin    = lang.equals("bm") ? "Admin" : "Admin";
            String roleManager  = lang.equals("bm") ? "Pengurus" : "Manager";

            // 3. Logik Paparan Alert Notifikasi
            String msg = request.getParameter("msg");
            if (msg != null) {
        %>
        <script>
            <% if (msg.equals("fail")) { %>
                alert("<%= lang.equals("bm") ? "Log masuk gagal! Sila cuba lagi." : "Login failed! Please Try Again" %>");
            <% } else if (msg.equals("registered")) { %>
                alert("<%= lang.equals("bm") ? "Pendaftaran berjaya!" : "Registration successful!" %>");
            <% } %>
        </script>
        <% } %>

        <div class="container">
            <div class="card">

                <!-- PANEL KIRI (Branding, Logo & Welcome Text di Tengah) -->
                <div class="left">
                    <div class="brand">
                        <span class="bus-icon"></span> <!-- Kekotak Logo Bas Mini CSS -->
                        <span class="brand-name">SANIBUS</span>
                    </div>
                    <div class="welcome-text">
                        <h1><%= welcomeTitle %></h1>
                        <p><%= welcomeSub %></p>
                    </div>
                </div>

                <!-- PANEL KANAN (Borang Akses & Butang Pautan) -->
                <div class="right">
                    
                    <div class="lang-picker">
                        <a href="?lang=en" class="lang-btn <%= lang.equals("en") ? "active" : "" %>">EN</a>
                        <a href="?lang=bm" class="lang-btn <%= lang.equals("bm") ? "active" : "" %>">BM</a>
                    </div>

                    <h2><%= loginTitle %></h2>
                    <p class="subtitle"><%= portalAccess %></p>

                    <form action="LoginServlet" method="post">
                        <input type="hidden" name="lang" value="<%= lang %>"> 
                        
                        <div class="form-container">
                            <div class="input-group">
                                <label><%= lblUser %></label>
                                <input type="text" name="username" placeholder="Username" required>
                            </div>

                            <div class="input-group">
                                <label><%= lblPass %></label>
                                <input type="password" name="password" placeholder="******" required>
                            </div>

                            <div class="input-group">
                                <label><%= lblRole %></label>
                                <select name="role">
                                    <option value="passenger"><%= rolePass %></option> 
                                    <option value="driver"><%= roleDriver %></option>
                                    <option value="admin"><%= roleAdmin %></option>
                                    <option value="manager"><%= roleManager %></option>
                                </select>
                            </div>
                        </div>

                        <button type="submit" class="login-btn"><%= btnLogin %></button>
                    </form>

                    <!-- BAHAGIAN FOOTER (Telah Ditukar Menjadi Kelas 'link-footer' Bersama Butang) -->
                    <div class="link-footer">
                        <span><%= txtNew %> <a href="register.jsp?lang=<%= lang %>" class="footer-btn"><%= txtSignup %></a></span>
                        <span><%= txtForgot %> <a href="forgot_password.jsp?lang=<%= lang %>" class="footer-btn"><%= txtReset %></a></span>
                    </div>
                </div>

            </div>
        </div>

    </body>
</html>