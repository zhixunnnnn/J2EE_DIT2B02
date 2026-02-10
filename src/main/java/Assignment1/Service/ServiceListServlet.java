package Assignment1.Service;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.Invocation;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.GenericType;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.io.IOException;
import java.util.ArrayList;

import Assignment1.Category;

@WebServlet("/serviceServlet")
public class ServiceListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String SERVICE_API = "http://localhost:8081/api/services";
    private static final String CATEGORY_API = "http://localhost:8081/api/categories";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Client client = ClientBuilder.newClient();

        try {
            // Fetch services
            WebTarget serviceTarget = client.target(SERVICE_API);
            Invocation.Builder serviceBuilder = serviceTarget.request(MediaType.APPLICATION_JSON);
            Response serviceResp = serviceBuilder.get();

            ArrayList<Service> serviceList = new ArrayList<Service>();
            if (serviceResp.getStatus() == Response.Status.OK.getStatusCode()) {
                serviceList = serviceResp.readEntity(new GenericType<ArrayList<Service>>() {});
			}

            // Fetch categories
            WebTarget categoryTarget = client.target(CATEGORY_API);
            Invocation.Builder categoryBuilder = categoryTarget.request(MediaType.APPLICATION_JSON);
            Response categoryResp = categoryBuilder.get();

            ArrayList<Category> categoryList = new ArrayList<>();
            if (categoryResp.getStatus() == Response.Status.OK.getStatusCode()) {
                categoryList = categoryResp.readEntity(new GenericType<ArrayList<Category>>() {});
            }

            // Save in session
            session.setAttribute("serviceList", serviceList);
            session.setAttribute("categoryList", categoryList);
			System.out.println("Service and Category lists set in session.");

            // Forward to JSP
            request.getRequestDispatcher("/public/services.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errCode", "API_FETCH_ERROR");
            request.getRequestDispatcher("/public/services.jsp").forward(request, response);
        } finally {
            client.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
