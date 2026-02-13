package Assignment1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/cart/update")
public class CartUpdateServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@SuppressWarnings("unchecked")
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null) {
			response.sendRedirect(request.getContextPath() + "/cart");
			return;
		}

		List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
		if (cart == null) {
			response.sendRedirect(request.getContextPath() + "/cart");
			return;
		}

		try {
			String serviceIdParam = request.getParameter("service_id");
			if (serviceIdParam == null || serviceIdParam.isEmpty()) {
				response.sendRedirect(request.getContextPath() + "/cart");
				return;
			}
			int serviceId = Integer.parseInt(serviceIdParam);
			String action = request.getParameter("action");
			String qtyParam = request.getParameter("quantity");
			int quantity = 0;
			if (qtyParam != null && !qtyParam.trim().isEmpty()) {
				try {
					quantity = Integer.parseInt(qtyParam.trim());
					quantity = Math.max(0, Math.min(99, quantity)); // clamp 0-99
				} catch (NumberFormatException e) {
					quantity = 0;
				}
			}

			if ("remove".equalsIgnoreCase(action) || quantity <= 0) {
				cart.removeIf(item -> item.getServiceId() == serviceId);
			} else {
				boolean found = false;
				for (CartItem item : cart) {
					if (item.getServiceId() == serviceId) {
						item.setQuantity(quantity);
						found = true;
						break;
					}
				}
				if (!found) {
					// Item was removed elsewhere, ignore
				}
			}

			response.sendRedirect(request.getContextPath() + "/cart");
		} catch (NumberFormatException e) {
			response.sendRedirect(request.getContextPath() + "/cart");
		}
	}
}