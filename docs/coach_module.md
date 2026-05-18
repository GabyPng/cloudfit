# Módulo Coach — CloudFit Web

**Proyecto:** CloudFit — Plataforma de Entrenamiento  
**Plataforma:** Web (Single Page Application)  
**Fecha:** Abril 2026

---

## 1. Descripción General

CloudFit conecta coaches (entrenadores personales) con clientes (atletas). El módulo Coach es la sección web exclusiva para entrenadores certificados.

**Funcionalidades principales:**
- Monitorear desempeño y actividad de atletas asignados.
- Crear y gestionar rutinas personalizadas.
- Asignar rutinas según objetivos.
- Armar planes semanales con drag-and-drop.
- Recibir alertas de inactividad.
- Visualizar métricas corporales y fatiga muscular.
- Imprimir planes de entrenamiento.

**Restricciones de rol:** Un usuario con rol `COACH` solo puede acceder a rutas, componentes y endpoints protegidos para este rol.

**Arquitectura de ejecución:** SPA embebida en Laravel. React gestiona la UI; Laravel sirve la vista inicial y expone la API REST consumida por React.

---

## 2. Stack Tecnológico

### 2.1 Frontend

| Tecnología | Versión | Propósito |
|---|---|---|
| React | 19.2.4 | Framework UI principal |
| React Router DOM | 7.13.2 | Enrutamiento y rutas protegidas |
| Tailwind CSS | 4.2.2 | Estilos utilitarios |
| Lucide React | 1.0.1 | Iconografía SVG |
| Supabase JS | 2.100.0 | SDK de autenticación / JWT |
| Recharts | — | Gráficos de composición corporal y progreso |
| Framer Motion | — | Animaciones de UI |
| Vite | 7.0.7 | Build tool |

### 2.2 Backend

| Tecnología | Propósito |
|---|---|
| Laravel 11 | API REST + MVC |
| Firebase JWT | Validación de tokens de Supabase |
| PHP | Lenguaje de programación backend |
| PostgreSQL | Base de datos relacional |
| Eloquent ORM | Abstracción de la base de datos |

### 2.3 Paleta de colores

| Color | Hex | Uso |
|---|---|---|
| Verde Lima | `#cafd00` | Acento principal, activo, rutinas completadas |
| Negro Fondo | `#0e0e0e` | Fondo general |
| Gris Oscuro | `#1a1a1a` | Fondo sidebar activo, cards |
| Gris Medio | `#131313` | Footer del sidebar |
| Rojo Alerta | `#ff7351` | Alertas, errores |
| Violeta | `#ac8aff` | Eventos de peso en ActivityFeed |
| Amarillo Suave | `#ffeea5` | Eventos de récord en ActivityFeed |

---

## 3. Autenticación y Autorización

### 3.1 Flujo de autenticación

```
Login UI
  → supabase.auth.signIn()
  → JWT emitido y guardado en localStorage (sb-auth-token)
  → Bearer Token adjunto en cada request
  → VerifySupabaseToken (Laravel middleware)
  → CheckRole(COACH)
  → Controller
```

### 3.2 Helper de fetch (frontend)

Todas las llamadas a la API pasan por este helper, que adjunta automáticamente el JWT de Supabase:

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

### 3.3 Extracción de rol en Laravel

```php
$role = $payload->user_metadata->role
    ?? $payload->app_metadata->role
    ?? $payload->role
    ?? null;

$role = strtoupper(trim($role));
```

El `coach_id` se resuelve en cada request a partir del email extraído del JWT, consultando la tabla `coaches`.

### 3.4 Capas de seguridad

| Capa | Mecanismo |
|---|---|
| API Laravel | JWT válido + rol `COACH` |
| React Routes | Componente `ProtectedRoute` |
| Web Middleware | `coach.web` (AuthenticateCoachWeb) |

### 3.5 Middleware

| Middleware | Función |
|---|---|
| `VerifySupabaseToken` | Extrae `uid`, `email` y `role` del JWT |
| `CheckRole` | Valida que el rol coincida con el requerido |
| `AuthenticateCoachWeb` | Variante web con fallback a base de datos |

### 3.6 Persistencia local

| Key | Contenido |
|---|---|
| `cloudfit.local_user` | Perfil del usuario |
| `sb-auth-token` | JWT de Supabase |

---

## 4. Base de Datos

### 4.1 Entidades principales

