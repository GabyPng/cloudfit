# Plan: Módulo Planes Nutricionales + Completar Pacientes

## Scope

Two frontend modules for the Nutriologo section. **Backend is fully implemented** — all work is React UI.

---

## Phase 0 — Verified API Contracts (already confirmed)

All endpoints exist and tested via controller code review.

| Method | URL | Use |
|--------|-----|-----|
| GET | `/api/nutriologo/planes` | List with `meals_count`, `assignments_count`, search |
| GET | `/api/nutriologo/planes/{id}` | Detail with `meals[]` and `assignments[].client` |
| POST | `/api/nutriologo/planes` | Create plan + meals array |
| PUT | `/api/nutriologo/planes/{id}` | Update; if `meals` key present, replaces all meals |
| DELETE | `/api/nutriologo/planes/{id}` | Hard delete |
| POST | `/api/nutriologo/planes/{id}/asignar` | Assign to patient: `{ client_id, starts_at, ends_at?, notes? }` |
| GET | `/api/nutriologo/clientes` | Paginated patient list (for assign-to dropdown) |

**Auth pattern** (copy from Pacientes.jsx `getSessionData`):
```js
const { data: { session } } = await supabase.auth.getSession();
const token = session?.access_token;
// headers: { Authorization: `Bearer ${token}`, Accept: 'application/json' }
```

**`requestJson` helper** (copy from Pacientes.jsx lines ~105-140):
```js
const requestJson = async (url, options = {}) => { ... }
```

**Plan payload shape** (from `storePlan` validation in NutriologoController.php):
```js
{
  title: string,           // required
  description: string,     // optional
  goal: string,            // optional
  daily_calories: number,  // optional integer
  macro_targets: {         // optional object
    proteinas: number,
    carbohidratos: number,
    grasas: number
  },
  starts_at: 'YYYY-MM-DD', // optional
  ends_at: 'YYYY-MM-DD',   // optional
  meals: [                 // optional array
    {
      meal_type: 'desayuno'|'colacion_1'|'comida'|'colacion_2'|'cena',
      name: string,
      portion: string,
      calories: number,
      protein_g: number,
      carbs_g: number,
      fat_g: number,
      notes: string,
      position: number
    }
  ]
}
```

**Design tokens** (from existing Nutriologo pages):
- Background layers: `#0e0e0e` (root) → `#131313` → `#1a1a1a` → `#262626`
- Accent / primary CTA: `#cafd00` text on `#405100` bg / `text-[#f3ffca]`
- Muted text: `#adaaaa`
- Border: `border-[#484847]/10` or `/20`
- Font: `font-headline` for headings, `uppercase tracking-widest` for labels
- Status pill classes: copy `statusStyles` object from Pacientes.jsx lines 29-54

---

## Phase 1 — Wire Routes & Enable Nav (5 min)

**Goal:** Make `/nutriologo/planes` navigable before building its content.

### 1a. `api-backend/resources/js/pages/Nutriologo/NutriologoLayout.jsx:19`

Change:
```js
{ icon: FileText, label: 'Planes Nutricionales', path: '/nutriologo/planes', available: false },
```
To:
```js
{ icon: FileText, label: 'Planes Nutricionales', path: '/nutriologo/planes', available: true },
```

### 1b. `api-backend/resources/js/app.jsx`

Add import after line 12:
```js
import NutriologoPlanesPage from './pages/Nutriologo/Planes';
```

Add route after the `/nutriologo/pacientes` block (after line 53):
```jsx
<Route
    path="/nutriologo/planes"
    element={(
        <ProtectedRoute allowedRoles={['nutriologo']}>
            <NutriologoPlanesPage />
        </ProtectedRoute>
    )}
/>
```

**Verification:** `grep -n "planes" api-backend/resources/js/app.jsx` → should show the import + route.

---

## Phase 2 — Create `Planes.jsx` (main task)

