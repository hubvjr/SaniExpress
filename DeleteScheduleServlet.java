package com.sani;

import com.sani.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DeleteScheduleServlet")
public class DeleteScheduleServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        String id = request.getParameter("id");

        try(Connection con = DBConnection.getConnection();
            PreparedStatement ps =
            con.prepareStatement(
            "DELETE FROM bus_schedules WHERE id=?")) {

            ps.setInt(1,Integer.parseInt(id));
            ps.executeUpdate();

        } catch(Exception e){
            e.printStackTrace();
        }

        response.sendRedirect("admin_schedule.jsp");
    }
}