| Modelo | Tabla | Descripción |
|---|---|---|
| `User` | `users` | Usuario base del sistema |
| `Coach` | `coaches` | Coach (usa `user_id` como PK) |
| `Client` | `clients` | Cliente vinculado a un coach |
| `Routine` | `routines` | Plan de entrenamiento |
| `RoutineExercise` | `routine_exercises` | Ejercicios dentro de una rutina |
| `RoutineAssignment` | `routine_assignments` | Vínculo coach→cliente→rutina |
| `WorkoutLog` | `workout_logs` | Registros de entrenamientos completados |
| `Progress` | `progress` | Composición corporal (peso, grasa, músculo) |

### 4.2 Relación simplificada

```
Coach
 ├── Clients
 │    └── Progress (composición corporal)
 ├── Routines
 │    └── RoutineExercises
 ├── RoutineAssignments (coach → cliente → rutina)
 └── WeeklyPlans (por cliente, 7 días)
```

### 4.3 Campos de modelos clave

**Routine:**

| Campo | Tipo | Descripción |
|---|---|---|
| `name` | string | Nombre de la rutina |
| `description` | string | Descripción |
| `coach_id` | integer | Coach propietario |
| `client_id` | integer | Cliente asignado (usado por móvil) |
| `is_active` | boolean | Estado activo |
| `tag` | string | Etiqueta (max 100 chars) |
| `icon_type` | enum | `dumbbell`, `zap`, `heart` |
| `accent_color` | string | Color de acento (max 20 chars) |
| `difficulty` | integer | 0–100 |
| `difficulty_label` | string | Básico / Intermedio / Avanzado |
| `duration_label` | string | Duración estimada legible |
| `training_plan` | string | Tipo de plan de entrenamiento |

**RoutineExercise:**

| Campo | Descripción |
|---|---|
| `routine_id` | Rutina padre |
| `exercise_id` | ID del catálogo de ejercicios |
| `exercise_name` | Nombre del ejercicio |
| `sets` | Series |
| `reps` | Repeticiones |
| `rest_time` | Descanso (30s–180s) |
| `weight` | Peso en kg |
| `notes` | Notas opcionales |
| `order` | Posición dentro de la rutina |

**RoutineAssignment:**

| Campo | Descripción |
|---|---|
| `client_id` | Cliente |
| `routine_id` | Rutina asignada |
| `coach_id` | Coach que asigna |
| `status` | `active`, `paused`, `completed` |
| `assigned_at` | Fecha de asignación |

### 4.4 Reglas de negocio de datos

- `difficulty` ≤ 40 → Básico; 41–70 → Intermedio; > 70 → Avanzado.
- No se puede asignar la misma rutina activa dos veces al mismo cliente.
- `rest_time` solo acepta valores: `30s`, `45s`, `60s`, `90s`, `120s`, `150s`, `180s`.
- Plan semanal: máximo 2000 caracteres en notas; los 7 días son fijos (Mon–Sun).

### 4.5 Nota de sincronización mobile/web

| Plataforma | Crea rutinas en | Crea asignación en |
|---|---|---|
| Mobile (Flutter) | `routines` con `client_id` | No crea en `routine_assignments` |
| Web (Laravel) | `routines` + `routine_assignments` | Siempre crea asignación |

Al listar rutinas de un cliente desde la web, siempre combinar ambas fuentes:
1. Query a `routine_assignments` (rutinas asignadas desde web).
2. Query a `routines WHERE client_id = X AND is_active = true AND id NOT IN (assigned_ids)` (rutinas desde móvil).

---

## 5. API REST

**Prefijo:** `/api/coach`  
**Header requerido:** `Authorization: Bearer {token}`  
**Middleware:** `supabase.auth` + `role:COACH`

### 5.1 Dashboard

```
GET /api/coach/dashboard
```

**Respuesta:**

```json
{
  "totalAtletas": 15,
  "nuevosEsteMes": 3,
  "porcentajeCumplimiento": 87,
  "alertasInactividad": 2,
  "planesActivos": 8,
  "clientes": [
    {
      "id": 123,
      "nombre": "Juan Pérez",
      "objetivo": "Ganancia muscular",
      "rutinas": [{ "id": 1, "name": "Pecho A", "iconType": "dumbbell" }],
      "estado": "activo",
      "peso": 85.5,
      "grasa": 18.2
    }
  ],
  "actividades": [
    {
      "tipo": "rutina_completada",
      "cliente_nombre": "Juan",
      "detalle": "completó Pecho A",
      "tiempo_hace": "hace 2 horas"
    }
  ]
}
```

Fórmula cumplimiento: `(clientes con log hoy / clientes activos) × 100`  
Tipos de actividad: `rutina_completada`, `peso_registrado`, `nuevo_cliente`.

