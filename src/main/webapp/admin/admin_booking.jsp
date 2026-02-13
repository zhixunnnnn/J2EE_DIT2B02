<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Bookings – SilverCare</title>

    <%
        Object userRole = session.getAttribute("sessRole");
        if (userRole == null) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
            return;
        }
        String userRoleString = userRole.toString();
        if (!"admin".equals(userRoleString)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
    %>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant:ital,wght@0,400;0,500;0,600;1,400&family=Outfit:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
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

    .loader {
        position: fixed; inset: 0; background: #f5f3ef;
        display: flex; align-items: center; justify-content: center;
        z-index: 9999; transition: opacity 0.5s ease, visibility 0.5s ease;
    }
    .loader.hidden { opacity: 0; visibility: hidden; }
    .loader-bar {
        width: 120px; height: 2px; background: #e8e4dc; overflow: hidden;
    }
    .loader-bar::after {
        content: ''; display: block; width: 40%; height: 100%;
        background: #2c2c2c; animation: loadingBar 1s ease-in-out infinite;
    }
    @keyframes loadingBar {
        0% { transform: translateX(-100%); }
        100% { transform: translateX(350%); }
    }

    .page-content { opacity: 0; transition: opacity 0.6s ease; }
    .page-content.visible { opacity: 1; }

    .data-table {
        width: 100%;
        border-collapse: collapse;
    }
    .data-table th {
        background-color: #e8e4dc;
        padding: 12px;
        text-align: left;
        font-weight: 500;
        border-bottom: 2px solid #2c2c2c;
        font-size: 0.875rem;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    .data-table td {
        padding: 16px 12px;
        border-bottom: 1px solid #e8e4dc;
    }
    .data-table tbody tr {
        transition: background-color 0.15s ease;
    }
    .data-table tbody tr:hover {
        background-color: #f5f3ef;
    }

    .status-badge {
        display: inline-block;
        padding: 4px 12px;
        font-size: 0.75rem;
        border-radius: 2px;
        font-weight: 500;
    }
    .status-confirmed { background: #d4f4dd; color: #1e7e34; }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-completed { background: #d1ecf1; color: #0c5460; }
    .status-cancelled { background: #f8d7da; color: #721c24; }

    .items-list { list-style: none; margin: 0; padding: 0; }
    .items-list li {
        display: flex; align-items: baseline; justify-content: space-between;
        padding: 4px 0; border-bottom: 1px dashed #e8e4dc;
    }
    .items-list li:last-child { border-bottom: none; }
    .item-name { flex: 1; }
    .item-qty { width: 40px; text-align: center; color: #8a8a8a; font-size: 0.75rem; }
    .item-price { width: 80px; text-align: right; font-variant-numeric: tabular-nums; }

    .booking-row { cursor: pointer; }
    .booking-row .expand-icon { transition: transform 0.2s ease; display: inline-block; }
    .booking-row.expanded .expand-icon { transform: rotate(90deg); }
    .detail-row { display: none; }
    .detail-row.show { display: table-row; }
    </style>
</head>

<body class="bg-stone-warm text-ink font-sans font-light min-h-screen">
    <!-- Loading Screen -->
    <div class="loader" id="loader">
        <div class="text-center">
            <p class="font-serif text-2xl text-ink mb-6">SilverCare</p>
            <div class="loader-bar"></div>
        </div>
    </div>

    <div class="page-content" id="pageContent">
    <%@ include file="../includes/header.jsp" %>

    <main class="pt-24 pb-20 px-5 md:px-12">
        <div class="max-w-7xl mx-auto">

            <!-- Page Header -->
            <header class="mb-12">
                <span class="text-copper text-xs uppercase tracking-[0.2em]">Administration</span>
                <h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-3 mb-4">
                    Booking Management
                </h1>
                <p class="text-ink-light text-base md:text-lg max-w-2xl">
                    View and manage all customer care service bookings and appointments.
                </p>
            </header>

            <!-- Stats Cards -->
            <div class="grid grid-cols-2 md:grid-cols-5 gap-4 mb-8">
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Total Bookings</p>
                    <p class="font-serif text-3xl font-medium text-ink">
                        <c:choose>
                            <c:when test="${not empty bookings}">${bookings.size()}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Total Items</p>
                    <p class="font-serif text-3xl font-medium text-ink">
                        <c:set var="totalItems" value="0"/>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${not empty b.items}">
                                <c:set var="totalItems" value="${totalItems + b.items.size()}"/>
                            </c:if>
                        </c:forEach>
                        ${totalItems}
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Confirmed</p>
                    <p class="font-serif text-3xl font-medium text-green-700">
                        <c:set var="confirmed" value="0"/>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${b.status == 'confirmed'}">
                                <c:set var="confirmed" value="${confirmed + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${confirmed}
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Pending</p>
                    <p class="font-serif text-3xl font-medium text-yellow-700">
                        <c:set var="pending" value="0"/>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${b.status == 'pending'}">
                                <c:set var="pending" value="${pending + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${pending}
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Completed</p>
                    <p class="font-serif text-3xl font-medium text-blue-700">
                        <c:set var="completed" value="0"/>
                        <c:forEach var="b" items="${bookings}">
                            <c:if test="${b.status == 'completed'}">
                                <c:set var="completed" value="${completed + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${completed}
                    </p>
                </div>
            </div>

            <!-- Bookings Table -->
            <section class="bg-white border border-stone-mid">
                <div class="px-6 py-5 border-b border-stone-mid">
                    <h2 class="font-serif text-xl font-medium text-ink">All Bookings</h2>
                </div>

                <div class="overflow-x-auto">
                    <table class="data-table" id="bookingsTable">
                        <thead>
                            <tr>
                                <th style="width:40px;"></th>
                                <th>Booking ID</th>
                                <th>Customer</th>
                                <th>Services</th>
                                <th>Scheduled Date</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="b" items="${bookings}" varStatus="loop">
                                <tr class="booking-row" onclick="toggleDetail(${loop.index})" id="row-${loop.index}">
                                    <td>
                                        <span class="expand-icon text-ink-muted">&#9654;</span>
                                    </td>
                                    <td>
                                        <span class="font-medium text-sm">#${b.bookingId}</span>
                                    </td>
                                    <td>
                                        <div>
                                            <span class="text-ink font-medium">${b.customerName}</span>
                                            <p class="text-ink-muted text-xs mt-0.5">${b.customerEmail}</p>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty b.items}">
                                                <c:choose>
                                                    <c:when test="${b.items.size() == 1}">
                                                        <span class="text-ink text-sm">${b.items.get(0).serviceName}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-ink text-sm">${b.items.get(0).serviceName}</span>
                                                        <span class="text-ink-muted text-xs ml-1">+${b.items.size() - 1} more</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-ink-muted text-sm">No services</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="text-ink-light text-sm">${b.bookingDate}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink font-medium text-sm">
                                            $<c:out value="${String.format('%.2f', b.totalAmount)}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${b.status == 'confirmed'}">
                                                <span class="status-badge status-confirmed">Confirmed</span>
                                            </c:when>
                                            <c:when test="${b.status == 'pending'}">
                                                <span class="status-badge status-pending">Pending</span>
                                            </c:when>
                                            <c:when test="${b.status == 'completed'}">
                                                <span class="status-badge status-completed">Completed</span>
                                            </c:when>
                                            <c:when test="${b.status == 'cancelled'}">
                                                <span class="status-badge status-cancelled">Cancelled</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge" style="background: #e8e4dc; color: #2c2c2c;">${b.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-right" onclick="event.stopPropagation()">
                                        <form method="post" action="${pageContext.request.contextPath}/admin/bookings/delete" class="inline"
                                              onsubmit="return confirm('Delete booking #${b.bookingId} and all its items?');">
                                            <input type="hidden" name="bookingId" value="${b.bookingId}">
                                            <button type="submit" class="text-xs px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-red-600 hover:border-red-200 hover:bg-red-50 transition-colors">
                                                Delete
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                <!-- Expandable cart detail row -->
                                <tr class="detail-row" id="detail-${loop.index}">
                                    <td colspan="8" style="padding: 0;">
                                        <div class="bg-stone-warm px-6 py-4 border-l-2 border-copper ml-4">
                                            <p class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-3">Cart Items (Booking #${b.bookingId})</p>
                                            <c:choose>
                                                <c:when test="${not empty b.items}">
                                                    <table class="w-full text-sm">
                                                        <thead>
                                                            <tr class="text-xs uppercase tracking-wide text-ink-muted">
                                                                <th class="text-left pb-2 font-medium">Service</th>
                                                                <th class="text-center pb-2 font-medium" style="width:60px;">Qty</th>
                                                                <th class="text-right pb-2 font-medium" style="width:100px;">Unit Price</th>
                                                                <th class="text-right pb-2 font-medium" style="width:100px;">Subtotal</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <c:forEach var="item" items="${b.items}">
                                                                <tr class="border-b border-stone-mid">
                                                                    <td class="py-2 text-ink">${item.serviceName}</td>
                                                                    <td class="py-2 text-center text-ink-light">&times;${item.quantity}</td>
                                                                    <td class="py-2 text-right text-ink-light">$${item.unitPrice}</td>
                                                                    <td class="py-2 text-right text-ink font-medium">$${item.lineTotal}</td>
                                                                </tr>
                                                            </c:forEach>
                                                        </tbody>
                                                        <tfoot>
                                                            <tr>
                                                                <td colspan="3" class="pt-3 text-right text-xs uppercase tracking-wide text-ink-muted font-medium">Total</td>
                                                                <td class="pt-3 text-right text-ink font-medium">
                                                                    $<c:out value="${String.format('%.2f', b.totalAmount)}"/>
                                                                </td>
                                                            </tr>
                                                        </tfoot>
                                                    </table>
                                                </c:when>
                                                <c:otherwise>
                                                    <p class="text-ink-muted text-sm">No service items in this booking</p>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty b.notes}">
                                                <div class="mt-3 pt-3 border-t border-stone-mid">
                                                    <p class="text-xs text-ink-muted uppercase tracking-wide mb-1">Notes</p>
                                                    <p class="text-sm text-ink-light">${b.notes}</p>
                                                </div>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty bookings}">
                                <tr>
                                    <td colspan="8" class="text-center py-12">
                                        <svg class="w-10 h-10 text-stone-deep mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                                        </svg>
                                        <p class="text-sm text-ink-muted">No bookings found</p>
                                        <p class="text-xs text-ink-muted mt-1">Bookings will appear here when customers make appointments</p>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </section>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <script>
    window.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 500);
    });

    function toggleDetail(idx) {
        const row = document.getElementById('row-' + idx);
        const detail = document.getElementById('detail-' + idx);
        if (detail.classList.contains('show')) {
            detail.classList.remove('show');
            row.classList.remove('expanded');
        } else {
            detail.classList.add('show');
            row.classList.add('expanded');
        }
    }
    </script>
</body>
</html>
