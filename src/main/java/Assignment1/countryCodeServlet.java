package Assignment1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

@WebServlet("/countryCodeServlet")
public class countryCodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String errText = "";
        String errCode = request.getParameter("errCode");
        String origin = request.getParameter("origin");
        if (errCode != null) {
            errText = errCode;
        }

        HttpSession session = request.getSession(true); // create session if not exists

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM country_code");
             ResultSet rs = pstmt.executeQuery()) {

            ArrayList<Country> countryList = new ArrayList<>();

            while (rs.next()) {
                Country c = new Country(
                        rs.getInt("id"),
                        rs.getInt("country_code"), // changed to int
                        rs.getString("country_name"),
                        rs.getString("iso2"),
                        rs.getString("flag_image")
                );
                countryList.add(c);
            }

            session.setAttribute("countryList", countryList);

            // safe redirect: fallback if origin is null
            String redirectPath = (origin != null && !origin.isBlank()) ? origin : "index.jsp";
            response.sendRedirect(request.getContextPath() + "/" + redirectPath + "?errCode=" + errText);

        } catch (Exception e) {
            e.printStackTrace();
            String redirectPath = (origin != null && !origin.isBlank()) ? origin : "index.jsp";
            response.sendRedirect(request.getContextPath() + "/" + redirectPath + "?errCode=DBError");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
