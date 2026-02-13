package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;

import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;

/**
 * Admin servlet for listing all bookings via API.
 * Calls GET /admin/bookings — response wrapped in {success, message, data:[...] }
 * URL: /admin/bookings
 */
@WebServlet("/admin/bookings")
public class AdminBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String API_URL = "http://localhost:8081/api/admin/bookings";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Object role = session != null ? session.getAttribute("sessRole") : null;
        if (role == null || !"admin".equalsIgnoreCase(role.toString())) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
            return;
        }

        ArrayList<HashMap<String, Object>> bookings = new ArrayList<>();

        try {
            Client client = ClientBuilder.newClient();
            WebTarget target = client.target(API_URL);
            Response apiResp = target.request(MediaType.APPLICATION_JSON).get();

            if (apiResp.getStatus() == 200) {
                String json = apiResp.readEntity(String.class);
                JsonReader reader = Json.createReader(new StringReader(json));
                JsonObject root = reader.readObject();
                reader.close();

                if (root.getBoolean("success", false) && !root.isNull("data")) {
                    JsonArray dataArr = root.getJsonArray("data");

                    // Group rows by bookingId (API returns one row per service item)
                    LinkedHashMap<String, HashMap<String, Object>> grouped = new LinkedHashMap<>();

                    for (int i = 0; i < dataArr.size(); i++) {
                        JsonObject b = dataArr.getJsonObject(i);
                        String bookingId = String.valueOf(b.getInt("bookingId", 0));

                        HashMap<String, Object> map = grouped.get(bookingId);
                        if (map == null) {
                            map = new HashMap<>();
                            map.put("bookingId", bookingId);
                            map.put("customerName", b.getString("customerName", ""));
                            map.put("customerEmail", b.getString("customerEmail", ""));
                            map.put("status", b.getString("status", ""));
                            map.put("notes", b.getString("notes", ""));

                            String scheduledAt = b.getString("scheduledAt", "");
                            if (scheduledAt != null && !scheduledAt.isEmpty()) {
                                scheduledAt = scheduledAt.replace("T", " ").substring(0, Math.min(16, scheduledAt.length()));
                            }
                            map.put("bookingDate", scheduledAt);

                            map.put("items", new ArrayList<HashMap<String, String>>());
                            map.put("totalAmount", 0.0);
                            grouped.put(bookingId, map);
                        }

                        // Add this service item
                        String serviceName = b.getString("serviceName", "");
                        if (serviceName != null && !serviceName.isEmpty()) {
                            HashMap<String, String> item = new HashMap<>();
                            item.put("serviceName", serviceName);
                            item.put("quantity", String.valueOf(b.getInt("quantity", 1)));
                            double unitPrice = b.getJsonNumber("unitPrice") != null ? b.getJsonNumber("unitPrice").doubleValue() : 0.0;
                            item.put("unitPrice", String.format("%.2f", unitPrice));
                            double lineTotal = unitPrice * b.getInt("quantity", 1);
                            item.put("lineTotal", String.format("%.2f", lineTotal));

                            @SuppressWarnings("unchecked")
                            ArrayList<HashMap<String, String>> items = (ArrayList<HashMap<String, String>>) map.get("items");
                            items.add(item);

                            double total = (Double) map.get("totalAmount");
                            map.put("totalAmount", total + lineTotal);
                        }
                    }

                    bookings.addAll(grouped.values());
                }
            }
            client.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Pass bookings list to JSP
        request.setAttribute("bookings", bookings);
        request.getRequestDispatcher("/admin/admin_booking.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
