package com.sani;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DeleteProfileServlet")
public class DeleteProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Integer userId =
                (Integer) session.getAttribute("userId");

        if(userId == null){
            response.sendRedirect("login.jsp");
            return;
        }

        try(Connection con = DBConnection.getConnection()){

            // delete related records first
            PreparedStatement ps1 =
                    con.prepareStatement(
                    "DELETE FROM refund_requests WHERE user_id=?");
            ps1.setInt(1, userId);
            ps1.executeUpdate();

            PreparedStatement ps2 =
                    con.prepareStatement(
                    "DELETE FROM payments WHERE user_id=?");
            ps2.setInt(1, userId);
            ps2.executeUpdate();

            PreparedStatement ps3 =
                    con.prepareStatement(
                    "DELETE FROM booked_seats WHERE user_id=?");
            ps3.setInt(1, userId);
            ps3.executeUpdate();

            // delete user account
            PreparedStatement ps4 =
                    con.prepareStatement(
                    "DELETE FROM users WHERE id=?");
            ps4.setInt(1, userId);

            int result = ps4.executeUpdate();

            if(result > 0){

                session.invalidate();

                response.sendRedirect(
                        "login.jsp?msg=deleted");

            }else{

                response.sendRedirect(
                        "edit_profile.jsp?msg=error");
            }

        }catch(Exception e){

            e.printStackTrace();

            response.sendRedirect(
                    "edit_profile.jsp?msg=exception");
        }
    }
}