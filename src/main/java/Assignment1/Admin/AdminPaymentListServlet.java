package Assignment1.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashMap;

import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;
import jakarta.json.JsonValue;

/**
 * Admin servlet for listing all payments via backend API.
 * URL: /admin/payments/list
 */
@WebServlet("/admin/payments/list")
public class AdminPaymentListServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String BACKEND_API = "http://localhost:8081/api";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		Object role = session != null ? session.getAttribute("sessRole") : null;
		if (role == null || !"admin".equalsIgnoreCase(role.toString())) {
			response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
			return;
		}

		ArrayList<HashMap<String, String>> payments = new ArrayList<>();
		HashMap<String, String> stats = new HashMap<>();

		Client client = ClientBuilder.newClient();

		try {
			Response apiResp = client.target(BACKEND_API + "/admin/payments")
					.request(MediaType.APPLICATION_JSON).get();

			String json = apiResp.readEntity(String.class);
			System.out.println("[AdminPayments] API status: " + apiResp.getStatus()
					+ ", length: " + (json != null ? json.length() : 0));

			if (apiResp.getStatus() == 200 && json != null && !json.isBlank()) {
				JsonReader reader = Json.createReader(new StringReader(json));
				JsonValue root = reader.read();
				reader.close();

				JsonArray dataArr = null;
				if (root.getValueType() == JsonValue.ValueType.ARRAY) {
					dataArr = root.asJsonArray();
				} else if (root.getValueType() == JsonValue.ValueType.OBJECT) {
					JsonObject obj = root.asJsonObject();
					if (obj.containsKey("data") && !obj.isNull("data")
							&& obj.get("data").getValueType() == JsonValue.ValueType.ARRAY) {
						dataArr = obj.getJsonArray("data");
					}
				}

				long totalAmountCents = 0;
				long totalRefundedCents = 0;
				int succeededCount = 0;
				int totalCount = 0;

				if (dataArr != null) {
					for (int i = 0; i < dataArr.size(); i++) {
						JsonObject p = dataArr.getJsonObject(i);
						HashMap<String, String> map = new HashMap<>();

						String piId = safeString(p, "paymentIntentId");
						String amountStr = safeString(p, "amount");
						long amount = 0;
						try { amount = Long.parseLong(amountStr); } catch (Exception e) {}
						String currency = safeString(p, "currency");
						String status = safeString(p, "status");
						String createdAt = safeString(p, "createdAt");
						String customerName = safeString(p, "customerName");
						String customerEmail = safeString(p, "customerEmail");
						String bookingId = safeString(p, "bookingId");
						String description = safeString(p, "description");
						String paymentId = safeString(p, "paymentId");

						// Sum refunds if present
						long refundedAmount = 0;
						if (p.containsKey("refunds") && !p.isNull("refunds")
								&& p.get("refunds").getValueType() == JsonValue.ValueType.ARRAY) {
							JsonArray refunds = p.getJsonArray("refunds");
							for (int j = 0; j < refunds.size(); j++) {
								JsonObject r = refunds.getJsonObject(j);
								if (r.containsKey("amount") && !r.isNull("amount")) {
									refundedAmount += r.getJsonNumber("amount").longValue();
								}
							}
						}
						if (refundedAmount == 0 && p.containsKey("amountRefunded") && !p.isNull("amountRefunded")) {
							try { refundedAmount = p.getJsonNumber("amountRefunded").longValue(); } catch (Exception e) {}
						}

						map.put("paymentId", paymentId);
						map.put("paymentIntentId", piId);
						map.put("amount", String.valueOf(amount));
						map.put("currency", currency.toUpperCase());
						map.put("status", status);
						map.put("customerName", customerName);
						map.put("customerEmail", customerEmail);
						map.put("bookingId", bookingId);
						map.put("createdAt", createdAt);
						map.put("description", description);
						map.put("refundedAmount", String.valueOf(refundedAmount));
						payments.add(map);
						totalCount++;

						if ("succeeded".equalsIgnoreCase(status)) {
							succeededCount++;
							totalAmountCents += amount;
						}
						totalRefundedCents += refundedAmount;
					}
				}

				stats.put("totalPayments", String.valueOf(totalCount));
				stats.put("succeededCount", String.valueOf(succeededCount));
				stats.put("totalAmount", String.valueOf(totalAmountCents));
				stats.put("totalRefunded", String.valueOf(totalRefundedCents));
				long avg = succeededCount > 0 ? totalAmountCents / succeededCount : 0;
				stats.put("averagePaymentAmount", String.valueOf(avg));
				stats.put("count", String.valueOf(payments.size()));

				System.out.println("[AdminPayments] Loaded " + payments.size()
						+ " payments, " + succeededCount + " succeeded");
			}

		} catch (Exception e) {
			System.out.println("[AdminPayments] ERROR: " + e.getMessage());
			e.printStackTrace();
		} finally {
			client.close();
		}

		request.setAttribute("payments", payments);
		request.setAttribute("paymentStats", stats);
		request.getRequestDispatcher("/admin/admin_payments.jsp").forward(request, response);
	}

	private String safeString(JsonObject obj, String key) {
		if (!obj.containsKey(key) || obj.isNull(key)) return "";
		JsonValue val = obj.get(key);
		switch (val.getValueType()) {
			case STRING: return obj.getString(key);
			case NUMBER: return String.valueOf(obj.getJsonNumber(key));
			case TRUE: return "true";
			case FALSE: return "false";
			default: return val.toString();
		}
	}
}
