import { useState, useEffect, useRef } from 'react';
import { useLocation } from 'react-router-dom';
import {
  CheckCircle, Loader2, AlertCircle, X, Printer, Save,
  Dumbbell, Zap, Heart, Search, Users, CalendarDays,
} from 'lucide-react';
import { supabase } from '../../lib/supabase';

const DAYS = [
  { key: 'Mon', label: 'LUNES' },
  { key: 'Tue', label: 'MARTES' },
  { key: 'Wed', label: 'MIÉRCOLES' },
  { key: 'Thu', label: 'JUEVES' },
  { key: 'Fri', label: 'VIERNES' },
  { key: 'Sat', label: 'SÁBADO' },
  { key: 'Sun', label: 'DOMINGO' },
];

const ICON_MAP = { dumbbell: Dumbbell, zap: Zap, heart: Heart };
const EMPTY_PLAN = () => Object.fromEntries(DAYS.map(d => [d.key, []]));

async function apiFetch(path, opts = {}) {
  const { data: s } = await supabase.auth.getSession();
  const token = s?.session?.access_token;
  const res = await fetch(`/api/coach${path}`, {
    ...opts,
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/json',
      'Content-Type': 'application/json',
      ...(opts.headers || {}),
    },
    body: opts.body ? JSON.stringify(opts.body) : undefined,
  });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  return res.json();
}

function printWeeklyPlan(client, weeklyPlan, notes = '') {
  const days = DAYS.map(d => ({ ...d, routines: weeklyPlan[d.key] || [] }));
  const activeDays = days.filter(d => d.routines.length > 0).length;
  const totalRoutines = days.reduce((s, d) => s + d.routines.length, 0);

  const html = `<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<title>Plan Semanal — ${client.name}</title>
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
.routine-card{border-left:3px solid #111;padding:4px 6px;background:#fafafa;border-radius:0 3px 3px 0}
.routine-name{font-weight:700;font-size:9px;margin-bottom:2px;line-height:1.2}
.routine-meta{font-size:8px;color:#777}
.exercises-mini{margin-top:4px}
.exercises-mini table{width:100%;border-collapse:collapse;font-size:7px}
.exercises-mini th{background:#eee;padding:2px 3px;text-align:left;font-weight:700}
.exercises-mini td{padding:2px 3px;border-bottom:1px solid #f0f0f0}
.summary{background:#f5f5f5;border:1px solid #ddd;padding:10px 14px;border-radius:5px;display:flex;gap:24px;align-items:center;margin-bottom:10px}
.summary h3{font-size:10px;font-weight:900;text-transform:uppercase;color:#555;white-space:nowrap}
.stat{text-align:center}
.stat-val{font-size:18px;font-weight:900;line-height:1}
.stat-lbl{font-size:7px;color:#888;text-transform:uppercase;letter-spacing:.5px;margin-top:2px}
.ftr{border-top:1px solid #ccc;padding-top:8px;font-size:8px;color:#aaa;display:flex;justify-content:space-between}
</style></head><body>
<div class="hdr">
  <div>
    <h1>Plan Semanal de Entrenamiento</h1>
  </div>
  <div class="meta">
    Generado el ${new Date().toLocaleDateString('es-MX',{year:'numeric',month:'long',day:'numeric'})}<br>
    CloudFit — Sistema de Gestión Deportiva
  </div>
</div>
<div class="client-info">
  <div class="client-avatar">${client.avatar}</div>
  <div>
    <div class="client-name">${client.name}</div>
    <div class="client-obj">Objetivo: ${client.objective || 'No especificado'} &nbsp;|&nbsp; ${client.email || ''}</div>
  </div>
</div>
<div class="week-grid">
  ${days.map(day => `
    <div class="day-col">
      <div class="day-header">${day.label}</div>
      <div class="day-body">
        ${day.routines.length === 0
          ? '<div class="rest-label">Descanso</div>'
          : day.routines.map(r => `
            <div class="routine-card">
              <div class="routine-name">${r.name}</div>
              <div class="routine-meta">${r.difficultyLabel || ''} · ${r.estDuration || 0}min</div>
              ${r.exercises?.length ? `
                <div class="exercises-mini">
                  <table>
                    <thead><tr><th>Ejercicio</th><th>S</th><th>R</th><th>Desc</th></tr></thead>
                    <tbody>${r.exercises.slice(0, 6).map(ex =>
                      `<tr><td>${ex.name}</td><td>${ex.sets}</td><td>${ex.reps}</td><td>${ex.rest}</td></tr>`
                    ).join('')}${r.exercises.length > 6 ? `<tr><td colspan="4" style="color:#888;font-style:italic">+${r.exercises.length - 6} más...</td></tr>` : ''}
                    </tbody>
                  </table>
                </div>` : ''}
            </div>`).join('')}
      </div>
    </div>`).join('')}
</div>
<div class="summary">
  <h3>Resumen semanal</h3>
  <div class="stat"><div class="stat-val">${activeDays}</div><div class="stat-lbl">Días activos</div></div>
  <div class="stat"><div class="stat-val">${7 - activeDays}</div><div class="stat-lbl">Días descanso</div></div>
  <div class="stat"><div class="stat-val">${totalRoutines}</div><div class="stat-lbl">Total rutinas</div></div>
  <div class="stat"><div class="stat-val">${days.reduce((s,d)=>s+d.routines.reduce((ss,r)=>ss+(r.estDuration||0),0),0)}</div><div class="stat-lbl">Min totales</div></div>
</div>
${notes ? `<div style="margin-bottom:10px;padding:8px 12px;background:#f9f9f9;border:1px solid #ddd;border-radius:5px;font-size:9px;color:#444"><strong style="text-transform:uppercase;letter-spacing:.5px">Notas:</strong> ${notes}</div>` : ''}
<div class="ftr">
  <span>CloudFit — Coach: ${client.name}</span>
  <span>Plan semanal impreso el ${new Date().toLocaleDateString('es-MX')}</span>
</div>
</body></html>`;

  const win = window.open('', '_blank', 'width=1100,height=750');
  win.document.write(html);
  win.document.close();
  win.focus();
  win.print();
}

