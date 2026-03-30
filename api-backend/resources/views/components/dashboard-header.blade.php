<header class="dashboard-header sticky top-0 z-40 bg-white/80 backdrop-blur-lg border-b border-gray-200 px-6 py-4 flex items-center justify-between shadow-sm w-full mx-auto max-w-7xl rounded-b-xl">
  <div class="brand flex items-center gap-3">
    <div class="brand-badge text-2xl hover:animate-spin cursor-default">🏋️</div>
    <span class="brand-name font-black tracking-tighter text-transparent bg-clip-text bg-gradient-to-r from-blue-700 to-indigo-600 text-3xl">CloudFit</span>
  </div>

  <div class="user-info flex items-center gap-6">
    <div class="flex items-center gap-3 bg-gray-50 px-3 py-1.5 rounded-full border border-gray-100 shadow-inner">
        <div class="user-avatar w-10 h-10 rounded-full bg-gradient-to-tr from-blue-500 to-indigo-500 flex items-center justify-center text-white font-bold text-lg shadow-sm" id="user-avatar">U</div>
        <div class="user-meta hidden sm:flex flex-col pr-2">
            <span class="user-name font-bold text-gray-800 leading-tight text-sm" id="user-name">Usuario</span>
            <span class="user-role text-[10px] font-bold tracking-wider text-blue-600 uppercase mt-0.5" id="user-role">—</span>
        </div>
    </div>
    <div class="h-8 w-px bg-gray-200 hidden sm:block"></div>
    <button id="logout-btn" class="btn-logout group flex items-center gap-2 px-4 py-2 rounded-xl border border-red-100 hover:bg-red-50 text-sm font-semibold text-red-600 transition-all duration-300 shadow-sm hover:shadow">
      <span class="group-hover:-translate-x-1 transition-transform">⎋</span> Salir
    </button>
  </div>
</header>
