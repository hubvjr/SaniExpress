<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String lang = request.getParameter("lang");
    if (lang == null) {
        lang = "en";
    }

    String pageTitle = "SANI SCHEDULING SYSTEM";

    String welcomeTitle = lang.equals("bm")
            ? "Perjalanan Anda Bermula Di Sini."
            : "Your Journey Starts Here.";

    String welcomeSub = lang.equals("bm")
            ? "Sertai perjalanan pintar bersama Sani."
            : "Join Sani smarter commute.";

    String registerTitle = lang.equals("bm")
            ? "DAFTAR AKAUN"
            : "REGISTER";

    String registerSub = lang.equals("bm")
            ? "CIPTA AKAUN"
            : "CREATE ACCOUNT";

    String lblFullname = lang.equals("bm")
            ? "NAMA PENUH"
            : "FULL NAME";

    String lblEmail = "EMAIL";

    String lblUsername = lang.equals("bm")
            ? "NAMA PENGGUNA"
            : "USERNAME";

    String lblPassword = lang.equals("bm")
            ? "KATA LALUAN"
            : "PASSWORD";

    String lblRole = lang.equals("bm")
            ? "PERANAN AKAUN"
            : "ACCOUNT ROLE";

    String placeholderName = lang.equals("bm")
            ? "Masukkan nama penuh"
            : "Enter full name";

    String placeholderUser = lang.equals("bm")
            ? "Masukkan nama pengguna"
            : "Username";

    String rolePassenger = lang.equals("bm")
            ? "PENUMPANG"
            : "PASSENGER";

    String btnRegister = lang.equals("bm")
            ? "Daftar"
            : "Register";

    String alreadyAccount = lang.equals("bm")
            ? "Sudah mempunyai akaun?"
            : "Already have an account?";

    String btnLogin = lang.equals("bm")
            ? "LOG MASUK"
            : "LOG IN";
%>

<!DOCTYPE html>
<html>
<head>
    <title><%= pageTitle %></title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<%
    String msg = request.getParameter("msg");
    if (msg != null) {
%>
<script>
<%
    if (msg.equals("fail")) {
%>
    alert("<%= lang.equals("bm")
        ? "Pendaftaran gagal! Sila cuba lagi."
        : "Registration failed! Please Try Again" %>");
<%
    }
%>
</script>
<%
    }
%>

<div class="container">
    <div class="card">

        <div class="left">
            <div class="brand">
                <span class="brand-name">SANIBUS</span>
            </div>

            <div class="welcome-text">
                <h1><%= welcomeTitle %></h1>
                <p><%= welcomeSub %></p>
            </div>
        </div>

        <div class="right">

            <div class="lang-picker">
                <a href="?lang=en"
                   class="lang-btn <%= lang.equals("en") ? "active" : "" %>">
                    EN
                </a>

                <a href="?lang=bm"
                   class="lang-btn <%= lang.equals("bm") ? "active" : "" %>">
                    BM
                </a>
            </div>

            <h2><%= registerTitle %></h2>
            <p class="subtitle"><%= registerSub %></p>

            <form action="RegisterServlet" method="post">

                <input type="hidden"
                       name="lang"
                       value="<%= lang %>">

                <div class="input-group">
                    <label><%= lblFullname %></label>
                    <input type="text"
                           name="fullname"
                           placeholder="<%= placeholderName %>"
                           required>
                </div>

                <div class="input-group">
                    <label><%= lblEmail %></label>
                    <input type="email"
                           name="email"
                           placeholder="user@gmail.com"
                           required>
                </div>

                <div class="input-group">
                    <label><%= lblUsername %></label>
                    <input type="text"
                           name="username"
                           placeholder="<%= placeholderUser %>"
                           required>
                </div>

                <div class="input-group">
                    <label><%= lblPassword %></label>

                    <input type="password"
                           id="password"
                           name="password"
                           placeholder="********"
                           required
                           oninput="validatePassword()">

                    <div id="password-alert"
                         style="font-size:11px;
                                margin-top:5px;
                                display:none;
                                font-weight:bold;">
                    </div>
                </div>

                <div class="input-group">
                    <label><%= lblRole %></label>

                    <div class="role-selector">
                        <label class="role-item">
                            <input type="radio"
                                   name="role"
                                   value="passenger"
                                   checked>

                            <span class="role-btn">
                                <%= rolePassenger %>
                            </span>
                        </label>
                    </div>
                </div>

                <button type="submit"
                        id="registerBtn"
                        class="login-btn">
                    <%= btnRegister %>
                </button>

            </form>

            <div class="link-footer">
                <span><%= alreadyAccount %></span>

                <a href="login.jsp?lang=<%= lang %>"
                   class="footer-btn">
                    <%= btnLogin %>
                </a>
            </div>

        </div>

    </div>
</div>

<script>
function validatePassword() {

    var passInput = document.getElementById("password");
    var alertBox = document.getElementById("password-alert");
    var registerBtn = document.getElementById("registerBtn");

    var value = passInput.value;

    var hasNumber = /\d/.test(value);
    var hasSpecial = /[!@#$%&]/.test(value);
    var isLongEnough = value.length >= 6;

    if (value.length === 0) {
        alertBox.style.display = "none";
        passInput.style.border = "";
        registerBtn.disabled = false;
        return;
    }

    alertBox.style.display = "block";

    if (hasNumber && hasSpecial && isLongEnough) {

        passInput.style.border = "2px solid #2ecc71";

        alertBox.innerHTML =
            "<%= lang.equals("bm")
            ? "Kata laluan memenuhi semua syarat"
            : "Password meets all requirements" %>";

        alertBox.style.color = "#2ecc71";

        registerBtn.disabled = false;

    } else {

        passInput.style.border = "2px solid #a61c22";

        alertBox.innerHTML =
            "<%= lang.equals("bm")
            ? "Kata laluan mesti mengandungi sekurang-kurangnya 6 aksara, 1 nombor dan 1 aksara khas (!@#$%&)"
            : "Password must contain at least 6 characters, 1 number and 1 special character (!@#$%&)" %>";

        alertBox.style.color = "#a61c22";

        registerBtn.disabled = true;
    }
}
</script>

</body>
</html>
```
