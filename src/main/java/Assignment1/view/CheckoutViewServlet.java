package Assignment1.view;

import java.io.IOException;
import java.util.List;

import Assignment1.CartItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * View servlet for checkout/payment page
 * Route: /checkout
 */
@WebServlet("/checkout")
public class CheckoutViewServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	@SuppressWarnings("unchecked")
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		HttpSession session = request.getSession(false);
		
		// Require login
		if (session == null || session.getAttribute("sessRole") == null) {
			response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
			return;
		}
		
		// Check if checkout data exists in session
		List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
		
		if (cart == null || cart.isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/cart?errCode=NoCheckoutData");
			return;
		}
		
		// Always recalculate amount from current cart to avoid stale/mismatched totals
		double total = 0.0;
		for (CartItem item : cart) {
			total += item.getLineTotal();
		}
		session.setAttribute("checkoutAmount", Double.valueOf(total));
		
		// Set attributes for JSP
		request.setAttribute("customerEmail", session.getAttribute("checkoutEmail"));
		request.setAttribute("customerName", session.getAttribute("checkoutName"));
		request.setAttribute("checkoutAmount", session.getAttribute("checkoutAmount"));
		request.setAttribute("userId", session.getAttribute("sessId"));
		
		request.getRequestDispatcher("/checkout.jsp").forward(request, response);
	}
}
