<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Payment Selection - SANI</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">
    <style>
        body { background-color: #d8a19a; font-family: 'Poppins', sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .payment-card { background: white; padding: 40px; border-radius: 30px; width: 450px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .amount-display { text-align: center; margin-bottom: 30px; background: #fdf2f1; padding: 20px; border-radius: 20px; }
        .method-opt { 
            display: flex; align-items: center; gap: 15px; padding: 20px; 
            border: 2px solid #f0f0f0; border-radius: 15px; margin-bottom: 15px; 
            cursor: pointer; transition: 0.3s; position: relative;
        }
        .method-opt:hover { border-color: #2b1c1a; background: #fafafa; }
        .method-opt input[type="radio"] { position: absolute; right: 20px; }
        .method-opt i { font-size: 24px; color: #2b1c1a; width: 30px; }
  .btn-confirm {
    width: 100%;
    padding: 18px;
    border: none;
    border-radius: 12px;
    background: #2b1c1a;
    color: white;
    font-family: 'Poppins', sans-serif;
    font-size: 13px;
    font-weight: 800;
    letter-spacing: 1px;
    text-transform: uppercase;
    cursor: pointer;
    margin-top: 10px;
    transition: 0.3s ease;
}

.btn-confirm:hover {
    background: #402b28;
    transform: translateY(-2px);
}
    </style>
    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>
   
    <%
        // FIXED: Explicit structural safety filter added to capture raw direct page hits safely
        String displayAmt = (session != null && session.getAttribute("totalAmount") != null) ? (String) session.getAttribute("totalAmount") : "0.00";
    %>
    <div class="payment-card">
        <div class="amount-display">
            <small style="font-weight:600; color:#b5a4a1;">TOTAL PAYABLE</small>
            <h1 style="color: #e32626; margin: 5px 0;">RM <%= displayAmt %></h1>
        </div>

        <form action="PaymentServlet"
      method="post"
      onsubmit="return validatePayment();">
<!-- FPX -->
<label class="method-opt"
       style="display:block;">

    <div style="
         display:flex;
         justify-content:space-between;
         align-items:center;">

        <div style="
             display:flex;
             align-items:center;
             gap:15px;">

            <i class="fa-solid fa-building-columns"></i>

            <strong>
                FPX Online Banking
            </strong>

        </div>

        <input type="radio"
               name="method"
               value="FPX"
               onclick="showPaymentDetails('fpx')"
               required>

    </div>

    <div
        id="fpxSection"
         class="payment-details"
         style="
             display:none;
             margin-top:20px;">

        <small style="color:#666;">

            You will be redirected to ToyyibPay
            to choose your bank.

        </small>

    </div>

</label>


<!-- E-Wallet -->
<label class="method-opt"
       style="display:block;">

    <div
        
    style="
         display:flex;
         justify-content:space-between;
         align-items:center;">

        <div style="
             display:flex;
             align-items:center;
             gap:15px;">

            <i class="fa-solid fa-wallet"></i>

            <strong>
                E-Wallet
            </strong>

        </div>

        <input type="radio"
               name="method"
               value="E-Wallet"
               onclick="showPaymentDetails('ewallet')">

    </div>

    <div
        id="ewalletSection"
         class="payment-details"
         style="
             display:none;
             margin-top:20px;">

        <select id="ewalletProvider"
        name="ewalletProvider"
        style="
            width:100%;
            padding:12px;
            box-sizing:border-box;">

          <option value="" selected disabled>
    Select E-Wallet
</option>

            <option value="Touch 'n Go eWallet">
                Touch 'n Go eWallet
            </option>

            <option value="GrabPay">
                GrabPay
            </option>

        </select>

    </div>

</label>


<!-- Card -->
<label class="method-opt"
       style="display:block;">

    <div
        
    style="
         display:flex;
         justify-content:space-between;
         align-items:center;">

        <div style="
             display:flex;
             align-items:center;
             gap:15px;">

            <i class="fa-solid fa-credit-card"></i>

            <strong>
                Credit / Debit Card
            </strong>

        </div>

        <input type="radio"
               name="method"
               value="Card"
               onclick="showPaymentDetails('card')">

    </div>

    <div
        
    id="cardSection"
         class="payment-details"
         style="
             display:none;
             margin-top:20px;">

       <input type="text"
       id="cardHolder"
       name="cardHolder"
       placeholder="CARD HOLDER NAME"
       style="
            width:100%;
            padding:12px;
            margin-bottom:12px;
            box-sizing:border-box;">
       
       <input type="text"
       id="cardNumber"
       name="cardNumber"
       placeholder="1234567812345678"
       maxlength="16"
       style="
            width:100%;
            padding:12px;
            margin-bottom:12px;
            box-sizing:border-box;">
       
       <input type="text"
       id="expiryDate"
       name="expiryDate"
       placeholder="MM/YY"
       maxlength="5"
       style="
            width:100%;
            padding:12px;
            margin-bottom:12px;
            box-sizing:border-box;">

       <input type="password"
       id="cvv"
       name="cvv"
       placeholder="CVV"
       maxlength="3"
       style="
            width:100%;
            padding:12px;
            box-sizing:border-box;">

    </div>

  
</label>


  <button type="submit"
        class="btn-confirm">

    CONFIRM PAYMENT

</button>
        </form>
    </div>
       <script>

function showPaymentDetails(type) {

    document.getElementById("fpxSection")
            .style.display = "none";

    document.getElementById("ewalletSection")
            .style.display = "none";

    document.getElementById("cardSection")
            .style.display = "none";

    if (type === "fpx") {

        document.getElementById("fpxSection")
                .style.display = "block";

    } else if (type === "ewallet") {

        document.getElementById("ewalletSection")
                .style.display = "block";

    } else if (type === "card") {

        document.getElementById("cardSection")
                .style.display = "block";
    }
}


function validatePayment() {

    const selectedMethod =
            document.querySelector(
                    'input[name="method"]:checked');

    if (!selectedMethod) {

        alert(
            "Please select a payment method.");

        return false;
    }


    // E-Wallet Validation
    if (selectedMethod.value === "E-Wallet") {

        const wallet =
                document.getElementById(
                        "ewalletProvider").value;

        if (wallet === "") {

            alert(
                "Please select an E-Wallet provider.");

            return false;
        }
    }


    // Card Validation
// Card Validation
if (selectedMethod.value === "Card") {

   

    const holder =
            document.getElementById(
                    "cardHolder").value.trim();

    const number =
            document.getElementById(
                    "cardNumber").value.trim();

    const expiry =
            document.getElementById(
                    "expiryDate").value.trim();

    const cvv =
            document.getElementById(
                    "cvv").value.trim();

    // FULL CAPITAL LETTERS
    const holderRegex = /^[A-Z ]+$/;

    if (!holderRegex.test(holder)) {

        alert(
            "Card holder name must be in CAPITAL LETTERS.");

        return false;
    }

    // EXACTLY 16 DIGITS
    const cardRegex = /^\d{16}$/;

    if (!cardRegex.test(number)) {

        alert(
            "Card number must contain exactly 16 digits.");

        return false;
    }

    // MM/YY FORMAT
    const expiryRegex =
            /^(0[1-9]|1[0-2])\/\d{2}$/;

    if (!expiryRegex.test(expiry)) {

        alert(
            "Expiry date must follow MM/YY format.");

        return false;
    }

    // CHECK EXPIRY DATE
    const parts = expiry.split("/");

    const expMonth =
            parseInt(parts[0], 10);

    const expYear =
            parseInt(parts[1], 10);

    const today =
            new Date();

    const currentMonth =
            today.getMonth() + 1;

    const currentYear =
            today.getFullYear() % 100;

    if (expYear < currentYear ||
            (expYear === currentYear
            && expMonth < currentMonth)) {

        alert(
            "Card expiry date cannot be in the past.");

        return false;
    }

    // EXACTLY 3 DIGITS
    const cvvRegex = /^\d{3}$/;

    if (!cvvRegex.test(cvv)) {

        alert(
            "CVV must contain exactly 3 digits.");

        return false;
    }
}
    return true;
}

</script>
</body>
</html>