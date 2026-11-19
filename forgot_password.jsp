<%
    String lang = request.getParameter("lang");
    if (lang == null) {
        lang = "en";
    }

    String pageTitle = lang.equals("bm")
            ? "SET SEMULA KATA LALUAN - SANI BUS"
            : "RESET PASSWORD - SANI BUS";

    String leftTitle = lang.equals("bm")
            ? "Keselamatan Akaun Anda."
            : "Security First.";

    String leftSubtitle = lang.equals("bm")
            ? "Pastikan akaun anda sentiasa selamat."
            : "Keep your account safe and connected.";

    String resetTitle = lang.equals("bm")
            ? "SET SEMULA KATA LALUAN"
            : "RESET PASSWORD";

    String resetSub = lang.equals("bm")
            ? "KEMASKINI AKSES AKAUN"
            : "UPDATE ACCOUNT ACCESS";

    String lblUsername = lang.equals("bm")
            ? "NAMA PENGGUNA"
            : "USERNAME";

    String lblPassword = lang.equals("bm")
            ? "KATA LALUAN BAHARU"
            : "NEW PASSWORD";

    String usernamePlaceholder = lang.equals("bm")
            ? "Masukkan Username anda"
            : "Enter your Username";

    String btnUpdate = lang.equals("bm")
            ? "KEMASKINI KATA LALUAN"
            : "UPDATE PASSWORD";

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
    <meta charset="UTF-8">
    <title><%= pageTitle %></title>
    <link rel="stylesheet" href="style.css">
</head>

<body>

<div class="container">
    <div class="card">

        <!-- LEFT PANEL -->
        <div class="left">
            <div class="brand">
                <span class="bus-icon"></span>
                <span class="brand-name">SANIBUS</span>
            </div>

            <div class="welcome-text">
                <h1><%= leftTitle %></h1>
                <p><%= leftSubtitle %></p>
            </div>
        </div>

        <!-- RIGHT PANEL -->
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

            <h2><%= resetTitle %></h2>
            <p class="subtitle"><%= resetSub %></p>

            <form action="ForgotPasswordServlet" method="post">

                <input type="hidden"
                       name="lang"
                       value="<%= lang %>">

                <div class="form-container">

                    <div class="input-group">
                        <label><%= lblUsername %></label>
                        <input type="text"
                               name="username"
                               placeholder="<%= usernamePlaceholder %>"
                               required>
                    </div>

                    <div class="input-group">
                        <label><%= lblPassword %></label>

                        <input type="password"
                               id="password"
                               name="password"
                               placeholder="********"
                               required
                               oninput="validatePasswordFormat()">

                        <div id="password-alert"
                             style="font-size:11px;
                                    margin-top:5px;
                                    display:none;
                                    font-weight:bold;">
                        </div>
                    </div>

                </div>

                <button type="submit"
                        id="submitBtn"
                        class="login-btn">
                    <%= btnUpdate %>
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
function validatePasswordFormat() {

    var passInput = document.getElementById("password");
    var alertBox = document.getElementById("password-alert");
    var submitBtn = document.getElementById("submitBtn");

    var value = passInput.value;

    var hasNumber = /\d/.test(value);
    var hasSpecial = /[!@#$%&]/.test(value);
    var isLongEnough = value.length >= 6;

    if (value.length === 0) {
        alertBox.style.display = "none";
        passInput.style.border = "2px solid #f7f2f2";
        submitBtn.disabled = false;
        return;
    }

    alertBox.style.display = "block";

    if (hasNumber && hasSpecial && isLongEnough) {

        passInput.style.border = "2px solid #2ecc71";

        alertBox.innerHTML =
            "<%= lang.equals("bm")
            ? "Kata laluan memenuhi semua syarat."
            : "Password meets all requirements." %>";

        alertBox.style.color = "#2ecc71";
        submitBtn.disabled = false;

    } else {

        passInput.style.border = "2px solid #a61c22";

        alertBox.innerHTML =
            "<%= lang.equals("bm")
            ? "Kata laluan mesti mengandungi sekurang-kurangnya 6 aksara, 1 nombor dan 1 aksara khas (!@#$%&)."
            : "Password must be at least 6 characters and include at least 1 number and 1 special character (!@#$%&)." %>";

        alertBox.style.color = "#a61c22";
        submitBtn.disabled = true;
    }
}
</script>

</body>
</html>
```
