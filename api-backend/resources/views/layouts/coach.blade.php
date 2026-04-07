<!DOCTYPE html>
<html class="dark" lang="es">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>@yield('title', 'CloudFit — Coach Dashboard')</title>

    {{-- Fonts --}}
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet" />

    {{-- Tailwind --}}
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary-fixed":          "#cafd00",
                        "on-secondary":           "#280067",
                        "tertiary":               "#ffeea5",
                        "secondary-dim":          "#8455ef",
                        "error-container":        "#b92902",
                        "tertiary-fixed":         "#fce047",
                        "secondary":              "#ac8aff",
                        "primary-container":      "#cafd00",
                        "surface-container":      "#1a1a1a",
                        "on-tertiary-container":  "#5d5000",
                        "surface-container-lowest":"#000000",
                        "on-secondary-fixed":     "#40009b",
                        "on-background":          "#ffffff",
                        "on-error":               "#450900",
                        "on-surface-variant":     "#adaaaa",
                        "primary-dim":            "#beee00",
                        "inverse-on-surface":     "#565555",
                        "background":             "#0e0e0e",
                        "surface-dim":            "#0e0e0e",
                        "error-dim":              "#d53d18",
                        "tertiary-fixed-dim":     "#edd13a",
                        "on-tertiary-fixed":      "#483d00",
                        "surface-container-high":  "#20201f",
                        "surface-bright":         "#2c2c2c",
                        "tertiary-container":     "#fce047",
                        "inverse-primary":        "#516700",
                        "on-tertiary":            "#665800",
                        "surface-container-highest":"#262626",
                        "primary-fixed-dim":      "#beee00",
                        "on-error-container":     "#ffd2c8",
                        "secondary-fixed-dim":    "#ceb9ff",
                        "secondary-container":    "#5516be",
                        "error":                  "#ff7351",
                        "on-surface":             "#ffffff",
                        "on-primary-container":   "#4a5e00",
                        "surface":                "#0e0e0e",
                        "on-primary-fixed":       "#3a4a00",
                        "on-tertiary-fixed-variant":"#685900",
                        "on-primary-fixed-variant":"#526900",
                        "surface-tint":           "#f3ffca",
                        "inverse-surface":        "#fcf9f8",
                        "on-primary":             "#516700",
                        "surface-variant":        "#262626",
                        "tertiary-dim":           "#edd13a",
                        "secondary-fixed":        "#dac9ff",
                        "on-secondary-container": "#d9c8ff",
                        "on-secondary-fixed-variant":"#5f28c8",
                        "primary":                "#f3ffca",
                        "outline":                "#767575",
                        "surface-container-low":  "#131313",
                        "outline-variant":        "#484847"
                    },
                    borderRadius: {
                        DEFAULT: "0.25rem",
                        lg:   "1rem",
                        xl:   "1.5rem",
                        full: "9999px"
                    },
                    fontFamily: {
                        headline: ["Lexend"],
                        body:     ["Inter"],
                        label:    ["Lexend"]
                    }
                }
            }
        }
    </script>

    <style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        body { font-family: 'Inter', sans-serif; background-color: #0e0e0e; color: #ffffff; }
        h1, h2, h3, .font-headline { font-family: 'Lexend', sans-serif; }
    </style>

    @stack('styles')
</head>
<body class="bg-background text-on-background overflow-hidden">

    {{-- ── Sidebar ── --}}
    <aside class="flex flex-col h-screen fixed left-0 top-0 bg-[#0e0e0e] font-['Lexend'] tracking-tight w-64 z-50">
        <div class="p-8">
            <h1 class="text-2xl font-black text-[#f3ffca] tracking-widest uppercase">CloudFit</h1>
            <p class="text-xs text-on-surface-variant mt-1 opacity-60">Coach Dashboard</p>
        </div>

        <nav class="flex-1 px-4 space-y-2">
            @php
                $navItems = [
                    ['icon' => 'dashboard',      'label' => 'Inicio',          'route' => 'coach.inicio',   'fill' => true],
                    ['icon' => 'groups',          'label' => 'Mis Clientes',    'route' => 'coach.clientes', 'fill' => false],
                    ['icon' => 'fitness_center',  'label' => 'Rutinas',         'route' => 'coach.rutinas',  'fill' => false],
                    ['icon' => 'monitoring',      'label' => 'Progreso Físico', 'route' => 'coach.progreso', 'fill' => false],
                    ['icon' => 'person',          'label' => 'Mi Perfil',       'route' => 'coach.perfil',   'fill' => false],
                ];
                $currentRoute = Route::currentRouteName();
            @endphp

            @foreach ($navItems as $item)
                @php $active = $currentRoute === $item['route']; @endphp
                <a href="{{ route($item['route']) ?? '#' }}"
                   class="flex items-center gap-4 px-4 py-3 transition-colors group
                          {{ $active
                              ? 'text-[#f3ffca] font-bold border-r-4 border-[#f3ffca] bg-[#1a1a1a]'
                              : 'text-[#a1a1a1] hover:bg-[#1a1a1a] hover:text-[#f3ffca]' }}">
                    <span class="material-symbols-outlined"
                          @if($item['fill']) style="font-variation-settings: 'FILL' 1;" @endif>{{ $item['icon'] }}</span>
                    <span>{{ $item['label'] }}</span>
                </a>
            @endforeach
        </nav>

        {{-- Coach profile footer --}}
        <div class="p-6 mt-auto bg-[#131313] flex items-center gap-3">
            <img src="{{ auth()->user()->avatar_url ?? 'https://ui-avatars.com/api/?name=Coach&background=cafd00&color=0e0e0e' }}"
                 alt="Coach Avatar"
                 class="w-10 h-10 rounded-full object-cover" />
            <div>
                <p class="text-sm font-bold text-on-surface">{{ auth()->user()->name ?? 'Coach' }}</p>
                <p class="text-[10px] uppercase tracking-widest text-primary">{{ auth()->user()->role ?? 'Coach' }}</p>
            </div>
        </div>
    </aside>

    {{-- ── Top Header ── --}}
    <header class="fixed top-0 right-0 left-64 flex justify-between items-center px-8 h-20 z-40 bg-[#0e0e0e]/80 backdrop-blur-xl border-b border-[#cafd00]/15 shadow-2xl shadow-black/50">
        <div class="flex items-center gap-6">
            <div class="relative">
                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant text-lg">search</span>
                <input type="text"
                       placeholder="Buscar cliente..."
                       class="bg-surface-container-low border-none rounded-lg pl-10 pr-4 py-2 text-sm focus:ring-1 focus:ring-primary w-64 transition-all" />
            </div>
        </div>
        <div class="flex items-center gap-6">
            <button class="flex items-center gap-2 bg-primary-fixed text-on-primary-fixed px-5 py-2.5 rounded-sm font-headline font-bold text-sm hover:opacity-90 transition-opacity uppercase tracking-tight">
                <span class="material-symbols-outlined text-sm">add</span>
                Asignar Rutina
            </button>
            <div class="relative">
                <span class="material-symbols-outlined text-on-surface-variant hover:text-primary cursor-pointer transition-colors">notifications</span>
                <span class="absolute -top-1 -right-1 w-2 h-2 bg-error rounded-full"></span>
            </div>
            <img src="{{ auth()->user()->avatar_url ?? 'https://ui-avatars.com/api/?name=Coach&background=cafd00&color=0e0e0e' }}"
                 alt="Coach Avatar"
                 class="w-9 h-9 rounded-full object-cover ring-2 ring-primary/20" />
        </div>
    </header>

    {{-- ── Main Canvas ── --}}
    <main class="ml-64 pt-24 p-8 min-h-screen bg-background">
        @yield('content')
    </main>

    @stack('scripts')
</body>
</html>
