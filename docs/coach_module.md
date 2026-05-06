# Módulo Coach — CloudFit

**Proyecto:** CloudFit — Plataforma de Entrenamiento  
**Plataforma:** Web (Single Page Application)  
**Fecha:** Abril 2026

---

## 1. Descripción General

CloudFit conecta coaches (entrenadores personales) con clientes (atletas). El módulo Coach es la sección web exclusiva para entrenadores certificados.

**Permite:**
- Monitorear desempeño y actividad de atletas asignados.
- Crear y gestionar rutinas personalizadas.
- Asignar rutinas según objetivos.
- Recibir alertas de inactividad.
- Visualizar métricas corporales.
- Imprimir planes de entrenamiento.

**Restricciones de rol:** Un usuario con rol `COACH` solo puede acceder a rutas, componentes y endpoints protegidos para este rol.

**Arquitectura de ejecución:** SPA embebida en Laravel. React maneja la UI en cliente; Laravel sirve la vista inicial y expone la API REST.

---

## 2. Stack Tecnológico

### 2.1 Frontend

| Tecnología | Versión | Propósito |
|---|---|---|
| React | 19.2.4 | Framework UI principal |
| React Router DOM | 7.13.2 | Enrutamiento cliente / rutas protegidas |
| Tailwind CSS | 4.2.2 | Framework utilitario de estilos |
| Lucide React | 1.0.1 | Iconografía SVG |
| Supabase JS | 2.100.0 | SDK de autenticación / JWT |
| Vite | 7.0.7 | Build tool |

### 2.2 Backend

| Tecnología | Propósito |
|---|---|
| Laravel 11 | API REST + MVC |
| Firebase JWT | Validación de tokens Supabase |
| PHP | Lenguaje backend |
| PostgreSQL | Base de datos relacional |
| Eloquent ORM | Abstracción de base de datos |

### 2.3 Infraestructura y Seguridad

- Autenticación stateless con tokens Bearer (JWT emitidos por Supabase).
- Validación mediante JWKS (llaves públicas de Supabase).
- Prefijo de API del módulo: `/api/coach`.

---

## 3. Autenticación y Autorización

### Flujo

```
Login UI → supabase.auth.signIn() → JWT emitido → localStorage (sb-auth-token)
→ Bearer Token en cada request → VerifySupabaseToken → CheckRole(COACH) → Controller
```

### Helper de fetch (frontend)

```js
async function apiFetch(path, opts = {}) {
  const { data: s } = await supabase.auth.getSession();
  const token = s?.session?.access_token;

  const res = await fetch(`/api/coach${path}`, {
    ...opts,
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
  });

  return res.json();
}
```

### Extracción de rol en Laravel

```php
$role = $payload->user_metadata->role
    ?? $payload->app_metadata->role
    ?? $payload->role
    ?? null;

$role = strtoupper(trim($role));
```

### Capas de seguridad

| Capa | Protección |
|---|---|
| API Laravel | JWT válido + rol COACH |
| React Routes | Componente `ProtectedRoute` |
| Web Middleware | `coach.web` |

### Persistencia local

| Key | Contenido |
|---|---|
| `cloudfit.local_user` | Perfil del usuario |
| `sb-auth-token` | JWT de Supabase |

### Registro de Coach

Componente: `CoachRegisterForm.jsx`  
Campos: nombre, correo, contraseña, especialidad, experiencia, certificados.  
Flujo: `signUp()` → JWT → `POST /api/sync` → redirect `/coach`.

---

## 4. Base de Datos

### Entidades principales

- `users`
- `coaches`
- `clients`
- `routines`
- `routine_exercises`
- `routine_assignments`
- `workout_logs`
- `progress`

### Relación simplificada

```
Coach
 ├── Clients
 ├── Routines
 │    └── Exercises
 └── Assignments
```

### Tabla `routines` — campos principales

| Campo | Descripción |
|---|---|
| `id` | Identificador |
| `name` | Nombre de la rutina |
| `description` | Descripción |
| `coach_id` | Coach propietario |
| `client_id` | Cliente asignado (móvil) |
| `is_active` | Estado activo |
| `tag` | Etiqueta |
| `icon_type` | Tipo de ícono |
| `accent_color` | Color de acento |
| `difficulty` | Nivel de dificultad (numérico) |
| `difficulty_label` | Etiqueta de dificultad |
| `duration_label` | Duración estimada |
| `training_plan` | Plan de entrenamiento |

### Nota de sincronización mobile/web

- **Mobile (Flutter):** crea rutinas con `client_id` en `routines`, sin registro en `routine_assignments`.
- **Web (Laravel):** crea en `routines` + registro en `routine_assignments` con `coach_id`, `client_id`, `status`.

Al listar rutinas de un cliente desde la web, siempre combinar ambas fuentes:
1. Query a `routine_assignments` (rutinas asignadas desde web).
2. Query a `routines WHERE client_id = X AND is_active = true AND id NOT IN (assigned_ids)` (rutinas desde móvil).

---

## 5. API REST

**Prefijo:** `/api/coach`  
**Header requerido:** `Authorization: Bearer {token}`

### Dashboard

```
GET /api/coach/dashboard
```

```json
{
  "kpis": {},
  "clients": [],
  "activities": []
}
```

KPIs: total atletas, nuevos este mes, % cumplimiento, alertas de inactividad, planes activos.  
Fórmula cumplimiento: `(clientes con log hoy / clientes activos) × 100`

### Clientes

