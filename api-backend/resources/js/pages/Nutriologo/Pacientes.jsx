import { useEffect, useMemo, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  AlertTriangle,
  CheckCircle2,
  ClipboardList,
  FileText,
  Loader2,
  Mail,
  PauseCircle,
  Plus,
  RefreshCw,
  Search,
  Trophy,
  Users,
  Utensils,
  XCircle,
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { syncLocalUserProfile } from '../../lib/localUserSync';
import KpiCard from '../Coach/components/KpiCard';
import NutriologoLayout from './NutriologoLayout';

const MEAL_TYPE_LABELS = {
  desayuno: 'Desayuno',
  colacion_1: 'Colación 1',
  comida: 'Comida',
  colacion_2: 'Colación 2',
  cena: 'Cena',
};

const emptyMeta = {
  current_page: 1,
  last_page: 1,
  per_page: 8,
  total: 0,
  has_more: false,
};

const statusStyles = {
  active: {
    label: 'Activo',
    pill: 'bg-[#cafd00]/15 text-[#f3ffca] border border-[#cafd00]/30',
  },
  paused: {
    label: 'En pausa',
    pill: 'bg-[#3b2e08] text-[#fce047] border border-[#fce047]/20',
  },
  completed: {
    label: 'Completado',
    pill: 'bg-[#10261d] text-[#7ef0b3] border border-[#7ef0b3]/20',
  },
  cancelled: {
    label: 'Cancelado',
    pill: 'bg-[#3a1712] text-[#ffb19d] border border-[#ff7351]/20',
  },
  alerta: {
    label: 'Alerta',
    pill: 'bg-[#3a1712] text-[#ffb19d] border border-[#ff7351]/20',
  },
  sin_plan: {
    label: 'Sin plan',
    pill: 'bg-[#262626] text-[#adaaaa] border border-[#484847]/30',
  },
};

function resolveStatus(patient) {
  if (patient?.status === 'alerta') return statusStyles.alerta;

  const key = patient?.status_key ?? patient?.status ?? 'sin_plan';
  return statusStyles[key] ?? statusStyles.sin_plan;
}

export default function NutriologoPacientesPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const [nutriologoName, setNutriologoName] = useState('Nutriólogo');
  const [patients, setPatients] = useState([]);
  const [plans, setPlans] = useState([]);
  const [meta, setMeta] = useState(emptyMeta);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [refreshTick, setRefreshTick] = useState(0);
  const [selectedPatientId, setSelectedPatientId] = useState(null);
  const [assignForm, setAssignForm] = useState({ planId: '', notes: '' });
  const [patientPlanMeals, setPatientPlanMeals] = useState([]);
  const [mealsLoading, setMealsLoading] = useState(false);

  const selectedPatient = useMemo(
    () => patients.find((patient) => String(patient.id) === String(selectedPatientId)) ?? patients[0] ?? null,
    [patients, selectedPatientId]
  );

  // Pre-select patient passed from Dashboard action buttons
  useEffect(() => {
    if (location.state?.patientId) {
      setSelectedPatientId(String(location.state.patientId));
    }
  }, [location.state]);

  // Fetch plan meals when selected patient changes
  useEffect(() => {
    const planId = selectedPatient?.current_plan_id;
    if (!planId) { setPatientPlanMeals([]); return; }
    let ignore = false;
    const load = async () => {
      try {
        setMealsLoading(true);
        const { data: { session } } = await supabase.auth.getSession();
        const token = session?.access_token;
        const res = await fetch(`/api/nutriologo/planes/${planId}`, {
          headers: { Accept: 'application/json', Authorization: `Bearer ${token}` },
        });
        if (!res.ok) return;
        const payload = await res.json();
        if (!ignore) setPatientPlanMeals(payload.meals ?? []);
      } catch {
        if (!ignore) setPatientPlanMeals([]);
      } finally {
        if (!ignore) setMealsLoading(false);
      }
    };
    load();
    return () => { ignore = true; };
  }, [selectedPatient?.current_plan_id]);

  const getSessionData = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    const token = session?.access_token;

    if (!token) {
      throw new Error('No se encontró una sesión activa.');
    }

    const name =
      session?.user?.user_metadata?.full_name ||
      session?.user?.user_metadata?.name ||
      session?.user?.email?.split('@')[0] ||
      'Nutriólogo';

    setNutriologoName(name);
    await syncLocalUserProfile(session).catch(() => null);

    return { session, token };
  };

  const requestJson = async (url, options = {}) => {
    const { session, token } = await getSessionData();
    const headers = {
      Accept: 'application/json',
      Authorization: `Bearer ${token}`,
      ...(options.body ? { 'Content-Type': 'application/json' } : {}),
      ...(options.headers ?? {}),
    };

    const doRequest = () => fetch(url, {
      ...options,
      headers,
    });

    let response = await doRequest();

    if (response.status === 401) {
      await syncLocalUserProfile(session).catch(() => null);
      response = await doRequest();
    }

    if (!response.ok) {
      let apiMessage = `No se pudo completar la solicitud (${response.status}).`;

      try {
        const payload = await response.json();
        apiMessage = payload?.error || payload?.message || apiMessage;
      } catch {
        // Ignore JSON parsing error and keep fallback message.
      }

      throw new Error(apiMessage);
    }

    return response.json();
  };

  useEffect(() => {
    let ignore = false;

    const loadData = async () => {
      try {
        setLoading(true);
        setError('');

        const [patientsPayload, plansPayload] = await Promise.all([
          requestJson(`/api/nutriologo/clientes?search=${encodeURIComponent(search)}&page=${page}&per_page=8`),
          requestJson('/api/nutriologo/planes?per_page=100'),
        ]);

        if (ignore) return;

        const nextPatients = patientsPayload?.data ?? [];

        setPatients(nextPatients);
        setPlans(plansPayload?.data ?? []);
        setMeta({ ...emptyMeta, ...(patientsPayload?.meta ?? {}) });
        setSelectedPatientId((current) => (
          nextPatients.some((patient) => String(patient.id) === String(current))
            ? current
            : (nextPatients[0]?.id ?? null)
        ));
      } catch (err) {
        if (!ignore) {
          setError(err.message || 'No se pudo cargar la gestión de pacientes.');
          setPatients([]);
          setMeta(emptyMeta);
        }
      } finally {
        if (!ignore) {
          setLoading(false);
        }
      }
    };

    loadData();

    return () => {
      ignore = true;
    };
  }, [page, refreshTick, search]);

  const summary = useMemo(() => ({
    conPlan: patients.filter((patient) => Boolean(patient.current_plan)).length,
    conObjetivo: patients.filter((patient) => patient.objective && patient.objective !== 'Sin objetivo registrado').length,
    alertas: patients.filter((patient) => ['paused', 'cancelled', 'alerta'].includes(patient.status_key ?? patient.status)).length,
  }), [patients]);

  const refreshData = () => {
    setRefreshTick((value) => value + 1);
  };

  const handleAssignPlan = async () => {
    if (!selectedPatient?.id) {
      setError('Selecciona un paciente para asignar un plan.');
      return;
    }

    if (!assignForm.planId) {
      setError('Selecciona un plan nutricional disponible.');
      return;
    }

    try {
      setSaving(true);
      setError('');
      setMessage('');

      await requestJson(`/api/nutriologo/planes/${assignForm.planId}/asignar`, {
        method: 'POST',
        body: JSON.stringify({
          client_id: selectedPatient.id,
          notes: assignForm.notes || null,
          starts_at: new Date().toISOString().slice(0, 10),
        }),
      });

      setMessage('Plan asignado correctamente al paciente.');
      setAssignForm((current) => ({ ...current, notes: '' }));
      refreshData();
    } catch (err) {
      setError(err.message || 'No fue posible asignar el plan.');
    } finally {
      setSaving(false);
    }
  };

  const handleStatusChange = async (status) => {
    if (!selectedPatient?.assignment_id) {
      setError('Este paciente aún no tiene una asignación activa para actualizar.');
      return;
    }

    try {
      setSaving(true);
      setError('');
      setMessage('');

      await requestJson(`/api/nutriologo/asignaciones/${selectedPatient.assignment_id}/status`, {
        method: 'PATCH',
        body: JSON.stringify({ status }),
      });

      setMessage('Estado del seguimiento actualizado.');
      refreshData();
    } catch (err) {
      setError(err.message || 'No fue posible actualizar el estado.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <NutriologoLayout nutriologoName={nutriologoName}>
      <div className="grid grid-cols-12 gap-8">
        <section className="col-span-12 flex flex-col gap-2">
          <p className="text-xs uppercase tracking-[0.25em] text-[#adaaaa]">Gestión de pacientes</p>
          <h1 className="text-4xl font-black font-headline text-white">Pacientes del nutriólogo</h1>
          <p className="text-sm text-[#adaaaa] max-w-3xl">
            Revisa objetivos, asigna planes nutricionales y actualiza el seguimiento desde un solo lugar.
          </p>
        </section>

        {(error || message) && (
          <section className={`col-span-12 rounded-xl px-4 py-3 text-sm ${error ? 'border border-red-500/20 bg-red-500/10 text-red-200' : 'border border-[#cafd00]/20 bg-[#cafd00]/10 text-[#f3ffca]'}`}>
            {error || message}
          </section>
        )}

        <section className="col-span-12 bg-[#1a1a1a] rounded-xl p-4 md:p-5 flex flex-col md:flex-row md:items-center gap-4 border border-[#484847]/10">
          <div className="relative flex-1">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#adaaaa]" />
            <input
              value={search}
              onChange={(event) => {
                setSearch(event.target.value);
                setPage(1);
              }}
              type="text"
              placeholder="Buscar por nombre o correo..."
              className="w-full bg-[#131313] rounded-lg pl-10 pr-4 py-3 text-sm text-white placeholder-[#777] focus:outline-none focus:ring-1 focus:ring-[#cafd00]"
            />
          </div>

          <button
            onClick={refreshData}
            className="inline-flex items-center justify-center gap-2 px-4 py-3 rounded-lg bg-[#262626] text-[#f3ffca] hover:bg-[#303030] transition-colors"
          >
            <RefreshCw size={15} />
            Recargar
          </button>
        </section>

        <section className="col-span-12 grid grid-cols-1 md:grid-cols-4 gap-6">
          <KpiCard label="Pacientes registrados" value={meta.total} icon={Users} valueColor="text-[#cafd00]" />
          <KpiCard label="Con plan actual" value={summary.conPlan} icon={FileText} iconColor="text-[#ac8aff]" valueColor="text-[#ac8aff]" />
          <KpiCard label="Objetivos definidos" value={summary.conObjetivo} icon={Trophy} iconColor="text-[#fce047]" valueColor="text-[#fce047]" />
          <KpiCard label="Alertas activas" value={summary.alertas} icon={AlertTriangle} iconColor="text-[#ff7351]" valueColor="text-[#ff7351]" />
        </section>

        <section className="col-span-12 lg:col-span-7 bg-[#1a1a1a] rounded-xl overflow-hidden border border-[#484847]/10">
          <div className="px-6 py-5 border-b border-[#484847]/10 flex items-center justify-between">
            <div>
              <h2 className="text-xl font-bold font-headline">Listado de pacientes</h2>
              <p className="text-xs text-[#adaaaa] mt-1">Selecciona un paciente para ver detalles y gestionar su plan.</p>
            </div>
            <span className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa]">Página {meta.current_page} / {meta.last_page}</span>
          </div>

          {loading ? (
            <div className="min-h-80 flex items-center justify-center text-[#f3ffca] gap-3">
              <Loader2 className="animate-spin" size={18} />
              <span>Cargando pacientes...</span>
            </div>
          ) : patients.length === 0 ? (
            <div className="min-h-80 flex items-center justify-center text-sm text-[#adaaaa] px-6 text-center">
              No se encontraron pacientes con los filtros actuales.
            </div>
          ) : (
            <div className="divide-y divide-[#484847]/10">
              {patients.map((patient) => {
                const statusConfig = resolveStatus(patient);
                const isSelected = String(patient.id) === String(selectedPatient?.id);

                return (
                  <button
                    key={patient.id}
                    onClick={() => setSelectedPatientId(patient.id)}
                    className={`w-full text-left px-6 py-4 transition-colors ${isSelected ? 'bg-[#20201f]' : 'hover:bg-[#181818]'}`}
                  >
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex items-center gap-3 min-w-0">
                        <div className="w-10 h-10 rounded-full bg-[#cafd00] text-[#0e0e0e] font-bold flex items-center justify-center shrink-0">
                          {(patient.name || 'P').charAt(0).toUpperCase()}
                        </div>
                        <div className="min-w-0">
                          <p className="text-sm font-semibold text-white truncate">{patient.name}</p>
                          <p className="text-xs text-[#adaaaa] truncate">{patient.email}</p>
                          <p className="text-[11px] text-[#f3ffca] mt-1 truncate">{patient.current_plan || 'Sin plan asignado'}</p>
                        </div>
                      </div>

                      <div className="flex flex-col items-end gap-2 shrink-0">
                        <span className={`text-[10px] uppercase tracking-widest px-2.5 py-1 rounded-full ${statusConfig.pill}`}>
                          {patient.status_label || statusConfig.label}
                        </span>
                        <span className="text-[10px] text-[#777]">{patient.last_update || 'Sin seguimiento'}</span>
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          )}

          <div className="px-6 py-4 border-t border-[#484847]/10 flex items-center justify-between text-[10px] uppercase tracking-[0.2em] text-[#adaaaa]">
            <span>Mostrando {patients.length} de {meta.total}</span>
            <div className="flex items-center gap-3">
              <button
                onClick={() => setPage((current) => Math.max(1, current - 1))}
                disabled={meta.current_page <= 1 || loading}
                className="px-3 py-1.5 rounded bg-[#262626] disabled:opacity-40"
              >
                Anterior
              </button>
              <button
                onClick={() => setPage((current) => Math.min(meta.last_page || 1, current + 1))}
                disabled={meta.current_page >= meta.last_page || loading}
                className="px-3 py-1.5 rounded bg-[#262626] disabled:opacity-40"
              >
                Siguiente
              </button>
            </div>
          </div>
        </section>

        <section className="col-span-12 lg:col-span-5 bg-[#1a1a1a] rounded-xl p-6 border border-[#484847]/10 flex flex-col gap-6">
          {!selectedPatient ? (
            <div className="min-h-80 flex items-center justify-center text-center text-sm text-[#adaaaa]">
              Selecciona un paciente para comenzar su gestión.
            </div>
          ) : (
            <>
              <div className="flex items-start gap-4">
                <div className="w-14 h-14 rounded-full bg-[#cafd00] text-[#0e0e0e] font-black text-xl flex items-center justify-center shrink-0">
                  {(selectedPatient.name || 'P').charAt(0).toUpperCase()}
                </div>
                <div className="min-w-0">
                  <h2 className="text-2xl font-bold font-headline text-white truncate">{selectedPatient.name}</h2>
                  <p className="text-sm text-[#adaaaa] truncate">{selectedPatient.email}</p>
                  <span className={`inline-flex mt-2 text-[10px] uppercase tracking-widest px-2.5 py-1 rounded-full ${resolveStatus(selectedPatient).pill}`}>
                    {selectedPatient.status_label || resolveStatus(selectedPatient).label}
                  </span>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div className="rounded-lg bg-[#131313] p-4">
                  <p className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa] mb-2">Objetivo</p>
                  <p className="text-sm text-white">{selectedPatient.objective || 'Sin objetivo registrado'}</p>
                </div>
                <div className="rounded-lg bg-[#131313] p-4">
                  <p className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa] mb-2">Plan actual</p>
                  <p className="text-sm text-white">{selectedPatient.current_plan || 'Sin plan asignado'}</p>
                </div>
              </div>

              <div className="flex flex-wrap gap-3">
                <button
                  onClick={() => window.open(`mailto:${selectedPatient.email}`, '_blank')}
                  className="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-[#262626] text-white hover:text-[#f3ffca] transition-colors"
                >
                  <Mail size={15} />
                  Contactar
                </button>
                <div className="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-[#131313] text-[#adaaaa]">
                  <ClipboardList size={15} />
                  {selectedPatient.last_update && selectedPatient.last_update !== 'Sin seguimiento reciente'
                    ? selectedPatient.last_update
                    : <span className="italic">Sin seguimiento reciente</span>
                  }
                </div>
              </div>

              {/* Plan meals */}
              {(patientPlanMeals.length > 0 || mealsLoading) && (
                <div className="rounded-xl bg-[#131313] p-4 border border-[#484847]/10">
                  <p className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa] mb-3 flex items-center gap-2">
                    <Utensils size={11} />
                    Comidas del plan actual
                    {mealsLoading && <Loader2 size={10} className="animate-spin" />}
                  </p>
                  <div className="space-y-2">
                    {patientPlanMeals.map((meal) => (
                      <div key={meal.id} className="flex items-center justify-between py-2 border-b border-[#484847]/10 last:border-0">
                        <div className="min-w-0">
                          <span className="text-[9px] uppercase tracking-widest text-[#adaaaa]">{MEAL_TYPE_LABELS[meal.meal_type] ?? meal.meal_type}</span>
                          <p className="text-sm text-white truncate">{meal.name}</p>
                          {meal.portion && <p className="text-[10px] text-[#6f6f6f]">{meal.portion}</p>}
                        </div>
                        <div className="text-right shrink-0 ml-3">
                          {meal.calories && <p className="text-sm font-bold text-[#cafd00]">{meal.calories} kcal</p>}
                          <p className="text-[10px] text-[#adaaaa]">
                            P:{meal.protein_g ?? '—'}g C:{meal.carbs_g ?? '—'}g G:{meal.fat_g ?? '—'}g
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div>
                <p className="text-[10px] uppercase tracking-[0.2em] text-[#adaaaa] mb-3">Acciones rápidas</p>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    disabled={saving || !selectedPatient.assignment_id}
                    onClick={() => handleStatusChange('active')}
                    className="inline-flex items-center justify-center gap-2 px-3 py-2.5 rounded-lg bg-[#13210f] text-[#98f08f] disabled:opacity-40"
                  >
                    <CheckCircle2 size={15} />
                    Activar
                  </button>
                  <button
                    disabled={saving || !selectedPatient.assignment_id}
                    onClick={() => handleStatusChange('paused')}
                    className="inline-flex items-center justify-center gap-2 px-3 py-2.5 rounded-lg bg-[#2d270d] text-[#fce047] disabled:opacity-40"
                  >
                    <PauseCircle size={15} />
                    Pausar
                  </button>
                  <button
                    disabled={saving || !selectedPatient.assignment_id}
                    onClick={() => handleStatusChange('completed')}
                    className="inline-flex items-center justify-center gap-2 px-3 py-2.5 rounded-lg bg-[#10261d] text-[#7ef0b3] disabled:opacity-40"
                  >
                    <Trophy size={15} />
                    Completar
                  </button>
                  <button
                    disabled={saving || !selectedPatient.assignment_id}
                    onClick={() => handleStatusChange('cancelled')}
                    className="inline-flex items-center justify-center gap-2 px-3 py-2.5 rounded-lg bg-[#3a1712] text-[#ffb19d] disabled:opacity-40"
                  >
                    <XCircle size={15} />
                    Cancelar
                  </button>
                </div>
              </div>

              <div className="rounded-xl bg-[#131313] p-4 border border-[#484847]/10">
                <h3 className="text-sm font-bold text-white mb-3">Asignar o reemplazar plan</h3>

                <div className="space-y-3">
                  <select
                    value={assignForm.planId}
                    onChange={(event) => setAssignForm((current) => ({ ...current, planId: event.target.value }))}
                    disabled={plans.length === 0}
                    className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00] disabled:opacity-50"
                  >
                    <option value="">{plans.length === 0 ? 'No hay planes disponibles todavía' : 'Selecciona un plan disponible'}</option>
                    {plans.map((plan) => (
                      <option key={plan.id} value={plan.id}>{plan.title}</option>
                    ))}
                  </select>

                  {plans.length === 0 && (
                    <div className="flex items-center justify-between gap-3">
                      <p className="text-xs text-[#adaaaa]">
                        Crea primero un plan nutricional para poder asignarlo.
                      </p>
                      <button
                        onClick={() => navigate('/nutriologo/planes')}
                        className="shrink-0 inline-flex items-center gap-1 text-xs text-[#cafd00] hover:underline"
                      >
                        <Plus size={12} />
                        Crear plan
                      </button>
                    </div>
                  )}

                  <textarea
                    rows={4}
                    value={assignForm.notes}
                    onChange={(event) => setAssignForm((current) => ({ ...current, notes: event.target.value }))}
                    placeholder="Notas de seguimiento u observaciones..."
                    className="w-full bg-[#0e0e0e] rounded-lg px-3 py-3 text-sm text-white border border-[#484847]/20 focus:outline-none focus:ring-1 focus:ring-[#cafd00] resize-none"
                  />

                  <button
                    onClick={handleAssignPlan}
                    disabled={saving || loading || plans.length === 0}
                    className="w-full inline-flex items-center justify-center gap-2 py-3 rounded-lg bg-[#cafd00] text-[#405100] font-bold uppercase tracking-wide disabled:opacity-50"
                  >
                    {saving ? <Loader2 className="animate-spin" size={16} /> : <FileText size={16} />}
                    Asignar plan nutricional
                  </button>
                </div>
              </div>
            </>
          )}
        </section>
      </div>
    </NutriologoLayout>
  );
}
