<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SilverCare</title>
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
            stone: {
              warm: '#f5f3ef',
              mid: '#e8e4dc',
              deep: '#d4cec3',
            },
            ink: {
              DEFAULT: '#2c2c2c',
              light: '#5a5a5a',
              muted: '#8a8a8a',
            },
            copper: {
              DEFAULT: '#b87a4b',
              light: '#d4a574',
            },
            forest: '#3d4f3d',
          }
        }
      }
    }
  </script>
  <style>
    html { scroll-behavior: smooth; }
    body { -webkit-font-smoothing: antialiased; }
    .fade-in { animation: fadeIn 0.8s ease both; }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }
    .stagger-1 { animation-delay: 0.1s; }
    .stagger-2 { animation-delay: 0.2s; }
    .stagger-3 { animation-delay: 0.3s; }
  </style>
</head>

<body class="bg-stone-warm text-ink font-sans font-light">

<%@ include file="includes/header.jsp" %>

<main class="pt-20">

  <section class="px-5 md:px-12 lg:px-20 py-16 md:py-24">
    <div class="max-w-6xl mx-auto">
      <div class="grid lg:grid-cols-2 gap-12 lg:gap-20 items-center">
        
        <div class="order-2 lg:order-1">
          <span class="inline-block text-copper text-xs uppercase tracking-[0.2em] mb-6">Est. 2024</span>
          <h1 class="font-serif text-4xl md:text-5xl lg:text-6xl font-medium text-ink leading-[1.1] mb-8">
            Where care<br>becomes craft
          </h1>
          <p class="text-ink-light text-base md:text-lg leading-relaxed mb-10 max-w-md">
            Thoughtful eldercare rooted in dignity. We bring the warmth of home to every interaction.
          </p>
          <div class="flex flex-wrap gap-4">
            <a href="<%=request.getContextPath()%>/services"
               class="inline-flex items-center gap-2 bg-ink text-white px-6 py-3 text-sm font-normal hover:bg-ink-light transition-colors">
               View Services
               <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
            </a>
            <a href="#about" class="inline-flex items-center gap-2 text-ink text-sm font-normal hover:text-copper transition-colors px-2 py-3">
               Learn more
            </a>
          </div>
        </div>

        <div class="order-1 lg:order-2">
          <div class="relative">
            <div class="aspect-[4/5] overflow-hidden">
              <img src="images/elderlycarehero.png" alt="Care" class="w-full h-full object-cover">
            </div>
            <div class="absolute -bottom-4 -left-4 md:-bottom-6 md:-left-6 bg-copper-light/20 w-24 h-24 md:w-32 md:h-32"></div>
          </div>
        </div>

      </div>
    </div>
  </section>

  <section class="border-t border-stone-mid">
    <div class="grid grid-cols-2 md:grid-cols-4">
      <div class="p-6 md:p-10 border-r border-b md:border-b-0 border-stone-mid">
        <span class="font-serif text-3xl md:text-4xl text-copper">12+</span>
        <p class="text-ink-muted text-sm mt-2">Years of service</p>
      </div>
      <div class="p-6 md:p-10 border-b md:border-b-0 md:border-r border-stone-mid">
        <span class="font-serif text-3xl md:text-4xl text-copper">500</span>
        <p class="text-ink-muted text-sm mt-2">Families supported</p>
      </div>
      <div class="p-6 md:p-10 border-r border-stone-mid">
        <span class="font-serif text-3xl md:text-4xl text-copper">24/7</span>
        <p class="text-ink-muted text-sm mt-2">Care available</p>
      </div>
      <div class="p-6 md:p-10">
        <span class="font-serif text-3xl md:text-4xl text-copper">98%</span>
        <p class="text-ink-muted text-sm mt-2">Satisfaction rate</p>
      </div>
    </div>
  </section>

  <section id="about" class="px-5 md:px-12 lg:px-20 py-20 md:py-28">
    <div class="max-w-6xl mx-auto">
      <div class="grid lg:grid-cols-5 gap-12 lg:gap-16">
        
        <div class="lg:col-span-2">
          <span class="text-copper text-xs uppercase tracking-[0.2em]">Our Philosophy</span>
          <h2 class="font-serif text-3xl md:text-4xl font-medium mt-4 leading-tight">
            Care is not a service. It is a relationship.
          </h2>
        </div>

        <div class="lg:col-span-3 space-y-6 text-ink-light">
          <p class="text-base leading-relaxed">
            We believe that aging should be met with grace, not apprehension. Our approach draws from decades of experience, combining professional expertise with genuine human connection.
          </p>
          <p class="text-base leading-relaxed">
            Every caregiver in our network undergoes rigorous training, but more importantly, they share our conviction that every person deserves attentive, respectful care.
          </p>
          <div class="pt-4 grid grid-cols-1 sm:grid-cols-2 gap-6">
            <div class="border-l-2 border-stone-deep pl-4">
              <span class="text-ink font-medium text-sm">Verified Training</span>
              <p class="text-sm text-ink-muted mt-1">Background checked, certified professionals</p>
            </div>
            <div class="border-l-2 border-stone-deep pl-4">
              <span class="text-ink font-medium text-sm">Personalised Plans</span>
              <p class="text-sm text-ink-muted mt-1">Tailored to individual needs and preferences</p>
            </div>
          </div>
        </div>

      </div>
    </div>
  </section>

  <section id="services" class="bg-white px-5 md:px-12 lg:px-20 py-20 md:py-28">
    <div class="max-w-6xl mx-auto">
      
      <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-6 mb-14">
        <div>
          <span class="text-copper text-xs uppercase tracking-[0.2em]">What We Offer</span>
          <h2 class="font-serif text-3xl md:text-4xl font-medium mt-4">Services</h2>
        </div>
        <a href="<%=request.getContextPath()%>/services" class="text-ink-muted text-sm hover:text-copper transition-colors flex items-center gap-2">
          See all services
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
        </a>
      </div>

      <div id="services-container" class="grid md:grid-cols-2 lg:grid-cols-3 gap-px bg-stone-mid">
        <div class="bg-white p-8 text-ink-muted">Loading...</div>
      </div>

    </div>
  </section>

  <section class="px-5 md:px-12 lg:px-20 py-20 md:py-28 bg-forest text-white">
    <div class="max-w-4xl mx-auto text-center">
      <h2 class="font-serif text-3xl md:text-4xl lg:text-5xl font-medium mb-6">Ready to begin?</h2>
      <p class="text-white/70 text-base md:text-lg mb-10 max-w-xl mx-auto">
        Reach out to discuss how we can support you and your family with care that truly understands.
      </p>
      <a href="<%=request.getContextPath()%>/register"
         class="inline-flex items-center gap-2 bg-white text-forest px-8 py-4 text-sm font-medium hover:bg-stone-warm transition-colors">
         Get Started
         <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
      </a>
    </div>
  </section>

