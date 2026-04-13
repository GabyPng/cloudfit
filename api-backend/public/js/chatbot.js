/**
 * CloudFit — chatbot.js
 * Handles the chatbot FAB, panel toggle, messaging, and API calls.
 */

(() => {
  /* ── DOM refs ──────────────────────────────────────── */
  const toggle       = document.getElementById('chatbot-toggle');
  const panel        = document.getElementById('chatbot-panel');
  const closeBtn     = document.getElementById('chat-close');
  const messages     = document.getElementById('chat-messages');
  const input        = document.getElementById('chat-input');
  const sendBtn      = document.getElementById('chat-send');
  const typing       = document.getElementById('typing-indicator');
  const fabBadge     = document.getElementById('fab-badge');
  const quickReplies = document.getElementById('quick-replies');

  /* ── State ────────────────────────────────────────── */
  let isOpen       = false;
  let unread       = 0;
  let hasGreeted   = false;

  /* ── Register with global scope for auth.js ─────── */
  window.CloudFit = window.CloudFit || {};
  window.CloudFit.chatbot = { greet };

  /* ── Auto-greet as guest on page load ───────────── */
  setTimeout(() => {
    if (!hasGreeted) {
      hasGreeted = true;
      appendBotMessage('👋 ¡Hola! Soy el asistente de *CloudFit*. Estoy en *modo demo* (sin sesión).\n\nEscribe *ayuda* para ver qué puedo hacer, o inicia sesión para acceder a tus datos reales.');
      showBadge();
    }
  }, 600);

  /* ── Panel toggle ────────────────────────────────── */
  toggle.addEventListener('click', () => {
    isOpen ? closePanel() : openPanel();
  });

  closeBtn.addEventListener('click', closePanel);

  function openPanel() {
    isOpen = true;
    panel.classList.add('open');
    toggle.querySelector('.toggle-icon').textContent = '✕';
    clearBadge();
    input.focus();
  }

  function closePanel() {
    isOpen = false;
    panel.classList.remove('open');
    toggle.querySelector('.toggle-icon').textContent = '💬';
  }

  /* ── Greet function (called by auth.js) ──────────── */
  function greet(nombre, role) {
    if (hasGreeted) return;
    hasGreeted = true;

    const greetings = {
      CLIENTE:       `¡Hola, ${nombre}! 💪 Soy tu asistente CloudFit.\n\nPuedo ayudarte con tu *progreso*, *rutina*, *plan nutricional* o *soporte*. ¿En qué empezamos?`,
      COACH:         `¡Hola, Coach ${nombre}! 🏋️ Estoy aquí para ayudarte.\n\nPuedes preguntarme sobre tus *clientes*, *rutinas* o necesitas *soporte*.`,
      NUTRIOLOGO:    `¡Hola, ${nombre}! 🥗 Soy tu asistente de CloudFit.\n\nPregúntame sobre tus *clientes* o los *planes nutricionales*.`,
      ADMINISTRADOR: `¡Hola, Admin ${nombre}! ⚡ Bienvenido al panel de control.\n\n¿En qué puedo ayudarte hoy?`,
    };

    const text = greetings[role] ?? `¡Hola, ${nombre}! 👋 Soy el asistente de CloudFit. Escribe *ayuda* para ver lo que puedo hacer.`;

    appendBotMessage(text);
    showBadge();

    // Carga botones de intents cuando hay sesión activa.
    loadIntentButtons();
  }

  /* ── Send message ────────────────────────────────── */
  sendBtn.addEventListener('click', sendMessage);

  input.addEventListener('keydown', e => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  });

  async function sendMessage(explicit = null) {
    const text = explicit?.text ?? input.value.trim();
    const intent = explicit?.intent ?? null;
    const userLabel = explicit?.label ?? text;
    if (!text || sendBtn.disabled) return;

    input.value      = '';
    sendBtn.disabled = true;

    appendUserMessage(userLabel);
    showTyping();

    try {
      const idToken = window.CloudFit?.idToken;

      // ── Sin sesión: respuestas locales (modo demo) ──
      if (!idToken) {
        await sleep(700);
        hideTyping();
        appendBotMessage(localReply(text));
        sendBtn.disabled = false;
        input.focus();
        return;
      }

      const res = await fetch(`${API_BASE}/chatbot/message`, {
        method: 'POST',
        headers: {
          'Content-Type':  'application/json',
          'Authorization': `Bearer ${idToken}`,
          'Accept':        'application/json',
        },
        body: JSON.stringify(intent ? { intent, message: text } : { message: text }),
      });

      const data = await res.json();

      hideTyping();

      if (!res.ok) {
        const errMsg = data.message ?? 'Ocurrió un error inesperado.';
        appendBotMessage(`⚠️ ${errMsg}`);
      } else {
        appendBotMessage(data.reply ?? '...', data.role);
        renderIntentButtons(data.buttons);
      }
    } catch (err) {
      hideTyping();
      appendBotMessage('🔌 No se pudo conectar con el servidor. Verifica que el backend esté corriendo en `localhost:8000`.');
    }

    sendBtn.disabled = false;
    input.focus();
  }

  /* ── Quick reply chips ───────────────────────────── */
  quickReplies?.addEventListener('click', e => {
    const chip = e.target.closest('.chip');
    if (!chip) return;

    const intent = chip.dataset.intent;
    const text = chip.dataset.msg;
    const label = chip.textContent?.trim() || text;

    if (intent) {
      sendMessage({ text: text || label, intent, label });
      return;
    }

    input.value = text || label;
    sendMessage();
  });

  async function loadIntentButtons() {
    const idToken = window.CloudFit?.idToken;
    if (!idToken) return;

    try {
      const res = await fetch(`${API_BASE}/chatbot/buttons`, {
        headers: {
          'Authorization': `Bearer ${idToken}`,
          'Accept': 'application/json',
        },
      });

      if (!res.ok) return;
      const data = await res.json();
      renderIntentButtons(data.buttons);
    } catch (_) {
      // Silencioso: si falla, se mantienen los chips por defecto.
    }
  }

  function renderIntentButtons(buttons) {
    if (!quickReplies || !Array.isArray(buttons) || buttons.length === 0) return;

    quickReplies.innerHTML = '';

    buttons.forEach(btn => {
      const el = document.createElement('button');
      el.className = 'chip whitespace-nowrap px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 text-xs font-semibold rounded-full border border-blue-100 transition-colors shadow-sm';
      el.dataset.intent = btn.intent;
      el.dataset.msg = btn.label;
      el.textContent = btn.label;
      quickReplies.appendChild(el);
    });
  }

  /* ── Message renderers ───────────────────────────── */
  function appendUserMessage(text) {
    const wrap   = document.createElement('div');
    wrap.className = 'msg user';

    const bubble = document.createElement('div');
    bubble.className  = 'msg-bubble';
    bubble.textContent = text;

    const time   = document.createElement('div');
    time.className    = 'msg-time';
    time.textContent  = timeNow();

    wrap.append(bubble, time);
    messages.appendChild(wrap);
    scrollBottom();
  }

  function appendBotMessage(text) {
    const wrap   = document.createElement('div');
    wrap.className = 'msg bot';

    const bubble = document.createElement('div');
    bubble.className  = 'msg-bubble';
    // Render *bold* markdown
    bubble.innerHTML = markdownLite(text);

    const time   = document.createElement('div');
    time.className    = 'msg-time';
    time.textContent  = timeNow();

    wrap.append(bubble, time);
    messages.appendChild(wrap);
    scrollBottom();

    if (!isOpen) showBadge();
  }

  /* ── Typing indicator ────────────────────────────── */
  function showTyping() {
    typing.classList.add('show');
    scrollBottom();
  }

  function hideTyping() {
    typing.classList.remove('show');
  }

  /* ── Badge ───────────────────────────────────────── */
  function showBadge() {
    if (isOpen) return;
    unread++;
    fabBadge.textContent  = unread;
    fabBadge.style.display = 'flex';
  }

  function clearBadge() {
    unread = 0;
    fabBadge.style.display = 'none';
  }

  /* ── Utils ───────────────────────────────────────── */
  function scrollBottom() {
    setTimeout(() => { messages.scrollTop = messages.scrollHeight; }, 50);
  }

  function timeNow() {
    return new Date().toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' });
  }

  /**
   * Minimal markdown: *text* → <b>text</b>, \n → <br>
   */
  function markdownLite(text) {
    return text
      .replace(/&/g,  '&amp;')
      .replace(/</g,  '&lt;')
      .replace(/>/g,  '&gt;')
      .replace(/\*(.*?)\*/g, '<b>$1</b>')
      .replace(/\n/g, '<br>');
  }

  function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

  /* ── Local (demo) replies ─────────────────────────
     Used when no Firebase session is active.
     These mirror the backend intents so the UI feels
     fully functional without a token.
  ─────────────────────────────────────────────────── */
  function localReply(msg) {
    const m = msg.toLowerCase();

    if (/hola|hi|hey|buenas|saludos/.test(m))
      return '👋 ¡Hola! Estás en *modo demo*. Inicia sesión para ver tus datos reales.\n\nPor ahora puedo explicarte cómo funciona CloudFit. Escribe *ayuda* para ver las opciones.';

    if (/ayuda|help|opci|men[uú]|comando/.test(m))
      return '🗺️ *Comandos disponibles* (modo demo):\n\n• *progreso* — explica el registro de progreso\n• *rutina* — explica los planes de entrenamiento\n• *nutrici* — explica los planes nutricionales\n• *soporte* — cómo abrir un ticket\n• *login* — cómo iniciar sesión\n\nInicia sesión para acceder a tus datos reales. 🔑';

    if (/progreso|peso|imc|avance/.test(m))
      return '📊 *Progreso* (demo):\n\nEn CloudFit registras tu peso e IMC periódicamente. Tu coach o tú pueden cargar nuevos registros desde el panel.\n\n🔑 Inicia sesión para ver tu historial real.';

    if (/rutina|entrenamiento|ejercicio|workout|gym/.test(m))
      return '🏋️ *Rutinas* (demo):\n\nTu coach crea rutinas personalizadas con ejercicios, series y repeticiones. Puedes consultarlas en tu panel.\n\n🔑 Inicia sesión para ver tu rutina actual.';

    if (/nutri|dieta|alimenta|comida|calor/.test(m))
      return '🥗 *Plan nutricional* (demo):\n\nTu nutriólogo diseña tu plan de alimentación con objetivos y guías específicas para ti.\n\n🔑 Inicia sesión para ver tu plan actual.';

    if (/ticket|soporte|problema|error/.test(m))
      return '🎫 *Soporte* (demo):\n\nPara abrir un ticket de soporte, inicia sesión y ve a la sección *Soporte* en tu panel. El equipo de CloudFit te atenderá.';

    if (/login|sesión|sesion|inicia|entrar|acceder/.test(m))
      return '🔑 Para iniciar sesión:\n\n1. Cierra este chat\n2. Escribe tu correo y contraseña en el formulario\n3. Haz clic en *Iniciar sesión*\n\n¿Aún no tienes cuenta? Contacta al administrador de CloudFit.';

    if (/adi[oó]s|bye|hasta|chao|chau/.test(m))
      return '👋 ¡Hasta pronto! Recuerda iniciar sesión para aprovechar todas las funciones de CloudFit. 💪';

    return '🤔 Estás en *modo demo*. No tengo acceso a datos reales sin sesión.\n\nEscribe *ayuda* para ver los temas disponibles, o inicia sesión para usar el asistente completo. 🔑';
  }
})();