function DayColumn({ day, routines, isDragOver, onDragOver, onDragLeave, onDrop, onRemove }) {
  return (
    <div className="flex flex-col gap-2">
      <h3 className={`font-headline font-bold text-sm uppercase tracking-wide ${routines.length > 0 ? 'text-[#cafd00]' : 'text-white'}`}>
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
        {routines.map(routine => (
          <div
            key={routine.instanceId}
            className="bg-[#262626] p-3 rounded-lg flex flex-col gap-1.5 border-l-4 group relative"
            style={{ borderLeftColor: routine.accentColor || '#cafd00' }}
          >
            <div className="flex justify-between items-start gap-1">
              <span className="font-bold text-xs leading-tight text-white">{routine.name}</span>
              <button
                onClick={() => onRemove(routine.instanceId)}
                className="text-[#484847] hover:text-[#ff7351] transition-colors opacity-0 group-hover:opacity-100 flex-shrink-0 mt-0.5"
              >
                <X size={11} />
              </button>
            </div>
            <div className="flex items-center gap-1.5 flex-wrap">
              <span className="text-[9px] bg-[#131313] px-1.5 py-0.5 rounded text-[#adaaaa] font-bold uppercase">
                {routine.difficultyLabel}
              </span>
              <span className="text-[9px] text-[#adaaaa]">{routine.estDuration}min</span>
            </div>
          </div>
        ))}

        {/* Drop zone */}
        <div
          className={`flex flex-col items-center justify-center gap-1 rounded-lg border-2 border-dashed transition-all p-2 ${
            isDragOver
              ? 'border-[#cafd00]/60 text-[#cafd00] bg-[#cafd00]/5'
              : 'border-[#484847]/30 text-[#484847]'
          }`}
          style={{ minHeight: routines.length === 0 ? '130px' : '44px' }}
        >
          <CalendarDays size={routines.length === 0 ? 18 : 12} />
          <span className="text-[8px] font-bold uppercase tracking-widest text-center leading-tight">
            {routines.length === 0 ? 'Soltar rutina' : 'Agregar'}
          </span>
        </div>
      </div>
    </div>
  );
}

