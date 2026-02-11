<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="Assignment1.Service.Service, Assignment1.Feedback, java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Service Detail | SilverCare</title>

    <%
        Service s = (Service) request.getAttribute("service");
        if (s == null) {
            response.sendRedirect(request.getContextPath() + "/services?errCode=ServiceNotFound");
            return;
        }

        ArrayList<Feedback> feedbackList = (ArrayList<Feedback>) request.getAttribute("feedbackList");
        String userRole = session.getAttribute("sessRole") != null ? session.getAttribute("sessRole").toString() : "";
        String errCode = request.getParameter("errCode");
    %>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant:ital,wght@0,400;0,500;0,600;1,400&family=Outfit:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        serif: ['Cormorant', 'Georgia', 'serif'],
                        sans: ['Outfit', 'system-ui', 'sans-serif'],
                    },
                    colors: {
                        stone: { warm: '#f5f3ef', mid: '#e8e4dc', deep: '#d4cec3' },
                        ink: { DEFAULT: '#2c2c2c', light: '#5a5a5a', muted: '#8a8a8a' },
                        copper: { DEFAULT: '#b87a4b', light: '#d4a574' },
                        forest: '#3d4f3d',
                    }
                }
            }
        }
    </script>
    <style>
        html { scroll-behavior: smooth; }
        body { -webkit-font-smoothing: antialiased; }
    </style>
</head>

