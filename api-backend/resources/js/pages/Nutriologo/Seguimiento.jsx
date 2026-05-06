import { useEffect, useMemo, useState } from 'react';
import {
  AlertCircle,
  CheckCircle,
  ChevronDown,
  ChevronUp,
  ClipboardList,
  Clock,
  Loader2,
  Plus,
  RefreshCw,
  Search,
  TrendingDown,
  TrendingUp,
  Utensils,
  X,
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import NutriologoLayout from './NutriologoLayout';

// ─── Constants ───────────────────────────────────────────────────────────────

const PLAN_STATUS_BADGE = {
  active:    'bg-[#10261d] text-[#7ef0b3] border border-[#7ef0b3]/30',
  paused:    'bg-[#3b2e08] text-[#fce047] border border-[#fce047]/30',
  completed: 'bg-[#1a1a3a] text-[#ac8aff] border border-[#ac8aff]/30',
  cancelled: 'bg-[#3a1712] text-[#ff7351] border border-[#ff7351]/30',
};
const PLAN_STATUS_LABEL = { active: 'Activo', paused: 'Pausado', completed: 'Completado', cancelled: 'Cancelado' };

const CHANGE_TYPE_LABELS = {
  plan_change: 'Cambio de plan', meal_update: 'Actualización de comida',
  macro_adjust: 'Ajuste de macros', calorie_adjust: 'Ajuste calórico', observation: 'Observación',
};

const STATUS_BADGE = {
  pending:  'bg-[#3b2e08] text-[#fce047] border border-[#fce047]/30',
  approved: 'bg-[#10261d] text-[#7ef0b3] border border-[#7ef0b3]/30',
  rejected: 'bg-[#3a1712] text-[#ff7351] border border-[#ff7351]/30',
};
const STATUS_LABEL = { pending: 'Pendiente', approved: 'Aprobado', rejected: 'Rechazado' };

// ─── Helpers ─────────────────────────────────────────────────────────────────

function adherenceBadge(pct) {
  if (pct == null) return 'bg-[#1a1a1a] text-[#adaaaa] border border-[#484847]/30';
  if (pct >= 80)   return 'bg-[#10261d] text-[#7ef0b3] border border-[#7ef0b3]/30';
  if (pct >= 50)   return 'bg-[#3b2e08] text-[#fce047] border border-[#fce047]/30';
  return 'bg-[#3a1712] text-[#ff7351] border border-[#ff7351]/30';
}

function daysSince(dateStr) {
  if (!dateStr) return null;
  const diff = Math.floor((Date.now() - new Date(dateStr)) / 86400000);
  if (diff === 0) return 'Hoy';
  if (diff === 1) return 'Ayer';
  return `Hace ${diff} días`;
}

function DeltaIcon({ current, previous }) {
  if (current == null || previous == null) return null;
  const diff = parseFloat(current) - parseFloat(previous);
  if (Math.abs(diff) < 0.01) return null;
  return diff > 0
    ? <TrendingUp size={12} className="text-[#ff7351]" />
    : <TrendingDown size={12} className="text-[#7ef0b3]" />;
}

// ─── Sub-components ───────────────────────────────────────────────────────────

function KpiChip({ label, value, unit, delta }) {
  return (
    <div className="bg-[#1a1a1a] border border-[#484847]/10 rounded-2xl px-5 py-4 flex flex-col gap-1 min-w-[110px]">
      <p className="text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa]">{label}</p>
      <div className="flex items-center gap-1.5">
        <span className="text-xl font-black text-white">
          {value != null ? `${value}${unit ? ` ${unit}` : ''}` : '—'}
        </span>
        {delta}
      </div>
    </div>
  );
}

function TimelineEntry({ entry }) {
  const [open, setOpen] = useState(false);

  if (entry.type === 'asignacion_plan') {
    return (
      <div className="flex gap-3">
        <div className="flex flex-col items-center">
          <div className="w-8 h-8 rounded-full bg-[#cafd00]/10 border border-[#cafd00]/30 flex items-center justify-center shrink-0">
            <ClipboardList size={14} className="text-[#cafd00]" />
          </div>
          <div className="w-px flex-1 bg-[#484847]/20 mt-1" />
        </div>
        <div className="pb-5 flex-1">
          <div className="flex items-center gap-2 mb-2 flex-wrap">
            <span className="text-[10px] font-black text-[#cafd00] uppercase tracking-[0.2em]">Plan nutricional</span>
            <span className="text-[10px] text-[#adaaaa]">{entry.date}</span>
            <span className={`text-[10px] px-2 py-0.5 rounded-full ${PLAN_STATUS_BADGE[entry.status] ?? PLAN_STATUS_BADGE.active}`}>
              {PLAN_STATUS_LABEL[entry.status] ?? entry.status}
            </span>
          </div>
          <p className="text-sm font-bold text-white mb-1">{entry.plan_title ?? 'Plan sin título'}</p>
          {entry.plan_goal && <p className="text-xs text-[#adaaaa] mb-1">Objetivo: {entry.plan_goal}</p>}
          <div className="flex flex-wrap gap-2 mt-1">
            {entry.plan_calories != null && (
              <span className="text-xs bg-[#1a1a1a] border border-[#484847]/20 rounded-lg px-2 py-1 text-[#f3ffca]">
                {entry.plan_calories} kcal/día
              </span>
            )}
            {entry.starts_at && (
              <span className="text-xs bg-[#1a1a1a] border border-[#484847]/20 rounded-lg px-2 py-1 text-[#adaaaa]">
                Inicio: {entry.starts_at}
              </span>
            )}
            {entry.ends_at && (
              <span className="text-xs bg-[#1a1a1a] border border-[#484847]/20 rounded-lg px-2 py-1 text-[#adaaaa]">
                Fin: {entry.ends_at}
              </span>
            )}
          </div>
          {entry.notes && <p className="mt-2 text-sm text-[#adaaaa] leading-relaxed">{entry.notes}</p>}
        </div>
      </div>
    );
  }

  if (entry.type === 'progreso') {
    return (
      <div className="flex gap-3">
        <div className="flex flex-col items-center">
          <div className="w-8 h-8 rounded-full bg-[#ac8aff]/20 border border-[#ac8aff]/40 flex items-center justify-center shrink-0">
            <TrendingUp size={14} className="text-[#ac8aff]" />
          </div>
          <div className="w-px flex-1 bg-[#484847]/20 mt-1" />
        </div>
        <div className="pb-5 flex-1">
          <div className="flex items-center gap-2 mb-2">
            <span className="text-[10px] font-black text-[#ac8aff] uppercase tracking-[0.2em]">Progreso</span>
            <span className="text-[10px] text-[#adaaaa]">{entry.date}</span>
            <span className="text-[10px] text-[#6f6f6f]">por {entry.author_name} ({entry.author_role})</span>
          </div>
          <div className="flex flex-wrap gap-2">
            {entry.weight_kg != null && (
              <span className="text-xs bg-[#1a1a1a] border border-[#484847]/20 rounded-lg px-2 py-1 text-[#f3ffca]">
                {entry.weight_kg} kg
              </span>
            )}
            {entry.bmi != null && (
              <span className="text-xs bg-[#1a1a1a] border border-[#484847]/20 rounded-lg px-2 py-1 text-white">
                IMC {entry.bmi}
              </span>
            )}
            {entry.body_fat_pct != null && (
              <span className="text-xs bg-[#1a1a1a] border border-[#484847]/20 rounded-lg px-2 py-1 text-white">
                {entry.body_fat_pct}% grasa
              </span>
            )}
            {entry.muscle_mass_kg != null && (
              <span className="text-xs bg-[#1a1a1a] border border-[#484847]/20 rounded-lg px-2 py-1 text-white">
                {entry.muscle_mass_kg} kg músculo
              </span>
            )}
            {entry.adherence_pct != null && (
              <span className={`text-xs rounded-lg px-2 py-1 ${adherenceBadge(entry.adherence_pct)}`}>
                {entry.adherence_pct}% adherencia
              </span>
            )}
          </div>
          {entry.notes && <p className="mt-2 text-sm text-[#adaaaa] leading-relaxed">{entry.notes}</p>}
        </div>
      </div>
    );
  }

  return (
    <div className="flex gap-3">
      <div className="flex flex-col items-center">
        <div className="w-8 h-8 rounded-full bg-[#cafd00]/10 border border-[#cafd00]/30 flex items-center justify-center shrink-0">
          <Utensils size={14} className="text-[#cafd00]" />
        </div>
        <div className="w-px flex-1 bg-[#484847]/20 mt-1" />
      </div>
      <div className="pb-5 flex-1">
        <div className="flex items-center gap-2 mb-2 flex-wrap">
          <span className="text-[10px] font-black text-[#cafd00] uppercase tracking-[0.2em]">Cambio de dieta</span>
          <span className="text-[10px] text-[#adaaaa]">{entry.date}</span>
          <span className={`text-[10px] px-2 py-0.5 rounded-full ${STATUS_BADGE[entry.status]}`}>
            {STATUS_LABEL[entry.status]}
          </span>
        </div>
        <p className="text-sm font-bold text-white mb-1">{CHANGE_TYPE_LABELS[entry.change_type]}</p>
        <p className="text-sm text-[#adaaaa]">{entry.reason}</p>
        {entry.client_response && (
          <p className="mt-2 text-xs text-[#7ef0b3] bg-[#10261d] border border-[#7ef0b3]/20 rounded-xl px-3 py-2">
            Respuesta: {entry.client_response}
          </p>
        )}
        {(entry.previous_value || entry.new_value) && (
          <button
            onClick={() => setOpen(v => !v)}
            className="mt-2 flex items-center gap-1 text-[10px] text-[#adaaaa] hover:text-white transition-colors"
          >
            {open ? <ChevronUp size={12} /> : <ChevronDown size={12} />}
            {open ? 'Ocultar' : 'Ver'} valores
          </button>
        )}
        {open && (
          <div className="mt-2 grid grid-cols-2 gap-2">
            {entry.previous_value && (
              <div className="bg-[#1a1a1a] border border-[#484847]/10 rounded-xl p-2">
                <p className="text-[9px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1">Anterior</p>
                <pre className="text-xs text-[#ff7351] whitespace-pre-wrap">
                  {JSON.stringify(entry.previous_value, null, 2)}
                </pre>
              </div>
            )}
            {entry.new_value && (
              <div className="bg-[#1a1a1a] border border-[#484847]/10 rounded-xl p-2">
                <p className="text-[9px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1">Propuesto</p>
                <pre className="text-xs text-[#7ef0b3] whitespace-pre-wrap">
                  {JSON.stringify(entry.new_value, null, 2)}
                </pre>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────

export default function NutriologoSeguimientoPage() {
  const [nutriologoName, setNutriologoName] = useState('Nutriólogo');
  const [patients, setPatients] = useState([]);
  const [loadingPatients, setLoadingPatients] = useState(true);
  const [search, setSearch] = useState('');
  const [selectedId, setSelectedId] = useState(null);
  const [timeline, setTimeline] = useState([]);
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [clientInfo, setClientInfo] = useState(null);
  const [refreshKey, setRefreshKey] = useState(0);

  const [progressOpen, setProgressOpen] = useState(false);
  const [dietOpen, setDietOpen] = useState(false);
  const [savingProgress, setSavingProgress] = useState(false);
  const [savingDiet, setSavingDiet] = useState(false);

  const [toast, setToast] = useState(null);

  const emptyProgress = {
    date: new Date().toISOString().split('T')[0],
    weight_kg: '', bmi: '', body_fat_pct: '', muscle_mass_kg: '',
    calories_target: '', adherence_pct: '', notes: '',
  };
  const emptyDiet = {
    date: new Date().toISOString().split('T')[0],
    change_type: 'observation', reason: '',
    prev_calories: '', new_calories: '',
    prev_protein: '', prev_carbs: '', prev_fat: '',
    new_protein: '', new_carbs: '', new_fat: '',
    prev_text: '', new_text: '',
  };

  const [progressForm, setProgressForm] = useState(emptyProgress);
  const [dietForm, setDietForm] = useState(emptyDiet);

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 4000);
  };

  const getToken = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    return session?.access_token;
  };

  // ── Boot ───────────────────────────────────────────────────────────────────
  useEffect(() => {
    let ignore = false;
    const boot = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!ignore && user?.email) setNutriologoName(user.email.split('@')[0]);

      const token = await getToken();
      try {
        const res = await fetch('/api/nutriologo/seguimiento/pacientes', {
          headers: { Accept: 'application/json', Authorization: `Bearer ${token}` },
        });
        const payload = await res.json();
        if (!ignore) setPatients(payload.data ?? []);
      } catch {
        // silent
      } finally {
        if (!ignore) setLoadingPatients(false);
      }
    };
    boot();
    return () => { ignore = true; };
  }, []);

  // ── Load detail ────────────────────────────────────────────────────────────
  useEffect(() => {
    if (!selectedId) { setTimeline([]); setClientInfo(null); return; }
    let ignore = false;
    const load = async () => {
      setLoadingDetail(true);
      setTimeline([]);
      const token = await getToken();
      try {
        const res = await fetch(`/api/nutriologo/seguimiento/${selectedId}/historial`, {
          headers: { Accept: 'application/json', Authorization: `Bearer ${token}` },
        });
        const payload = await res.json();
        if (!ignore) {
          setClientInfo(payload.client ?? null);
          setTimeline(payload.timeline ?? []);
        }
      } finally {
        if (!ignore) setLoadingDetail(false);
      }
    };
    load();
    return () => { ignore = true; };
  }, [selectedId, refreshKey]);

  // ── Derived ────────────────────────────────────────────────────────────────
  const filteredPatients = useMemo(() => {
    const q = search.toLowerCase().trim();
    if (!q) return patients;
    return patients.filter(p =>
      p.name?.toLowerCase().includes(q) || p.email?.toLowerCase().includes(q)
    );
  }, [patients, search]);

  const selectedPatient = useMemo(
    () => patients.find(p => String(p.id) === String(selectedId)) ?? null,
    [patients, selectedId]
  );

  const progressRecords = useMemo(
    () => timeline.filter(e => e.type === 'progreso').sort((a, b) => new Date(b.date) - new Date(a.date)),
    [timeline]
  );
  const lastRecord = progressRecords[0] ?? null;
  const prevRecord = progressRecords[1] ?? null;

  // ── Submit progress ────────────────────────────────────────────────────────
  const handleProgressSubmit = async (e) => {
    e.preventDefault();
    setSavingProgress(true);
    const token = await getToken();
    const body = Object.fromEntries(Object.entries(progressForm).filter(([, v]) => v !== ''));
    try {
      const res = await fetch(`/api/nutriologo/seguimiento/${selectedId}/progreso`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify(body),
      });
      const payload = await res.json();
      if (!res.ok) throw new Error(payload.message ?? 'Error al guardar');
      setTimeline(prev => [{ type: 'progreso', ...payload.data, author_name: nutriologoName, author_role: 'nutriologo' }, ...prev]);
      setPatients(prev => prev.map(p =>
        String(p.id) === String(selectedId)
          ? { ...p, last_record_date: body.date, last_weight_kg: body.weight_kg || p.last_weight_kg, last_adherence: body.adherence_pct || p.last_adherence }
          : p
      ));
      setProgressForm(emptyProgress);
      setProgressOpen(false);
      showToast('Registro de progreso guardado correctamente.');
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setSavingProgress(false);
    }
  };

  const buildDietValues = (form) => {
    const { change_type: type } = form;
    let previousValue = null;
    let newValue = null;
    if (type === 'calorie_adjust') {
      if (form.prev_calories) previousValue = { calorias: Number(form.prev_calories) };
      if (form.new_calories)  newValue      = { calorias: Number(form.new_calories) };
    } else if (type === 'macro_adjust') {
      const hasPrev = form.prev_protein || form.prev_carbs || form.prev_fat;
      const hasNew  = form.new_protein  || form.new_carbs  || form.new_fat;
      if (hasPrev) previousValue = { proteina_g: Number(form.prev_protein) || undefined, carbohidratos_g: Number(form.prev_carbs) || undefined, grasa_g: Number(form.prev_fat) || undefined };
      if (hasNew)  newValue      = { proteina_g: Number(form.new_protein)  || undefined, carbohidratos_g: Number(form.new_carbs)  || undefined, grasa_g: Number(form.new_fat)  || undefined };
    } else if (type === 'meal_update' || type === 'plan_change') {
      if (form.prev_text) previousValue = { descripcion: form.prev_text };
      if (form.new_text)  newValue      = { descripcion: form.new_text };
    }
    return { previousValue, newValue };
  };

  // ── Submit diet change ─────────────────────────────────────────────────────
  const handleDietSubmit = async (e) => {
    e.preventDefault();
    setSavingDiet(true);
    const token = await getToken();
    const { previousValue, newValue } = buildDietValues(dietForm);
    const body = {
      change_type: dietForm.change_type, reason: dietForm.reason, date: dietForm.date,
      ...(previousValue !== null && { previous_value: previousValue }),
      ...(newValue !== null && { new_value: newValue }),
    };
    try {
      const res = await fetch(`/api/nutriologo/seguimiento/${selectedId}/cambio-dieta`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify(body),
      });
      const payload = await res.json();
      if (!res.ok) throw new Error(payload.message ?? 'Error al proponer cambio');
      setTimeline(prev => [{ type: 'cambio_dieta', ...payload.data, proposed_by: nutriologoName, previous_value: previousValue, new_value: newValue }, ...prev]);
      setPatients(prev => prev.map(p =>
        String(p.id) === String(selectedId) ? { ...p, pending_changes: (p.pending_changes ?? 0) + 1 } : p
      ));
      setDietForm(emptyDiet);
      setDietOpen(false);
      showToast('Propuesta enviada. El cliente recibirá una notificación.');
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setSavingDiet(false);
    }
  };

  // ─── Render ────────────────────────────────────────────────────────────────
  return (
    <NutriologoLayout nutriologoName={nutriologoName} mainClass="ml-64 min-h-screen bg-[#0e0e0e]">

      {/* Toast */}
      {toast && (
        <div className="fixed top-8 right-8 z-[100] animate-in fade-in slide-in-from-top-4 duration-300">
          <div className={`flex items-center gap-4 px-6 py-4 rounded-2xl border shadow-2xl backdrop-blur-xl ${
            toast.type === 'success'
              ? 'bg-[#cafd00]/10 border-[#cafd00]/20 text-[#cafd00]'
              : 'bg-[#ff7351]/10 border-[#ff7351]/20 text-[#ff7351]'
          }`}>
            <div className={`p-2 rounded-lg ${toast.type === 'success' ? 'bg-[#cafd00]/20' : 'bg-[#ff7351]/20'}`}>
              {toast.type === 'success' ? <CheckCircle size={18} /> : <AlertCircle size={18} />}
            </div>
            <div>
              <p className="text-[10px] font-black uppercase tracking-widest opacity-60 mb-0.5">
                {toast.type === 'success' ? 'Éxito' : 'Error'}
              </p>
              <p className="text-sm font-bold">{toast.message}</p>
            </div>
            <button onClick={() => setToast(null)} className="ml-2 hover:opacity-70 transition-opacity">
              <X size={16} />
            </button>
          </div>
        </div>
      )}

      <div className="pt-20 flex">

        {/* ── Left panel: patient list ──────────────────────────────────── */}
        <aside className="w-80 shrink-0 border-r border-[#484847]/10 flex flex-col h-[calc(100vh-5rem)] sticky top-20 overflow-hidden bg-[#0e0e0e]">
          <div className="p-5 border-b border-[#484847]/10">
            <h2 className="text-[10px] font-black text-white uppercase tracking-[0.2em] mb-4">Pacientes</h2>
            <div className="relative">
              <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#adaaaa]" />
              <input
                type="text"
                value={search}
                onChange={e => setSearch(e.target.value)}
                placeholder="Buscar..."
                className="w-full bg-[#131313] border-none rounded-xl pl-9 pr-3 py-2.5 text-sm text-white placeholder-[#adaaaa] focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all"
              />
            </div>
          </div>

          <div className="flex-1 overflow-y-auto">
            {loadingPatients ? (
              <div className="flex justify-center items-center py-12">
                <Loader2 size={20} className="animate-spin text-[#cafd00]" />
              </div>
            ) : filteredPatients.length === 0 ? (
              <p className="text-center text-[#adaaaa] text-sm py-12">Sin pacientes</p>
            ) : (
              filteredPatients.map(patient => {
                const isActive = String(selectedId) === String(patient.id);
                return (
                  <button
                    key={patient.id}
                    onClick={() => setSelectedId(String(patient.id))}
                    className={`w-full text-left px-4 py-3.5 border-b border-[#484847]/5 transition-all ${
                      isActive
                        ? 'bg-[#1a1a1a] border-l-4 border-l-[#cafd00]'
                        : 'border-l-4 border-l-transparent hover:bg-[#131313]'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <div className={`w-9 h-9 rounded-full flex items-center justify-center text-sm font-black shrink-0 ${
                        isActive
                          ? 'bg-[#cafd00]/10 text-[#cafd00]'
                          : 'bg-[#262626] text-[#adaaaa]'
                      }`}>
                        {patient.name?.charAt(0).toUpperCase() ?? '?'}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className={`text-sm font-bold truncate ${isActive ? 'text-white' : 'text-[#adaaaa]'}`}>{patient.name}</p>
                        <p className="text-[11px] text-[#6f6f6f] truncate">{patient.email}</p>
                        <div className="flex items-center gap-2 mt-1">
                          {patient.last_record_date && (
                            <span className="text-[10px] text-[#6f6f6f]">{daysSince(patient.last_record_date)}</span>
                          )}
                          {patient.last_adherence != null && (
                            <span className={`text-[10px] px-1.5 py-0.5 rounded-lg ${adherenceBadge(patient.last_adherence)}`}>
                              {patient.last_adherence}%
                            </span>
                          )}
                          {patient.pending_changes > 0 && (
                            <span className="text-[10px] bg-[#3b2e08] text-[#fce047] border border-[#fce047]/30 rounded-lg px-1.5 py-0.5 flex items-center gap-1">
                              <Clock size={9} /> {patient.pending_changes}
                            </span>
                          )}
                        </div>
                      </div>
                    </div>
                  </button>
                );
              })
            )}
          </div>
        </aside>

        {/* ── Right panel: detail ───────────────────────────────────────── */}
        <main className="flex-1 overflow-y-auto">
          {!selectedId ? (
            <div className="flex flex-col items-center justify-center h-full text-[#adaaaa] gap-4 pt-32">
              <TrendingUp size={48} className="opacity-10" />
              <div className="text-center">
                <p className="text-sm font-bold text-white">Selecciona un paciente</p>
                <p className="text-xs text-[#adaaaa] mt-1">para ver su historial de seguimiento</p>
              </div>
            </div>
          ) : loadingDetail ? (
            <div className="flex justify-center items-center pt-32">
              <Loader2 size={28} className="animate-spin text-[#cafd00]" />
            </div>
          ) : (
            <div className="p-8 space-y-6">

              {/* ── Patient header ──────────────────────────────────────── */}
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1">Seguimiento</p>
                  <h1 className="text-3xl font-black text-white tracking-tight font-headline">{clientInfo?.name}</h1>
                  <p className="text-sm text-[#adaaaa]">{clientInfo?.email}</p>
                </div>
                <button
                  onClick={() => setRefreshKey(k => k + 1)}
                  className="flex items-center gap-2 text-[#adaaaa] hover:text-white text-xs font-bold uppercase tracking-wider transition-colors px-3 py-2 rounded-xl hover:bg-[#1a1a1a]"
                >
                  <RefreshCw size={13} /> Actualizar
                </button>
              </div>

              {/* ── KPI chips ────────────────────────────────────────────── */}
              <div className="flex flex-wrap gap-3">
                <KpiChip
                  label="Peso"
                  value={lastRecord?.weight_kg}
                  unit="kg"
                  delta={<DeltaIcon current={lastRecord?.weight_kg} previous={prevRecord?.weight_kg} />}
                />
                <KpiChip
                  label="IMC"
                  value={lastRecord?.bmi}
                  delta={<DeltaIcon current={lastRecord?.bmi} previous={prevRecord?.bmi} />}
                />
                <KpiChip
                  label="% Grasa"
                  value={lastRecord?.body_fat_pct}
                  unit="%"
                  delta={<DeltaIcon current={lastRecord?.body_fat_pct} previous={prevRecord?.body_fat_pct} />}
                />
                <KpiChip label="Adherencia" value={lastRecord?.adherence_pct} unit="%" />
              </div>

              {/* ── Nuevo registro de progreso ───────────────────────────── */}
              <div className="bg-[#131313] border border-[#484847]/10 rounded-2xl overflow-hidden">
                <button
                  onClick={() => { setProgressOpen(v => !v); setDietOpen(false); }}
                  className="w-full flex items-center justify-between px-6 py-4 hover:bg-[#1a1a1a] transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-7 h-7 rounded-lg bg-[#ac8aff]/20 flex items-center justify-center">
                      <Plus size={14} className="text-[#ac8aff]" />
                    </div>
                    <span className="text-sm font-black text-white uppercase tracking-tight">Registrar progreso</span>
                  </div>
                  {progressOpen ? <ChevronUp size={16} className="text-[#adaaaa]" /> : <ChevronDown size={16} className="text-[#adaaaa]" />}
                </button>

                {progressOpen && (
                  <form onSubmit={handleProgressSubmit} className="px-6 pb-6 pt-1 border-t border-[#484847]/10">
                    <div className="grid grid-cols-2 gap-4 mt-4">
                      {[
                        { key: 'date', label: 'Fecha *', type: 'date', required: true },
                        { key: 'weight_kg', label: 'Peso (kg)', type: 'number', step: '0.01', min: '0', max: '500', placeholder: '70.5' },
                        { key: 'bmi', label: 'IMC', type: 'number', step: '0.01', min: '0', max: '100', placeholder: '22.5' },
                        { key: 'body_fat_pct', label: '% Grasa corporal', type: 'number', step: '0.01', min: '0', max: '100', placeholder: '18.0' },
                        { key: 'muscle_mass_kg', label: 'Masa muscular (kg)', type: 'number', step: '0.01', min: '0', max: '300', placeholder: '35.0' },
                        { key: 'calories_target', label: 'Calorías objetivo', type: 'number', min: '0', placeholder: '2000' },
                        { key: 'adherence_pct', label: 'Adherencia (%)', type: 'number', min: '0', max: '100', placeholder: '85' },
                      ].map(({ key, label, ...inputProps }) => (
                        <div key={key}>
                          <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1.5">{label}</label>
                          <input
                            {...inputProps}
                            value={progressForm[key]}
                            onChange={e => setProgressForm(f => ({ ...f, [key]: e.target.value }))}
                            className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white placeholder-[#484847] focus:outline-none focus:ring-2 focus:ring-[#ac8aff]/30 transition-all"
                          />
                        </div>
                      ))}
                    </div>
                    <div className="mt-4">
                      <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1.5">Notas</label>
                      <textarea
                        rows={3}
                        value={progressForm.notes}
                        onChange={e => setProgressForm(f => ({ ...f, notes: e.target.value }))}
                        placeholder="Observaciones del periodo..."
                        className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white placeholder-[#484847] focus:outline-none focus:ring-2 focus:ring-[#ac8aff]/30 transition-all resize-none"
                      />
                    </div>
                    <div className="flex justify-end gap-3 mt-5">
                      <button
                        type="button"
                        onClick={() => setProgressOpen(false)}
                        className="px-5 py-2.5 text-sm font-bold text-[#adaaaa] hover:text-white border border-[#484847]/20 rounded-xl transition-colors"
                      >
                        Cancelar
                      </button>
                      <button
                        type="submit"
                        disabled={savingProgress}
                        className="flex items-center gap-2 px-6 py-2.5 bg-[#ac8aff] text-[#0e0e0e] font-black text-sm uppercase tracking-tighter rounded-xl hover:opacity-90 transition-opacity disabled:opacity-50 shadow-lg shadow-[#ac8aff]/20"
                      >
                        {savingProgress && <Loader2 size={14} className="animate-spin" />}
                        Guardar registro
                      </button>
                    </div>
                  </form>
                )}
              </div>

              {/* ── Proponer cambio de dieta ─────────────────────────────── */}
              <div className="bg-[#131313] border border-[#484847]/10 rounded-2xl overflow-hidden">
                <button
                  onClick={() => { setDietOpen(v => !v); setProgressOpen(false); }}
                  className="w-full flex items-center justify-between px-6 py-4 hover:bg-[#1a1a1a] transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-7 h-7 rounded-lg bg-[#cafd00]/10 flex items-center justify-center">
                      <Utensils size={14} className="text-[#cafd00]" />
                    </div>
                    <span className="text-sm font-black text-white uppercase tracking-tight">Proponer cambio de dieta</span>
                  </div>
                  {dietOpen ? <ChevronUp size={16} className="text-[#adaaaa]" /> : <ChevronDown size={16} className="text-[#adaaaa]" />}
                </button>

                {dietOpen && (
                  <form onSubmit={handleDietSubmit} className="px-6 pb-6 pt-1 border-t border-[#484847]/10">
                    <div className="grid grid-cols-2 gap-4 mt-4">
                      <div>
                        <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1.5">Fecha *</label>
                        <input
                          type="date" required value={dietForm.date}
                          onChange={e => setDietForm(f => ({ ...f, date: e.target.value }))}
                          className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all"
                        />
                      </div>
                      <div>
                        <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1.5">Tipo de cambio *</label>
                        <select
                          required value={dietForm.change_type}
                          onChange={e => setDietForm(f => ({ ...f, change_type: e.target.value }))}
                          className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all appearance-none"
                        >
                          {Object.entries(CHANGE_TYPE_LABELS).map(([k, v]) => (
                            <option key={k} value={k}>{v}</option>
                          ))}
                        </select>
                      </div>
                    </div>
                    <div className="mt-4">
                      <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1.5">Razón del cambio *</label>
                      <textarea
                        rows={3} required value={dietForm.reason}
                        onChange={e => setDietForm(f => ({ ...f, reason: e.target.value }))}
                        placeholder="Explica por qué propones este cambio..."
                        className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white placeholder-[#484847] focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all resize-none"
                      />
                    </div>
                    {dietForm.change_type === 'calorie_adjust' && (
                      <div className="grid grid-cols-2 gap-4 mt-4">
                        <div>
                          <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1.5">Calorías anteriores</label>
                          <input
                            type="number" min="0" placeholder="2000"
                            value={dietForm.prev_calories}
                            onChange={e => setDietForm(f => ({ ...f, prev_calories: e.target.value }))}
                            className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white placeholder-[#484847] focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all"
                          />
                        </div>
                        <div>
                          <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1.5">Calorías propuestas</label>
                          <input
                            type="number" min="0" placeholder="1800"
                            value={dietForm.new_calories}
                            onChange={e => setDietForm(f => ({ ...f, new_calories: e.target.value }))}
                            className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white placeholder-[#484847] focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all"
                          />
                        </div>
                      </div>
                    )}

                    {dietForm.change_type === 'macro_adjust' && (
                      <div className="mt-4 space-y-3">
                        <p className="text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa]">Macros anteriores (g)</p>
                        <div className="grid grid-cols-3 gap-3">
                          {[['prev_protein','Proteína'],['prev_carbs','Carbohidratos'],['prev_fat','Grasa']].map(([key, label]) => (
                            <div key={key}>
                              <label className="block text-[10px] text-[#6f6f6f] mb-1">{label}</label>
                              <input type="number" min="0" step="0.1" placeholder="0"
                                value={dietForm[key]}
                                onChange={e => setDietForm(f => ({ ...f, [key]: e.target.value }))}
                                className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white placeholder-[#484847] focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all"
                              />
                            </div>
                          ))}
                        </div>
                        <p className="text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa]">Macros propuestos (g)</p>
                        <div className="grid grid-cols-3 gap-3">
                          {[['new_protein','Proteína'],['new_carbs','Carbohidratos'],['new_fat','Grasa']].map(([key, label]) => (
                            <div key={key}>
                              <label className="block text-[10px] text-[#6f6f6f] mb-1">{label}</label>
                              <input type="number" min="0" step="0.1" placeholder="0"
                                value={dietForm[key]}
                                onChange={e => setDietForm(f => ({ ...f, [key]: e.target.value }))}
                                className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white placeholder-[#484847] focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all"
                              />
                            </div>
                          ))}
                        </div>
                      </div>
                    )}

                    {(dietForm.change_type === 'meal_update' || dietForm.change_type === 'plan_change') && (
                      <div className="grid grid-cols-2 gap-4 mt-4">
                        <div>
                          <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1.5">
                            {dietForm.change_type === 'plan_change' ? 'Plan anterior' : 'Comida anterior'}
                          </label>
                          <input type="text"
                            value={dietForm.prev_text}
                            onChange={e => setDietForm(f => ({ ...f, prev_text: e.target.value }))}
                            placeholder={dietForm.change_type === 'plan_change' ? 'Nombre del plan actual' : 'Nombre de la comida actual'}
                            className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white placeholder-[#484847] focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all"
                          />
                        </div>
                        <div>
                          <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] mb-1.5">
                            {dietForm.change_type === 'plan_change' ? 'Plan propuesto' : 'Comida propuesta'}
                          </label>
                          <input type="text"
                            value={dietForm.new_text}
                            onChange={e => setDietForm(f => ({ ...f, new_text: e.target.value }))}
                            placeholder={dietForm.change_type === 'plan_change' ? 'Nombre del nuevo plan' : 'Nombre de la nueva comida'}
                            className="w-full bg-[#0e0e0e] border-none rounded-xl px-3 py-2.5 text-sm text-white placeholder-[#484847] focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all"
                          />
                        </div>
                      </div>
                    )}
                    <div className="flex justify-end gap-3 mt-5">
                      <button
                        type="button"
                        onClick={() => setDietOpen(false)}
                        className="px-5 py-2.5 text-sm font-bold text-[#adaaaa] hover:text-white border border-[#484847]/20 rounded-xl transition-colors"
                      >
                        Cancelar
                      </button>
                      <button
                        type="submit"
                        disabled={savingDiet}
                        className="flex items-center gap-2 px-6 py-2.5 bg-[#cafd00] text-[#3a4a00] font-black text-sm uppercase tracking-tighter rounded-xl hover:opacity-90 transition-opacity disabled:opacity-50 shadow-lg shadow-[#cafd00]/10"
                      >
                        {savingDiet && <Loader2 size={14} className="animate-spin" />}
                        Enviar propuesta
                      </button>
                    </div>
                  </form>
                )}
              </div>

              {/* ── Timeline ─────────────────────────────────────────────── */}
              <div className="bg-[#131313] border border-[#484847]/10 rounded-2xl p-6">
                <div className="flex items-center justify-between mb-6">
                  <h2 className="text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa]">
                    Historial
                  </h2>
                  <span className="text-[10px] font-bold text-[#cafd00] bg-[#cafd00]/10 px-3 py-1 rounded-full border border-[#cafd00]/20">
                    {timeline.length} entradas
                  </span>
                </div>

                {timeline.length === 0 ? (
                  <div className="text-center py-12 text-[#adaaaa]">
                    <TrendingUp size={36} className="mx-auto mb-3 opacity-10" />
                    <p className="text-sm font-bold text-white">Sin registros todavía</p>
                    <p className="text-xs mt-1 text-[#adaaaa]">Agrega el primer registro de progreso arriba</p>
                  </div>
                ) : (
                  <div>
                    {timeline.map((entry, i) => (
                      <TimelineEntry key={`${entry.type}-${entry.id ?? i}`} entry={entry} />
                    ))}
                  </div>
                )}
              </div>

            </div>
          )}
        </main>
      </div>
    </NutriologoLayout>
  );
}