### 5.2 Clientes

```
GET  /api/coach/rutinas/clients            → listado con iniciales de avatar
GET  /api/coach/rutinas/clients/{id}       → detalle (altura, fecha nacimiento, objetivo)
GET  /api/coach/rutinas/clients/{id}/routines → rutinas activas (web + móvil combinadas)
```

### 5.3 Rutinas

```
GET    /api/coach/rutinas/routines?level=all|basics|advanced
POST   /api/coach/rutinas/routines
PUT    /api/coach/rutinas/routines/{id}
DELETE /api/coach/rutinas/routines/{id}
```

El parámetro `level`:
- `basics` → `difficulty ≤ 40`
- `advanced` → `difficulty > 40`
- `all` → sin filtro

### 5.4 Ejercicios

```
GET    /api/coach/rutinas/routines/{id}/exercises
POST   /api/coach/rutinas/routines/{id}/exercises
PUT    /api/coach/rutinas/exercises/{id}
PATCH  /api/coach/rutinas/routines/{id}/exercises/reorder
DELETE /api/coach/rutinas/exercises/{id}
```

El reorder hace un batch update de `order` para todos los ejercicios de la rutina.  
Al guardar, se hace upsert del ejercicio en el catálogo de ejercicios (`exercise_catalog`).

### 5.5 Asignaciones

```
POST  /api/coach/rutinas/assignments
GET   /api/coach/rutinas/assignments?clientId={id}
PATCH /api/coach/rutinas/assignments/{id}/status
```

### 5.6 Plan Semanal

```
GET  /api/coach/weekly-plan/{clientId}
POST /api/coach/weekly-plan/{clientId}
```

El POST hace full-replace del plan: reemplaza todos los días al guardar.  
Estructura de body:

```json
{
  "plan": {
    "Mon": [1, 3],
    "Tue": [],
    "Wed": [2],
    "Thu": [],
    "Fri": [1],
    "Sat": [],
    "Sun": []
  },
  "notes": "Descanso total el domingo."
}
```

### 5.7 Progreso

```
GET /api/coach/progreso/clients
GET /api/coach/progreso/clients/{id}/composicion
GET /api/coach/progreso/clients/{id}/fuerza
GET /api/coach/progreso/clients/{id}/fatiga
```

- **composicion:** historial de `progress` ordenado por fecha; calcula peso actual, % grasa, masa muscular y cambios mensuales.
- **fuerza:** consulta `workout_logs` con `routine_exercises`; busca ejercicios clave (sentadilla, press, etc.) y calcula 1RM estimado (fórmula Epley).
- **fatiga:** últimos 7 días; mapea ejercicios a grupos musculares; suma series/volumen; niveles: recuperado (0), bajo (1–6), moderado (7–12), alto (≥13).

### 5.8 Chatbot IA

```
POST /api/chatbot
```

Capacidades: consultas sobre clientes, rutinas y métricas del coach autenticado.

---

## 6. Estructura de Archivos

```
resources/js/
├── pages/Coach/
│   ├── index.jsx              ← Enrutador principal del módulo
│   ├── CoachLayout.jsx        ← Layout: sidebar, outlet, chatbot
│   ├── Dashboard.jsx          ← Panel principal con KPIs
│   ├── Rutinas.jsx            ← CRUD rutinas + gestor de ejercicios
│   ├── MisClientes.jsx        ← Plan semanal con drag-and-drop
│   ├── Progreso.jsx           ← Composición corporal y fatiga
│   ├── MapaFatiga.jsx         ← SVG de cuerpo con grupos musculares
│   └── components/
│       ├── KpiCard.jsx
│       ├── ClientTable.jsx
│       └── ActivityFeed.jsx

app/Http/Controllers/Coach/
├── CoachController.php        ← Dashboard, clientes, KPIs
├── CoachWebController.php     ← Renderización web de vistas
├── RutinasController.php      ← CRUD rutinas, ejercicios, asignaciones
├── ProgresoController.php     ← Composición, fuerza, fatiga
└── WeeklyPlanController.php   ← Plan semanal

app/Models/
├── Coach.php
├── Client.php
├── Routine.php
├── RoutineExercise.php
├── RoutineAssignment.php
├── WorkoutLog.php
└── Progress.php

routes/
├── web.php                    ← Rutas web bajo middleware coach.web
└── api/coach.php              ← Rutas API del módulo coach
```

---

## 7. Componentes React

### 7.1 CoachLayout.jsx

Layout base de todas las vistas del módulo.

