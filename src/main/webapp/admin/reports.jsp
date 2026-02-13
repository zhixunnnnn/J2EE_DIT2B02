<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & Analytics – SilverCare</title>

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
                    forest: '#3d4f3d',
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

    @keyframes fadeSlideIn {
        from { opacity: 0; transform: translateY(16px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .stagger-1 { animation: fadeSlideIn 0.6s ease 0.1s both; }
    .stagger-2 { animation: fadeSlideIn 0.6s ease 0.2s both; }
    .stagger-3 { animation: fadeSlideIn 0.6s ease 0.3s both; }
    .stagger-4 { animation: fadeSlideIn 0.6s ease 0.4s both; }
    .stagger-5 { animation: fadeSlideIn 0.6s ease 0.5s both; }

    .metric-card { transition: transform 0.2s ease, border-color 0.2s ease; }
    .metric-card:hover { transform: translateY(-2px); border-color: #2c2c2c; }

    .report-card {
        transition: transform 0.2s ease, border-color 0.2s ease;
        cursor: pointer;
    }
    .report-card:hover {
        transform: translateY(-2px);
        border-color: #2c2c2c;
    }

    .tab-btn {
        transition: all 0.2s ease;
    }
    .tab-btn.active {
        background-color: #2c2c2c;
        color: #f5f3ef;
    }

    .report-row { transition: background-color 0.15s ease; }
    .report-row:hover { background-color: #f5f3ef; }
    .text-mono { font-variant-numeric: tabular-nums; }
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
            <header class="mb-10">
                <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                    <div>
                        <a href="<%= request.getContextPath() %>/admin" class="text-sm text-ink-muted hover:text-ink transition-colors inline-flex items-center gap-1 mb-3 stagger-1">
                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 19l-7-7 7-7"/>
                            </svg>
                            Dashboard
                        </a>
                        <span class="block text-copper text-xs uppercase tracking-[0.2em] stagger-1">Administration</span>
                        <h1 class="font-serif text-3xl md:text-4xl font-medium text-ink mt-2 stagger-2">Reports &amp; Analytics</h1>
                        <p class="mt-2 text-ink-light text-base max-w-xl stagger-2">
                            Comprehensive reporting and insights for service management, customer analytics, and sales performance.
                        </p>
                    </div>
                </div>
            </header>

            <!-- Report Categories -->
            <div class="mb-8 stagger-3">
                <div class="flex gap-3 flex-wrap">
                    <button onclick="showReportSection('services')" class="tab-btn active px-5 py-2.5 text-sm border border-stone-mid bg-white hover:border-ink transition-colors" id="tab-services">
                        Service Reports
                    </button>
                    <button onclick="showReportSection('customers')" class="tab-btn px-5 py-2.5 text-sm border border-stone-mid bg-white hover:border-ink transition-colors" id="tab-customers">
                        Customer Reports
                    </button>
                    <button onclick="showReportSection('sales')" class="tab-btn px-5 py-2.5 text-sm border border-stone-mid bg-white hover:border-ink transition-colors" id="tab-sales">
                        Sales Reports
                    </button>
                </div>
            </div>

            <!-- Service Reports Section -->
            <div id="section-services" class="report-section stagger-4">
                <div class="grid md:grid-cols-3 gap-5 mb-8">
                    <div class="report-card metric-card bg-white border border-stone-mid p-5" onclick="loadBestRatedServices()">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Best rated</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"/>
                            </svg>
                        </div>
                        <h3 class="font-serif text-xl font-medium text-ink mb-1">Best Rated Services</h3>
                        <p class="text-ink-light text-xs">Services with highest customer ratings</p>
                    </div>
                    <div class="report-card metric-card bg-white border border-stone-mid p-5" onclick="loadLowestRatedServices()">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Needs focus</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                            </svg>
                        </div>
                        <h3 class="font-serif text-xl font-medium text-ink mb-1">Lowest Rated Services</h3>
                        <p class="text-ink-light text-xs">Services needing improvement</p>
                    </div>
                    <div class="report-card metric-card bg-white border border-stone-mid p-5" onclick="loadHighDemandServices()">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Popular</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"/>
                            </svg>
                        </div>
                        <h3 class="font-serif text-xl font-medium text-ink mb-1">High Demand Services</h3>
                        <p class="text-ink-light text-xs">Most booked services</p>
                    </div>
                </div>

                <div id="service-report-results" class="hidden">
                    <div class="bg-white border border-stone-mid overflow-hidden">
                        <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                            <h3 class="font-serif text-lg font-medium text-ink" id="service-report-title"></h3>
                            <button onclick="closeReport('service')" class="text-ink-muted hover:text-ink transition-colors p-1" aria-label="Close">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12"/>
                                </svg>
                            </button>
                        </div>
                        <div id="service-report-content" class="overflow-x-auto"></div>
                    </div>
                </div>
            </div>

            <!-- Customer Reports Section -->
            <div id="section-customers" class="report-section hidden stagger-4">
                <div class="grid md:grid-cols-2 gap-5 mb-8">
                    <div class="report-card metric-card bg-white border border-stone-mid p-5">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">By area</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                            </svg>
                        </div>
                        <h3 class="font-serif text-xl font-medium text-ink mb-4">Customers by Area</h3>
                        <div class="flex gap-2">
                            <input type="text" id="postal-code-input" placeholder="Enter postal code"
                                   class="flex-1 px-4 py-2.5 text-sm bg-white border border-stone-mid focus:outline-none focus:border-ink transition-colors">
                            <button onclick="loadCustomersByArea()" class="px-5 py-2.5 text-sm bg-ink text-stone-warm hover:bg-ink-light transition-colors font-normal">
                                Search
                            </button>
                        </div>
                    </div>
                    <div class="report-card metric-card bg-white border border-stone-mid p-5">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">By service</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                            </svg>
                        </div>
                        <h3 class="font-serif text-xl font-medium text-ink mb-4">Customers by Service</h3>
                        <div class="flex gap-2">
                            <select id="service-select" class="flex-1 px-4 py-2.5 text-sm bg-white border border-stone-mid focus:outline-none focus:border-ink transition-colors">
                                <option value="">Select a service...</option>
                            </select>
                            <button onclick="loadCustomersByService()" class="px-5 py-2.5 text-sm bg-ink text-stone-warm hover:bg-ink-light transition-colors font-normal">
                                Search
                            </button>
                        </div>
                    </div>
                </div>

                <div id="customer-report-results" class="hidden">
                    <div class="bg-white border border-stone-mid overflow-hidden">
                        <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                            <h3 class="font-serif text-lg font-medium text-ink" id="customer-report-title"></h3>
                            <button onclick="closeReport('customer')" class="text-ink-muted hover:text-ink transition-colors p-1" aria-label="Close">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12"/>
                                </svg>
                            </button>
                        </div>
                        <div id="customer-report-content" class="overflow-x-auto"></div>
                    </div>
                </div>
            </div>

            <!-- Sales Reports Section -->
            <div id="section-sales" class="report-section hidden stagger-4">
                <div class="grid md:grid-cols-2 gap-5 mb-8">
                    <div class="report-card metric-card bg-white border border-stone-mid p-5" onclick="loadTopCustomers()">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Top spenders</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                        </div>
                        <h3 class="font-serif text-xl font-medium text-ink mb-1">Top Customers</h3>
                        <p class="text-ink-light text-xs">Customers by total spending</p>
                    </div>
                    <div class="report-card metric-card bg-white border border-stone-mid p-5">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-xs uppercase tracking-wide text-ink-muted">Date range</span>
                            <svg class="w-4 h-4 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                            </svg>
                        </div>
                        <h3 class="font-serif text-xl font-medium text-ink mb-4">Bookings by Date Range</h3>
                        <div class="space-y-2">
                            <input type="date" id="start-date" class="w-full px-4 py-2.5 text-sm bg-white border border-stone-mid focus:outline-none focus:border-ink transition-colors">
                            <input type="date" id="end-date" class="w-full px-4 py-2.5 text-sm bg-white border border-stone-mid focus:outline-none focus:border-ink transition-colors">
                            <button onclick="loadBookingsByDate()" class="w-full px-5 py-2.5 text-sm bg-ink text-stone-warm hover:bg-ink-light transition-colors font-normal">
                                Generate Report
                            </button>
                        </div>
                    </div>
                </div>

                <div id="sales-report-results" class="hidden">
                    <div class="bg-white border border-stone-mid overflow-hidden">
                        <div class="px-6 py-5 border-b border-stone-mid flex items-center justify-between">
                            <h3 class="font-serif text-lg font-medium text-ink" id="sales-report-title"></h3>
                            <button onclick="closeReport('sales')" class="text-ink-muted hover:text-ink transition-colors p-1" aria-label="Close">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12"/>
                                </svg>
                            </button>
                        </div>
                        <div id="sales-report-content" class="overflow-x-auto"></div>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <script>
    const API_BASE = '<%= request.getContextPath() %>';

    // Tab switching
    function showReportSection(section) {
        document.querySelectorAll('.report-section').forEach(s => s.classList.add('hidden'));
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        
        document.getElementById('section-' + section).classList.remove('hidden');
        document.getElementById('tab-' + section).classList.add('active');
        
        // Close any open reports
        closeReport('service');
        closeReport('customer');
        closeReport('sales');
    }

    function closeReport(type) {
        document.getElementById(type + '-report-results').classList.add('hidden');
    }

    // Service Reports
    async function loadBestRatedServices() {
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/services/best-rated?limit=10`);
            const data = await response.json();
            
            if (data.success) {
                displayServiceReport('Best Rated Services', data.data);
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    async function loadLowestRatedServices() {
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/services/lowest-rated?limit=10`);
            const data = await response.json();
            
            if (data.success) {
                displayServiceReport('Lowest Rated Services', data.data);
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    async function loadHighDemandServices() {
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/services/high-demand?limit=10`);
            const data = await response.json();
            
            if (data.success) {
                displayServiceReport('High Demand Services', data.data);
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    function displayServiceReport(title, services) {
        document.getElementById('service-report-title').textContent = title;
        
        let html = '<table class="min-w-full"><thead><tr class="border-b border-stone-mid">';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Service Name</th>';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Category</th>';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Avg Rating</th>';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Total Feedback</th>';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Price</th>';
        html += '</tr></thead><tbody>';
        
        services.forEach(service => {
            html += `<tr class="report-row border-b border-stone-mid/50 last:border-b-0">
                <td class="py-4 px-4 text-sm text-ink">\${service.serviceName}</td>
                <td class="py-4 px-4 text-sm text-ink-light">\${service.categoryName || 'N/A'}</td>
                <td class="py-4 px-4 text-sm text-ink">\${service.avgRating !== null ? service.avgRating.toFixed(2) + ' ★' : 'N/A'}</td>
                <td class="py-4 px-4 text-sm text-ink text-mono">\${service.totalFeedback}</td>
                <td class="py-4 px-4 text-sm font-medium text-ink text-mono">$\${service.price.toFixed(2)}</td>
            </tr>`;
        });
        
        html += '</tbody></table>';
        document.getElementById('service-report-content').innerHTML = html;
        document.getElementById('service-report-results').classList.remove('hidden');
    }

    // Customer Reports
    async function loadCustomersByArea() {
        const postalCode = document.getElementById('postal-code-input').value.trim();
        if (!postalCode) {
            alert('Please enter a postal code');
            return;
        }
        
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/customers/by-area?postalCode=\${encodeURIComponent(postalCode)}`);
            const data = await response.json();
            
            if (data.success) {
                displayCustomerReport(`Customers in Area: \${postalCode}`, data.data);
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    async function loadCustomersByService() {
        const serviceId = document.getElementById('service-select').value;
        if (!serviceId) {
            alert('Please select a service');
            return;
        }
        
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/customers/by-service?serviceId=\${serviceId}`);
            const data = await response.json();
            
            if (data.success) {
                const serviceName = document.getElementById('service-select').selectedOptions[0].text;
                displayCustomerReport(`Customers who booked: \${serviceName}`, data.data);
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    function displayCustomerReport(title, customers) {
        document.getElementById('customer-report-title').textContent = title;
        
        let html = '<table class="min-w-full"><thead><tr class="border-b border-stone-mid">';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Name</th>';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Email</th>';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Phone</th>';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Postal Code</th>';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">City</th>';
        html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Country</th>';
        html += '</tr></thead><tbody>';
        
        customers.forEach(customer => {
            html += `<tr class="report-row border-b border-stone-mid/50 last:border-b-0">
                <td class="py-4 px-4 text-sm text-ink">\${customer.name}</td>
                <td class="py-4 px-4 text-sm text-ink-light">\${customer.email}</td>
                <td class="py-4 px-4 text-sm text-ink-light">\${customer.phone || 'N/A'}</td>
                <td class="py-4 px-4 text-sm text-ink-light">\${customer.postalCode || 'N/A'}</td>
                <td class="py-4 px-4 text-sm text-ink-light">\${customer.city || 'N/A'}</td>
                <td class="py-4 px-4 text-sm text-ink-light">\${customer.countryName || 'N/A'}</td>
            </tr>`;
        });
        
        html += '</tbody></table>';
        document.getElementById('customer-report-content').innerHTML = html;
        document.getElementById('customer-report-results').classList.remove('hidden');
    }

    // Sales Reports
    async function loadTopCustomers() {
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/customers/top?limit=10`);
            const data = await response.json();
            
            if (data.success) {
                displaySalesReport('Top Customers by Spending', data.data, 'customers');
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    async function loadBookingsByDate() {
        const startDate = document.getElementById('start-date').value;
        const endDate = document.getElementById('end-date').value;
        
        if (!startDate || !endDate) {
            alert('Please select both start and end dates');
            return;
        }
        
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/bookings/by-date?startDate=\${startDate}&endDate=\${endDate}`);
            const data = await response.json();
            
            if (data.success) {
                displaySalesReport(`Bookings from \${startDate} to \${endDate}`, data.data, 'bookings');
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    function displaySalesReport(title, data, type) {
        document.getElementById('sales-report-title').textContent = title;
        
        let html = '<table class="min-w-full"><thead><tr class="border-b border-stone-mid">';
        
        if (type === 'customers') {
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Name</th>';
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Email</th>';
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Phone</th>';
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Total Bookings</th>';
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Total Spent</th>';
            html += '</tr></thead><tbody>';
            
            data.forEach(customer => {
                html += `<tr class="report-row border-b border-stone-mid/50 last:border-b-0">
                    <td class="py-4 px-4 text-sm text-ink">\${customer.name}</td>
                    <td class="py-4 px-4 text-sm text-ink-light">\${customer.email}</td>
                    <td class="py-4 px-4 text-sm text-ink-light">\${customer.phone || 'N/A'}</td>
                    <td class="py-4 px-4 text-sm text-ink text-mono">\${customer.totalBookings}</td>
                    <td class="py-4 px-4 text-sm font-medium text-ink text-mono">$\${customer.totalSpent.toFixed(2)}</td>
                </tr>`;
            });
        } else if (type === 'bookings') {
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Booking ID</th>';
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Customer</th>';
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Scheduled Date</th>';
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Status</th>';
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Total Services</th>';
            html += '<th class="py-3 px-4 text-left text-xs uppercase tracking-wide text-ink-muted font-normal">Total Amount</th>';
            html += '</tr></thead><tbody>';
            
            data.forEach(booking => {
                const scheduledDate = new Date(booking.scheduledAt).toLocaleString();
                html += `<tr class="report-row border-b border-stone-mid/50 last:border-b-0">
                    <td class="py-4 px-4 text-sm text-ink text-mono">\${booking.bookingId}</td>
                    <td class="py-4 px-4 text-sm text-ink">\${booking.customerName}</td>
                    <td class="py-4 px-4 text-sm text-ink-light">\${scheduledDate}</td>
                    <td class="py-4 px-4 text-sm text-ink-light">\${booking.status}</td>
                    <td class="py-4 px-4 text-sm text-ink text-mono">\${booking.totalServices}</td>
                    <td class="py-4 px-4 text-sm font-medium text-ink text-mono">$\${booking.totalAmount.toFixed(2)}</td>
                </tr>`;
            });
        }
        
        html += '</tbody></table>';
        document.getElementById('sales-report-content').innerHTML = html;
        document.getElementById('sales-report-results').classList.remove('hidden');
    }

    // Load services for dropdown
    async function loadServicesDropdown() {
        try {
            const response = await fetch(`\${API_BASE}/api/services`);
            const services = await response.json();
            
            const select = document.getElementById('service-select');
            services.forEach(service => {
                const option = document.createElement('option');
                option.value = service.serviceId;
                option.textContent = service.serviceName;
                select.appendChild(option);
            });
        } catch (error) {
            console.error('Error loading services:', error);
        }
    }

    // Initialize
    window.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 500);
        
        loadServicesDropdown();
    });
    </script>

</body>
</html>
