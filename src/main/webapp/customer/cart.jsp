<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.*,Assignment1.CartItem" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Cart | SilverCare</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
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
                    }
                }
            }
        }
    </script>
    <style>
        html { scroll-behavior: smooth; }
        body { -webkit-font-smoothing: antialiased; }
    </style>
    <%
        Object userRole = session.getAttribute("sessRole");
        if (userRole == null) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
            return;
        }
        String errCode = request.getParameter("errCode");
        String errMsg = null;
        if (errCode != null) {
            if ("DateNull".equals(errCode)) errMsg = "Please select a service date.";
            else if ("DatePast".equals(errCode)) errMsg = "Service date cannot be in the past.";
            else if ("DateInvalid".equals(errCode)) errMsg = "Invalid date format.";
            else if ("InvalidAmount".equals(errCode)) errMsg = "Cart total is invalid. Please review your cart.";
            else if ("EmptyCart".equals(errCode)) errMsg = "Your cart is empty. Add services to proceed.";
            else if ("NoCheckoutData".equals(errCode)) errMsg = "Please complete the booking details in your cart first.";
        }
    %>
</head>

<body class="bg-stone-warm text-ink font-sans font-light min-h-screen">
    <%@ include file="../includes/header.jsp" %>

    <%
        HttpSession sessionObj = request.getSession(false);
        List<CartItem> cart = null;
        if (sessionObj != null) {
            cart = (List<CartItem>) sessionObj.getAttribute("cart");
        }
        boolean isEmpty = (cart == null || cart.isEmpty());
        double totalAmount = 0.0;
        if (!isEmpty) {
            for (CartItem item : cart) {
                totalAmount += item.getLineTotal();
            }
        }
    %>

    <main class="pt-24 max-w-6xl mx-auto px-5 md:px-12 py-12 md:py-16">
        <div class="mb-10">
            <span class="text-copper text-xs uppercase tracking-[0.2em]">Your Selection</span>
            <h1 class="font-serif text-3xl md:text-4xl font-medium text-ink mt-2">Care Cart</h1>
            <p class="mt-3 text-ink-light text-base max-w-xl">
                Review the services you've selected. Adjust quantities or proceed to confirm your booking.
            </p>
            <% if (errMsg != null) { %>
            <div class="mt-4 p-4 border border-red-200 bg-red-50 text-red-700 text-sm">
                <%= errMsg %>
            </div>
            <% } %>
        </div>

        <div class="bg-white border border-stone-mid p-5 md:p-8">
            <% if (isEmpty) { %>
                <div class="flex flex-col items-center justify-center py-16">
                    <div class="w-16 h-16 bg-stone-mid flex items-center justify-center mb-5">
                        <span class="text-2xl">🧺</span>
                    </div>
                    <h2 class="font-serif text-xl md:text-2xl font-medium text-ink mb-3">Your cart is empty</h2>
                    <p class="text-ink-light text-sm md:text-base mb-8 text-center max-w-sm">
                        Browse our care services and add them to your cart to start a booking.
                    </p>
                    <a href="<%=request.getContextPath()%>/services" 
                       class="inline-flex items-center gap-2 bg-ink text-stone-warm px-6 py-3 text-sm font-normal hover:bg-ink-light transition-colors">
                        Browse Services
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                        </svg>
                    </a>
                </div>
            <% } else { %>

                <!-- Cart table -->
                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm">
                        <thead>
                            <tr class="border-b border-stone-mid text-left text-xs uppercase tracking-[0.15em] text-ink-muted">
                                <th class="py-3 pr-3 font-normal">Service</th>
                                <th class="py-3 px-3 font-normal">Category</th>
                                <th class="py-3 px-3 text-right font-normal">Unit Price</th>
                                <th class="py-3 px-3 text-center font-normal">Quantity</th>
                                <th class="py-3 px-3 text-right font-normal">Line Total</th>
                                <th class="py-3 pl-3 text-center font-normal">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-stone-mid">
                            <% for (CartItem item : cart) { %>
                                <tr class="hover:bg-stone-warm/50 cart-row" data-unit-price="<%= item.getUnitPrice() %>" data-service-id="<%= item.getServiceId() %>">
                                    <td class="py-4 pr-3 align-middle">
                                        <div class="font-medium text-ink"><%= item.getServiceName() %></div>
                                        <div class="text-xs text-ink-muted mt-0.5">ID: <%= item.getServiceId() %></div>
                                    </td>
                                    <td class="py-4 px-3 align-middle text-ink-light"><%= item.getCategoryName() %></td>
                                    <td class="py-4 px-3 align-middle text-right text-ink-light unit-price-cell">
                                        $<%= String.format("%.2f", item.getUnitPrice()) %>
                                    </td>
                                    <td class="py-4 px-3 align-middle text-center">
                                        <form action="<%=request.getContextPath()%>/cart/update" method="post" class="cart-update-form inline-flex items-center gap-2 justify-center">
                                            <input type="hidden" name="service_id" value="<%= item.getServiceId() %>">
                                            <input type="hidden" name="action" value="update">
                                            <input type="number" name="quantity" min="1" max="99" value="<%= item.getQuantity() %>"
                                                   class="cart-qty-input w-16 border border-stone-mid px-3 py-1.5 text-sm text-center focus:outline-none focus:border-ink bg-white">
                                            <button type="submit"
                                                    class="text-xs px-3 py-1.5 border border-copper text-copper font-normal hover:bg-copper hover:text-white transition-colors">
                                                Update
                                            </button>
                                        </form>
                                    </td>
                                    <td class="py-4 px-3 align-middle text-right font-medium text-ink line-total-cell">
                                        $<%= String.format("%.2f", item.getLineTotal()) %>
                                    </td>
                                    <td class="py-4 pl-3 align-middle text-center">
                                        <form action="<%=request.getContextPath()%>/cart/update" method="post">
                                            <input type="hidden" name="service_id" value="<%= item.getServiceId() %>">
                                            <input type="hidden" name="quantity" value="0">
                                            <input type="hidden" name="action" value="remove">
                                            <button type="submit"
                                                    class="text-xs px-3 py-1.5 text-ink-muted hover:text-ink border border-stone-mid hover:border-ink transition-colors">
                                                Remove
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Summary + clear/browse buttons -->
                <div class="mt-8 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div class="flex items-center gap-3 text-sm">
                        <form action="<%=request.getContextPath()%>/cart/clear" method="post">
                            <button type="submit"
                                    class="inline-flex items-center px-4 py-2 border border-stone-mid text-ink-light text-xs font-normal hover:border-ink hover:text-ink transition-colors">
                                Clear Cart
                            </button>
                        </form>
                        <a href="<%=request.getContextPath()%>/services"
                           class="inline-flex items-center px-4 py-2 border border-stone-mid text-ink-light text-xs font-normal hover:border-ink hover:text-ink transition-colors">
                            Continue Browsing
                        </a>
                    </div>
                    <div class="text-right">
                        <div class="text-xs text-ink-muted uppercase tracking-[0.15em]">Total</div>
                        <div class="font-serif text-2xl md:text-3xl font-medium text-ink mt-1" id="cart-grand-total">
                            $<%= String.format("%.2f", totalAmount) %>
                        </div>
                    </div>
                </div>

                <!-- Checkout form -->
                <div class="mt-10 pt-8 border-t border-stone-mid">
                    <h2 class="font-serif text-xl md:text-2xl font-medium text-ink mb-2">Confirm Booking Details</h2>
                    <p class="text-sm text-ink-light mb-6 max-w-xl">
                        Choose when the services should start and leave any additional notes for our care team.
                    </p>

                    <form action="<%=request.getContextPath()%>/cart/checkout" method="post" class="space-y-5">
                        <div class="grid md:grid-cols-2 gap-5">
                            <div>
                                <label class="block text-sm text-ink mb-2">
                                    Service Date <span class="text-copper">*</span>
                                </label>
                                <input type="date" name="service_date" required
                                       class="w-full border border-stone-mid px-4 py-3 text-sm focus:outline-none focus:border-ink bg-white">
                            </div>
                            <div>
                                <label class="block text-sm text-ink mb-2">Preferred Time</label>
                                <input type="text" name="preferred_time" placeholder="e.g. Morning, 2–4 pm"
                                       class="w-full border border-stone-mid px-4 py-3 text-sm focus:outline-none focus:border-ink bg-white">
                            </div>
                        </div>

                        <div>
                            <label class="block text-sm text-ink mb-2">Notes for our team</label>
                            <textarea name="notes" rows="3"
                                      placeholder="Share any medical conditions, mobility concerns, or special preferences."
                                      class="w-full border border-stone-mid px-4 py-3 text-sm focus:outline-none focus:border-ink bg-white resize-y"></textarea>
                        </div>

                        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 pt-2">
                            <p class="text-xs text-ink-muted max-w-md">
                                By confirming, you agree that SilverCare will review your booking and contact you if any clarification is needed.
                            </p>
                            <button type="submit"
                                    class="inline-flex items-center justify-center gap-2 px-8 py-3 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                                Confirm Booking
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                                </svg>
                            </button>
                        </div>
                    </form>
                </div>

            <% } %>
        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>

    <script>
    (function() {
        function formatMoney(n) {
            return '$' + parseFloat(n).toFixed(2);
        }
        function recalcCart() {
            var total = 0;
            document.querySelectorAll('.cart-row').forEach(function(row) {
                var unitPrice = parseFloat(row.getAttribute('data-unit-price')) || 0;
                var qtyInput = row.querySelector('.cart-qty-input');
                var qty = qtyInput ? (parseInt(qtyInput.value, 10) || 0) : 0;
                var lineTotal = unitPrice * Math.max(0, qty);
                total += lineTotal;
                var lineCell = row.querySelector('.line-total-cell');
                if (lineCell) lineCell.textContent = formatMoney(lineTotal);
            });
            var grandEl = document.getElementById('cart-grand-total');
            if (grandEl) grandEl.textContent = formatMoney(total);
        }
        document.querySelectorAll('.cart-qty-input').forEach(function(input) {
            input.addEventListener('input', recalcCart);
            input.addEventListener('change', recalcCart);
        });
    })();
    </script>
</body>
</html>