export default function PlanSemanal() {
  const [clients, setClients] = useState([]);
  const [selectedClientId, setSelectedClientId] = useState(null);
  const [routines, setRoutines] = useState([]);
  const [weeklyPlan, setWeeklyPlan] = useState(EMPTY_PLAN());
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const location = useLocation();
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [toast, setToast] = useState(null);
  const [draggedRoutine, setDraggedRoutine] = useState(null);
  const [dragOverDay, setDragOverDay] = useState(null);
  const [notes, setNotes] = useState('');
  const [planLoading, setPlanLoading] = useState(false);
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
      autoScrollRef.current = setInterval(() => {
        bankScrollRef.current?.scrollBy(0, -10);
      }, 16);
    } else if (y > rect.height - ZONE) {
      autoScrollRef.current = setInterval(() => {
        bankScrollRef.current?.scrollBy(0, 10);
      }, 16);
    }
  };

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 4000);
  };

  useEffect(() => {
    const params = new URLSearchParams(location.search);
    const clientIdFromUrl = params.get('clientId');

    Promise.all([
      apiFetch('/rutinas/clients'),
      apiFetch('/rutinas/routines?level=all'),
    ]).then(([c, r]) => {
      setClients(c);
      setRoutines(r);
      const preselect = clientIdFromUrl ? Number(clientIdFromUrl) : null;
      setSelectedClientId(preselect && c.some(x => x.id === preselect) ? preselect : c[0]?.id ?? null);
    }).catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    if (!selectedClientId || routines.length === 0) return;
    setPlanLoading(true);
    apiFetch(`/weekly-plan/${selectedClientId}`)
      .then(({ plan, notes: savedNotes }) => {
        const fullPlan = EMPTY_PLAN();
        for (const [day, ids] of Object.entries(plan)) {
          fullPlan[day] = ids
            .map((id, i) => {
              const r = routines.find(r => r.id === id);
              return r ? { ...r, instanceId: `${day}-${id}-${i}` } : null;
            })
            .filter(Boolean);
        }
        setWeeklyPlan(fullPlan);
        setNotes(savedNotes || '');
      })
      .catch(() => {
        setWeeklyPlan(EMPTY_PLAN());
        setNotes('');
      })
      .finally(() => setPlanLoading(false));
  }, [selectedClientId, routines]);

  const handleDragStart = (e, routine) => {
    setDraggedRoutine(routine);
    e.dataTransfer.effectAllowed = 'copy';
  };

  const handleDragEnd = () => {
    stopAutoScroll();
    setDraggedRoutine(null);
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
    if (draggedRoutine) {
      setWeeklyPlan(prev => ({
        ...prev,
        [dayKey]: [...(prev[dayKey] || []), { ...draggedRoutine, instanceId: Date.now() }],
      }));
    }
    setDraggedRoutine(null);
    setDragOverDay(null);
  };

  const removeFromDay = (dayKey, instanceId) => {
    setWeeklyPlan(prev => ({
      ...prev,
      [dayKey]: prev[dayKey].filter(r => r.instanceId !== instanceId),
    }));
  };

  const handleSave = async () => {
    if (!selectedClientId) return;
    setSaving(true);
    try {
      const planIds = {};
      for (const day of DAYS) {
        planIds[day.key] = weeklyPlan[day.key].map(r => r.id);
      }
      await apiFetch(`/weekly-plan/${selectedClientId}`, {
        method: 'POST',
        body: { plan: planIds, notes },
      });
      showToast('Plan semanal guardado exitosamente');
    } catch {
      showToast('Error al guardar el plan', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handlePrint = () => {
    const client = clients.find(c => c.id === selectedClientId);
    if (!client) return;
    printWeeklyPlan(client, weeklyPlan, notes);
  };

  const selectedClient = clients.find(c => c.id === selectedClientId);
  const filteredRoutines = routines.filter(r =>
    r.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (loading) return (
    <div className="flex items-center justify-center h-64">
      <Loader2 size={32} className="animate-spin text-[#cafd00]" />
    </div>
  );

  if (error) return (
    <div className="flex items-center justify-center h-64">
      <p className="text-[#ff7351] text-sm">Error: {error}</p>
    </div>
  );

  return (
    <div className="space-y-5 relative">

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

      {/* Page Header */}
      <div>
        <h1 className="text-4xl font-black tracking-tight text-white uppercase font-headline">Plan Semanal</h1>
        <p className="text-[#adaaaa] mt-1.5 text-sm">
          Arma el plan de entrenamiento semanal de tus atletas arrastrando rutinas al calendario.
        </p>
      </div>

      {/* Client Selector + Actions Bar */}
      <div className="flex flex-wrap items-center gap-3 bg-[#131313] rounded-2xl px-5 py-4 border border-[#484847]/10">
        <div className="flex items-center gap-3 flex-1 min-w-[200px]">
          <div className="w-10 h-10 rounded-full bg-[#5516be]/20 flex items-center justify-center text-sm font-black text-[#ac8aff] flex-shrink-0">
            {selectedClient?.avatar || <Users size={16} />}
          </div>
          <div className="flex flex-col gap-0.5">
            <label className="text-[9px] font-black uppercase tracking-widest text-[#adaaaa]">Cliente</label>
            <select
              value={selectedClientId || ''}
              onChange={e => setSelectedClientId(Number(e.target.value))}
              className="bg-transparent border-none text-white font-bold text-sm focus:outline-none cursor-pointer"
            >
              {clients.length === 0 && <option value="">Sin clientes</option>}
              {clients.map(c => (
                <option key={c.id} value={c.id} className="bg-[#131313]">{c.name}</option>
              ))}
            </select>
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

      {/* Main Content: Weekly Grid + Routine Bank */}
      <div className="flex gap-4" style={{ minHeight: '68vh' }}>

        {/* Weekly Grid */}
        <div className="flex-1 min-w-0">
          {planLoading && (
            <div className="flex items-center justify-center h-16 mb-3">
              <Loader2 size={20} className="animate-spin text-[#cafd00]" />
              <span className="ml-2 text-xs text-[#adaaaa]">Cargando plan...</span>
            </div>
          )}
          <div className="grid grid-cols-4 gap-3">
            {/* Row 1: Mon–Thu / Row 2: Fri–Sun + Notes (auto-placed by CSS grid) */}
            {DAYS.map(day => (
              <DayColumn
                key={day.key}
                day={day}
                routines={weeklyPlan[day.key] || []}
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
                  placeholder="Notas del plan semanal&#10;(objetivos, restricciones, etc.)"
                  style={{ minHeight: '100px' }}
                  value={notes}
                  onChange={e => setNotes(e.target.value)}
                />
              </div>
            </div>
          </div>
        </div>

        {/* Routine Bank Sidebar */}
        <aside className="w-72 flex-shrink-0 bg-[#131313] rounded-2xl border border-[#484847]/10 flex flex-col overflow-hidden" style={{ maxHeight: 'calc(100vh - 270px)' }}>
          <div className="p-5 border-b border-[#484847]/10">
            <h2 className="font-headline font-black text-base text-white uppercase tracking-tight">Banco de Rutinas</h2>
            <p className="text-[10px] text-[#adaaaa] font-headline uppercase tracking-widest mt-0.5">Arrastra al calendario</p>
          </div>

          <div
            ref={bankScrollRef}
            onDragOver={handleBankDragOver}
            onDragLeave={stopAutoScroll}
            className="p-4 flex flex-col gap-3 overflow-y-auto flex-1"
          >
            {/* Search */}
            <div className="relative">
              <Search size={13} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#adaaaa]" />
              <input
                type="text"
                value={searchQuery}
                onChange={e => setSearchQuery(e.target.value)}
                placeholder="Buscar rutina..."
                className="w-full bg-[#262626] border-none rounded-lg pl-9 pr-3 py-2 text-xs text-white placeholder-[#484847] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/30"
              />
            </div>

            {filteredRoutines.length === 0 && (
              <div className="flex flex-col items-center justify-center py-10 text-[#adaaaa]">
                <Dumbbell size={28} className="mb-2 opacity-20" />
                <p className="text-xs text-center">
                  {routines.length === 0
                    ? 'No tienes rutinas creadas aún'
                    : 'Sin resultados para la búsqueda'}
                </p>
              </div>
            )}

            {filteredRoutines.map(routine => {
              const Icon = ICON_MAP[routine.iconType] || Dumbbell;
              return (
                <div
                  key={routine.id}
                  draggable
                  onDragStart={e => handleDragStart(e, routine)}
                  onDragEnd={handleDragEnd}
                  className={`bg-[#1a1a1a] p-4 rounded-xl border border-[#484847]/10 hover:border-[#cafd00]/30 transition-colors cursor-grab active:cursor-grabbing select-none ${draggedRoutine?.id === routine.id ? 'opacity-50' : ''}`}
                >
                  <div className="flex justify-between items-start mb-3">
                    <div
                      className="p-2 rounded-lg"
                      style={{ backgroundColor: `${routine.accentColor}20`, color: routine.accentColor }}
                    >
                      <Icon size={15} />
                    </div>
                    <span className="text-[#484847] text-base leading-none select-none">⠿</span>
                  </div>
                  <h4 className="font-bold text-sm text-white mb-1 leading-tight">{routine.name}</h4>
                  {routine.trainingPlan && (
                    <p className="text-[10px] text-[#adaaaa] mb-2 truncate">{routine.trainingPlan}</p>
                  )}
                  <div className="flex items-center gap-1.5 flex-wrap">
                    <span className="text-[9px] bg-[#262626] px-2 py-0.5 rounded font-bold uppercase text-[#adaaaa]">
                      {routine.difficultyLabel}
                    </span>
                    <span className="text-[9px] bg-[#262626] px-2 py-0.5 rounded font-bold uppercase text-[#adaaaa]">
                      {routine.estDuration}min
                    </span>
                    <span className="text-[9px] text-[#484847]">
                      {routine.exercises?.length ?? 0} ejercicios
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        </aside>
      </div>
    </div>
  );
}