**File:** `api-backend/resources/js/pages/Nutriologo/Planes.jsx`

**Copy patterns from:** `Pacientes.jsx` (auth, requestJson, KpiCard usage, layout structure)

### UI Structure

```
NutriologoLayout
  ├─ Header: title + "Nuevo Plan" button
  ├─ KPI row: Total Planes | Planes Activos | Total Comidas | Pacientes Asignados
  ├─ Search bar + Refresh
  ├─ Two-column grid (lg)
  │   ├─ LEFT col-7: Plan list (cards, selectable)
  │   │   Each card: title, goal pill, meals_count, assignments_count, is_active toggle, Edit/Delete actions
  │   └─ RIGHT col-5: Plan detail panel
  │       ├─ When no plan selected: empty state
  │       └─ When plan selected:
  │           ├─ Plan header (title, goal, calories, macro bars)
  │           ├─ Meals list (grouped by meal_type, each row: name, portion, calories, macros)
  │           ├─ "Asignar a paciente" mini-form (patient dropdown + notes + starts_at + button)
  │           └─ Danger zone: Edit plan button | Delete button
  └─ Modal overlay: CreatePlan / EditPlan form (slide-in panel or centered modal)
```

### State shape

```js
const [plans, setPlans] = useState([]);
const [meta, setMeta] = useState({ current_page:1, last_page:1, total:0 });
const [patients, setPatients] = useState([]);          // for assign dropdown
const [selectedPlanId, setSelectedPlanId] = useState(null);
const [planDetail, setPlanDetail] = useState(null);    // fetched on selection
const [search, setSearch] = useState('');
const [page, setPage] = useState(1);
const [refreshTick, setRefreshTick] = useState(0);
const [loading, setLoading] = useState(true);
const [detailLoading, setDetailLoading] = useState(false);
const [saving, setSaving] = useState(false);
const [error, setError] = useState('');
const [message, setMessage] = useState('');

// Modal state
const [modal, setModal] = useState(null); // null | 'create' | 'edit' | 'delete-confirm'

// Plan form
const emptyPlanForm = {
  title: '', description: '', goal: '', daily_calories: '',
  macro_targets: { proteinas: 30, carbohidratos: 50, grasas: 20 },
  starts_at: '', ends_at: '',
  meals: []
};
const [planForm, setPlanForm] = useState(emptyPlanForm);

// Assign form
const [assignForm, setAssignForm] = useState({ clientId: '', notes: '', starts_at: '' });
```

### Data loading

```js
// Load plans list (on search/page/refreshTick change)
useEffect(() => { /* GET /api/nutriologo/planes?search=...&page=... */ }, [search, page, refreshTick]);

// Load plan detail (on selectedPlanId change)
useEffect(() => {
  if (!selectedPlanId) return;
  // GET /api/nutriologo/planes/{selectedPlanId}
}, [selectedPlanId]);

// Load patients once (for assign dropdown)
useEffect(() => { /* GET /api/nutriologo/clientes?per_page=50 */ }, []);
```

### Key handlers

```js
const handleCreatePlan = async () => { /* POST /api/nutriologo/planes, body: planForm */ };
const handleEditPlan = async () => { /* PUT /api/nutriologo/planes/{id}, body: planForm */ };
const handleDeletePlan = async () => { /* DELETE /api/nutriologo/planes/{id} */ };
const handleToggleActive = async (plan) => {
  /* PUT /api/nutriologo/planes/{plan.id} with { is_active: !plan.is_active } — no meals key */
};
const handleAssignPlan = async () => {
  /* POST /api/nutriologo/planes/{selectedPlanId}/asignar */
};
```

### Meal form within plan form

Add meals inline in the Create/Edit modal:
- "Agregar comida" button appends to `planForm.meals[]`
- Each meal row: meal_type select, name input, portion, calories, protein_g, carbs_g, fat_g, notes, delete row button
- `position` auto-assigned as array index

