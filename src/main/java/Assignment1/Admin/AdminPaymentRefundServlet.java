package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.Entity;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.io.IOException;
import java.io.StringReader;
import java.util.HashMap;
import java.util.Map;

import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;

/**
 * Admin servlet for refunding payments via backend API.
 * URL: /admin/payments/refund
 */
@WebServlet("/admin/payments/refund")
public class AdminPaymentRefundServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String BACKEND_API = "http://localhost:8081/api";

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		Object role = session != null ? session.getAttribute("sessRole") : null;
		if (role == null || !"admin".equalsIgnoreCase(role.toString())) {
			response.setStatus(403);
			response.setContentType("application/json");
			response.getWriter().print("{\"success\":false,\"message\":\"Unauthorized\"}");
			return;
		}

		String paymentIntentId = request.getParameter("paymentIntentId");
		String amountStr = request.getParameter("amount");
		String reason = request.getParameter("reason");

		if (paymentIntentId == null || paymentIntentId.isBlank()) {
			session.setAttribute("flashError", "Missing payment intent ID.");
			response.sendRedirect(request.getContextPath() + "/admin/payments/list");
			return;
		}

		Client client = ClientBuilder.newClient();
		try {
			Map<String, Object> refundData = new HashMap<>();
			refundData.put("paymentIntentId", paymentIntentId);
			if (amountStr != null && !amountStr.isBlank()) {
				try { refundData.put("amount", Long.parseLong(amountStr.trim())); } catch (Exception e) {}
			}
			if (reason != null && !reason.isBlank()) {
				refundData.put("reason", reason.trim());
			}

			Response apiResp = client.target(BACKEND_API + "/payments/refund")
					.request(MediaType.APPLICATION_JSON)
					.post(Entity.json(refundData));

			String respBody = apiResp.readEntity(String.class);
			System.out.println("[AdminRefund] API status: " + apiResp.getStatus()
					+ ", response: " + respBody);

			if (apiResp.getStatus() == 200) {
				session.setAttribute("flashSuccess", "Refund processed successfully.");
			} else {
				String msg = "Refund failed.";
				try {
					JsonReader reader = Json.createReader(new StringReader(respBody));
					JsonObject obj = reader.readObject();
					reader.close();
					if (obj.containsKey("message") && !obj.isNull("message")) {
						msg = obj.getString("message");
					} else if (obj.containsKey("error") && !obj.isNull("error")) {
						msg = obj.getString("error");
					}
				} catch (Exception ignore) {}
				session.setAttribute("flashError", msg);
			}

		} catch (Exception e) {
			e.printStackTrace();
			session.setAttribute("flashError", "Error processing refund: " + e.getMessage());
		} finally {
			client.close();
		}

		response.sendRedirect(request.getContextPath() + "/admin/payments/list");
	}
}
