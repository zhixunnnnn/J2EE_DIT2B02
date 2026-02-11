<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login – SilverCare</title>

<%
String errText = "";
String errCode = request.getParameter("errCode");

if (errCode != null) {
    switch(errCode){
        case "invalidLogin":
            errText = "Invalid email or password.";
            break;
        case "NoSession":
            errText = "Please log in first.";
            break;
        case "UserNotFound":
            errText = "Account not found.";
            break;
        default:
            errText = "Login failed. Please try again.";
    }
}


HttpSession loginSession = request.getSession(false);
if (loginSession != null && loginSession.getAttribute("sessRole") != null) {
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
      }
    }
  }
}
</script>
<style>
html { scroll-behavior: smooth; }
body { -webkit-font-smoothing: antialiased; }

/* Loading screen */
.loader {
  position: fixed;
  inset: 0;
  background: #f5f3ef;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  transition: opacity 0.5s ease, visibility 0.5s ease;
}
.loader.hidden {
  opacity: 0;
  visibility: hidden;
}
.loader-content {
  text-align: center;
}
.loader-bar {
  width: 120px;
  height: 2px;
  background: #e8e4dc;
  margin: 0 auto;
  overflow: hidden;
}
.loader-bar::after {
  content: '';
  display: block;
  width: 40%;
  height: 100%;
  background: #2c2c2c;
  animation: loadingBar 1s ease-in-out infinite;
}
@keyframes loadingBar {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(350%); }
}

/* Page content transitions */
.page-content {
  opacity: 0;
  transition: opacity 0.6s ease;
}
.page-content.visible {
  opacity: 1;
}

/* Staggered fade-in animations */
.stagger-1 { animation: fadeSlideIn 0.6s ease 0.1s both; }
.stagger-2 { animation: fadeSlideIn 0.6s ease 0.2s both; }
.stagger-3 { animation: fadeSlideIn 0.6s ease 0.3s both; }
.stagger-4 { animation: fadeSlideIn 0.6s ease 0.4s both; }

@keyframes fadeSlideIn {
  from { opacity: 0; transform: translateY(16px); }
  to { opacity: 1; transform: translateY(0); }
}

.fade-in { animation: fadeIn 0.6s ease both; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
</style>
</head>

<body class="bg-stone-warm text-ink font-sans font-light min-h-screen">
	<!-- Loading Screen -->
	<div class="loader" id="loader">
		<div class="loader-content">
			<p class="font-serif text-2xl text-ink mb-6">SilverCare</p>
			<div class="loader-bar"></div>
		</div>
	</div>

	<div class="page-content" id="pageContent">
	<%@ include file="../includes/header.jsp"%>

	<main class="pt-24 pb-20 px-5 md:px-12">
		<div class="max-w-5xl mx-auto">
			<div class="grid lg:grid-cols-2 gap-16 lg:gap-24 items-start">

				<section class="hidden lg:block pt-8">
					<span class="text-copper text-xs uppercase tracking-[0.2em] stagger-1">Welcome back</span>
					<h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-4 mb-6 stagger-2">
						Continue where<br>you left off
					</h1>
					<p class="text-ink-light text-base leading-relaxed max-w-sm mb-8 stagger-3">
						Access your bookings, manage appointments, and stay connected with your family's care journey.
					</p>
					<div class="border-l-2 border-stone-deep pl-4 stagger-4">
						<p class="text-ink-muted text-sm">
							New to SilverCare?
						</p>
						<a href="<%=request.getContextPath()%>/register" 
						   class="text-copper text-sm hover:underline">
							Create an account
						</a>
					</div>
				</section>

				<section class="fade-in">
					<div class="bg-white border border-stone-mid p-8 md:p-10">
						
						<div class="mb-8">
							<h2 class="font-serif text-2xl font-medium text-ink mb-2">Sign in</h2>
							<p class="text-ink-muted text-sm">Enter your credentials to continue</p>
						</div>

						<form method="post"
    						action="<%=request.getContextPath()%>/customersServlet"
   							class="space-y-5">

							<input type="hidden" name="action" value="login">

							<div>
								<label for="email" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
									Email
								</label>
								<input type="text" id="email" name="email"
									autocomplete="email"
									class="w-full border border-stone-mid bg-stone-warm
									       px-4 py-3 text-sm text-ink
									       placeholder:text-ink-muted
									       outline-none
									       focus:border-ink
									       transition-colors duration-200"
									placeholder="you@example.com">
							</div>

							<div>
								<label for="password" class="block text-xs uppercase tracking-wide text-ink-muted mb-2">
									Password
								</label>
								<input type="password" id="password" name="password"
									autocomplete="current-password"
									class="w-full border border-stone-mid bg-stone-warm
									       px-4 py-3 text-sm text-ink
									       placeholder:text-ink-muted
									       outline-none
									       focus:border-ink
									       transition-colors duration-200"
									placeholder="Enter your password">
							</div>

							<%
							if (errText != null && !errText.trim().isEmpty()) {
							%>
							<p class="text-sm text-red-600 bg-red-50 border border-red-200 px-4 py-2">
								<%=errText%>
							</p>
							<%
							}
							%>

							<div class="pt-2">
								<button type="submit" name="btnSubmit" value="login"
									class="w-full bg-ink text-stone-warm
									       text-sm font-normal
									       px-6 py-3
									       hover:bg-ink-light
									       transition-colors duration-200">
									Continue
								</button>
							</div>
						</form>

						<div class="mt-8 pt-6 border-t border-stone-mid text-center lg:hidden">
							<p class="text-ink-muted text-sm">
								Don't have an account?
								<a href="<%=request.getContextPath()%>/register"
								   class="text-copper hover:underline ml-1">
									Register
								</a>
							</p>
						</div>
					</div>
				</section>
			</div>
		</div>
	</main>

	<%@ include file="../includes/footer.jsp"%>
	</div>

	<script>
		window.addEventListener('load', function() {
			setTimeout(function() {
				document.getElementById('loader').classList.add('hidden');
				document.getElementById('pageContent').classList.add('visible');
			}, 600);
		});
	</script>
</body>
</html>