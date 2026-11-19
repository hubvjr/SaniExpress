package com.sani;

import java.io.*;
import java.net.*;
import java.sql.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ToyyibPayServlet")
public class ToyyibPayServlet extends HttpServlet {

    private static final String USER_SECRET_KEY =
            "3lu8k1g8-4aa9-svq1-7rfi-h35x7pwqcfkf";

    private static final String CATEGORY_CODE =
            "j9rmbhop";

       @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        doPost(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session =
                request.getSession();

        Integer userId =
                (Integer) session.getAttribute("userId");

        String username =
                (String) session.getAttribute("username");

        String amount =
                (String) session.getAttribute("totalAmount");

        String scheduleId =
                (String) session.getAttribute("schedule_id");

        String transactionId =
                (String) session.getAttribute(
                        "bookingTransactionId");

        try {

            String returnUrl =
                    "http://localhost:8080/SANI_SCHEDULING/ToyyibReturnServlet";

            String callbackUrl =
                    returnUrl;

            String postData =
                    "userSecretKey="
                    + URLEncoder.encode(USER_SECRET_KEY,"UTF-8")

                    + "&categoryCode="
                    + CATEGORY_CODE

                    + "&billName="
                    + URLEncoder.encode(
                            "SANI BUS TICKET",
                            "UTF-8")

                    + "&billDescription="
                    + URLEncoder.encode(
                            "Bus Ticket Booking",
                            "UTF-8")

                    + "&billPriceSetting=1"

                    + "&billPayorInfo=1"

                    + "&billAmount="
                    + (int)(Double.parseDouble(amount) * 100)

                    + "&billReturnUrl="
                    + URLEncoder.encode(
                            returnUrl,
                            "UTF-8")

                    + "&billCallbackUrl="
                    + URLEncoder.encode(
                            callbackUrl,
                            "UTF-8")

                    + "&billExternalReferenceNo="
                    + transactionId

                    + "&billTo="
                    + URLEncoder.encode(
                            username,
                            "UTF-8")

                    + "&billEmail="
                    + "test@sani.com"

                    + "&billPhone="
                    + "0179017235";

            URL url =
                    new URL(
"https://dev.toyyibpay.com/index.php/api/createBill");

            HttpURLConnection conn =
                    (HttpURLConnection)
                            url.openConnection();

            conn.setDoOutput(true);

            conn.setRequestMethod("POST");

            try(OutputStream os =
                    conn.getOutputStream()) {

                os.write(
                        postData.getBytes("UTF-8"));
            }

            BufferedReader br =
                    new BufferedReader(
                            new InputStreamReader(
                                    conn.getInputStream()));

            String result =
                    br.readLine();

            String billCode =
                    result.replace(
                            "[{\"BillCode\":\"",
                            "")
                            .replace("\"}]",
                                    "");

          

            response.sendRedirect(
                    "https://dev.toyyibpay.com/"
                    + billCode);

        } catch(Exception e){

            e.printStackTrace();

            response.sendRedirect(
                    "paymentSelection.jsp?error=toyyib");
        }
    }
}