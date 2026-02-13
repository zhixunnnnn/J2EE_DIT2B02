<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Service Visits – SilverCare</title>

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
                    forest: { DEFAULT: '#3d4f3d' },
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

    .data-table { width: 100%; border-collapse: collapse; }
    .data-table th {
        background-color: #e8e4dc; padding: 12px; text-align: left;
        font-weight: 500; border-bottom: 2px solid #2c2c2c;
        font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em;
    }
    .data-table td { padding: 16px 12px; border-bottom: 1px solid #e8e4dc; }
    .data-table tbody tr { transition: background-color 0.15s ease; }
    .data-table tbody tr:hover { background-color: #f5f3ef; }

    .status-badge {
        display: inline-block; padding: 4px 12px;
        font-size: 0.75rem; border-radius: 2px; font-weight: 500;
    }
    .status-scheduled { background: #e0e7ff; color: #3730a3; }
    .status-en_route { background: #fef3c7; color: #92400e; }
    .status-checked_in { background: #d1fae5; color: #065f46; }
    .status-in_progress { background: #dbeafe; color: #1e40af; }
    .status-checked_out { background: #e0e7ff; color: #4338ca; }
    .status-completed { background: #d1ecf1; color: #0c5460; }
    .status-cancelled { background: #f8d7da; color: #721c24; }

    .modal-overlay {
        position: fixed; inset: 0; z-index: 200;
        background: rgba(0,0,0,0.4); display: none;
        align-items: center; justify-content: center;
    }
    .modal-overlay.show { display: flex; }
    .modal-box {
        background: white; border: 1px solid #e8e4dc;
        width: 100%; max-width: 560px; max-height: 90vh; overflow-y: auto;
    }
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
                    Service Visits
                </h1>
                <p class="text-ink-light text-base md:text-lg max-w-2xl">
                    Create, manage and monitor caregiver service visits for customer bookings.
                </p>
                <div class="flex items-center gap-4 mt-5">
                    <a href="${pageContext.request.contextPath}/admin"
                       class="text-xs text-ink-muted hover:text-copper transition-colors inline-flex items-center gap-1">
                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                        </svg>
                        Back to Dashboard
                    </a>
                    <button onclick="openCreateModal()"
                            class="px-5 py-2 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                        + New Visit
                    </button>
                </div>
            </header>

            <!-- Success/Error Messages -->
            <%
                String successMsg = (String) session.getAttribute("successMsg");
                String errorMsg = (String) session.getAttribute("errorMsg");
                if (successMsg != null) { session.removeAttribute("successMsg"); %>
                <div class="bg-green-50 border border-green-200 text-green-800 px-5 py-3 text-sm mb-6"><%= successMsg %></div>
            <% } if (errorMsg != null) { session.removeAttribute("errorMsg"); %>
                <div class="bg-red-50 border border-red-200 text-red-800 px-5 py-3 text-sm mb-6"><%= errorMsg %></div>
            <% } %>

            <!-- Stats Cards -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Total Visits</p>
                    <p class="font-serif text-3xl font-medium text-ink">
                        <c:choose>
                            <c:when test="${not empty visits}">${fn:length(visits)}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Scheduled</p>
                    <p class="font-serif text-3xl font-medium" style="color:#3730a3;">
                        <c:set var="scheduledCount" value="0"/>
                        <c:forEach var="v" items="${visits}">
                            <c:if test="${v.status == 'SCHEDULED'}">
                                <c:set var="scheduledCount" value="${scheduledCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${scheduledCount}
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Active</p>
                    <p class="font-serif text-3xl font-medium text-forest">
                        <c:set var="activeCount" value="0"/>
                        <c:forEach var="v" items="${visits}">
                            <c:if test="${v.status == 'EN_ROUTE' || v.status == 'CHECKED_IN' || v.status == 'IN_PROGRESS'}">
                                <c:set var="activeCount" value="${activeCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${activeCount}
                    </p>
                </div>
                <div class="bg-white border border-stone-mid p-4">
                    <p class="text-xs uppercase tracking-wide text-ink-muted mb-2">Completed</p>
                    <p class="font-serif text-3xl font-medium" style="color:#0c5460;">
                        <c:set var="completedCount" value="0"/>
                        <c:forEach var="v" items="${visits}">
                            <c:if test="${v.status == 'COMPLETED'}">
                                <c:set var="completedCount" value="${completedCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${completedCount}
                    </p>
                </div>
            </div>

            <!-- Visits Table -->
            <section class="bg-white border border-stone-mid">
                <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                    <h2 class="font-serif text-xl font-medium text-ink">All Service Visits</h2>
                    <div class="flex items-center gap-3">
                        <select id="statusFilter" onchange="filterByStatus()"
                                class="text-sm border border-stone-mid px-3 py-1.5 bg-white text-ink focus:outline-none">
                            <option value="">All Statuses</option>
                            <option value="SCHEDULED">Scheduled</option>
                            <option value="EN_ROUTE">En Route</option>
                            <option value="CHECKED_IN">Checked In</option>
                            <option value="IN_PROGRESS">In Progress</option>
                            <option value="CHECKED_OUT">Checked Out</option>
                            <option value="COMPLETED">Completed</option>
                            <option value="CANCELLED">Cancelled</option>
                        </select>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="data-table" id="visitsTable">
                        <thead>
                            <tr>
                                <th>Visit ID</th>
                                <th>Customer</th>
                                <th>Caregiver</th>
                                <th>Scheduled</th>
                                <th>Status</th>
                                <th>Location</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="v" items="${visits}">
                                <tr data-status="${v.status}">
                                    <td>
                                        <span class="font-medium text-sm">#${v.visitId}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink font-medium text-sm">${v.customerName}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink text-sm">${v.caregiverName}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink-light text-sm">${v.scheduledStart}</span>
                                    </td>
                                    <td>
                                        <c:set var="sKey" value="${fn:toLowerCase(v.status)}"/>
                                        <span class="status-badge status-${sKey}">${v.statusLabel}</span>
                                    </td>
                                    <td>
                                        <span class="text-ink-light text-sm">${v.location}</span>
                                    </td>
                                    <td class="text-right">
                                        <div class="flex items-center justify-end gap-2">
                                            <button onclick="openStatusModal('${v.visitId}', '${v.status}')"
                                                    class="text-xs px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-copper hover:border-copper transition-colors">
                                                Status
                                            </button>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/service-visits/delete"
                                                  class="inline" onsubmit="return confirm('Delete visit #${v.visitId}?');">
                                                <input type="hidden" name="visitId" value="${v.visitId}">
                                                <button type="submit"
                                                        class="text-xs px-3 py-1.5 border border-stone-mid text-ink-muted hover:text-red-600 hover:border-red-200 hover:bg-red-50 transition-colors">
                                                    Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty visits}">
                                <tr id="emptyRow">
                                    <td colspan="7" class="text-center py-12">
                                        <svg class="w-10 h-10 text-stone-deep mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                                        </svg>
                                        <p class="text-sm text-ink-muted">No service visits found</p>
                                        <p class="text-xs text-ink-muted mt-1">Click "+ New Visit" to create a service visit</p>
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

    <!-- ══════════════ Create Visit Modal ══════════════ -->
    <div class="modal-overlay" id="createModal">
        <div class="modal-box">
            <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                <h3 class="font-serif text-xl font-medium text-ink">Create Service Visit</h3>
                <button onclick="closeCreateModal()" class="text-ink-muted hover:text-ink transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/service-visits/create" class="p-6 space-y-5" id="createVisitForm">
                <!-- Hidden fields auto-populated from selections -->
                <input type="hidden" name="bookingId" id="createBookingId">
                <input type="hidden" name="customerUserId" id="createCustomerUserId">
                <input type="hidden" name="customerName" id="createCustomerName">
                <input type="hidden" name="caregiverUserId" id="createCaregiverUserId">
                <input type="hidden" name="caregiverName" id="createCaregiverName">

                <!-- Select Booking -->
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Select Booking</label>
                    <select id="bookingSelect" required onchange="onBookingSelected(this)"
                            class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                        <option value="">— Loading bookings... —</option>
                    </select>
                    <div id="bookingInfo" class="mt-3 hidden">
                        <div class="bg-stone-warm border border-stone-mid p-4 space-y-3">
                            <p class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-1">Booking Details</p>
                            <div class="grid grid-cols-2 gap-2 text-sm">
                                <div>
                                    <span class="text-ink-muted">Customer:</span>
                                    <span class="text-ink font-medium" id="infoCustomerName">—</span>
                                </div>
                                <div>
                                    <span class="text-ink-muted">Booked For:</span>
                                    <span class="text-ink" id="infoScheduledAt">—</span>
                                </div>
                                <div class="col-span-2">
                                    <span class="text-ink-muted">Services:</span>
                                    <span class="text-ink" id="infoServices">—</span>
                                </div>
                                <div class="col-span-2" id="infoNotesRow" style="display:none;">
                                    <span class="text-ink-muted">Notes:</span>
                                    <span class="text-ink" id="infoNotes">—</span>
                                </div>
                            </div>

                            <!-- Customer Address -->
                            <div id="infoAddressSection" style="display:none;">
                                <div class="border-t border-stone-mid pt-3 mt-1">
                                    <p class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 flex items-center gap-1.5">
                                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                                        Visit Location
                                    </p>
                                    <p class="text-sm text-ink" id="infoAddress">—</p>
                                    <button type="button" onclick="useAddressAsLocation()" class="mt-1.5 text-xs text-copper hover:text-copper-light transition-colors underline underline-offset-2">Use as visit location ↓</button>
                                </div>
                            </div>

                            <!-- Medical & Care Info -->
                            <div id="infoMedicalSection" style="display:none;">
                                <div class="border-t border-stone-mid pt-3 mt-1">
                                    <p class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 flex items-center gap-1.5">
                                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                                        Medical &amp; Care Info
                                    </p>
                                    <div class="space-y-1.5 text-sm">
                                        <div id="infoMedicalNotesRow" style="display:none;">
                                            <span class="text-ink-muted">Medical Notes:</span>
                                            <span class="text-ink" id="infoMedicalNotes">—</span>
                                        </div>
                                        <div id="infoCarePrefsRow" style="display:none;">
                                            <span class="text-ink-muted">Care Preferences:</span>
                                            <span class="text-ink" id="infoCarePrefs">—</span>
                                        </div>
                                        <div id="infoEmergencyRow" style="display:none;">
                                            <span class="text-ink-muted">Emergency Contact:</span>
                                            <span class="text-ink" id="infoEmergency">—</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Select Caregiver -->
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Assign Caregiver</label>
                    <select id="caregiverSelect" required onchange="onCaregiverSelected(this)"
                            class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                        <option value="">— Loading caregivers... —</option>
                    </select>
                    <div id="caregiverInfo" class="mt-3 hidden">
                        <div class="bg-stone-warm border border-stone-mid p-4">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 bg-stone-mid flex items-center justify-center flex-shrink-0">
                                    <span class="font-serif text-base text-ink" id="infoCaregiverInitial">?</span>
                                </div>
                                <div>
                                    <p class="text-sm font-medium text-ink" id="infoCaregiverName">—</p>
                                    <div class="flex items-center gap-3 text-xs text-ink-light mt-0.5">
                                        <span id="infoCaregiverExp">—</span>
                                        <span id="infoCaregiverRating">—</span>
                                        <span id="infoCaregiverAvail">—</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Schedule -->
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Start Time</label>
                        <input type="datetime-local" name="scheduledStartTime" required id="createStartTime"
                               class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                    </div>
                    <div>
                        <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">End Time</label>
                        <input type="datetime-local" name="scheduledEndTime" required id="createEndTime"
                               class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                    </div>
                </div>
                <!-- Location & Notes -->
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Location</label>
                    <input type="text" name="location" placeholder="Address or visit location"
                           class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                </div>
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Notes</label>
                    <textarea name="notes" rows="2" placeholder="Optional notes"
                           class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink resize-none"></textarea>
                </div>
                <!-- Submit -->
                <div class="flex items-center justify-end gap-3 pt-2">
                    <button type="button" onclick="closeCreateModal()"
                            class="px-5 py-2 text-sm text-ink-muted border border-stone-mid hover:bg-stone-warm transition-colors">
                        Cancel
                    </button>
                    <button type="submit"
                            class="px-5 py-2 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                        Create Visit
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- ══════════════ Update Status Modal ══════════════ -->
    <div class="modal-overlay" id="statusModal">
        <div class="modal-box">
            <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                <h3 class="font-serif text-xl font-medium text-ink">Update Visit Status</h3>
                <button onclick="closeStatusModal()" class="text-ink-muted hover:text-ink transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/service-visits/status" class="p-6 space-y-5">
                <input type="hidden" name="visitId" id="statusVisitId">
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">New Status</label>
                    <select name="status" id="statusSelect" required
                            class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink">
                        <option value="SCHEDULED">Scheduled</option>
                        <option value="EN_ROUTE">En Route</option>
                        <option value="CHECKED_IN">Checked In</option>
                        <option value="IN_PROGRESS">In Progress</option>
                        <option value="CHECKED_OUT">Checked Out</option>
                        <option value="COMPLETED">Completed</option>
                        <option value="CANCELLED">Cancelled</option>
                    </select>
                </div>
                <div>
                    <label class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2 block">Notes</label>
                    <textarea name="notes" rows="2" placeholder="Optional notes for status change"
                              class="w-full border border-stone-mid px-4 py-2.5 text-sm bg-white text-ink focus:outline-none focus:border-ink resize-none"></textarea>
                </div>
                <div class="flex items-center justify-end gap-3 pt-2">
                    <button type="button" onclick="closeStatusModal()"
                            class="px-5 py-2 text-sm text-ink-muted border border-stone-mid hover:bg-stone-warm transition-colors">
                        Cancel
                    </button>
                    <button type="submit"
                            class="px-5 py-2 bg-ink text-stone-warm text-sm font-normal hover:bg-ink-light transition-colors">
                        Update Status
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
    const API_HOST = 'http://localhost:8081/api';
    let bookingsCache = [];
    let caregiversCache = [];
    let customerCache = {};  // userId -> customer data

    // ── Loader ──
    window.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 500);
    });

    // ── Create Modal ──
    function openCreateModal() {
        document.getElementById('createModal').classList.add('show');
        loadBookingsForSelect();
        loadCaregiversForSelect();
    }
    function closeCreateModal() {
        document.getElementById('createModal').classList.remove('show');
        // Reset form state
        document.getElementById('createVisitForm').reset();
        document.getElementById('bookingInfo').classList.add('hidden');
        document.getElementById('caregiverInfo').classList.add('hidden');
        document.getElementById('createBookingId').value = '';
        document.getElementById('createCustomerUserId').value = '';
        document.getElementById('createCustomerName').value = '';
        document.getElementById('createCaregiverUserId').value = '';
        document.getElementById('createCaregiverName').value = '';
    }

    // ── Load bookings into dropdown ──
    async function loadBookingsForSelect() {
        const sel = document.getElementById('bookingSelect');
        sel.innerHTML = '<option value="">— Loading bookings... —</option>';

        try {
            const res = await fetch(API_HOST + '/bookings');
            const bookings = await res.json();
            bookingsCache = Array.isArray(bookings) ? bookings : [];

            // Also pre-fetch customer names for all unique user IDs
            const userIds = [...new Set(bookingsCache.map(b => b.customerUserId).filter(Boolean))];
            await Promise.all(userIds.map(uid => fetchCustomerName(uid)));

            sel.innerHTML = '<option value="">— Select a booking —</option>';

            if (bookingsCache.length === 0) {
                sel.innerHTML = '<option value="">— No bookings found —</option>';
                return;
            }

            bookingsCache.forEach(b => {
                const opt = document.createElement('option');
                opt.value = b.bookingId;

                // Format display text
                const custObj = customerCache[b.customerUserId];
                const custName = (typeof custObj === 'object' ? custObj.name : custObj) || 'Unknown Customer';
                const dateStr = b.scheduledAt ? new Date(b.scheduledAt).toLocaleDateString('en-SG', { day: 'numeric', month: 'short', year: 'numeric' }) : 'No date';
                const services = (b.bookingDetails || []).map(d => d.serviceName).filter(Boolean).join(', ') || 'No services';
                const statusLabel = (b.status || 'unknown').charAt(0).toUpperCase() + (b.status || 'unknown').slice(1);

                opt.textContent = '#' + b.bookingId + ' — ' + custName + ' — ' + dateStr + ' [' + statusLabel + ']';
                opt.dataset.customerUserId = b.customerUserId || '';
                opt.dataset.customerName = custName;
                opt.dataset.scheduledAt = dateStr;
                opt.dataset.services = services;
                opt.dataset.notes = b.notes || '';
                opt.dataset.status = b.status || '';
                sel.appendChild(opt);
            });
        } catch (e) {
            console.error('Failed to load bookings:', e);
            sel.innerHTML = '<option value="">— Error loading bookings —</option>';
        }
    }

    // ── Fetch customer data by UUID (caches full object) ──
    async function fetchCustomerName(userId) {
        if (customerCache[userId]) return typeof customerCache[userId] === 'string' ? customerCache[userId] : customerCache[userId].name;
        try {
            const res = await fetch(API_HOST + '/customers/' + userId);
            if (res.ok) {
                const cust = await res.json();
                // Cache the full customer object for address & medical info
                customerCache[userId] = {
                    name: cust.name || cust.email || 'Unknown',
                    block: cust.block || '',
                    street: cust.street || '',
                    unitNumber: cust.unitNumber || '',
                    buildingName: cust.buildingName || '',
                    postalCode: cust.postalCode || '',
                    city: cust.city || '',
                    state: cust.state || '',
                    addressLine2: cust.addressLine2 || '',
                    countryName: cust.countryName || '',
                    medicalNotes: cust.medicalNotes || '',
                    carePreferences: cust.carePreferences || '',
                    emergencyContactName: cust.emergencyContactName || '',
                    emergencyContactPhone: cust.emergencyContactPhone || ''
                };
                return customerCache[userId].name;
            }
        } catch (e) {
            console.error('Failed to fetch customer:', e);
        }
        customerCache[userId] = { name: 'Unknown' };
        return 'Unknown';
    }

    // ── Format customer address from cached data ──
    function formatCustomerAddress(custData) {
        if (!custData || typeof custData === 'string') return '';
        const parts = [];
        if (custData.block) parts.push('Blk ' + custData.block);
        if (custData.street) parts.push(custData.street);
        if (custData.unitNumber) parts.push('#' + custData.unitNumber);
        if (custData.buildingName) parts.push(custData.buildingName);
        if (custData.addressLine2) parts.push(custData.addressLine2);
        let line1 = parts.join(', ');
        const parts2 = [];
        if (custData.city) parts2.push(custData.city);
        if (custData.state) parts2.push(custData.state);
        if (custData.postalCode) parts2.push(custData.postalCode);
        if (custData.countryName) parts2.push(custData.countryName);
        let line2 = parts2.join(', ');
        return [line1, line2].filter(Boolean).join(', ');
    }

    // ── Use address as location ──
    function useAddressAsLocation() {
        const addr = document.getElementById('infoAddress').textContent;
        if (addr && addr !== '—') {
            document.querySelector('input[name="location"]').value = addr;
        }
    }

    // ── When a booking is selected ──
    function onBookingSelected(sel) {
        const opt = sel.options[sel.selectedIndex];
        const infoEl = document.getElementById('bookingInfo');

        if (!opt.value) {
            infoEl.classList.add('hidden');
            document.getElementById('createBookingId').value = '';
            document.getElementById('createCustomerUserId').value = '';
            document.getElementById('createCustomerName').value = '';
            document.getElementById('createStartTime').value = '';
            return;
        }

        // Populate hidden fields
        document.getElementById('createBookingId').value = opt.value;
        document.getElementById('createCustomerUserId').value = opt.dataset.customerUserId;
        document.getElementById('createCustomerName').value = opt.dataset.customerName;

        // Show info card
        document.getElementById('infoCustomerName').textContent = opt.dataset.customerName;
        document.getElementById('infoScheduledAt').textContent = opt.dataset.scheduledAt;
        document.getElementById('infoServices').textContent = opt.dataset.services;

        // Show notes if present
        const notesRow = document.getElementById('infoNotesRow');
        if (opt.dataset.notes) {
            document.getElementById('infoNotes').textContent = opt.dataset.notes;
            notesRow.style.display = '';
        } else {
            notesRow.style.display = 'none';
        }

        // Show customer address & medical info from cache
        const custData = customerCache[opt.dataset.customerUserId];
        const addrSection = document.getElementById('infoAddressSection');
        const medSection = document.getElementById('infoMedicalSection');

        if (custData && typeof custData === 'object') {
            // Address
            const addr = formatCustomerAddress(custData);
            if (addr) {
                document.getElementById('infoAddress').textContent = addr;
                addrSection.style.display = '';
                // Auto-fill location field
                document.querySelector('input[name="location"]').value = addr;
            } else {
                addrSection.style.display = 'none';
            }

            // Medical / Care info
            let hasMedical = false;
            const medNotesRow = document.getElementById('infoMedicalNotesRow');
            const carePrefsRow = document.getElementById('infoCarePrefsRow');
            const emergRow = document.getElementById('infoEmergencyRow');

            if (custData.medicalNotes) {
                document.getElementById('infoMedicalNotes').textContent = custData.medicalNotes;
                medNotesRow.style.display = '';
                hasMedical = true;
            } else { medNotesRow.style.display = 'none'; }

            if (custData.carePreferences) {
                document.getElementById('infoCarePrefs').textContent = custData.carePreferences;
                carePrefsRow.style.display = '';
                hasMedical = true;
            } else { carePrefsRow.style.display = 'none'; }

            if (custData.emergencyContactName || custData.emergencyContactPhone) {
                const emParts = [custData.emergencyContactName, custData.emergencyContactPhone].filter(Boolean);
                document.getElementById('infoEmergency').textContent = emParts.join(' — ');
                emergRow.style.display = '';
                hasMedical = true;
            } else { emergRow.style.display = 'none'; }

            medSection.style.display = hasMedical ? '' : 'none';
        } else {
            addrSection.style.display = 'none';
            medSection.style.display = 'none';
        }

        infoEl.classList.remove('hidden');

        // Pre-fill start time from booking scheduled date
        const booking = bookingsCache.find(b => b.bookingId == opt.value);
        if (booking && booking.scheduledAt) {
            const dt = new Date(booking.scheduledAt);
            // Set start time to 9:00 AM on that date as default
            dt.setHours(9, 0, 0, 0);
            const localISO = dt.getFullYear() + '-' +
                String(dt.getMonth() + 1).padStart(2, '0') + '-' +
                String(dt.getDate()).padStart(2, '0') + 'T09:00';
            document.getElementById('createStartTime').value = localISO;

            // Default end time 1 hour later
            const endISO = dt.getFullYear() + '-' +
                String(dt.getMonth() + 1).padStart(2, '0') + '-' +
                String(dt.getDate()).padStart(2, '0') + 'T10:00';
            document.getElementById('createEndTime').value = endISO;
        }
    }

    // ── Load caregivers into dropdown ──
    async function loadCaregiversForSelect() {
        const sel = document.getElementById('caregiverSelect');
        sel.innerHTML = '<option value="">— Loading caregivers... —</option>';

        try {
            const res = await fetch(API_HOST + '/caregivers');
            const result = await res.json();
            caregiversCache = Array.isArray(result) ? result : (result.data || []);

            sel.innerHTML = '<option value="">— Select a caregiver —</option>';

            if (caregiversCache.length === 0) {
                sel.innerHTML = '<option value="">— No caregivers found —</option>';
                return;
            }

            caregiversCache.forEach(c => {
                const opt = document.createElement('option');
                opt.value = c.userId;

                const name = c.caregiverName || 'Unnamed';
                const rating = c.ratingAvg ? ' ★ ' + c.ratingAvg.toFixed(1) : '';
                const avail = c.isAvailable !== false ? ' · Available' : ' · Unavailable';
                const exp = c.yearsOfExperience ? ' · ' + c.yearsOfExperience + 'yr exp' : '';

                opt.textContent = name + rating + exp + avail;
                opt.dataset.name = name;
                opt.dataset.exp = c.yearsOfExperience ? c.yearsOfExperience + ' years experience' : 'No experience info';
                opt.dataset.rating = c.ratingAvg ? '★ ' + c.ratingAvg.toFixed(1) + ' rating' : 'No rating';
                opt.dataset.avail = c.isAvailable !== false ? 'Available' : 'Unavailable';
                sel.appendChild(opt);
            });
        } catch (e) {
            console.error('Failed to load caregivers:', e);
            sel.innerHTML = '<option value="">— Error loading caregivers —</option>';
        }
    }

    // ── When a caregiver is selected ──
    function onCaregiverSelected(sel) {
        const opt = sel.options[sel.selectedIndex];
        const infoEl = document.getElementById('caregiverInfo');

        if (!opt.value) {
            infoEl.classList.add('hidden');
            document.getElementById('createCaregiverUserId').value = '';
            document.getElementById('createCaregiverName').value = '';
            return;
        }

        // Populate hidden fields
        document.getElementById('createCaregiverUserId').value = opt.value;
        document.getElementById('createCaregiverName').value = opt.dataset.name;

        // Show info card
        document.getElementById('infoCaregiverInitial').textContent = opt.dataset.name.charAt(0).toUpperCase();
        document.getElementById('infoCaregiverName').textContent = opt.dataset.name;
        document.getElementById('infoCaregiverExp').textContent = opt.dataset.exp;
        document.getElementById('infoCaregiverRating').textContent = opt.dataset.rating;
        document.getElementById('infoCaregiverAvail').textContent = opt.dataset.avail;
        infoEl.classList.remove('hidden');
    }

    // ── Status Modal ──
    function openStatusModal(visitId, currentStatus) {
        document.getElementById('statusVisitId').value = visitId;
        document.getElementById('statusSelect').value = currentStatus;
        document.getElementById('statusModal').classList.add('show');
    }
    function closeStatusModal() { document.getElementById('statusModal').classList.remove('show'); }

    // ── Filter ──
    function filterByStatus() {
        const val = document.getElementById('statusFilter').value;
        const rows = document.querySelectorAll('#visitsTable tbody tr[data-status]');
        rows.forEach(row => {
            if (!val || row.dataset.status === val) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    // Close modals on overlay click
    document.querySelectorAll('.modal-overlay').forEach(m => {
        m.addEventListener('click', e => { if (e.target === m) m.classList.remove('show'); });
    });
    </script>
</body>
</html>