**Props:** `coachName`, `coachRole`, `children`

**Contiene:**
- Sidebar con navegación.
- `<Outlet />` (rutas hijas con React Router).
- Componente `<Chatbot />` integrado.
- Botón de logout (`supabase.auth.signOut()`).

**Rutas del sidebar:**

| Ruta | Ícono | Estado |
|---|---|---|
| `/coach` | LayoutDashboard | Activo |
| `/coach/clientes` | CalendarDays | Activo |
| `/coach/rutinas` | Dumbbell | Activo |
| `/coach/progreso` | TrendingUp | Activo |

### 7.2 Dashboard.jsx

**Estado:**
```js
const [data, setData] = useState({ kpis: {}, clients: [], activities: [] });
const [loading, setLoading] = useState(true);
const [error, setError] = useState(null);
```

**KPIs mostrados:** Total Atletas, % Cumplimiento, Alertas Inactividad, Planes Activos.

**Subcomponentes usados:** `KpiCard`, `ClientTable`, `ActivityFeed`.

### 7.3 Rutinas.jsx

Componente más complejo del módulo. Gestiona rutinas completas con ejercicios.

**Estado principal:**

| Variable | Propósito |
|---|---|
| `activeTab` | Tab activo: lista / crear / asignar |
| `clients` | Clientes del coach |
| `routines` | Lista de rutinas |
| `exercises` | Ejercicios de la rutina activa |
| `selectedClient` | Cliente seleccionado para asignación |
| `selectedRoutine` | Rutina seleccionada |
| `difficulty` | Slider 0–100 |
| `routineFilter` | Filtro: all / basics / advanced |
| `toast` | Sistema de notificaciones |

**Modos:**
- **Lectura:** Grid de cards con dificultad, duración, ícono y color de acento.
- **Formulario:** Crear/editar rutina con gestor dinámico de ejercicios (add/remove/reorder).

**Panel derecho al crear:** Vista previa en tiempo real, duración estimada, volumen total, slider de dificultad.

**CustomSelect:** Componente propio para series, reps y descanso.

**Fórmula duración estimada:** `(series × descanso_en_segundos) × cantidad_ejercicios`

### 7.4 MisClientes.jsx — Plan Semanal

**Funcionalidades:**
- Selector de cliente.
- Banco lateral de rutinas con buscador.
- Drag-and-drop de rutinas a los 7 días de la semana.
- Auto-scroll durante el drag.
- Notas por plan (textarea, max 2000 chars).
- Botón de impresión: genera HTML con el plan completo y llama `window.print()`.

**API calls:**
- `GET /rutinas/clients`
- `GET /rutinas/routines?level=all`
- `GET /weekly-plan/{clientId}`
- `POST /weekly-plan/{clientId}`

### 7.5 Progreso.jsx

**Tabs:**
- **Tab 0 — Composición Corporal:** 3 KPIs (Peso Actual, % Grasa, Masa Muscular), 2 gráficos Recharts (peso, grasa/músculo), delta de cambio mensual.
- **Tab 1 — Fatiga Muscular:** Componente `MapaFatiga` integrado con datos de los últimos 7 días.

### 7.6 MapaFatiga.jsx

SVG interactivo con vista frontal y dorsal del cuerpo.

**Dimensiones del SVG:** 200×430 px por vista (frente/espalda).

**12 grupos musculares mapeados:**

| Nivel de fatiga | Series acumuladas |
|---|---|
| Recuperado | 0 |
| Bajo | 1–6 |
| Moderado | 7–12 |
| Alto | ≥13 |

**Interacción:** Tooltip al hover sobre cada grupo muscular. Desglose con barras de progreso.

---

## 8. Subcomponentes

### KpiCard.jsx

**Props:** `label`, `value`, `icon`, `iconColor`, `valueColor`, `children`

Muestra una métrica grande con ícono. Acepta `children` para contenido extra (ej. barra de progreso).

### ClientTable.jsx

Tabla de monitoreo de clientes con 5 columnas:

| Columna | Descripción |
|---|---|
| Cliente | Nombre + iniciales de avatar |
| Enfoque | Objetivo del cliente |
| Estado Hoy | Punto rojo/verde según actividad |
| Última Métrica | Peso o % grasa más reciente |
| Acciones | Plan Semanal / Evolución (aparecen en hover) |

Incluye paginación en el footer.

### ActivityFeed.jsx

Timeline vertical de eventos recientes.

