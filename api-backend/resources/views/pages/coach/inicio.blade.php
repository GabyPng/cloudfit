@extends('layouts.coach')

@section('title', 'Inicio — Coach Dashboard')

@section('content')
<div class="grid grid-cols-12 gap-8">

    {{-- ══════════════════════════════════════════════
         KPIs
    ══════════════════════════════════════════════ --}}
    <section class="col-span-12 grid grid-cols-1 md:grid-cols-4 gap-6">

        {{-- Total Atletas --}}
        <div class="bg-surface-container rounded-xl p-6 relative overflow-hidden group">
            <div class="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                <span class="material-symbols-outlined text-6xl">groups</span>
            </div>
            <p class="text-on-surface-variant text-xs font-label uppercase tracking-widest mb-2">Total Atletas</p>
            <h3 class="text-4xl font-headline font-black text-primary-fixed">{{ $totalAtletas }}</h3>
            <div class="mt-4 flex items-center gap-2 text-[10px] text-primary">
                <span class="material-symbols-outlined text-xs">trending_up</span>
                <span>+{{ $nuevosEsteMes ?? 0 }} este mes</span>
            </div>
        </div>

        {{-- Cumplimiento Diario --}}
        <div class="bg-surface-container rounded-xl p-6 relative overflow-hidden group">
            <div class="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity text-secondary">
                <span class="material-symbols-outlined text-6xl">check_circle</span>
            </div>
            <p class="text-on-surface-variant text-xs font-label uppercase tracking-widest mb-2">Cumplimiento Diario</p>
            <h3 class="text-4xl font-headline font-black text-secondary">{{ $porcentajeCumplimiento }}%</h3>
            <div class="mt-4 w-full bg-surface-container-highest h-1 rounded-full overflow-hidden">
                <div class="bg-secondary h-full transition-all duration-500" style="width: {{ $porcentajeCumplimiento }}%"></div>
            </div>
        </div>

        {{-- Alertas Inactividad --}}
        <div class="bg-surface-container rounded-xl p-6 relative overflow-hidden group">
            <div class="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity text-error">
                <span class="material-symbols-outlined text-6xl">warning</span>
            </div>
            <p class="text-on-surface-variant text-xs font-label uppercase tracking-widest mb-2">Alertas Inactividad</p>
            <h3 class="text-4xl font-headline font-black text-error">{{ $alertasInactividad ?? 0 }}</h3>
            @if(($alertasInactividad ?? 0) > 0)
                <p class="text-[10px] text-error-dim mt-4 uppercase font-bold">Requiere acción inmediata</p>
            @endif
        </div>

        {{-- Planes Activos --}}
        <div class="bg-surface-container rounded-xl p-6 relative overflow-hidden group">
            <div class="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity text-primary">
                <span class="material-symbols-outlined text-6xl">article</span>
            </div>
            <p class="text-on-surface-variant text-xs font-label uppercase tracking-widest mb-2">Planes Activos</p>
            <h3 class="text-4xl font-headline font-black text-primary-fixed">{{ $planesActivos ?? 0 }}</h3>
            <div class="mt-4 flex items-center gap-2 text-[10px] text-on-surface-variant">
                <span class="material-symbols-outlined text-xs">schedule</span>
                <span>Actualizado hace 1h</span>
            </div>
        </div>

    </section>

    {{-- ══════════════════════════════════════════════
         Tabla: Monitoreo de Clientes
    ══════════════════════════════════════════════ --}}
    <section class="col-span-12 lg:col-span-8 bg-surface-container rounded-xl overflow-hidden flex flex-col">
        <div class="p-6 flex justify-between items-center border-b border-outline-variant/10">
            <h2 class="text-xl font-headline font-bold">Monitoreo de Clientes</h2>
            <div class="flex gap-2">
                <button class="p-2 bg-surface-container-highest rounded-lg text-on-surface-variant hover:text-primary transition-colors">
                    <span class="material-symbols-outlined text-sm">filter_list</span>
                </button>
                <button class="p-2 bg-surface-container-highest rounded-lg text-on-surface-variant hover:text-primary transition-colors">
                    <span class="material-symbols-outlined text-sm">download</span>
                </button>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left">
                <thead class="bg-surface-container-low">
                    <tr>
                        <th class="px-6 py-4 text-[10px] font-label uppercase tracking-widest text-on-surface-variant">Cliente</th>
                        <th class="px-6 py-4 text-[10px] font-label uppercase tracking-widest text-on-surface-variant">Plan Actual</th>
                        <th class="px-6 py-4 text-[10px] font-label uppercase tracking-widest text-on-surface-variant">Estado Hoy</th>
                        <th class="px-6 py-4 text-[10px] font-label uppercase tracking-widest text-on-surface-variant">Última Métrica</th>
                        <th class="px-6 py-4 text-[10px] font-label uppercase tracking-widest text-on-surface-variant text-right">Acciones</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-outline-variant/5">
                    @foreach ($clientes as $cliente)
                        @php
                            $esInactivo = $cliente->estado === 'inactivo';
                        @endphp
                        <tr class="hover:bg-surface-container-high transition-colors group">
                            {{-- Cliente --}}
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <img src="{{ $cliente->avatar ?? 'https://ui-avatars.com/api/?name=' . urlencode($cliente->nombre) . '&background=1a1a1a&color=ffffff' }}"
                                         alt="{{ $cliente->nombre }}"
                                         class="w-8 h-8 rounded-full object-cover {{ $esInactivo ? 'grayscale opacity-60' : '' }}" />
                                    <span class="text-sm font-medium {{ $esInactivo ? 'text-on-surface-variant' : '' }}">{{ $cliente->nombre }}</span>
                                </div>
                            </td>

                            {{-- Plan --}}
                            <td class="px-6 py-4">
                                @if ($esInactivo)
                                    <span class="px-3 py-1 bg-surface-container-highest text-on-surface-variant rounded-full text-[10px] font-bold uppercase tracking-tight">
                                        {{ $cliente->plan_nombre }}
                                    </span>
                                @else
                                    <span class="px-3 py-1 bg-secondary-container text-on-secondary-container rounded-full text-[10px] font-bold uppercase tracking-tight">
                                        {{ $cliente->plan_nombre }}
                                    </span>
                                @endif
                            </td>

                            {{-- Estado --}}
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-2">
                                    @if ($esInactivo)
                                        <span class="w-2 h-2 bg-error rounded-full"></span>
                                        <span class="text-xs text-error">{{ $cliente->estado_label ?? 'Inactivo' }}</span>
                                    @else
                                        <span class="w-2 h-2 bg-primary-fixed rounded-full shadow-[0_0_8px_#cafd00]"></span>
                                        <span class="text-xs text-on-surface-variant">{{ $cliente->estado_label ?? 'Entrenado' }}</span>
                                    @endif
                                </div>
                            </td>

                            {{-- Última Métrica --}}
                            <td class="px-6 py-4">
                                <div class="flex flex-col">
                                    <span class="text-sm font-headline {{ $esInactivo ? 'text-on-surface-variant' : '' }}">{{ $cliente->peso }} kg</span>
                                    <span class="text-[10px] text-on-surface-variant">Grasa: {{ $cliente->grasa }}%</span>
                                </div>
                            </td>

                            {{-- Acciones --}}
                            <td class="px-6 py-4 text-right">
                                <div class="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button class="text-[10px] font-bold uppercase bg-surface-container-highest px-3 py-1.5 rounded hover:text-primary transition-colors">Rutina</button>
                                    <button class="text-[10px] font-bold uppercase bg-surface-container-highest px-3 py-1.5 rounded hover:text-secondary transition-colors">Evolución</button>
                                </div>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        {{-- Paginación --}}
        <div class="mt-auto p-6 flex justify-between items-center text-[10px] text-on-surface-variant font-label uppercase tracking-widest border-t border-outline-variant/10">
            <span>Mostrando {{ $clientes->count() }} de {{ $totalAtletas }} clientes</span>
            @if ($clientes instanceof \Illuminate\Pagination\LengthAwarePaginator)
                <div class="flex gap-4">
                    @if ($clientes->onFirstPage())
                        <span class="opacity-40">Anterior</span>
                    @else
                        <a href="{{ $clientes->previousPageUrl() }}" class="hover:text-primary transition-colors">Anterior</a>
                    @endif

                    @if ($clientes->hasMorePages())
                        <a href="{{ $clientes->nextPageUrl() }}" class="text-primary font-bold">Siguiente</a>
                    @else
                        <span class="opacity-40">Siguiente</span>
                    @endif
                </div>
            @endif
        </div>
    </section>

    {{-- ══════════════════════════════════════════════
         Panel lateral: Actividad Reciente
    ══════════════════════════════════════════════ --}}
    <section class="col-span-12 lg:col-span-4 flex flex-col gap-6">

        {{-- Activity Feed --}}
        <div class="bg-surface-container rounded-xl p-6 flex flex-col h-full">
            <div class="flex items-center justify-between mb-8">
                <h2 class="text-xl font-headline font-bold">Actividad Reciente</h2>
                <span class="material-symbols-outlined text-on-surface-variant">history</span>
            </div>

            <div class="space-y-8 relative">
                {{-- Vertical timeline line --}}
                <div class="absolute left-3.5 top-2 bottom-2 w-0.5 bg-outline-variant/20"></div>

                @foreach ($actividades as $actividad)
                    @php
                        $iconMap = [
                            'rutina_completada' => ['icon' => 'task_alt',       'bg' => 'bg-primary-container',    'text' => 'text-on-primary-container', 'glow' => 'shadow-[0_0_12px_rgba(202,253,0,0.3)]', 'fill' => true,  'nameClass' => 'text-primary-fixed'],
                            'peso_registrado'   => ['icon' => 'monitor_weight', 'bg' => 'bg-secondary-container',  'text' => 'text-on-secondary-container', 'glow' => '', 'fill' => true,  'nameClass' => 'text-secondary'],
                            'record_personal'   => ['icon' => 'star',           'bg' => 'bg-tertiary-container',   'text' => 'text-on-tertiary-container',  'glow' => '', 'fill' => true,  'nameClass' => 'text-tertiary'],
                            'nuevo_cliente'     => ['icon' => 'person_add',     'bg' => 'bg-surface-container-highest', 'text' => 'text-on-surface-variant', 'glow' => '', 'fill' => false, 'nameClass' => 'text-on-surface'],
                        ];
                        $style = $iconMap[$actividad->tipo] ?? $iconMap['nuevo_cliente'];
                    @endphp

                    <div class="relative pl-10 {{ $actividad->tipo === 'nuevo_cliente' ? 'opacity-60' : '' }}">
                        <div class="absolute left-0 top-1 w-7 h-7 {{ $style['bg'] }} rounded-full flex items-center justify-center {{ $style['text'] }} {{ $style['glow'] }}">
                            <span class="material-symbols-outlined text-sm"
                                  @if($style['fill']) style="font-variation-settings: 'FILL' 1;" @endif>{{ $style['icon'] }}</span>
                        </div>
                        <div class="flex flex-col">
                            <p class="text-sm font-medium">
                                <span class="{{ $style['nameClass'] }}">{{ $actividad->cliente_nombre }}</span>
                                {{ $actividad->detalle }}
                            </p>
                            <span class="text-[10px] text-on-surface-variant uppercase tracking-wider mt-1">{{ $actividad->tiempo_hace }}</span>
                        </div>
                    </div>
                @endforeach
            </div>

            <button class="mt-auto w-full py-3 bg-surface-container-highest rounded-lg text-xs font-bold uppercase tracking-widest hover:bg-primary-container hover:text-on-primary-container transition-all">
                Ver todo el historial
            </button>
        </div>

        {{-- AI Insights Card --}}
        <div class="bg-gradient-to-br from-secondary-container to-surface-container rounded-xl p-6 relative overflow-hidden group">
            <div class="absolute -right-8 -bottom-8 w-32 h-32 bg-secondary/10 rounded-full blur-3xl group-hover:scale-150 transition-transform duration-700"></div>
            <h4 class="text-sm font-headline font-bold text-secondary-fixed mb-2">CloudFit AI Insights</h4>
            <p class="text-xs text-on-secondary-container leading-relaxed">
                Detectamos una baja en el rendimiento cardiovascular de uno de tus atletas. ¿Quieres enviar un mensaje de motivación?
            </p>
            <button class="mt-4 text-[10px] font-bold uppercase py-2 px-4 bg-on-secondary-container text-secondary-container rounded group-hover:translate-x-1 transition-transform">
                Redactar mensaje
            </button>
        </div>

    </section>
</div>
@endsection
