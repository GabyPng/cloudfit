<!-- FAB toggle button -->
<button id="chatbot-toggle" aria-label="Abrir asistente CloudFit" title="Asistente CloudFit" class="fixed bottom-6 right-6 w-14 h-14 bg-gradient-to-r from-blue-600 to-indigo-600 rounded-full shadow-lg hover:shadow-xl hover:-translate-y-1 transition-all flex items-center justify-center text-white z-50">
  <span class="toggle-icon text-2xl">💬</span>
  <span id="fab-badge" class="fab-badge absolute -top-2 -right-2 bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full border-2 border-white" style="display:none">1</span>
</button>

<!-- Chat panel -->
<div id="chatbot-panel" role="dialog" aria-label="Asistente CloudFit" class="fixed bottom-24 right-6 w-[90vw] sm:w-96 bg-white rounded-2xl shadow-2xl border border-gray-100 flex flex-col overflow-hidden z-50 transition-all transform origin-bottom-right" style="display: none; height: 500px; max-height: calc(100vh - 120px);">

  <!-- Header -->
  <div class="chat-header bg-gradient-to-r from-blue-600 to-indigo-600 p-4 text-white flex items-center justify-between shadow-md z-10">
    <div class="flex items-center gap-3">
        <div class="bot-avatar text-2xl bg-white/20 p-2 rounded-full backdrop-blur-sm">🤖</div>
        <div class="bot-info">
            <div class="bot-name font-bold tracking-tight text-sm">CloudFit Assistant</div>
            <div class="bot-status flex items-center gap-1.5 text-xs text-blue-100 font-medium">
                <span class="status-dot w-2 h-2 bg-green-400 rounded-full animate-pulse"></span>
                En línea
            </div>
        </div>
    </div>
    <button id="chat-close" aria-label="Cerrar chatbot" class="text-white/80 hover:text-white hover:bg-white/20 rounded-full p-1.5 transition-colors">✕</button>
  </div>

  <!-- Messages -->
  <div id="chat-messages" role="log" aria-live="polite" class="flex-1 overflow-y-auto p-4 bg-gray-50 flex flex-col gap-3">
    <!-- Typing indicator (inside messages list) -->
    <div id="typing-indicator" aria-label="El asistente está escribiendo" class="hidden self-start bg-white border border-gray-100 rounded-2xl p-3 shadow-sm w-fit mt-1">
      <div class="flex gap-1.5 items-center">
          <div class="typing-dot w-2 h-2 bg-gray-300 rounded-full animate-bounce"></div>
          <div class="typing-dot w-2 h-2 bg-gray-300 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
          <div class="typing-dot w-2 h-2 bg-gray-300 rounded-full animate-bounce" style="animation-delay: 0.4s"></div>
      </div>
    </div>
  </div>

  <!-- Quick replies -->
  <div class="quick-replies flex gap-2 overflow-x-auto p-3 bg-white border-t border-gray-50 hide-scrollbar" id="quick-replies" style="scrollbar-width: thin;">
    <button class="chip whitespace-nowrap px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 text-xs font-semibold rounded-full border border-blue-100 transition-colors shadow-sm" data-msg="ayuda">🗺️ Ayuda</button>
    <button class="chip whitespace-nowrap px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 text-xs font-semibold rounded-full border border-blue-100 transition-colors shadow-sm" data-msg="progreso">📊 Progreso</button>
    <button class="chip whitespace-nowrap px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 text-xs font-semibold rounded-full border border-blue-100 transition-colors shadow-sm" data-msg="rutina">🏋️ Rutina</button>
    <button class="chip whitespace-nowrap px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 text-xs font-semibold rounded-full border border-blue-100 transition-colors shadow-sm" data-msg="nutrición">🥗 Nutrición</button>
    <button class="chip whitespace-nowrap px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 text-xs font-semibold rounded-full border border-blue-100 transition-colors shadow-sm" data-msg="soporte">🎫 Soporte</button>
  </div>

  <!-- Input -->
  <div class="chat-input-area p-3 bg-white border-t border-gray-100 flex items-center gap-2 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)]">
    <input id="chat-input" type="text" placeholder="Escribe un mensaje..." autocomplete="off"
      aria-label="Mensaje al asistente" maxlength="500" class="flex-1 bg-gray-50 border border-gray-200 rounded-full px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all" />
    <button id="chat-send" aria-label="Enviar mensaje" class="w-10 h-10 rounded-full bg-blue-600 hover:bg-blue-700 text-white flex items-center justify-center transition-colors shadow-sm disabled:opacity-50 disabled:cursor-not-allowed">➤</button>
  </div>

</div>
