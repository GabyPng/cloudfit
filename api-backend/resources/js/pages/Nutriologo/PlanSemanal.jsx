import { useState, useEffect, useRef } from 'react';
import {
  CheckCircle, Loader2, AlertCircle, X, Save, Printer,
  Utensils, Search, Users, CalendarDays,
  FileText, ChevronDown,
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { syncLocalUserProfile } from '../../lib/localUserSync';
import NutriologoLayout from './NutriologoLayout';

const DAYS = [
  { key: 'Mon', label: 'LUNES' },
  { key: 'Tue', label: 'MARTES' },
  { key: 'Wed', label: 'MIÉRCOLES' },
  { key: 'Thu', label: 'JUEVES' },
  { key: 'Fri', label: 'VIERNES' },
  { key: 'Sat', label: 'SÁBADO' },
  { key: 'Sun', label: 'DOMINGO' },
];

const EMPTY_PLAN = () => Object.fromEntries(DAYS.map(d => [d.key, []]));

const GOAL_COLORS = {
  'Pérdida de peso': '#cafd00',
  'Aumento de masa': '#ac8aff',
  'Mantenimiento': '#7ef0b3',
  'Rendimiento': '#fce047',
  default: '#ff7351',
};

function goalColor(goal = '') {
  return GOAL_COLORS[goal] ?? GOAL_COLORS.default;
}

function esc(str) {
  return String(str ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function printWeeklyNutritionPlan(client, weeklyPlan, notes = '') {
  const days = DAYS.map(d => ({ ...d, plans: weeklyPlan[d.key] || [] }));
  const activeDays    = days.filter(d => d.plans.length > 0).length;
  const totalPlans    = days.reduce((s, d) => s + d.plans.length, 0);
  const totalCalories = days.reduce((s, d) => s + d.plans.reduce((ss, p) => ss + (Number(p.daily_calories) || 0), 0), 0);
  const avgCalories   = totalPlans > 0 ? Math.round(totalCalories / totalPlans) : 0;

  const html = `<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<title>Plan Semanal Nutricional — ${esc(client.name)}</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Arial,sans-serif;font-size:11px;color:#111;padding:12mm 16mm}
.hdr{border-bottom:3px solid #111;padding-bottom:10px;margin-bottom:14px;display:flex;justify-content:space-between;align-items:flex-end}
.hdr h1{font-size:18px;font-weight:900;text-transform:uppercase}
.hdr .meta{font-size:9px;color:#555;text-align:right}
.client-info{background:#f5f5f5;padding:10px 14px;border-radius:6px;margin-bottom:14px;display:flex;gap:20px;align-items:center}
.client-avatar{width:36px;height:36px;background:#111;color:#fff;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:14px;font-weight:900;flex-shrink:0}
.client-name{font-size:14px;font-weight:900;text-transform:uppercase}
.client-obj{font-size:10px;color:#666;margin-top:2px}
.week-grid{display:grid;grid-template-columns:repeat(7,1fr);gap:6px;margin-bottom:14px}
.day-col{border:1px solid #ddd;border-radius:5px;overflow:hidden;min-height:120px}
.day-header{background:#111;color:#fff;padding:5px 4px;text-align:center;font-size:8px;font-weight:900;text-transform:uppercase;letter-spacing:.8px}
.day-body{padding:6px;display:flex;flex-direction:column;gap:5px}
.rest-label{text-align:center;color:#bbb;font-size:9px;padding:16px 4px;font-style:italic}
.plan-card{border-left:3px solid #7ac70c;padding:4px 6px;background:#fafafa;border-radius:0 3px 3px 0}
.plan-name{font-weight:700;font-size:9px;margin-bottom:2px;line-height:1.2}
.plan-meta{font-size:8px;color:#777}
.plan-goal{font-size:7px;color:#999;margin-top:1px;font-style:italic}
.summary{background:#f5f5f5;border:1px solid #ddd;padding:10px 14px;border-radius:5px;display:flex;gap:24px;align-items:center;margin-bottom:10px}
.summary h3{font-size:10px;font-weight:900;text-transform:uppercase;color:#555;white-space:nowrap}
.stat{text-align:center}
.stat-val{font-size:18px;font-weight:900;line-height:1}
.stat-lbl{font-size:7px;color:#888;text-transform:uppercase;letter-spacing:.5px;margin-top:2px}
.ftr{border-top:1px solid #ccc;padding-top:8px;font-size:8px;color:#aaa;display:flex;justify-content:space-between}
</style></head><body>
<div class="hdr">
  <div><h1>Plan Semanal Nutricional</h1></div>
  <div class="meta">
    Generado el ${new Date().toLocaleDateString('es-MX',{year:'numeric',month:'long',day:'numeric'})}<br>
    CloudFit — Sistema de Gestión Nutricional
  </div>
</div>
<div class="client-info">
  <div class="client-avatar">${esc(client.name?.charAt(0).toUpperCase())}</div>
  <div>
    <div class="client-name">${esc(client.name)}</div>
    <div class="client-obj">Objetivo: ${esc(client.objective || 'No especificado')} &nbsp;|&nbsp; ${esc(client.email || '')}</div>
  </div>
</div>
<div class="week-grid">
  ${days.map(day => `
    <div class="day-col">
      <div class="day-header">${esc(day.label)}</div>
      <div class="day-body">
        ${day.plans.length === 0
          ? '<div class="rest-label">Sin plan</div>'
          : day.plans.map(p => `
            <div class="plan-card">
              <div class="plan-name">${esc(p.title)}</div>
              <div class="plan-meta">${p.daily_calories ? `${esc(p.daily_calories)} kcal` : ''} · ${esc(p.meals_count ?? 0)} comidas</div>
              ${p.goal ? `<div class="plan-goal">${esc(p.goal)}</div>` : ''}
            </div>`).join('')}
      </div>
    </div>`).join('')}
</div>
<div class="summary">
  <h3>Resumen semanal</h3>
  <div class="stat"><div class="stat-val">${activeDays}</div><div class="stat-lbl">Días con plan</div></div>
  <div class="stat"><div class="stat-val">${7 - activeDays}</div><div class="stat-lbl">Días libres</div></div>
  <div class="stat"><div class="stat-val">${totalPlans}</div><div class="stat-lbl">Total planes</div></div>
  <div class="stat"><div class="stat-val">${avgCalories || '—'}</div><div class="stat-lbl">Kcal prom/día</div></div>
</div>
${notes ? `<div style="margin-bottom:10px;padding:8px 12px;background:#f9f9f9;border:1px solid #ddd;border-radius:5px;font-size:9px;color:#444"><strong style="text-transform:uppercase;letter-spacing:.5px">Notas:</strong> ${esc(notes)}</div>` : ''}
<div class="ftr">
  <span>CloudFit — Paciente: ${esc(client.name)}</span>
  <span>Plan semanal impreso el ${new Date().toLocaleDateString('es-MX')}</span>
</div>
</body></html>`;

  const win = window.open('', '_blank', 'width=1100,height=750');
  win.document.write(html);
  win.document.close();
  win.focus();
  win.print();
}

async function apiFetch(path, opts = {}) {
  let { data: { session } } = await supabase.auth.getSession();
  let token = session?.access_token;

  const makeReq = (t) => fetch(`/api/nutriologo${path}`, {
    ...opts,
    headers: {
      Authorization: `Bearer ${t}`,
      Accept: 'application/json',
      'Content-Type': 'application/json',
      ...(opts.headers || {}),
    },
    body: opts.body ? JSON.stringify(opts.body) : undefined,
  });

  let res = await makeReq(token);

  if (res.status === 401) {
    ({ data: { session } } = await supabase.auth.getSession());
    await syncLocalUserProfile(session).catch(() => null);
    token = session?.access_token;
    res = await makeReq(token);
  }

  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.message ?? `Error ${res.status}`);
  }
  return res.json();
}

function DayColumn({ day, plans, isDragOver, onDragOver, onDragLeave, onDrop, onRemove }) {
  return (
    <div className="flex flex-col gap-2">
      <h3 className={`font-headline font-bold text-sm uppercase tracking-wide ${plans.length > 0 ? 'text-[#cafd00]' : 'text-white'}`}>
        {day.label}
      </h3>
      <div
        onDragOver={onDragOver}
        onDragLeave={onDragLeave}
        onDrop={onDrop}
        className={`flex-1 flex flex-col gap-2 rounded-xl p-3 border-2 transition-all ${
          isDragOver
            ? 'bg-[#cafd00]/5 border-[#cafd00]/50 shadow-lg shadow-[#cafd00]/5'
            : 'bg-[#1a1a1a] border-[#484847]/20'
        }`}
        style={{ minHeight: '200px' }}
      >
        {plans.map(plan => (
          <div
            key={plan.instanceId}
            className="bg-[#262626] p-3 rounded-lg flex flex-col gap-1.5 border-l-4 group relative"
            style={{ borderLeftColor: goalColor(plan.goal) }}
          >
            <div className="flex justify-between items-start gap-1">
              <span className="font-bold text-xs leading-tight text-white">{plan.title}</span>
              <button
                onClick={() => onRemove(plan.instanceId)}
                className="text-[#484847] hover:text-[#ff7351] transition-colors opacity-0 group-hover:opacity-100 flex-shrink-0 mt-0.5"
              >
                <X size={11} />
              </button>
            </div>
            <div className="flex items-center gap-1.5 flex-wrap">
              {plan.goal && (
                <span className="text-[9px] bg-[#131313] px-1.5 py-0.5 rounded font-bold uppercase text-[#adaaaa]">
                  {plan.goal}
                </span>
              )}
              {plan.daily_calories && (
                <span className="text-[9px] text-[#adaaaa]">{plan.daily_calories} kcal</span>
              )}
              {plan.meals_count > 0 && (
                <span className="text-[9px] text-[#484847]">{plan.meals_count} comidas</span>
              )}
            </div>
          </div>
        ))}

        <div
          className={`flex flex-col items-center justify-center gap-1 rounded-lg border-2 border-dashed transition-all p-2 ${
            isDragOver
              ? 'border-[#cafd00]/60 text-[#cafd00] bg-[#cafd00]/5'
              : 'border-[#484847]/30 text-[#484847]'
          }`}
          style={{ minHeight: plans.length === 0 ? '130px' : '44px' }}
        >
          <CalendarDays size={plans.length === 0 ? 18 : 12} />
          <span className="text-[8px] font-bold uppercase tracking-widest text-center leading-tight">
            {plans.length === 0 ? 'Soltar plan' : 'Agregar'}
          </span>
        </div>
      </div>
    </div>
  );
}

export default function PlanSemanalNutri() {
  const [nutriologoName, setNutriologoName] = useState('Nutriólogo');
  const [clients, setClients] = useState([]);
  const [selectedClientId, setSelectedClientId] = useState(null);
  const [plans, setPlans] = useState([]);
  const [weeklyPlan, setWeeklyPlan] = useState(EMPTY_PLAN());
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [planLoading, setPlanLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [notes, setNotes] = useState('');
  const [toast, setToast] = useState(null);
  const [draggedPlan, setDraggedPlan] = useState(null);
  const [dragOverDay, setDragOverDay] = useState(null);
  const bankScrollRef = useRef(null);
  const autoScrollRef = useRef(null);

  const stopAutoScroll = () => {
    if (autoScrollRef.current) {
      clearInterval(autoScrollRef.current);
      autoScrollRef.current = null;
    }
  };

  const handleBankDragOver = (e) => {
    if (!bankScrollRef.current) return;
    const rect = bankScrollRef.current.getBoundingClientRect();
    const ZONE = 64;
    const y = e.clientY - rect.top;
    stopAutoScroll();
    if (y < ZONE) {
      autoScrollRef.current = setInterval(() => bankScrollRef.current?.scrollBy(0, -10), 16);
    } else if (y > rect.height - ZONE) {
      autoScrollRef.current = setInterval(() => bankScrollRef.current?.scrollBy(0, 10), 16);
    }
  };

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 4000);
  };

  // Load clients + plans
  useEffect(() => {
    const load = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        const name =
          session?.user?.user_metadata?.full_name ||
          session?.user?.user_metadata?.name ||
          session?.user?.email?.split('@')[0] ||
          'Nutriólogo';
        setNutriologoName(name);

        const [clientsData, plansData] = await Promise.all([
          apiFetch('/clientes?per_page=50'),
          apiFetch('/planes?per_page=100'),
        ]);

        const clientList = clientsData.data ?? [];
        const planList   = plansData.data ?? [];

        setClients(clientList);
        setPlans(planList.filter(p => p.is_active));
        setSelectedClientId(clientList[0]?.id ?? null);
      } catch (err) {
        showToast(err.message, 'error');
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  // Load weekly plan when client changes
  useEffect(() => {
    if (!selectedClientId || plans.length === 0) return;
    setPlanLoading(true);
    apiFetch(`/weekly-plan/${selectedClientId}`)
      .then(({ plan, notes: savedNotes }) => {
        const full = EMPTY_PLAN();
        for (const [day, ids] of Object.entries(plan)) {
          full[day] = ids
            .map((id, i) => {
              const p = plans.find(p => String(p.id) === String(id));
              return p ? { ...p, instanceId: `${day}-${id}-${i}` } : null;
            })
            .filter(Boolean);
        }
        setWeeklyPlan(full);
        setNotes(savedNotes || '');
      })
      .catch(() => {
        setWeeklyPlan(EMPTY_PLAN());
        setNotes('');
      })
      .finally(() => setPlanLoading(false));
  }, [selectedClientId, plans]);

  const handleDragStart = (e, plan) => {
    setDraggedPlan(plan);
    e.dataTransfer.effectAllowed = 'copy';
  };

  const handleDragEnd = () => {
    stopAutoScroll();
    setDraggedPlan(null);
    setDragOverDay(null);
  };

  const handleDragOver = (e, dayKey) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';
    setDragOverDay(dayKey);
  };

  const handleDragLeave = () => setDragOverDay(null);

  const handleDrop = (e, dayKey) => {
    e.preventDefault();
    if (draggedPlan) {
      setWeeklyPlan(prev => ({
        ...prev,
        [dayKey]: [...(prev[dayKey] || []), { ...draggedPlan, instanceId: `${dayKey}-${draggedPlan.id}-${Date.now()}` }],
      }));
    }
    setDraggedPlan(null);
    setDragOverDay(null);
  };

  const removeFromDay = (dayKey, instanceId) => {
    setWeeklyPlan(prev => ({
      ...prev,
      [dayKey]: prev[dayKey].filter(p => p.instanceId !== instanceId),
    }));
  };

  const handlePrint = () => {
    if (!selectedClient) return;
    printWeeklyNutritionPlan(selectedClient, weeklyPlan, notes);
  };

  const handleSave = async () => {
    if (!selectedClientId) return;
    setSaving(true);
    try {
      const planIds = {};
      for (const day of DAYS) {
        planIds[day.key] = weeklyPlan[day.key].map(p => p.id);
      }
      await apiFetch(`/weekly-plan/${selectedClientId}`, {
        method: 'POST',
        body: { plan: planIds, notes },
      });
      showToast('Plan semanal guardado exitosamente');
    } catch (err) {
      showToast(err.message || 'Error al guardar el plan', 'error');
    } finally {
      setSaving(false);
    }
  };

  const selectedClient = clients.find(c => String(c.id) === String(selectedClientId));
  const filteredPlans  = plans.filter(p =>
    p.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    (p.goal ?? '').toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (loading) {
    return (
      <NutriologoLayout nutriologoName={nutriologoName}>
        <div className="flex items-center justify-center h-64">
          <Loader2 size={32} className="animate-spin text-[#cafd00]" />
        </div>
      </NutriologoLayout>
    );
  }

  return (
    <NutriologoLayout nutriologoName={nutriologoName}>

      {/* Toast */}
      {toast && (
        <div className="fixed top-8 right-8 z-[100] animate-in fade-in slide-in-from-top-4 duration-300">
          <div className={`flex items-center gap-4 px-6 py-4 rounded-2xl border shadow-2xl backdrop-blur-xl ${
            toast.type === 'success'
              ? 'bg-[#cafd00]/10 border-[#cafd00]/20 text-[#cafd00]'
              : 'bg-[#ff7351]/10 border-[#ff7351]/20 text-[#ff7351]'
          }`}>
            <div className={`p-2 rounded-lg ${toast.type === 'success' ? 'bg-[#cafd00]/20' : 'bg-[#ff7351]/20'}`}>
              {toast.type === 'success' ? <CheckCircle size={20} /> : <AlertCircle size={20} />}
            </div>
            <p className="text-sm font-bold">{toast.msg}</p>
            <button onClick={() => setToast(null)} className="ml-2 hover:opacity-70 transition-opacity">
              <X size={16} />
            </button>
          </div>
        </div>
      )}

      <div className="space-y-5">

        {/* Header */}
        <div>
          <p className="text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa]">Gestión de planes</p>
          <h1 className="text-4xl font-black tracking-tight text-white uppercase font-headline mt-1">Plan Semanal</h1>
          <p className="text-[#adaaaa] mt-1.5 text-sm">
            Arrastra los planes nutricionales al calendario para armar la semana de cada paciente.
          </p>
        </div>

        {/* Client Selector + Actions */}
        <div className="flex flex-wrap items-center gap-3 bg-[#131313] rounded-2xl px-5 py-4 border border-[#484847]/10">
          <div className="flex items-center gap-3 flex-1 min-w-[200px]">
            <div className="w-10 h-10 rounded-full bg-[#cafd00]/10 flex items-center justify-center text-sm font-black text-[#cafd00] flex-shrink-0">
              {selectedClient
                ? selectedClient.name?.charAt(0).toUpperCase()
                : <Users size={16} className="text-[#adaaaa]" />}
            </div>
            <div className="flex flex-col gap-0.5">
              <label className="text-[9px] font-black uppercase tracking-widest text-[#adaaaa]">Paciente</label>
              <div className="relative flex items-center gap-1">
                <select
                  value={selectedClientId ?? ''}
                  onChange={e => setSelectedClientId(e.target.value)}
                  className="bg-transparent border-none text-white font-bold text-sm focus:outline-none cursor-pointer appearance-none pr-5"
                >
                  {clients.length === 0 && <option value="">Sin pacientes</option>}
                  {clients.map(c => (
                    <option key={c.id} value={c.id} className="bg-[#131313]">{c.name}</option>
                  ))}
                </select>
                <ChevronDown size={12} className="text-[#adaaaa] pointer-events-none absolute right-0" />
              </div>
            </div>
          </div>

          {selectedClient?.objective && (
            <span className="text-xs text-[#cafd00] bg-[#cafd00]/10 border border-[#cafd00]/20 px-3 py-1 rounded-full font-bold">
              {selectedClient.objective}
            </span>
          )}

          <div className="flex items-center gap-2 ml-auto">
            <button
              onClick={handleSave}
              disabled={saving || !selectedClientId}
              className="flex items-center gap-2 px-5 py-2.5 bg-[#cafd00] text-[#3a4a00] rounded-xl text-sm font-black hover:brightness-110 transition-all disabled:opacity-50 shadow-lg shadow-[#cafd00]/10"
            >
              <Save size={15} />
              {saving ? 'Guardando...' : 'Guardar Plan'}
            </button>
            <button
              onClick={handlePrint}
              disabled={!selectedClientId}
              className="flex items-center gap-2 px-5 py-2.5 bg-[#1a1a1a] border border-[#484847] text-[#adaaaa] hover:text-white hover:border-[#cafd00]/50 rounded-xl text-sm font-bold transition-all disabled:opacity-40"
            >
              <Printer size={15} />
              Imprimir
            </button>
          </div>
        </div>

        {/* Main: Calendar + Plan Bank */}
        <div className="flex gap-4" style={{ minHeight: '68vh' }}>

          {/* Weekly Grid */}
          <div className="flex-1 min-w-0">
            {planLoading && (
              <div className="flex items-center justify-center h-12 mb-3">
                <Loader2 size={18} className="animate-spin text-[#cafd00]" />
                <span className="ml-2 text-xs text-[#adaaaa]">Cargando plan...</span>
              </div>
            )}
            <div className="grid grid-cols-4 gap-3">
              {DAYS.map(day => (
                <DayColumn
                  key={day.key}
                  day={day}
                  plans={weeklyPlan[day.key] || []}
                  isDragOver={dragOverDay === day.key}
                  onDragOver={e => handleDragOver(e, day.key)}
                  onDragLeave={handleDragLeave}
                  onDrop={e => handleDrop(e, day.key)}
                  onRemove={instanceId => removeFromDay(day.key, instanceId)}
                />
              ))}

              {/* Notes slot */}
              <div className="flex flex-col gap-2">
                <h3 className="font-headline font-bold text-sm uppercase tracking-wide text-[#adaaaa]/50">NOTAS</h3>
                <div className="flex-1 bg-[#1a1a1a]/40 border-2 border-[#484847]/20 rounded-xl p-3 flex flex-col">
                  <textarea
                    className="w-full flex-1 bg-transparent border-none focus:ring-0 text-sm text-[#adaaaa] placeholder-[#484847]/60 resize-none focus:outline-none"
                    placeholder="Notas del plan semanal&#10;(restricciones, objetivos, etc.)"
                    style={{ minHeight: '100px' }}
                    value={notes}
                    onChange={e => setNotes(e.target.value)}
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Plan Bank Sidebar */}
          <aside
            className="w-72 flex-shrink-0 bg-[#131313] rounded-2xl border border-[#484847]/10 flex flex-col overflow-hidden"
            style={{ maxHeight: 'calc(100vh - 270px)' }}
          >
            <div className="p-5 border-b border-[#484847]/10">
              <h2 className="font-headline font-black text-base text-white uppercase tracking-tight">Banco de Planes</h2>
              <p className="text-[10px] text-[#adaaaa] font-headline uppercase tracking-widest mt-0.5">Arrastra al calendario</p>
            </div>

            <div
              ref={bankScrollRef}
              onDragOver={handleBankDragOver}
              onDragLeave={stopAutoScroll}
              className="p-4 flex flex-col gap-3 overflow-y-auto flex-1"
            >
              <div className="relative">
                <Search size={13} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#adaaaa]" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={e => setSearchQuery(e.target.value)}
                  placeholder="Buscar plan..."
                  className="w-full bg-[#262626] border-none rounded-lg pl-9 pr-3 py-2 text-xs text-white placeholder-[#484847] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/30"
                />
              </div>

              {filteredPlans.length === 0 && (
                <div className="flex flex-col items-center justify-center py-10 text-[#adaaaa]">
                  <Utensils size={28} className="mb-2 opacity-20" />
                  <p className="text-xs text-center">
                    {plans.length === 0
                      ? 'No tienes planes activos'
                      : 'Sin resultados'}
                  </p>
                </div>
              )}

              {filteredPlans.map(plan => (
                <div
                  key={plan.id}
                  draggable
                  onDragStart={e => handleDragStart(e, plan)}
                  onDragEnd={handleDragEnd}
                  className={`bg-[#1a1a1a] p-4 rounded-xl border border-[#484847]/10 hover:border-[#cafd00]/30 transition-colors cursor-grab active:cursor-grabbing select-none ${draggedPlan?.id === plan.id ? 'opacity-50' : ''}`}
                >
                  <div className="flex justify-between items-start mb-2">
                    <div
                      className="p-2 rounded-lg"
                      style={{ backgroundColor: `${goalColor(plan.goal)}20`, color: goalColor(plan.goal) }}
                    >
                      <Utensils size={14} />
                    </div>
                    <span className="text-[#484847] text-base leading-none select-none">⠿</span>
                  </div>
                  <h4 className="font-bold text-sm text-white mb-1 leading-tight">{plan.title}</h4>
                  {plan.goal && (
                    <p className="text-[10px] text-[#adaaaa] mb-2 truncate">{plan.goal}</p>
                  )}
                  <div className="flex items-center gap-1.5 flex-wrap">
                    {plan.daily_calories && (
                      <span className="text-[9px] bg-[#262626] px-2 py-0.5 rounded font-bold uppercase text-[#cafd00]">
                        {plan.daily_calories} kcal
                      </span>
                    )}
                    <span className="text-[9px] bg-[#262626] px-2 py-0.5 rounded font-bold uppercase text-[#adaaaa]">
                      {plan.meals_count ?? 0} comidas
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </aside>
        </div>
      </div>
    </NutriologoLayout>
  );
}
