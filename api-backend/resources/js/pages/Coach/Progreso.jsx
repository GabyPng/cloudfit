import { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip as ChartTooltip,
  ResponsiveContainer, Legend,
} from 'recharts';
import { motion, AnimatePresence } from 'framer-motion';
import {
  TrendingUp, TrendingDown, Minus, Weight, Flame, Dumbbell,
  ChevronRight, Loader2, Users,
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import MapaFatiga from './MapaFatiga';

// ─── Helpers ─────────────────────────────────────────────────────────────────

function formatDate(dateStr) {
  if (!dateStr) return '';
  const [, m, d] = dateStr.split('-');
  return `${d}/${m}`;
}

async function authFetch(path) {
  const { data: { session } } = await supabase.auth.getSession();
  const token = session?.access_token;
  if (!token) throw new Error('Sin sesión');
  const res = await fetch(path, { headers: { Authorization: `Bearer ${token}`, Accept: 'application/json' } });
  if (!res.ok) throw new Error(`Error ${res.status}`);
  return res.json();
}

// ─── Sub-components ───────────────────────────────────────────────────────────

function KpiCard({ label, value, unit, delta, icon: Icon, iconColor, positive = true }) {
  const isPositive = delta > 0;
  const isNeutral  = delta === 0;
  const good = positive ? isPositive : !isPositive;

  const DeltaIcon = isNeutral ? Minus : isPositive ? TrendingUp : TrendingDown;
  const deltaColor = isNeutral ? '#adaaaa' : good ? '#cafd00' : '#ff7351';

  return (
    <div className="bg-[#1a1a1a] rounded-2xl p-5 border border-[#222] flex flex-col gap-3">
      <div className="flex items-center justify-between">
        <span className="text-xs text-[#adaaaa] uppercase tracking-wider font-semibold">{label}</span>
        <Icon size={16} style={{ color: iconColor ?? '#cafd00' }} />
      </div>
      <div className="flex items-end gap-2">
        <span className="text-3xl font-black" style={{ color: iconColor ?? '#cafd00' }}>
          {value ?? '—'}
        </span>
        {unit && <span className="text-sm text-[#adaaaa] mb-1">{unit}</span>}
      </div>
      {delta !== undefined && (
        <div className="flex items-center gap-1.5 text-xs">
          <DeltaIcon size={12} style={{ color: deltaColor }} />
          <span style={{ color: deltaColor }}>
            {isNeutral ? 'Sin cambio' : `${isPositive ? '+' : ''}${delta} ${unit ?? ''} este mes`}
          </span>
        </div>
      )}
    </div>
  );
}

const CHART_TOOLTIP_STYLE = {
  backgroundColor: '#1a1a1a',
  border: '1px solid #333',
  borderRadius: 10,
  color: '#fff',
  fontSize: 12,
};

function CustomDot({ cx, cy, fill }) {
  return <circle cx={cx} cy={cy} r={4} fill={fill} stroke="#0e0e0e" strokeWidth={2} />;
}

// ─── Main Component ───────────────────────────────────────────────────────────

const TABS = ['Composición', 'Fatiga Muscular'];

export default function Progreso() {
  const [clients, setClients]           = useState([]);
  const [selectedClient, setSelected]   = useState(null);
  const location = useLocation();
  const [tab, setTab]                   = useState(0);
  const [loadingClients, setLoadingClients] = useState(true);

  // Composición state
  const [compData, setCompData]         = useState(null);
  const [loadingComp, setLoadingComp]   = useState(false);

  // Fatiga state
  const [fatigaData, setFatigaData]     = useState(null);
  const [loadingFatiga, setLoadingFatiga] = useState(false);

  // Load clients list, then pre-select if clientId is in the URL
  useEffect(() => {
    const params = new URLSearchParams(location.search);
    const clientIdFromUrl = params.get('clientId');

    authFetch('/api/coach/progreso/clients')
      .then(data => {
        setClients(data);
        if (clientIdFromUrl) {
          const found = data.find(c => c.id === Number(clientIdFromUrl));
          if (found) setSelected(found);
        }
      })
      .catch(console.error)
      .finally(() => setLoadingClients(false));
  }, []);

  // Load composición when client or tab changes
  useEffect(() => {
    if (!selectedClient || tab !== 0) return;
    setLoadingComp(true);
    authFetch(`/api/coach/progreso/clients/${selectedClient.id}/composicion`)
      .then(setCompData)
      .catch(console.error)
      .finally(() => setLoadingComp(false));
  }, [selectedClient, tab]);

  // Load fatiga when client + tab
  useEffect(() => {
    if (!selectedClient || tab !== 1) return;
    setLoadingFatiga(true);
    authFetch(`/api/coach/progreso/clients/${selectedClient.id}/fatiga`)
      .then((d) => setFatigaData(d.semana))
      .catch(console.error)
      .finally(() => setLoadingFatiga(false));
  }, [selectedClient, tab]);

  const Loading = () => (
    <div className="flex items-center justify-center h-64">
      <Loader2 size={28} className="animate-spin text-[#cafd00]" />
    </div>
  );

  const EmptyState = ({ message }) => (
    <div className="flex flex-col items-center justify-center h-64 gap-3">
      <TrendingUp size={40} className="text-[#333]" />
      <p className="text-sm text-[#555]">{message}</p>
    </div>
  );

  return (
    <div className="flex flex-col gap-8">
      {/* Page header */}
      <div>
        <h1 className="text-3xl font-black text-white tracking-tighter">Progreso Físico</h1>
        <p className="text-sm text-[#adaaaa] mt-1">Análisis detallado de evolución y rendimiento</p>
      </div>

      {/* Client selector */}
      <section>
        <p className="text-xs font-bold text-[#adaaaa] uppercase tracking-wider mb-3">Seleccionar Cliente</p>
        {loadingClients ? (
          <div className="flex gap-3">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-16 w-36 rounded-xl bg-[#1a1a1a] animate-pulse" />
            ))}
          </div>
        ) : clients.length === 0 ? (
          <div className="flex items-center gap-2 text-sm text-[#555]">
            <Users size={16} />
            <span>No hay clientes asignados</span>
          </div>
        ) : (
          <div className="flex flex-wrap gap-3">
            {clients.map((client) => {
              const active = selectedClient?.id === client.id;
              return (
                <motion.button
                  key={client.id}
                  onClick={() => setSelected(client)}
                  whileHover={{ scale: 1.03 }}
                  whileTap={{ scale: 0.97 }}
                  className={`flex items-center gap-3 px-4 py-3 rounded-xl border transition-all duration-200 ${
                    active
                      ? 'bg-[#cafd00]/10 border-[#cafd00] text-white'
                      : 'bg-[#1a1a1a] border-[#222] text-[#adaaaa] hover:border-[#444] hover:text-white'
                  }`}
                >
                  <div
                    className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-[#0e0e0e] flex-shrink-0"
                    style={{ background: active ? '#cafd00' : '#333' }}
                  >
                    <span className={active ? 'text-[#0e0e0e]' : 'text-[#adaaaa]'}>
                      {client.initials}
                    </span>
                  </div>
                  <div className="text-left">
                    <p className={`text-sm font-semibold leading-tight ${active ? 'text-white' : ''}`}>{client.name}</p>
                    {client.objetivo && (
                      <p className="text-[10px] text-[#555] truncate max-w-[100px]">{client.objetivo}</p>
                    )}
                  </div>
                  {active && <ChevronRight size={14} className="text-[#cafd00] ml-1" />}
                </motion.button>
              );
            })}
          </div>
        )}
      </section>

      {/* Main content (only if client selected) */}
      <AnimatePresence>
        {selectedClient && (
          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            transition={{ duration: 0.3 }}
            className="flex flex-col gap-6"
          >
            {/* Tabs */}
            <div className="flex gap-1 bg-[#1a1a1a] rounded-xl p-1 border border-[#222] w-fit">
              {TABS.map((t, i) => (
                <button
                  key={t}
                  onClick={() => setTab(i)}
                  className={`px-5 py-2 rounded-lg text-sm font-bold transition-all duration-200 ${
                    tab === i
                      ? 'bg-[#cafd00] text-[#0e0e0e]'
                      : 'text-[#adaaaa] hover:text-white'
                  }`}
                >
                  {t}
                </button>
              ))}
            </div>

            {/* ── Tab 0: Composición Corporal ── */}
            {tab === 0 && (
              <AnimatePresence mode="wait">
                <motion.div
                  key="composicion"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  transition={{ duration: 0.2 }}
                  className="flex flex-col gap-6"
                >
                  {loadingComp ? (
                    <Loading />
                  ) : !compData ? (
                    <EmptyState message="Sin registros de composición corporal" />
                  ) : (
                    <>
                      {/* KPIs */}
                      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                        <KpiCard
                          label="Peso Actual"
                          value={compData.kpis.peso_actual}
                          unit="kg"
                          delta={compData.kpis.cambio_peso}
                          icon={Weight}
                          iconColor="#cafd00"
                          positive={false}
                        />
                        <KpiCard
                          label="% Grasa Corporal"
                          value={compData.kpis.grasa_actual}
                          unit="%"
                          delta={compData.kpis.cambio_grasa}
                          icon={Flame}
                          iconColor="#ff7351"
                          positive={false}
                        />
                        <KpiCard
                          label="Masa Muscular"
                          value={compData.kpis.musculo_actual}
                          unit="kg"
                          delta={compData.kpis.cambio_musculo}
                          icon={Dumbbell}
                          iconColor="#ac8aff"
                          positive={true}
                        />
                      </div>

                      {compData.datos.length === 0 ? (
                        <EmptyState message="No hay datos históricos registrados aún" />
                      ) : (
                        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                          {/* Peso chart */}
                          <div className="bg-[#1a1a1a] rounded-2xl p-6 border border-[#222]">
                            <h3 className="text-sm font-bold text-white mb-4">Evolución del Peso (kg)</h3>
                            <ResponsiveContainer width="100%" height={220}>
                              <LineChart data={compData.datos} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
                                <CartesianGrid strokeDasharray="3 3" stroke="#222" />
                                <XAxis dataKey="fecha" tickFormatter={formatDate} tick={{ fill: '#555', fontSize: 11 }} axisLine={false} tickLine={false} />
                                <YAxis tick={{ fill: '#555', fontSize: 11 }} axisLine={false} tickLine={false} />
                                <ChartTooltip
                                  contentStyle={CHART_TOOLTIP_STYLE}
                                  labelFormatter={(l) => `Fecha: ${formatDate(l)}`}
                                  formatter={(v) => [`${v} kg`, 'Peso']}
                                />
                                <Line
                                  type="monotone"
                                  dataKey="peso"
                                  stroke="#cafd00"
                                  strokeWidth={2.5}
                                  dot={<CustomDot fill="#cafd00" />}
                                  activeDot={{ r: 6, fill: '#cafd00', stroke: '#0e0e0e' }}
                                />
                              </LineChart>
                            </ResponsiveContainer>
                          </div>

                          {/* Body fat chart */}
                          <div className="bg-[#1a1a1a] rounded-2xl p-6 border border-[#222]">
                            <h3 className="text-sm font-bold text-white mb-4">Evolución de % Grasa Corporal</h3>
                            <ResponsiveContainer width="100%" height={220}>
                              <LineChart data={compData.datos} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
                                <CartesianGrid strokeDasharray="3 3" stroke="#222" />
                                <XAxis dataKey="fecha" tickFormatter={formatDate} tick={{ fill: '#555', fontSize: 11 }} axisLine={false} tickLine={false} />
                                <YAxis tick={{ fill: '#555', fontSize: 11 }} axisLine={false} tickLine={false} unit="%" />
                                <ChartTooltip
                                  contentStyle={CHART_TOOLTIP_STYLE}
                                  labelFormatter={(l) => `Fecha: ${formatDate(l)}`}
                                  formatter={(v) => [`${v}%`, '% Grasa']}
                                />
                                <Line
                                  type="monotone"
                                  dataKey="grasa"
                                  stroke="#ff7351"
                                  strokeWidth={2.5}
                                  dot={<CustomDot fill="#ff7351" />}
                                  activeDot={{ r: 6, fill: '#ff7351', stroke: '#0e0e0e' }}
                                />
                                {compData.datos.some((d) => d.musculo > 0) && (
                                  <Line
                                    type="monotone"
                                    dataKey="musculo"
                                    stroke="#ac8aff"
                                    strokeWidth={2.5}
                                    dot={<CustomDot fill="#ac8aff" />}
                                    activeDot={{ r: 6, fill: '#ac8aff', stroke: '#0e0e0e' }}
                                    name="Masa Muscular (kg)"
                                  />
                                )}
                                <Legend
                                  wrapperStyle={{ fontSize: 11, color: '#adaaaa', paddingTop: 8 }}
                                  formatter={(v) => v === 'grasa' ? '% Grasa' : 'Músculo (kg)'}
                                />
                              </LineChart>
                            </ResponsiveContainer>
                          </div>
                        </div>
                      )}
                    </>
                  )}
                </motion.div>
              </AnimatePresence>
            )}

            {/* ── Tab 1: Mapa de Fatiga ── */}
            {tab === 1 && (
              <AnimatePresence mode="wait">
                <motion.div
                  key="fatiga"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  transition={{ duration: 0.2 }}
                >
                  {loadingFatiga ? (
                    <Loading />
                  ) : !fatigaData ? (
                    <EmptyState message="Sin datos de entrenamiento en los últimos 7 días" />
                  ) : (
                    <div className="bg-[#1a1a1a] rounded-2xl p-6 border border-[#222]">
                      <MapaFatiga muscleData={fatigaData} />
                    </div>
                  )}
                </motion.div>
              </AnimatePresence>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Empty state when no client selected */}
      {!selectedClient && !loadingClients && clients.length > 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="flex flex-col items-center justify-center h-64 gap-4 bg-[#1a1a1a] rounded-2xl border border-[#222]"
        >
          <TrendingUp size={48} className="text-[#333]" />
          <div className="text-center">
            <p className="text-sm font-semibold text-[#adaaaa]">Selecciona un cliente</p>
            <p className="text-xs text-[#555] mt-1">para visualizar su progreso físico</p>
          </div>
        </motion.div>
      )}
    </div>
  );
}
