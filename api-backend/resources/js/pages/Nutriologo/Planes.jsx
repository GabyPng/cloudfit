import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  AlertTriangle,
  CheckCircle2,
  ChevronDown,
  ClipboardList,
  Edit2,
  FileText,
  Loader2,
  Plus,
  Printer,
  RefreshCw,
  Search,
  Trash2,
  UserX,
  Users,
  X,
  Utensils,
  ToggleLeft,
  ToggleRight,
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { syncLocalUserProfile } from '../../lib/localUserSync';
import { track } from '../../lib/analytics';
import KpiCard from '../Coach/components/KpiCard';
import NutriologoLayout from './NutriologoLayout';

const MEAL_TYPES = [
  { value: 'desayuno', label: 'Desayuno' },
  { value: 'colacion_1', label: 'Colación 1' },
  { value: 'comida', label: 'Comida' },
  { value: 'colacion_2', label: 'Colación 2' },
  { value: 'cena', label: 'Cena' },
];

const MEAL_TYPE_LABELS = Object.fromEntries(MEAL_TYPES.map((t) => [t.value, t.label]));

const emptyMeal = () => ({
  meal_type: 'desayuno',
  name: '',
  portion: '',
  calories: '',
  protein_g: '',
  carbs_g: '',
  fat_g: '',
  notes: '',
});

const emptyPlanForm = {
  title: '',
  description: '',
  goal: '',
  daily_calories: '',
  macro_targets: { proteinas: 30, carbohidratos: 50, grasas: 20 },
  starts_at: '',
  ends_at: '',
  meals: [],
};

const MEAL_TYPE_ICONS = {
  desayuno: '🌅', colacion_1: '🍎', comida: '🍽️', colacion_2: '🥜', cena: '🌙',
};