### Meal type labels

```js
const mealTypeLabels = {
  desayuno: 'Desayuno',
  colacion_1: 'Colación 1',
  comida: 'Comida',
  colacion_2: 'Colación 2',
  cena: 'Cena',
};
```

### Macro bar component (inline, no separate file)

```jsx
function MacroBar({ label, value, color }) {
  return (
    <div>
      <div className="flex justify-between text-[10px] text-[#adaaaa] mb-1">
        <span>{label}</span><span>{value}%</span>
      </div>
      <div className="h-1.5 bg-[#262626] rounded-full">
        <div className={`h-full rounded-full ${color}`} style={{ width: `${value}%` }} />
      </div>
    </div>
  );
}
```

**Verification:**
- `grep -n "NutriologoPlanesPage\|Planes" api-backend/resources/js/app.jsx` → route present
- Navigate to `/nutriologo/planes` in browser, page loads, plan list appears

---

## Phase 3 — Complete `Pacientes.jsx`

**File:** `api-backend/resources/js/pages/Nutriologo/Pacientes.jsx`

### 3a. Read pre-selected patient from navigation state (Dashboard "Plan" button)

Add at the top of the component, after state declarations:
```js
import { useLocation } from 'react-router-dom';
// inside component:
const location = useLocation();

useEffect(() => {
  if (location.state?.patientId) {
    setSelectedPatientId(String(location.state.patientId));
  }
}, [location.state]);
```

### 3b. Empty plans state — add "Ir a Planes" button (line 481-484)

Replace the static `<p>` text:
```jsx
{plans.length === 0 && (
  <div className="flex items-center justify-between">
    <p className="text-xs text-[#adaaaa]">
      Crea primero un plan nutricional para poder asignarlo.
    </p>
    <button
      onClick={() => navigate('/nutriologo/planes')}
      className="text-xs text-[#cafd00] hover:underline flex items-center gap-1"
    >
      <Plus size={12} /> Crear plan
    </button>
  </div>
)}
```
Also add `Plus` to lucide imports and `useNavigate` to react-router imports (check if already present — `useNavigate` IS already imported via NutriologoLayout indirectly, but must be imported in Pacientes.jsx itself).

### 3c. Show plan meals in patient detail

After the "Plan actual" / "Objetivo" grid cards (line ~411), add a collapsible meals section that fetches on demand:

```js
const [patientPlanMeals, setPatientPlanMeals] = useState([]);
const [mealsLoading, setMealsLoading] = useState(false);

// When selectedPatient changes AND has an assignment, fetch plan detail for meals
useEffect(() => {
  if (!selectedPatient?.assignment_id || !selectedPatient?.current_plan_id) return;
  // GET /api/nutriologo/planes/{selectedPatient.current_plan_id}
  // set setPatientPlanMeals(detail.meals)
}, [selectedPatient?.current_plan_id]);
```

**Note:** The `clientes` endpoint currently returns `current_plan` (name string) but NOT `current_plan_id`. This requires a small backend addition OR derive via a second call. **Recommended:** Add `current_plan_id` to the `clientes` subselect in `NutriologoController::clientes`. 

Add to the subselect in `clientes()` method:
```php
DB::raw("({$assignSub->toSql()}) as assignment_id"),
DB::raw("(SELECT np.id FROM nutrition_plans np 
    JOIN nutrition_plan_assignments npa2 ON npa2.nutrition_plan_id = np.id 
    WHERE npa2.client_id = u.user_id AND npa2.nutriologo_id = {$nutriologo->id}
    ORDER BY npa2.assigned_at DESC LIMIT 1) as current_plan_id"),
```