```
GET  /api/coach/rutinas/clients
GET  /api/coach/rutinas/clients/{id}
GET  /api/coach/rutinas/clients/{id}/routines
```

### Rutinas

```
GET    /api/coach/rutinas/routines
POST   /api/coach/rutinas/routines
PUT    /api/coach/rutinas/routines/{id}
DELETE /api/coach/rutinas/routines/{id}
```

### Ejercicios

```
GET    /api/coach/rutinas/routines/{id}/exercises
POST   /api/coach/rutinas/routines/{id}/exercises
PUT    /api/coach/rutinas/exercises/{id}
PATCH  /api/coach/rutinas/routines/{id}/exercises/reorder
DELETE /api/coach/rutinas/exercises/{id}
```

Campos por ejercicio: `series`, `reps`, `peso`, `descanso`.  
Fórmula duración estimada: `(series × descanso) × cantidad_ejercicios`

### Asignaciones

```
POST  /api/coach/rutinas/assignments
GET   /api/coach/rutinas/assignments
PATCH /api/coach/rutinas/assignments/{id}/status
```

Una asignación crea registro en `routine_assignments` con `status='active'`.

### Chatbot IA

```
POST /api/chatbot
```

Capacidades: consultas sobre clientes, rutinas y métricas del coach autenticado.

---

## 6. Componentes React

### Rutas del módulo

Todas bajo `CoachLayout.jsx`:

| Ruta | Estado |
|---|---|
| `/coach` | Activo (Dashboard) |
| `/coach/clientes` | Activo |
| `/coach/rutinas` | Activo |
| `/coach/progreso` | Planificado |
| `/coach/perfil` | Planificado |

### CoachLayout.jsx

Contiene: Sidebar, Outlet (rutas hijas), Chatbot IA, botón Logout.

### KpiCard.jsx

Props: `title`, `value`, `icon`, `color`, `trend`.

### ClientTable.jsx

Funcionalidades: estado activo/inactivo, iniciales automáticas, botón de impresión, panel de detalles.

Flujo de impresión:
1. Click "Imprimir"
2. `GET /rutinas/clients/{id}/routines`
3. Generar HTML de impresión
4. `window.print()`

### ActivityFeed.jsx

Eventos: rutina completada, registro de peso, nuevo cliente.

### Rutinas.jsx

Gestiona: tabs (lista/crear/asignar), toasts, loading/error state, constructor dinámico de ejercicios.

---

## 7. Gestión de Estado

No usa Redux, Zustand ni Context global. Solo hooks locales.

**Hooks:** `useState`, `useEffect`, `useCallback`

### Estado Dashboard

```js
const [data, setData] = useState({ kpis: {}, clients: [], activities: [] });
```

### Estado Rutinas

| Variable | Propósito |
|---|---|
| `activeTab` | Tab activo (lista/crear/asignar) |
| `clients` | Lista de clientes del coach |
| `routines` | Lista de rutinas |
| `exercises` | Ejercicios de la rutina seleccionada |
| `selectedClient` | Cliente seleccionado |
| `selectedRoutine` | Rutina seleccionada |
| `difficulty` | Nivel de dificultad |
| `routineFilter` | Filtro de rutinas |
| `toast` | Estado de notificaciones |

---

## 8. Diseño Visual

### Paleta de colores

| Color | Hex |
|---|---|
| Verde Lima (primario) | `#cafd00` |
| Negro Fondo | `#0e0e0e` |
| Gris Oscuro | `#1a1a1a` |
| Rojo Alerta | `#ff7351` |

Tema oscuro por menor fatiga visual, estética fitness y mejor contraste.

---

## 9. Funcionalidades Detalladas

### Dashboard Principal

KPIs mostrados:
- Total atletas
- Nuevos este mes
- % cumplimiento `(clientes con log hoy / clientes activos) × 100`
- Alertas de inactividad
- Planes activos

### Gestión de Clientes

Información disponible por cliente: datos personales, altura, objetivo, rutinas asignadas.

### Crear Rutina

Campos: nombre, plan de entrenamiento, dificultad, lista dinámica de ejercicios (series, reps, peso, descanso).

### Asignar Rutina

Flujo: elegir cliente → elegir rutina → confirmar → genera `routine_assignments` con `status='active'`.

### Imprimir Plan

Flujo: seleccionar cliente → generar HTML → `window.print()` → PDF o impresión física.

---

## 10. Roadmap

| Funcionalidad | Estado |
|---|---|
| Seguimiento progreso (`/coach/progreso`) | Planificado |
| Perfil coach (`/coach/perfil`) | Planificado |
| Mensajería directa | No iniciado |
| Plantillas de rutina | No iniciado |
| Exportación de reportes | No iniciado |
| Notificaciones push | No iniciado |

---

## 11. Glosario

| Término | Definición |
|---|---|
| Coach | Usuario con rol COACH |
| Cliente | Usuario atleta |
| Rutina | Plan de entrenamiento |
| Ejercicio | Unidad dentro de una rutina |
| Asignación | Vínculo cliente–rutina en `routine_assignments` |
| JWT | Token de autenticación |
| JWKS | Llaves públicas de validación de Supabase |
| SPA | Single Page Application |
| KPI | Indicador clave de desempeño |
| ORM | Mapeo objeto-relacional (Eloquent) |
| Middleware | Capa de validación previa al controlador |
| Supabase | Backend-as-a-Service usado por CloudFit |
| Vite | Build tool del frontend |
| HMR | Hot Module Replacement |
| Tailwind CSS | Framework utilitario de estilos |