function esc(str) {
  return String(str ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function printNutritionPlan(plan, meals = []) {
  const totalCalories = meals.reduce((s, m) => s + (Number(m.calories) || 0), 0);
  const totalProtein  = meals.reduce((s, m) => s + (Number(m.protein_g) || 0), 0);
  const totalCarbs    = meals.reduce((s, m) => s + (Number(m.carbs_g) || 0), 0);
  const totalFat      = meals.reduce((s, m) => s + (Number(m.fat_g) || 0), 0);

  const mealTypeLabel = { desayuno:'Desayuno', colacion_1:'Colación 1', comida:'Comida', colacion_2:'Colación 2', cena:'Cena' };

  const html = `<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<title>Plan Nutricional — ${esc(plan.title)}</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Arial,sans-serif;font-size:11px;color:#111;padding:12mm 16mm}
.hdr{border-bottom:3px solid #111;padding-bottom:10px;margin-bottom:14px;display:flex;justify-content:space-between;align-items:flex-end}
.hdr h1{font-size:18px;font-weight:900;text-transform:uppercase}
.hdr .meta{font-size:9px;color:#555;text-align:right}
.plan-header{background:#f5f5f5;padding:12px 16px;border-radius:6px;margin-bottom:14px}
.plan-title{font-size:16px;font-weight:900;text-transform:uppercase;margin-bottom:4px}
.plan-goal{font-size:11px;color:#555;margin-bottom:6px}
.plan-desc{font-size:10px;color:#777}
.badges{display:flex;gap:8px;margin-top:8px;flex-wrap:wrap}
.badge{background:#111;color:#fff;font-size:8px;font-weight:700;padding:3px 8px;border-radius:3px;text-transform:uppercase;letter-spacing:.5px}
.badge.green{background:#2d4a00;color:#cafd00}
.section-title{font-size:10px;font-weight:900;text-transform:uppercase;letter-spacing:.8px;color:#555;margin:12px 0 6px}
.macros-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:14px}
.macro-card{border:1px solid #ddd;border-radius:5px;padding:8px 10px;text-align:center}
.macro-val{font-size:20px;font-weight:900}
.macro-lbl{font-size:8px;color:#777;text-transform:uppercase;letter-spacing:.5px;margin-top:2px}
.macro-sub{font-size:9px;color:#999;margin-top:1px}
table{width:100%;border-collapse:collapse;margin-bottom:14px}
thead th{background:#111;color:#fff;padding:6px 8px;text-align:left;font-size:9px;text-transform:uppercase;letter-spacing:.5px}
tbody tr:nth-child(even){background:#f9f9f9}
tbody td{padding:6px 8px;font-size:10px;border-bottom:1px solid #eee;vertical-align:top}
.meal-type{font-weight:700;font-size:9px;text-transform:uppercase;color:#555}
.meal-name{font-weight:600}
.meal-portion{font-size:9px;color:#777}
.meal-notes{font-size:9px;color:#999;font-style:italic}
.totals-row td{background:#f0f0f0;font-weight:700;border-top:2px solid #111}
.summary-bar{display:flex;gap:20px;background:#f5f5f5;border:1px solid #ddd;padding:10px 14px;border-radius:5px;margin-bottom:10px;align-items:center}
.summary-bar h3{font-size:10px;font-weight:900;text-transform:uppercase;color:#555;white-space:nowrap}
.stat{text-align:center}
.stat-val{font-size:18px;font-weight:900;line-height:1}
.stat-lbl{font-size:7px;color:#888;text-transform:uppercase;letter-spacing:.5px;margin-top:2px}
.ftr{border-top:1px solid #ccc;padding-top:8px;font-size:8px;color:#aaa;display:flex;justify-content:space-between}
</style></head><body>
<div class="hdr">
  <div><h1>Plan Nutricional</h1></div>
  <div class="meta">
    Generado el ${new Date().toLocaleDateString('es-MX',{year:'numeric',month:'long',day:'numeric'})}<br>
    CloudFit — Sistema de Gestión Nutricional
  </div>
</div>
<div class="plan-header">
  <div class="plan-title">${esc(plan.title)}</div>
  ${plan.goal ? `<div class="plan-goal">Objetivo: ${esc(plan.goal)}</div>` : ''}
  ${plan.description ? `<div class="plan-desc">${esc(plan.description)}</div>` : ''}
  <div class="badges">
    ${plan.daily_calories ? `<span class="badge green">${esc(plan.daily_calories)} kcal/día</span>` : ''}
    ${meals.length ? `<span class="badge">${meals.length} comidas</span>` : ''}
    ${plan.starts_at ? `<span class="badge">Inicio: ${esc(plan.starts_at)}</span>` : ''}
    ${plan.ends_at ? `<span class="badge">Fin: ${esc(plan.ends_at)}</span>` : ''}
    <span class="badge">${plan.is_active ? 'ACTIVO' : 'INACTIVO'}</span>
  </div>
</div>
${plan.macro_targets ? `
<p class="section-title">Distribución de Macros</p>
<div class="macros-grid">
  <div class="macro-card">
    <div class="macro-val" style="color:#6b46c1">${esc(plan.macro_targets.proteinas ?? 0)}%</div>
    <div class="macro-lbl">Proteínas</div>
    ${totalProtein > 0 ? `<div class="macro-sub">${totalProtein.toFixed(1)}g total</div>` : ''}
  </div>
  <div class="macro-card">
    <div class="macro-val" style="color:#b7791f">${esc(plan.macro_targets.carbohidratos ?? 0)}%</div>
    <div class="macro-lbl">Carbohidratos</div>
    ${totalCarbs > 0 ? `<div class="macro-sub">${totalCarbs.toFixed(1)}g total</div>` : ''}
  </div>
  <div class="macro-card">
    <div class="macro-val" style="color:#c05621">${esc(plan.macro_targets.grasas ?? 0)}%</div>
    <div class="macro-lbl">Grasas</div>
    ${totalFat > 0 ? `<div class="macro-sub">${totalFat.toFixed(1)}g total</div>` : ''}
  </div>
</div>` : ''}
${meals.length > 0 ? `
<p class="section-title">Comidas del Plan</p>
<table>
  <thead>
    <tr>
      <th style="width:18%">Tipo</th>
      <th>Nombre / Porción</th>
      <th style="width:10%;text-align:right">Kcal</th>
      <th style="width:10%;text-align:right">Prot.</th>
      <th style="width:10%;text-align:right">Carbs</th>
      <th style="width:10%;text-align:right">Grasas</th>
    </tr>
  </thead>
  <tbody>
    ${meals.map(m => `
    <tr>
      <td><div class="meal-type">${esc(mealTypeLabel[m.meal_type] ?? m.meal_type)}</div></td>
      <td>
        <div class="meal-name">${esc(m.name || '—')}</div>
        ${m.portion ? `<div class="meal-portion">${esc(m.portion)}</div>` : ''}
        ${m.notes ? `<div class="meal-notes">${esc(m.notes)}</div>` : ''}
      </td>
      <td style="text-align:right">${m.calories != null ? esc(m.calories) : '—'}</td>
      <td style="text-align:right">${m.protein_g != null ? `${esc(m.protein_g)}g` : '—'}</td>
      <td style="text-align:right">${m.carbs_g != null ? `${esc(m.carbs_g)}g` : '—'}</td>
      <td style="text-align:right">${m.fat_g != null ? `${esc(m.fat_g)}g` : '—'}</td>
    </tr>`).join('')}
    ${totalCalories > 0 ? `
    <tr class="totals-row">
      <td colspan="2">TOTAL</td>
      <td style="text-align:right">${Math.round(totalCalories)}</td>
      <td style="text-align:right">${totalProtein.toFixed(1)}g</td>
      <td style="text-align:right">${totalCarbs.toFixed(1)}g</td>
      <td style="text-align:right">${totalFat.toFixed(1)}g</td>
    </tr>` : ''}
  </tbody>
</table>` : '<p style="font-size:10px;color:#999;margin-bottom:14px;font-style:italic">Sin comidas configuradas en este plan.</p>'}
<div class="ftr">
  <span>CloudFit — Plan: ${esc(plan.title)}</span>
  <span>Impreso el ${new Date().toLocaleDateString('es-MX')}</span>
</div>
</body></html>`;

  const win = window.open('', '_blank', 'width=900,height=750');
  win.document.write(html);
  win.document.close();
  win.focus();
  win.print();
}

function MacroBar({ label, value, color }) {
  const pct = Math.min(100, Math.max(0, Number(value) || 0));
  return (
    <div>
      <div className="flex justify-between text-[10px] text-[#adaaaa] mb-1">
        <span>{label}</span>
        <span>{pct}%</span>
      </div>
      <div className="h-1.5 bg-[#262626] rounded-full overflow-hidden">
        <div className={`h-full rounded-full transition-all duration-500 ${color}`} style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

export default function NutriologoPlanesPage() {
  const navigate = useNavigate();
  const [nutriologoName, setNutriologoName] = useState('Nutriólogo');
  const [plans, setPlans] = useState([]);
  const [meta, setMeta] = useState({ current_page: 1, last_page: 1, total: 0, has_more: false });
  const [patients, setPatients] = useState([]);
  const [selectedPlanId, setSelectedPlanId] = useState(null);
  const [planDetail, setPlanDetail] = useState(null);
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [refreshTick, setRefreshTick] = useState(0);
  const [loading, setLoading] = useState(true);
  const [detailLoading, setDetailLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [toast, setToast] = useState(null);

  const [modal, setModal] = useState(null); // null | 'create' | 'edit' | 'delete-confirm'
  const [planForm, setPlanForm] = useState(emptyPlanForm);
  const [assignForm, setAssignForm] = useState({ clientId: '', notes: '', starts_at: '' });

  const selectedPlan = useMemo(
    () => plans.find((p) => String(p.id) === String(selectedPlanId)) ?? null,
    [plans, selectedPlanId],
  );

  const kpis = useMemo(() => ({
    total: meta.total,
    activos: plans.filter((p) => p.is_active).length,
    sinPlan: patients.filter((p) => !p.current_plan_id).length,
    asignados: plans.reduce((sum, p) => sum + (p.assignments_count ?? 0), 0),
  }), [plans, meta.total, patients]);

  const getToken = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    return session?.access_token ?? null;
  };

  const requestJson = async (url, options = {}) => {
    let token = await getToken();
    if (!token) throw new Error('Sesión no encontrada.');

    const makeReq = (t) => fetch(url, {
      ...options,
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        Authorization: `Bearer ${t}`,
        ...(options.headers ?? {}),
      },
    });

    let res = await makeReq(token);

    if (res.status === 401) {
      const { data: { session } } = await supabase.auth.getSession();
      await syncLocalUserProfile(session).catch(() => null);
      token = session?.access_token;
      res = await makeReq(token);
    }

    if (!res.ok) {
      const body = await res.json().catch(() => ({}));
      throw new Error(body?.message ?? `Error ${res.status}`);
    }

    return res.json();
  };

  // Load plans list
  useEffect(() => {
    let ignore = false;
    const load = async () => {
      try {
        setLoading(true);
        const { data: { session } } = await supabase.auth.getSession();
        const name =
          session?.user?.user_metadata?.full_name ||
          session?.user?.user_metadata?.name ||
          session?.user?.email?.split('@')[0] ||
          'Nutriólogo';
        setNutriologoName(name);

        const params = new URLSearchParams({ per_page: 20, page });
        if (search) params.set('search', search);

        const payload = await requestJson(`/api/nutriologo/planes?${params}`);
        if (!ignore) {
          setPlans(payload.data ?? []);
          setMeta(payload.meta ?? { current_page: 1, last_page: 1, total: 0 });
        }
      } catch (err) {
        if (!ignore) showToast(err.message, 'error');
      } finally {
        if (!ignore) setLoading(false);
      }
    };
    load();
    return () => { ignore = true; };
  }, [search, page, refreshTick]);

  // Load plan detail
  useEffect(() => {
    if (!selectedPlanId) { setPlanDetail(null); return; }
    let ignore = false;
    const load = async () => {
      try {
        setDetailLoading(true);
        const payload = await requestJson(`/api/nutriologo/planes/${selectedPlanId}`);
        if (!ignore) setPlanDetail(payload.data ?? payload);
      } catch {
        if (!ignore) setPlanDetail(null);
      } finally {
        if (!ignore) setDetailLoading(false);
      }
    };
    load();
    return () => { ignore = true; };
  }, [selectedPlanId, refreshTick]);

  // Load patients for assign dropdown (once)
  useEffect(() => {
    requestJson('/api/nutriologo/clientes?per_page=50')
      .then((payload) => setPatients(payload.data ?? []))
      .catch(() => {});
  }, []);

  const refresh = () => setRefreshTick((v) => v + 1);

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3500);
  };

  const openCreate = () => {
    setPlanForm(emptyPlanForm);
    setModal('create');
  };

  const openEdit = () => {
    if (!planDetail) return;
    setPlanForm({
      title: planDetail.title ?? '',
      description: planDetail.description ?? '',
      goal: planDetail.goal ?? '',
      daily_calories: planDetail.daily_calories ?? '',
      macro_targets: planDetail.macro_targets ?? { proteinas: 30, carbohidratos: 50, grasas: 20 },
      starts_at: planDetail.starts_at ?? '',
      ends_at: planDetail.ends_at ?? '',
      meals: (planDetail.meals ?? []).map((m) => ({
        meal_type: m.meal_type,
        name: m.name ?? '',
        portion: m.portion ?? '',
        calories: m.calories ?? '',
        protein_g: m.protein_g ?? '',
        carbs_g: m.carbs_g ?? '',
        fat_g: m.fat_g ?? '',
        notes: m.notes ?? '',
      })),
    });
    setModal('edit');
  };

  const handleSavePlan = async () => {
    if (!planForm.title.trim()) { showToast('El título del plan es requerido.', 'error'); return; }
    try {
      setSaving(true);
      const body = {
        ...planForm,
        daily_calories: planForm.daily_calories !== '' ? Number(planForm.daily_calories) : null,
        meals: planForm.meals.map((m, i) => ({
          ...m,
          calories: m.calories !== '' ? Number(m.calories) : null,
          protein_g: m.protein_g !== '' ? Number(m.protein_g) : null,
          carbs_g: m.carbs_g !== '' ? Number(m.carbs_g) : null,
          fat_g: m.fat_g !== '' ? Number(m.fat_g) : null,
          position: i,
        })),
      };

      if (modal === 'create') {
        await requestJson('/api/nutriologo/planes', { method: 'POST', body: JSON.stringify(body) });
        track('plan_created', { plan_title: body.title, meals_count: body.meals.length, daily_calories: body.daily_calories ?? null });
        showToast('Plan nutricional creado correctamente.');
      } else {
        await requestJson(`/api/nutriologo/planes/${selectedPlanId}`, { method: 'PUT', body: JSON.stringify(body) });
        track('plan_updated', { plan_id: selectedPlanId });
        showToast('Plan actualizado correctamente.');
      }

      setModal(null);
      refresh();
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleDeletePlan = async () => {
    try {
      setSaving(true);
      await requestJson(`/api/nutriologo/planes/${selectedPlanId}`, { method: 'DELETE' });
      track('plan_deleted', { plan_id: selectedPlanId });
      setSelectedPlanId(null);
      setPlanDetail(null);
      setModal(null);
      showToast('Plan eliminado correctamente.');
      refresh();
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleToggleActive = async (plan) => {
    try {
      await requestJson(`/api/nutriologo/planes/${plan.id}`, {
        method: 'PUT',
        body: JSON.stringify({ is_active: !plan.is_active }),
      });
      showToast(plan.is_active ? 'Plan desactivado.' : 'Plan activado.');
      refresh();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const updateMeal = (index, field, value) => {
    setPlanForm((f) => {
      const meals = [...f.meals];
      meals[index] = { ...meals[index], [field]: value };
      return { ...f, meals };
    });
  };

  const removeMeal = (index) => {
    setPlanForm((f) => ({ ...f, meals: f.meals.filter((_, i) => i !== index) }));
  };

  return (
    <NutriologoLayout nutriologoName={nutriologoName}>
      {/* Toast */}
      {toast && (
        <div className={`fixed top-6 right-6 z-[100] flex items-center gap-3 px-5 py-4 rounded-2xl shadow-2xl border backdrop-blur-md transition-all duration-300 ${
          toast.type === 'error'
            ? 'bg-[#1a0f0f] border-red-500/30 text-red-300'
            : 'bg-[#0f1a00] border-[#cafd00]/30 text-[#f3ffca]'
        }`}>
          {toast.type === 'error' ? <AlertTriangle size={16} /> : <CheckCircle2 size={16} />}
          <span className="text-sm font-medium">{toast.message}</span>
          <button onClick={() => setToast(null)} className="ml-2 opacity-60 hover:opacity-100 transition-opacity"><X size={14} /></button>
        </div>
      )}

      <div className="grid grid-cols-12 gap-8">

        {/* Header */}
        <section className="col-span-12 flex flex-col gap-2">
          <p className="text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa]">Gestión de planes</p>
          <div className="flex items-end justify-between">
            <div>
              <h1 className="text-4xl font-black font-headline text-white">Planes Nutricionales</h1>
              <p className="text-sm text-[#adaaaa] max-w-2xl mt-1">
                Crea, edita y asigna planes nutricionales completos con comidas detalladas.
              </p>
            </div>
            <button
              onClick={openCreate}
              className="inline-flex items-center gap-2 px-5 py-3 rounded-xl bg-[#cafd00] text-[#405100] font-black uppercase tracking-tighter hover:bg-[#d4ff1a] transition-colors shadow-lg shadow-[#cafd00]/10"
            >
              <Plus size={16} />
              Nuevo Plan
            </button>
          </div>
        </section>

        {/* KPIs */}
        <section className="col-span-12 grid grid-cols-1 md:grid-cols-4 gap-6">
          <KpiCard label="Total Planes" value={kpis.total} icon={FileText} valueColor="text-[#cafd00]" />
          <KpiCard label="Planes Activos" value={kpis.activos} icon={CheckCircle2} iconColor="text-[#7ef0b3]" valueColor="text-[#7ef0b3]" />
          <KpiCard label="Sin plan asignado" value={kpis.sinPlan} icon={UserX} iconColor="text-[#ff7351]" valueColor="text-[#ff7351]" />
          <KpiCard label="Pacientes Asignados" value={kpis.asignados} icon={Users} iconColor="text-[#fce047]" valueColor="text-[#fce047]" />
        </section>

        {/* Search + Refresh */}
        <section className="col-span-12 bg-[#1a1a1a] rounded-xl p-4 flex gap-4 border border-[#484847]/10">
          <div className="relative flex-1">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#adaaaa]" />
            <input
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(1); }}
              type="text"
              placeholder="Buscar por título u objetivo..."
              className="w-full bg-[#131313] rounded-lg pl-10 pr-4 py-3 text-sm text-white placeholder-[#777] focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
            />
          </div>
          <button
            onClick={refresh}
            className="inline-flex items-center gap-2 px-4 py-3 rounded-xl bg-[#1e1e1e] text-[#f3ffca] hover:bg-[#262626] transition-colors border border-white/5 font-black uppercase tracking-tighter text-xs"
          >
            <RefreshCw size={15} />
            Recargar
          </button>
        </section>

        {/* Plan list + Detail panel */}
        <section className="col-span-12 lg:col-span-7 bg-[#1a1a1a] rounded-xl overflow-hidden border border-[#484847]/10">
          <div className="px-6 py-5 border-b border-[#484847]/10 flex items-center justify-between">
            <div>
              <h2 className="text-xl font-bold font-headline">Listado de planes</h2>
              <p className="text-xs text-[#adaaaa] mt-1">Selecciona un plan para ver sus detalles y comidas.</p>
            </div>
            <span className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa]">
              Página {meta.current_page} / {meta.last_page}
            </span>
          </div>

          {loading ? (
            <div className="min-h-80 flex items-center justify-center text-[#f3ffca] gap-3">
              <Loader2 className="animate-spin" size={18} />
              <span>Cargando planes...</span>
            </div>
          ) : plans.length === 0 ? (
            <div className="min-h-80 flex flex-col items-center justify-center gap-4 text-center px-6">
              <div className="w-14 h-14 rounded-full bg-[#262626] flex items-center justify-center">
                <FileText size={24} className="text-[#adaaaa]" />
              </div>
              <div>
                <p className="text-white font-bold">No hay planes todavía</p>
                <p className="text-sm text-[#adaaaa] mt-1">Crea tu primer plan nutricional para tus pacientes.</p>
              </div>
              <button
                onClick={openCreate}
                className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#cafd00] text-[#405100] font-black uppercase tracking-tighter text-xs shadow-lg shadow-[#cafd00]/10"
              >
                <Plus size={14} />
                Crear primer plan
              </button>
            </div>
          ) : (
            <div className="divide-y divide-[#484847]/5">
              {plans.map((plan) => (
                <div
                  key={plan.id}
                  role="button"
                  tabIndex={0}
                  onClick={() => setSelectedPlanId(String(plan.id))}
                  onKeyDown={(e) => e.key === 'Enter' && setSelectedPlanId(String(plan.id))}
                  className={`w-full text-left px-6 py-4 transition-colors hover:bg-[#20201f] group cursor-pointer ${String(selectedPlanId) === String(plan.id) ? 'bg-[#1e1e1e] border-l-4 border-l-[#cafd00]' : ''}`}
                >
                  <div className="flex items-start justify-between gap-4">
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <p className="text-sm font-bold text-white truncate">{plan.title}</p>
                        <span className={`text-[9px] uppercase tracking-widest px-2 py-0.5 rounded-full ${plan.is_active ? 'bg-[#cafd00]/15 text-[#f3ffca] border border-[#cafd00]/30' : 'bg-[#262626] text-[#6f6f6f] border border-[#484847]/20'}`}>
                          {plan.is_active ? 'Activo' : 'Inactivo'}
                        </span>
                      </div>
                      {plan.goal && (
                        <p className="text-xs text-[#adaaaa] mt-0.5 truncate">{plan.goal}</p>
                      )}
                      <div className="flex items-center gap-4 mt-2 text-[10px] text-[#6f6f6f]">
                        <span className="flex items-center gap-1"><Utensils size={10} />{plan.meals_count ?? 0} comidas</span>
                        <span className="flex items-center gap-1"><Users size={10} />{plan.assignments_count ?? 0} asignados</span>
                        {plan.daily_calories && <span>{plan.daily_calories} kcal/día</span>}
                      </div>
                    </div>
                    <button
                      onClick={(e) => { e.stopPropagation(); handleToggleActive(plan); }}
                      className="shrink-0 text-[#adaaaa] hover:text-[#cafd00] transition-colors"
                      title={plan.is_active ? 'Desactivar' : 'Activar'}
                    >
                      {plan.is_active ? <ToggleRight size={22} className="text-[#cafd00]" /> : <ToggleLeft size={22} />}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Pagination */}
          {meta.last_page > 1 && (
            <div className="px-6 py-4 border-t border-[#484847]/10 flex justify-between items-center text-[10px] text-[#adaaaa] font-headline uppercase tracking-widest">
              <button
                disabled={page <= 1}
                onClick={() => setPage((p) => p - 1)}
                className="hover:text-[#f3ffca] disabled:opacity-30 transition-colors"
              >
                Anterior
              </button>
              <span>{meta.current_page} / {meta.last_page}</span>
              <button
                disabled={page >= meta.last_page}
                onClick={() => setPage((p) => p + 1)}
                className="hover:text-[#f3ffca] disabled:opacity-30 transition-colors"
              >
                Siguiente
              </button>
            </div>
          )}
        </section>

        {/* Detail panel */}
        <section className="col-span-12 lg:col-span-5 bg-[#1a1a1a] rounded-xl p-6 border border-[#484847]/10 flex flex-col gap-6">
          {!selectedPlan ? (
            <div className="min-h-80 flex flex-col items-center justify-center text-center gap-3">
              <ClipboardList size={32} className="text-[#484847]" />
              <p className="text-sm text-[#adaaaa]">Selecciona un plan para ver sus detalles.</p>
            </div>
          ) : (
            <>
              {/* Plan header */}
              <div>
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <h2 className="text-2xl font-black font-headline text-white leading-tight">{selectedPlan.title}</h2>
                    {selectedPlan.goal && (
                      <p className="text-sm text-[#adaaaa] mt-1">{selectedPlan.goal}</p>
                    )}
                  </div>
                  <div className="flex gap-2 shrink-0">
                    <button
                      onClick={() => printNutritionPlan(selectedPlan, planDetail?.meals ?? [])}
                      className="p-2 rounded-lg bg-[#262626] text-[#adaaaa] hover:text-[#f3ffca] transition-colors"
                      title="Imprimir plan"
                    >
                      <Printer size={15} />
                    </button>
                    <button
                      onClick={openEdit}
                      className="p-2 rounded-lg bg-[#262626] text-[#adaaaa] hover:text-[#f3ffca] transition-colors"
                      title="Editar plan"
                    >
                      <Edit2 size={15} />
                    </button>
                    <button
                      onClick={() => setModal('delete-confirm')}
                      className="p-2 rounded-lg bg-[#262626] text-[#adaaaa] hover:text-[#ff7351] transition-colors"
                      title="Eliminar plan"
                    >
                      <Trash2 size={15} />
                    </button>
                  </div>
                </div>

                {selectedPlan.daily_calories && (
                  <div className="mt-3 inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-[#131313] text-sm">
                    <span className="text-[#cafd00] font-bold">{selectedPlan.daily_calories}</span>
                    <span className="text-[#adaaaa] text-xs">kcal/día</span>
                  </div>
                )}
              </div>

              {/* Macro bars */}
              {selectedPlan.macro_targets && (
                <div className="rounded-xl bg-[#131313] p-4 space-y-3">
                  <p className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa] mb-2">Distribución de macros</p>
                  <MacroBar label="Proteínas" value={selectedPlan.macro_targets?.proteinas ?? 0} color="bg-[#ac8aff]" />
                  <MacroBar label="Carbohidratos" value={selectedPlan.macro_targets?.carbohidratos ?? 0} color="bg-[#fce047]" />
                  <MacroBar label="Grasas" value={selectedPlan.macro_targets?.grasas ?? 0} color="bg-[#ff7351]" />
                </div>
              )}

              {/* Meals */}
              <div className="rounded-xl bg-[#131313] p-4 border border-[#484847]/10">
                <p className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa] mb-3">
                  Comidas del plan {detailLoading && <Loader2 size={10} className="inline animate-spin ml-1" />}
                </p>
                {!planDetail || (planDetail.meals ?? []).length === 0 ? (
                  <p className="text-xs text-[#6f6f6f] italic">Sin comidas configuradas. Edita el plan para agregar.</p>
                ) : (
                  <div className="space-y-2">
                    {(planDetail?.meals ?? []).map((meal) => (
                      <div key={meal.id} className="flex items-center justify-between py-2.5 border-b border-[#484847]/10 last:border-0">
                        <div className="min-w-0">
                          <span className="text-[9px] uppercase tracking-widest text-[#adaaaa]">{MEAL_TYPE_LABELS[meal.meal_type] ?? meal.meal_type}</span>
                          <p className="text-sm text-white font-medium truncate">{meal.name}</p>
                          {meal.portion && <p className="text-[10px] text-[#6f6f6f]">{meal.portion}</p>}
                        </div>
                        <div className="text-right shrink-0 ml-3">
                          {meal.calories && <p className="text-sm font-bold text-[#cafd00]">{meal.calories} kcal</p>}
                          <p className="text-[10px] text-[#adaaaa]">
                            P:{meal.protein_g ?? '—'}g&nbsp;C:{meal.carbs_g ?? '—'}g&nbsp;G:{meal.fat_g ?? '—'}g
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Assign to patient */}
              <div className="rounded-xl bg-[#131313] p-4 border border-[#484847]/10">
                <h3 className="text-sm font-bold text-white mb-3">Asignar a paciente</h3>
                <div className="space-y-3">
                  <select
                    value={assignForm.clientId}
                    onChange={(e) => setAssignForm((f) => ({ ...f, clientId: e.target.value }))}
                    disabled={patients.length === 0}
                    className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00] disabled:opacity-50"
                  >
                    <option value="">{patients.length === 0 ? 'Sin pacientes disponibles' : 'Selecciona un paciente'}</option>
                    {patients.map((p) => (
                      <option key={p.id} value={p.id}>{p.name} — {p.email}</option>
                    ))}
                  </select>

                  <input
                    type="date"
                    value={assignForm.starts_at}
                    onChange={(e) => setAssignForm((f) => ({ ...f, starts_at: e.target.value }))}
                    className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                  />

                  <textarea
                    rows={2}
                    value={assignForm.notes}
                    onChange={(e) => setAssignForm((f) => ({ ...f, notes: e.target.value }))}
                    placeholder="Notas para el paciente..."
                    className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00] resize-none"
                  />
                </div>
              </div>
            </>
          )}
        </section>
      </div>

      {/* Create / Edit Modal */}
      {(modal === 'create' || modal === 'edit') && (
        <div className="fixed inset-0 z-50 flex items-start justify-end bg-black/60 backdrop-blur-sm overflow-y-auto">
          <div className="w-full max-w-2xl bg-[#131313] min-h-screen p-8 flex flex-col gap-6 shadow-2xl">
            <div className="flex items-center justify-between">
              <h2 className="text-2xl font-black font-headline text-white">
                {modal === 'create' ? 'Nuevo Plan Nutricional' : 'Editar Plan'}
              </h2>
              <button
                onClick={() => setModal(null)}
                className="p-2 rounded-xl bg-[#1e1e1e] text-[#adaaaa] hover:text-white transition-colors border border-white/5"
              >
                <X size={18} />
              </button>
            </div>

            {/* Plan fields */}
            <div className="space-y-4">
              <p className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa]">Información general</p>

              <div>
                <label className="text-xs text-[#adaaaa] mb-1 block">Título *</label>
                <input
                  value={planForm.title}
                  onChange={(e) => setPlanForm((f) => ({ ...f, title: e.target.value }))}
                  placeholder="Ej. Plan hipocalórico fase 1"
                  className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                />
              </div>

              <div>
                <label className="text-xs text-[#adaaaa] mb-1 block">Objetivo</label>
                <input
                  value={planForm.goal}
                  onChange={(e) => setPlanForm((f) => ({ ...f, goal: e.target.value }))}
                  placeholder="Ej. Pérdida de peso, aumento de masa muscular..."
                  className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                />
              </div>

              <div>
                <label className="text-xs text-[#adaaaa] mb-1 block">Descripción</label>
                <textarea
                  rows={2}
                  value={planForm.description}
                  onChange={(e) => setPlanForm((f) => ({ ...f, description: e.target.value }))}
                  placeholder="Descripción breve del plan..."
                  className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00] resize-none"
                />
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="text-xs text-[#adaaaa] mb-1 block">Calorías/día</label>
                  <input
                    type="number"
                    value={planForm.daily_calories}
                    onChange={(e) => setPlanForm((f) => ({ ...f, daily_calories: e.target.value }))}
                    placeholder="2000"
                    className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                  />
                </div>
                <div>
                  <label className="text-xs text-[#adaaaa] mb-1 block">Inicio</label>
                  <input
                    type="date"
                    value={planForm.starts_at}
                    onChange={(e) => setPlanForm((f) => ({ ...f, starts_at: e.target.value }))}
                    className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                  />
                </div>
                <div>
                  <label className="text-xs text-[#adaaaa] mb-1 block">Fin</label>
                  <input
                    type="date"
                    value={planForm.ends_at}
                    onChange={(e) => setPlanForm((f) => ({ ...f, ends_at: e.target.value }))}
                    className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                  />
                </div>
              </div>

              {/* Macros */}
              <div>
                <p className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa] mb-3">Distribución de macros (%)</p>
                <div className="grid grid-cols-3 gap-3">
                  {[
                    { key: 'proteinas', label: 'Proteínas', color: 'text-[#ac8aff]' },
                    { key: 'carbohidratos', label: 'Carbohidratos', color: 'text-[#fce047]' },
                    { key: 'grasas', label: 'Grasas', color: 'text-[#ff7351]' },
                  ].map(({ key, label, color }) => (
                    <div key={key}>
                      <label className={`text-xs mb-1 block ${color}`}>{label}</label>
                      <input
                        type="number"
                        min="0"
                        max="100"
                        value={planForm.macro_targets[key] ?? ''}
                        onChange={(e) => setPlanForm((f) => ({
                          ...f,
                          macro_targets: { ...f.macro_targets, [key]: e.target.value },
                        }))}
                        className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                      />
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Meals */}
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <p className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa]">
                  Comidas ({planForm.meals.length})
                </p>
                <button
                  onClick={() => setPlanForm((f) => ({ ...f, meals: [...f.meals, emptyMeal()] }))}
                  className="inline-flex items-center gap-1.5 text-xs text-[#cafd00] hover:text-[#d4ff1a] transition-colors"
                >
                  <Plus size={13} />
                  Agregar comida
                </button>
              </div>

              {planForm.meals.length === 0 && (
                <p className="text-xs text-[#6f6f6f] italic">Sin comidas. El plan se puede crear sin ellas y agregar después.</p>
              )}

              {planForm.meals.map((meal, i) => (
                <div key={i} className="bg-[#0e0e0e] rounded-xl p-4 border border-[#484847]/20 space-y-3">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xs font-bold text-[#f3ffca]">Comida {i + 1}</span>
                    <button onClick={() => removeMeal(i)} className="text-[#adaaaa] hover:text-[#ff7351] transition-colors">
                      <Trash2 size={13} />
                    </button>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="text-[10px] text-[#adaaaa] mb-1 block">Tipo</label>
                      <select
                        value={meal.meal_type}
                        onChange={(e) => updateMeal(i, 'meal_type', e.target.value)}
                        className="w-full bg-[#131313] rounded-lg px-3 py-2.5 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                      >
                        {MEAL_TYPES.map((t) => (
                          <option key={t.value} value={t.value}>{t.label}</option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <label className="text-[10px] text-[#adaaaa] mb-1 block">Nombre</label>
                      <input
                        value={meal.name}
                        onChange={(e) => updateMeal(i, 'name', e.target.value)}
                        placeholder="Ej. Avena con fruta"
                        className="w-full bg-[#131313] rounded-lg px-3 py-2.5 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="text-[10px] text-[#adaaaa] mb-1 block">Porción</label>
                      <input
                        value={meal.portion}
                        onChange={(e) => updateMeal(i, 'portion', e.target.value)}
                        placeholder="Ej. 1 taza (250g)"
                        className="w-full bg-[#131313] rounded-lg px-3 py-2.5 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                      />
                    </div>
                    <div>
                      <label className="text-[10px] text-[#adaaaa] mb-1 block">Calorías</label>
                      <input
                        type="number"
                        value={meal.calories}
                        onChange={(e) => updateMeal(i, 'calories', e.target.value)}
                        placeholder="350"
                        className="w-full bg-[#131313] rounded-lg px-3 py-2.5 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-3 gap-3">
                    {[
                      { key: 'protein_g', label: 'Proteína (g)', color: 'text-[#ac8aff]' },
                      { key: 'carbs_g', label: 'Carbs (g)', color: 'text-[#fce047]' },
                      { key: 'fat_g', label: 'Grasas (g)', color: 'text-[#ff7351]' },
                    ].map(({ key, label, color }) => (
                      <div key={key}>
                        <label className={`text-[10px] mb-1 block ${color}`}>{label}</label>
                        <input
                          type="number"
                          value={meal[key]}
                          onChange={(e) => updateMeal(i, key, e.target.value)}
                          placeholder="0"
                          className="w-full bg-[#131313] rounded-lg px-3 py-2.5 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                        />
                      </div>
                    ))}
                  </div>

                  <div>
                    <label className="text-[10px] text-[#adaaaa] mb-1 block">Notas</label>
                    <input
                      value={meal.notes}
                      onChange={(e) => updateMeal(i, 'notes', e.target.value)}
                      placeholder="Notas adicionales..."
                      className="w-full bg-[#131313] rounded-lg px-3 py-2.5 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
                    />
                  </div>
                </div>
              ))}
            </div>

            <button
              onClick={handleSavePlan}
              disabled={saving}
              className="w-full inline-flex items-center justify-center gap-2 py-4 rounded-xl bg-[#cafd00] text-[#405100] font-black uppercase tracking-tighter disabled:opacity-50 shadow-lg shadow-[#cafd00]/10"
            >
              {saving ? <Loader2 className="animate-spin" size={16} /> : <FileText size={16} />}
              {modal === 'create' ? 'Crear Plan' : 'Guardar Cambios'}
            </button>
          </div>
        </div>
      )}

      {/* Delete confirmation */}
      {modal === 'delete-confirm' && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm">
          <div className="bg-[#131313] rounded-[2rem] p-8 max-w-sm w-full mx-4 flex flex-col gap-5 border border-white/5 shadow-2xl animate-in zoom-in-95 duration-300">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-2xl bg-[#3a1712] flex items-center justify-center shrink-0">
                <AlertTriangle size={18} className="text-[#ff7351]" />
              </div>
              <div>
                <h3 className="font-black uppercase tracking-tight text-white">Eliminar plan</h3>
                <p className="text-xs text-[#adaaaa] mt-0.5">Esta acción no se puede deshacer.</p>
              </div>
            </div>
            <p className="text-sm text-[#adaaaa]">
              ¿Seguro que deseas eliminar <span className="text-white font-bold">"{selectedPlan?.title}"</span>?
              Se perderán todas sus comidas y asignaciones.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setModal(null)}
                className="flex-1 py-3 rounded-xl bg-[#1e1e1e] text-[#adaaaa] hover:text-white transition-colors font-black uppercase tracking-tighter text-xs border border-white/5"
              >
                Cancelar
              </button>
              <button
                onClick={handleDeletePlan}
                disabled={saving}
                className="flex-1 py-3 rounded-xl bg-[#ff7351] text-white font-black uppercase tracking-tighter text-xs disabled:opacity-50 shadow-lg shadow-[#ff7351]/20"
              >
                {saving ? <Loader2 className="animate-spin mx-auto" size={14} /> : 'Eliminar'}
              </button>
            </div>
          </div>
        </div>
      )}
    </NutriologoLayout>
  );
}
