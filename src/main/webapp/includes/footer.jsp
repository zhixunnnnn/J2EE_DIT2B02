<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<footer class="mt-24 bg-stone-warm border-t border-stone-mid">
  <div class="max-w-6xl mx-auto px-5 md:px-12 py-14 grid grid-cols-1 md:grid-cols-3 gap-12">

    <!-- Branding -->
    <div>
      <h3 class="text-2xl font-serif font-medium text-ink mb-3">
        SilverCare
      </h3>
      <p class="text-sm text-ink-light leading-relaxed">
        Compassionate elderly care rooted in European calm and Scandinavian simplicity.
      </p>
    </div>

    <!-- Navigation -->
    <div>
      <h4 class="text-ink font-medium text-sm mb-4">Navigation</h4>
      <ul class="space-y-2 text-sm">
        <li><a href="<%=request.getContextPath()%>/" class="footer-link">Home</a></li>
        <li><a href="<%=request.getContextPath()%>/services" class="footer-link">Services</a></li>
        <li><a href="<%=request.getContextPath()%>/register" class="footer-link">Register</a></li>
        <li><a href="<%=request.getContextPath()%>/login" class="footer-link">Login</a></li>
      </ul>
    </div>

    <!-- Contact -->
    <div>
      <h4 class="text-ink font-medium text-sm mb-4">Contact</h4>
      <ul class="space-y-2 text-sm">
        <li>Email: <a href="mailto:hello@silvercare.com" class="footer-link">hello@silvercare.com</a></li>
        <li>Phone: <span class="text-ink-light">+65 6789 1234</span></li>
        <li>Address: <span class="text-ink-light">123 Harmony Ave, Singapore</span></li>
      </ul>
    </div>

  </div>

  <!-- Bottom Bar -->
  <div class="border-t border-stone-mid">
    <div class="max-w-6xl mx-auto px-5 md:px-12 py-6 flex flex-col md:flex-row justify-between items-center text-xs text-ink-muted">
      <p>&copy; 2025 SilverCare. All rights reserved.</p>

      <div class="mt-3 md:mt-0 space-x-4">
        <a href="#" class="footer-link">Privacy Policy</a>
        <a href="#" class="footer-link">Terms</a>
      </div>
    </div>
  </div>

  <style>
    .bg-stone-warm { background-color: #f5f3ef; }
    .border-stone-mid { border-color: #e8e4dc; }
    .text-ink { color: #2c2c2c; }
    .text-ink-light { color: #5a5a5a; }
    .text-ink-muted { color: #8a8a8a; }
    .text-copper { color: #b87a4b; }
    .footer-link {
      color: #5a5a5a;
      transition: color 0.2s ease;
    }
    .footer-link:hover {
      color: #b87a4b;
    }
  </style>
</footer>