<body class="bg-stone-warm text-ink font-sans font-light min-h-screen">
    <%@ include file="../includes/header.jsp" %>

    <main class="pt-24 max-w-5xl mx-auto px-5 md:px-12 py-12 md:py-16 space-y-12">

        <!-- BACK LINK -->
        <div>
            <a href="<%= request.getContextPath() %>/services"
               class="inline-flex items-center gap-1 text-sm text-ink-light hover:text-ink transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M7 16l-4-4m0 0l4-4m-4 4h18"/>
                </svg>
                Back to services
            </a>
        </div>

        <!-- SERVICE HERO CARD -->
        <section class="bg-white border border-stone-mid overflow-hidden">
            <div class="grid md:grid-cols-[1.1fr_1.3fr]">
                <!-- Image -->
                <div class="relative h-56 md:h-full overflow-hidden bg-stone-mid">
                    <img src="<%= request.getContextPath() %>/<%= s.getImagePath() %>"
                         alt="<%= s.getServiceName() %>"
                         class="w-full h-full object-cover" />
                    <div class="absolute inset-0 bg-gradient-to-t from-black/30 via-transparent to-transparent pointer-events-none"></div>
                    <div class="absolute bottom-4 left-4 flex flex-col gap-2 text-xs text-white">
                        <span class="inline-flex items-center gap-1.5 px-2 py-1 bg-black/30 backdrop-blur">
                            <span class="w-1.5 h-1.5 bg-copper"></span>
                            Available service
                        </span>
                        <span class="inline-flex items-center gap-1.5 px-2 py-1 bg-black/30 backdrop-blur">
                            Duration: <span class="font-medium"><%= s.getDurationMin() %> min</span>
                        </span>
                    </div>
                </div>

                <!-- Content -->
                <div class="px-6 py-6 md:px-8 md:py-8 flex flex-col gap-5">
                    <div class="space-y-3">
                        <span class="inline-block text-copper text-xs uppercase tracking-[0.2em]">SilverCare Service</span>
                        <h1 class="font-serif text-2xl md:text-3xl font-medium text-ink">
                            <%= s.getServiceName() %>
                        </h1>
                        <p class="text-sm text-ink-light leading-relaxed">
                            <%= s.getDescription() %>
                        </p>
                    </div>

                    <div class="grid grid-cols-2 md:grid-cols-3 gap-4 text-sm">
                        <div class="space-y-1">
                            <p class="text-xs uppercase tracking-[0.15em] text-ink-muted">Price</p>
                            <p class="font-serif text-xl font-medium text-ink">
                                $<%= s.getPrice() %> <span class="text-xs font-sans font-normal text-ink-muted">/ session</span>
                            </p>
                        </div>
                        <div class="space-y-1">
                            <p class="text-xs uppercase tracking-[0.15em] text-ink-muted">Duration</p>
                            <p class="text-sm font-medium text-ink"><%= s.getDurationMin() %> minutes</p>
                        </div>
                        <div class="space-y-1">
                            <p class="text-xs uppercase tracking-[0.15em] text-ink-muted">Service ID</p>
                            <p class="text-xs font-mono text-ink-light"><%= s.getServiceId() %></p>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="mt-2 flex flex-col sm:flex-row gap-3">
                        <!-- Add to cart - only serviceId needed, CartAddServlet fetches the rest from API -->
                        <form method="post" action="<%= request.getContextPath() %>/cart/add" class="flex-1">
                            <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>">
                            <button type="submit"
                                    class="w-full inline-flex items-center justify-center gap-2 px-5 py-3 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                                Add to cart
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4v16m8-8H4"/>
                                </svg>
                            </button>
                        </form>

                        <a href="<%= request.getContextPath() %>/services"
                           class="flex-1 inline-flex items-center justify-center px-5 py-3 border border-stone-mid text-sm text-ink-light hover:border-ink hover:text-ink transition-colors">
                            Back to services
                        </a>
                    </div>
                </div>
            </div>
        </section>

        <!-- FEEDBACK LIST -->
        <section class="space-y-5" id="feedback">
            <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-2">
                <div class="space-y-1">
                    <h2 class="font-serif text-xl md:text-2xl font-medium text-ink">Customer feedback</h2>
                    <p class="text-sm text-ink-light">
                        Read what families and caregivers have shared about this service.
                    </p>
                </div>

                <c:if test="${not empty feedbackList}">
                    <p class="text-xs text-ink-muted">${fn:length(feedbackList)} review(s)</p>
                </c:if>
            </div>

            <c:choose>
                <c:when test="${empty feedbackList}">
                    <div class="border border-dashed border-stone-deep bg-white px-5 py-6 text-sm text-ink-muted">
                        No feedback yet for this service. Be the first to share your experience.
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="space-y-4">
                        <c:forEach var="f" items="${feedbackList}">
                            <div class="bg-white border border-stone-mid px-5 py-5">
                                <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3">
                                    <div class="space-y-1">
                                        <p class="text-sm font-medium text-ink">${f.userName}</p>
                                        <p class="text-xs text-ink-muted">
                                            Rating: <span class="font-medium text-copper">${f.rating}</span>/5
                                        </p>
                                    </div>
                                    <p class="text-xs text-ink-muted">
                                        <fmt:formatDate value="${f.createdAtDate}" pattern="dd MMM yyyy, HH:mm" />
                                    </p>
                                </div>
                                <p class="mt-3 text-sm text-ink-light leading-relaxed">${f.comments}</p>

                                <c:if test="${userRole eq 'admin'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/feedback/delete"
                                          class="mt-4 flex justify-end">
                                        <input type="hidden" name="feedback_id" value="${f.feedbackId}" />
                                        <button type="submit"
                                                class="text-xs px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-ink hover:border-ink transition-colors">
                                            Delete feedback
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <!-- FEEDBACK FORM -->
        <section class="space-y-5" id="leave-feedback">
            <h2 class="font-serif text-xl md:text-2xl font-medium text-ink">Leave your feedback</h2>

            <!-- Error banners -->
            <c:if test="${param.errCode eq 'invalidRating'}">
                <div class="border border-copper bg-copper/5 px-4 py-3 text-sm text-copper">
                    Rating must be between 1 and 5.
                </div>
            </c:if>
            <c:if test="${param.errCode eq 'notLoggedIn'}">
                <div class="border border-ink bg-stone-mid px-4 py-3 text-sm text-ink">
                    You must be logged in to leave feedback.
                </div>
            </c:if>

            <div class="bg-white border border-stone-mid px-5 py-6 md:px-6 md:py-7">
                <form action="<%= request.getContextPath() %>/serviceDetailServlet" method="post" class="space-y-5">
                    <input type="hidden" name="serviceId" value="<%= s.getServiceId() %>" />

                    <div class="grid sm:grid-cols-2 gap-5">
                        <!-- Rating -->
                        <div class="space-y-2">
                            <label class="block text-sm text-ink">Rating</label>
                            <p class="text-xs text-ink-muted mb-1">
                                Choose a rating from 1 (very poor) to 5 (excellent).
                            </p>
                            <select name="rating" required
                                    class="w-full border border-stone-mid px-4 py-3 text-sm focus:outline-none focus:border-ink bg-white">
                                <option value="">-- Select rating --</option>
                                <option value="1">1 - Very poor</option>
                                <option value="2">2 - Poor</option>
                                <option value="3">3 - Average</option>
                                <option value="4">4 - Good</option>
                                <option value="5">5 - Excellent</option>
                            </select>
                        </div>

                        <!-- Comments -->
                        <div class="space-y-2">
                            <label class="block text-sm text-ink">Comments</label>
                            <textarea name="comments" rows="4" required
                                      placeholder="Share what went well, what could be improved..."
                                      class="w-full border border-stone-mid px-4 py-3 text-sm focus:outline-none focus:border-ink bg-white resize-none"></textarea>
                        </div>
                    </div>

                    <div class="pt-2 flex justify-end">
                        <button type="submit"
                                class="inline-flex items-center gap-2 px-6 py-3 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                            Submit feedback
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                            </svg>
                        </button>
                    </div>
                </form>
            </div>
        </section>

    </main>

    <%@ include file="../includes/footer.jsp" %>
</body>
</html>