</main>

<%@ include file="includes/footer.jsp" %>

<script>
  var API_BASE_URL = 'http://localhost:8081/api';
  var ctx = '<%=request.getContextPath()%>';

  function escapeHtml(text) {
    if (!text) return '';
    var div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  function getImageSrc(img, ctx) {
    if (!img || img.trim() === '') {
      return ctx + '/images/default-service.png';
    }
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return img;
    }
    var sanitized = img.replace(/[^a-zA-Z0-9\/.\-_]/g, '');
    return ctx + (sanitized.startsWith('/') ? sanitized : '/' + sanitized);
  }

  function loadServices() {
    var container = document.getElementById('services-container');
    var fetchUrl = API_BASE_URL + '/services';
    
    fetch(fetchUrl, {
      method: 'GET',
      mode: 'cors',
      headers: { 'Accept': 'application/json' }
    })
    .then(function(response) {
      if (!response.ok) throw new Error('Failed to fetch');
      return response.json();
    })
    .then(function(services) {
      if (!Array.isArray(services)) throw new Error('Invalid format');
      
      var displayServices = services.slice(0, 3);
      
      if (displayServices.length === 0) {
        container.innerHTML = '<div class="bg-white p-8 text-ink-muted col-span-full">No services available.</div>';
        return;
      }
      
      container.innerHTML = displayServices.map(function(service, i) {
        var imgSrc = getImageSrc(service.imagePath || service.image_path, ctx);
        var serviceName = escapeHtml(service.serviceName || service.service_name || 'Service');
        var description = escapeHtml(service.description || '');
        var price = service.price ? service.price.toFixed(0) : '—';
        
        return '<article class="bg-white p-0 group fade-in stagger-' + (i + 1) + '">' +
            '<div class="aspect-[3/2] overflow-hidden">' +
              '<img src="' + imgSrc + '" alt="' + serviceName + '" class="w-full h-full object-cover grayscale group-hover:grayscale-0 transition-all duration-500" onerror="this.src=\'' + ctx + '/images/default-service.png\'">' +
            '</div>' +
            '<div class="p-6 md:p-8">' +
              '<div class="flex items-start justify-between gap-4 mb-3">' +
                '<h3 class="font-serif text-xl font-medium text-ink">' + serviceName + '</h3>' +
                '<span class="text-copper text-sm whitespace-nowrap">$' + price + '</span>' +
              '</div>' +
              '<p class="text-ink-muted text-sm leading-relaxed line-clamp-2">' + description + '</p>' +
            '</div>' +
          '</article>';
      }).join('');
    })
    .catch(function(error) {
      console.error('Error:', error);
      container.innerHTML = '<div class="bg-white p-8 text-ink-muted col-span-full">Unable to load services.</div>';
    });
  }

  document.addEventListener('DOMContentLoaded', loadServices);
</script>

</body>
</html>