Then in JSX, after the 2-col grid (line ~411):
```jsx
{patientPlanMeals.length > 0 && (
  <div className="rounded-xl bg-[#131313] p-4 border border-[#484847]/10">
    <p className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa] mb-3">Comidas del plan actual</p>
    <div className="space-y-2">
      {patientPlanMeals.map((meal) => (
        <div key={meal.id} className="flex items-center justify-between py-2 border-b border-[#484847]/10 last:border-0">
          <div>
            <span className="text-[10px] uppercase text-[#adaaaa]">{mealTypeLabels[meal.meal_type]}</span>
            <p className="text-sm text-white">{meal.name}</p>
            <p className="text-[10px] text-[#adaaaa]">{meal.portion}</p>
          </div>
          <div className="text-right">
            <p className="text-sm font-bold text-[#cafd00]">{meal.calories} kcal</p>
            <p className="text-[10px] text-[#adaaaa]">P:{meal.protein_g}g C:{meal.carbs_g}g G:{meal.fat_g}g</p>
          </div>
        </div>
      ))}
    </div>
  </div>
)}
```

### 3d. Replace static "Sin seguimiento reciente" chip with actionable state

Replace lines ~421-425:
```jsx
<div className="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-[#131313] text-[#adaaaa]">
  <ClipboardList size={15} />
  {selectedPatient.last_update
    ? selectedPatient.last_update
    : <span className="italic">Sin seguimiento reciente</span>
  }
</div>
```

**Verification:** Import `useNavigate` in Pacientes.jsx top — `import { useNavigate, useLocation } from 'react-router-dom'`.

---

## Phase 4 — Fix Dashboard Action Buttons

**File:** `api-backend/resources/js/pages/Nutriologo/Dashboard.jsx`

### Lines 281-292 — Pass patient ID in navigate state

```jsx
// "Plan" button (line 282):
onClick={() => navigate('/nutriologo/pacientes', { state: { patientId: paciente.id } })}

// "Seguimiento" button (line 288):
onClick={() => navigate('/nutriologo/pacientes', { state: { patientId: paciente.id } })}
```

**Verification:** Click "Plan" on a patient row → Pacientes page opens with that patient pre-selected in the detail panel.

---

## Phase 5 — Backend Addition: `current_plan_id` in clientes endpoint

**File:** `api-backend/app/Http/Controllers/Nutriologo/NutriologoController.php`

In the `clientes()` method, the query currently returns `current_plan` (plan title string). Add `current_plan_id` as an additional subselect so the frontend can fetch plan meals.

Find the `->selectRaw(...)` block in `clientes()` and add:
```php
DB::raw("(SELECT npa_inner.nutrition_plan_id 
    FROM nutrition_plan_assignments npa_inner
    WHERE npa_inner.client_id = u.user_id 
      AND npa_inner.nutriologo_id = {$nutriologo->id}
    ORDER BY npa_inner.assigned_at DESC 
    LIMIT 1) as current_plan_id"),
```

**Verification:** `GET /api/nutriologo/clientes` response includes `current_plan_id` field on each patient object.

---

## Execution Order

1. Phase 1 (wiring) — no risk, enables navigation
2. Phase 5 (backend `current_plan_id`) — needed before Phase 3c works
3. Phase 2 (Planes.jsx) — largest task, self-contained
4. Phase 3 (Pacientes.jsx completions) — depends on Phase 5 for meals
5. Phase 4 (Dashboard fix) — trivial, depends on Phase 3a being in place

---

## Files Modified / Created

| Action | File |
|--------|------|
| MODIFY | `api-backend/resources/js/pages/Nutriologo/NutriologoLayout.jsx` |
| MODIFY | `api-backend/resources/js/app.jsx` |
| CREATE | `api-backend/resources/js/pages/Nutriologo/Planes.jsx` |
| MODIFY | `api-backend/resources/js/pages/Nutriologo/Pacientes.jsx` |
| MODIFY | `api-backend/resources/js/pages/Nutriologo/Dashboard.jsx` |
| MODIFY | `api-backend/app/Http/Controllers/Nutriologo/NutriologoController.php` |
