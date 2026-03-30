/**
 * CloudFit — auth.js
 * Handles Supabase Auth sign-in / sign-out and UI state transitions.
 */

(() => {
  /* ── DOM refs ──────────────────────────────────────── */
  const authSection      = document.getElementById('auth-section');
  const dashboardSection = document.getElementById('dashboard-section');
  const loginForm        = document.getElementById('login-form');
  const emailInput       = document.getElementById('email-input');
  const passwordInput    = document.getElementById('password-input');
  const loginBtn         = document.getElementById('login-btn');
  const loginError       = document.getElementById('login-error');
  const logoutBtn        = document.getElementById('logout-btn');

  const userNameEl        = document.getElementById('user-name');
  const userRoleEl        = document.getElementById('user-role');
  const userAvatarEl      = document.getElementById('user-avatar');
  const welcomeTitleEl    = document.getElementById('welcome-title');
  const welcomeSubtitleEl = document.getElementById('welcome-subtitle');

  /* ── Exported token (used by chatbot.js) ─────────────────── */
  window.CloudFit = window.CloudFit || {};

  /* ── Auth state observer ──────────────────────────── */
  supabaseClient.auth.onAuthStateChange(async (event, session) => {
    if (session && session.user) {
      const user    = session.user;
      const token   = session.access_token;
      const decoded = parseJwt(token);

      // Role is stored in app_metadata by Supabase
      const role   = user.app_metadata?.role ?? decoded?.role ?? 'CLIENTE';
      const nombre = user.user_metadata?.nombre ?? user.email.split('@')[0];
      const initial = nombre.charAt(0).toUpperCase();

      // Store for chatbot
      window.CloudFit.idToken = token;
      window.CloudFit.role    = role;
      window.CloudFit.nombre  = nombre;

      // Refresh token automatically handled by Supabase SDK
      supabaseClient.auth.onAuthStateChange(async (ev, sess) => {
        if (sess) window.CloudFit.idToken = sess.access_token;
      });

      // Update UI
      userNameEl.textContent   = nombre;
      userRoleEl.textContent   = formatRole(role);
      userAvatarEl.textContent = initial;
      updateWelcomeBanner(nombre, role);

      authSection.style.display      = 'none';
      dashboardSection.style.display = 'flex';

      // Trigger chatbot greeting after 800ms
      setTimeout(() => {
        if (window.CloudFit.chatbot?.greet) {
          window.CloudFit.chatbot.greet(nombre, role);
        }
      }, 800);

    } else {
      window.CloudFit.idToken = null;
      authSection.style.display      = 'flex';
      dashboardSection.style.display = 'none';
    }
  });

  /* ── Login ────────────────────────────────────────── */
  loginForm.addEventListener('submit', async e => {
    e.preventDefault();
    loginError.style.display = 'none';
    loginBtn.disabled        = true;
    loginBtn.textContent     = 'Iniciando...';

    const { error } = await supabaseClient.auth.signInWithPassword({
      email:    emailInput.value.trim(),
      password: passwordInput.value,
    });

    if (error) {
      loginError.textContent   = friendlyAuthError(error.message);
      loginError.style.display = 'block';
      loginBtn.disabled        = false;
      loginBtn.textContent     = 'Iniciar sesión';
    }
  });

  /* ── Logout ───────────────────────────────────────── */
  logoutBtn.addEventListener('click', () => supabaseClient.auth.signOut());

  /* ── Helpers ──────────────────────────────────────── */
  function parseJwt(token) {
    try {
      const base64 = token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
      return JSON.parse(atob(base64));
    } catch { return {}; }
  }

  function formatRole(role) {
    const map = {
      ADMINISTRADOR: 'Administrador',
      COACH:         'Coach',
      NUTRIOLOGO:    'Nutriólogo',
      CLIENTE:       'Cliente',
    };
    return map[role] ?? role;
  }

  function updateWelcomeBanner(nombre, role) {
    const hour   = new Date().getHours();
    const saludo =
      hour < 12 ? 'Buenos días' :
      hour < 19 ? 'Buenas tardes' :
                  'Buenas noches';

    welcomeTitleEl.textContent    = `${saludo}, ${nombre}! 👋`;
    welcomeSubtitleEl.textContent =
      role === 'CLIENTE'    ? 'Tu plan de entrenamiento y nutrición te esperan.' :
      role === 'COACH'       ? 'Revisa a tus clientes y gestiona sus rutinas.' :
      role === 'NUTRIOLOGO'  ? 'Gestiona los planes nutricionales de tus clientes.' :
                               'Bienvenido al panel de administración de CloudFit.';
  }

  function friendlyAuthError(message) {
    if (message.includes('Invalid login credentials')) return 'Correo o contraseña incorrectos.';
    if (message.includes('Email not confirmed'))       return 'Por favor confirma tu correo primero.';
    if (message.includes('Too many requests'))         return 'Demasiados intentos. Intenta en unos minutos.';
    return 'Ocurrió un error. Intenta de nuevo.';
  }
})();
