package Assignment1.view;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/profile", "/profile/edit", "/profile/delete"})
public class ProfileViewServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("sessRole") == null) {
			response.sendRedirect(request.getContextPath() + "/login");
			return;
		}

		String path = request.getServletPath();
		String jspPath;

		switch (path) {
			case "/profile/edit":
				jspPath = "/customer/edit_profile.jsp";
				break;
			case "/profile/delete":
				jspPath = "/customer/delete_profile.jsp";
				break;
			default:
				jspPath = "/customer/profile.jsp";
		}

		request.getRequestDispatcher(jspPath).forward(request, response);
	}
}
