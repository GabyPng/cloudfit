@extends('layouts.app')

@section('title', 'Dashboard - CloudFit')

@section('content')
<section id="dashboard-section" class="page-wrap flex flex-col items-center w-full mt-4" style="display:none;">

    <!-- Welcome banner -->
    <div class="welcome-banner w-full max-w-4xl bg-gradient-to-r from-blue-600 to-indigo-700 rounded-2xl p-8 mb-8 text-white shadow-xl flex items-center gap-6 transform transition-all hover:scale-[1.02] duration-300">
        <span class="emoji text-6xl bg-white/20 p-4 rounded-full backdrop-blur-sm shadow-inner">🚀</span>
        <div>
            <h1 class="welcome-title text-3xl font-bold tracking-tight mb-2 drop-shadow-sm" id="welcome-title">Bienvenido</h1>
            <p class="welcome-subtitle text-blue-100 font-medium text-lg opacity-90" id="welcome-subtitle">Cargando información...</p>
        </div>
    </div>

    <!-- Stats Grid -->
    <div class="dashboard-grid grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 w-full max-w-5xl">
        <div class="stat-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-lg hover:-translate-y-1 transition-all duration-300 flex flex-col items-start gap-4 cursor-pointer group">
            <div class="stat-icon text-4xl bg-orange-50 p-4 rounded-xl group-hover:bg-orange-100 transition-colors shadow-inner">💪</div>
            <div>
                <div class="stat-label text-sm text-gray-500 font-semibold mb-1 uppercase tracking-wide">Entrenamiento</div>
                <div class="stat-value text-xl font-bold text-gray-800">Ver plan</div>
            </div>
        </div>
        <div class="stat-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-lg hover:-translate-y-1 transition-all duration-300 flex flex-col items-start gap-4 cursor-pointer group">
            <div class="stat-icon text-4xl bg-green-50 p-4 rounded-xl group-hover:bg-green-100 transition-colors shadow-inner">🥗</div>
            <div>
                <div class="stat-label text-sm text-gray-500 font-semibold mb-1 uppercase tracking-wide">Nutrición</div>
                <div class="stat-value text-xl font-bold text-gray-800">Ver plan</div>
            </div>
        </div>
        <div class="stat-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-lg hover:-translate-y-1 transition-all duration-300 flex flex-col items-start gap-4 cursor-pointer group">
            <div class="stat-icon text-4xl bg-blue-50 p-4 rounded-xl group-hover:bg-blue-100 transition-colors shadow-inner">📊</div>
            <div>
                <div class="stat-label text-sm text-gray-500 font-semibold mb-1 uppercase tracking-wide">Progreso</div>
                <div class="stat-value text-xl font-bold text-gray-800">Ver historial</div>
            </div>
        </div>
        <div class="stat-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-lg hover:-translate-y-1 transition-all duration-300 flex flex-col items-start gap-4 cursor-pointer group">
            <div class="stat-icon text-4xl bg-purple-50 p-4 rounded-xl group-hover:bg-purple-100 transition-colors shadow-inner">🎫</div>
            <div>
                <div class="stat-label text-sm text-gray-500 font-semibold mb-1 uppercase tracking-wide">Soporte</div>
                <div class="stat-value text-xl font-bold text-gray-800">Tickets</div>
            </div>
        </div>
    </div>

</section>
@endsection
