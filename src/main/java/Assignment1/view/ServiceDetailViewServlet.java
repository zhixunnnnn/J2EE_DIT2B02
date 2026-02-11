package Assignment1.view;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/service/*")
public class ServiceDetailViewServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Extract service ID from path: /service/123 -> 123
		String pathInfo = request.getPathInfo();
		if (pathInfo != null && pathInfo.length() > 1) {
			String serviceId = pathInfo.substring(1);
			request.setAttribute("serviceId", serviceId);
		}
		request.getRequestDispatcher("/public/service_details.jsp").forward(request, response);
	}
}