| Tipo de evento | Color de ícono |
|---|---|
| Rutina completada | `#cafd00` (verde lima) |
| Registro de peso | `#ac8aff` (violeta) |
| Récord personal | `#ffeea5` (amarillo) |
| Nuevo cliente | `#adaaaa` (gris) |

---

## 9. Flujos de Usuario

### Crear y asignar rutina

```
Crear rutina (nombre + plan + ejercicios)
  → Guardar → POST /rutinas/routines
  → Asignar cliente → POST /rutinas/assignments
  → Cliente recibe rutina activa
```

### Armar plan semanal

```
Seleccionar cliente
  → Cargar banco de rutinas
  → Drag rutinas a días de la semana
  → Guardar → POST /weekly-plan/{clientId}
  → Opcional: Imprimir → window.print()
```

### Monitorear progreso

```
Seleccionar cliente
  → Tab Composición → gráficos de peso y composición corporal
  → Tab Fatiga → mapa SVG con niveles por grupo muscular
```

### Monitorear inactividad

```
Dashboard → KPI Alertas Inactividad
  → Identificar clientes inactivos en ClientTable
  → Pausar asignación → PATCH /assignments/{id}/status
```

---

## 10. Controladores — Métodos Principales

### CoachController.php

**`dashboard()`**
- Resuelve `coach_id` desde el email del JWT.
- Calcula los 5 KPIs.
- Obtiene clientes con `last_workout_date`, peso y % grasa.
- Agrupa rutinas activas por cliente.
- Genera lista de actividades recientes.

### RutinasController.php

| Método | Función |
|---|---|
| `clientsList()` | Listado con iniciales para avatar |
| `clientDetail()` | Info completa (altura, objetivo, fecha nacimiento) |
| `routinesList()` | Filtra por `level` |
| `routineStore()` | Crea rutina + inserta ejercicios + upsert catálogo |
| `routineUpdate()` | Update parcial, puede reinsertar ejercicios |
| `routineDestroy()` | Soft delete de rutina y ejercicios |
| `exerciseStore()` | Añade ejercicio con `maxOrder + 1` |
| `exercisesReorder()` | Batch update de `order` |
| `assignmentStore()` | Valida no duplicados activos antes de crear |
| `assignmentStatus()` | Cambia status: `active`, `paused`, `completed` |
| `clientRoutinesList()` | Combina asignaciones web + rutinas directas de móvil |

**Helpers internos:** `formatRoutine()`, `formatExercise()`, `upsertExerciseCatalog()`

### ProgresoController.php

| Método | Función |
|---|---|
| `composicion()` | KPIs de peso/grasa/músculo y cambios mensuales |
| `fuerza()` | 1RM estimado con fórmula Epley por ejercicio clave |
| `fatiga()` | Mapeo de ejercicios a grupos musculares, suma series últimos 7 días |

### WeeklyPlanController.php

| Método | Función |
|---|---|
| `show()` | Retorna estructura `{ Mon: [ids...], Tue: [...], ... }` |
| `save()` | Full-replace del plan; valida existencia de rutinas |

---

## 11. Roadmap

| Funcionalidad | Estado |
|---|---|
| Dashboard con KPIs | Activo |
| Gestión de rutinas (CRUD) | Activo |
| Plan semanal con drag-drop | Activo |
| Progreso (composición corporal) | Activo |
| Mapa de fatiga muscular | Activo |
| Perfil del coach | No iniciado |
| Mensajería directa | No iniciado |
| Plantillas de rutina | No iniciado |
| Exportación de reportes | No iniciado |
| Notificaciones push | No iniciado |

---

## 12. Glosario

| Término | Definición |
|---|---|
| Coach | Usuario con rol `COACH` |
| Cliente | Usuario atleta asignado al coach |
| Rutina | Plan de entrenamiento con ejercicios |
| Ejercicio | Unidad dentro de una rutina (series, reps, peso, descanso) |
| Asignación | Vínculo coach→cliente→rutina en `routine_assignments` |
| Plan Semanal | Distribución de rutinas en los 7 días de la semana |
| 1RM | Repetición máxima, calculada con fórmula Epley |
| JWT | Token de autenticación emitido por Supabase |
| JWKS | Llaves públicas de validación de Supabase |
| SPA | Single Page Application |
| KPI | Indicador clave de desempeño |
| ORM | Mapeo objeto-relacional (Eloquent) |
| Middleware | Capa de validación previa al controlador |
| Upsert | Insert o update dependiendo de si el registro existe |
| Drag-and-drop | Arrastrar y soltar rutinas en el plan semanal |
| Epley | Fórmula para estimar 1RM: `peso × (1 + reps / 30)` |
