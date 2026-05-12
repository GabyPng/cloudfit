import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Users,
  CheckCircle,
  AlertTriangle,
  FileText,
  TrendingUp,
  Clock,
  Filter,
  Download,
  History,
  Loader2,
  Star,
  UserPlus,
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { syncLocalUserProfile } from '../../lib/localUserSync';
import KpiCard from '../Coach/components/KpiCard';

const initialData = {
  stats: {
    total_pacientes: 0,
    nuevos_este_mes: 0,
    adherencia_promedio: 0,
    alertas_nutricionales: 0,
    planes_activos: 0,
  },
  pacientes: [],
  actividades: [],
};

const CACHE_KEY = 'cf_nutri_dashboard';
const CACHE_TTL = 60_000;

function readCache() {
  try {
    const raw = sessionStorage.getItem(CACHE_KEY);
    if (!raw) return null;
    const { ts, data } = JSON.parse(raw);
    return Date.now() - ts < CACHE_TTL ? data : null;
  } catch {
    return null;
  }
}

function writeCache(data) {
  try { sessionStorage.setItem(CACHE_KEY, JSON.stringify({ ts: Date.now(), data })); } catch {}
}

const statusDot = (estado) => {
  if (estado === 'alerta') {
    return <span className="w-2 h-2 bg-[#ff7351] rounded-full inline-block" />;
  }
  return <span className="w-2 h-2 bg-[#cafd00] rounded-full inline-block shadow-[0_0_8px_#cafd00]" />;
};

const typeConfig = {
  plan_asignado: {
    icon: FileText,
    bg: 'bg-[#cafd00]',
    text: 'text-[#4a5e00]',
    glow: 'shadow-[0_0_12px_rgba(202,253,0,0.3)]',
    nameClass: 'text-[#cafd00]',
    dim: false,
  },
  objetivo_cumplido: {
    icon: Star,
    bg: 'bg-[#fce047]',
    text: 'text-[#5d5000]',
    glow: '',
    nameClass: 'text-[#ffeea5]',
    dim: false,
  },
  nuevo_paciente: {
    icon: UserPlus,
    bg: 'bg-[#262626]',
    text: 'text-[#adaaaa]',
    glow: '',
    nameClass: 'text-white',
    dim: true,
  },
  alerta_nutricional: {
    icon: AlertTriangle,
    bg: 'bg-[#ff7351]',
    text: 'text-[#4a1408]',
    glow: '',
    nameClass: 'text-[#ffb19d]',
    dim: false,
  },
};

export default function Dashboard() {
  const navigate = useNavigate();
  const cached = readCache();
  const [data, setData] = useState(cached ?? initialData);
  const [loading, setLoading] = useState(!cached);
  const [error, setError] = useState('');

  useEffect(() => {
    let ignore = false;

    const loadDashboard = async () => {
      try {
        setLoading(true);
        setError('');

        const { data: { session } } = await supabase.auth.getSession();
        const token = session?.access_token;

        if (!token) {
          throw new Error('No se encontró una sesión activa.');
        }

        await syncLocalUserProfile(session).catch(() => null);

        const requestDashboard = () => fetch('/api/nutriologo/dashboard', {
          headers: {
            Accept: 'application/json',
            Authorization: `Bearer ${token}`,
          },
        });

        let response = await requestDashboard();

        if (response.status === 401) {
          await syncLocalUserProfile(session).catch(() => null);
          response = await requestDashboard();
        }

        if (!response.ok) {
          throw new Error(`No se pudo cargar el dashboard (${response.status}).`);
        }

        const payload = await response.json();

        if (!ignore) {
          const next = {
            stats: payload?.stats ?? initialData.stats,
            pacientes: payload?.pacientes ?? [],
            actividades: payload?.actividades ?? [],
          };
          writeCache(next);
          setData(next);
        }
      } catch (err) {
        if (!ignore) {
          setError(err.message || 'Ocurrió un error al cargar el panel.');
        }
      } finally {
        if (!ignore) {
          setLoading(false);
        }
      }
    };

    loadDashboard();

    return () => {
      ignore = true;
    };
  }, []);

  const stats = data.stats ?? initialData.stats;

  return (
    <div className="grid grid-cols-12 gap-8">
      <section className="col-span-12 flex flex-col gap-2">
        <h1 className="text-4xl font-black font-headline text-white">Panel principal del Nutriólogo</h1>
      </section>

      {error && (
        <section className="col-span-12 rounded-xl border border-red-500/20 bg-red-500/10 px-4 py-3 text-sm text-red-200">
          {error}
        </section>
      )}

      {loading ? (
        <section className="col-span-12 min-h-80 flex items-center justify-center bg-[#1a1a1a] rounded-xl">
          <div className="flex items-center gap-3 text-[#f3ffca]">
            <Loader2 className="animate-spin" size={22} />
          </div>
        </section>
      ) : (
        <>
          <section className="col-span-12 grid grid-cols-1 md:grid-cols-4 gap-6">
            <KpiCard label="Pacientes Activos" value={stats.total_pacientes} icon={Users} valueColor="text-[#cafd00]">
              <div className="flex items-center gap-2 text-[10px] text-[#f3ffca]">
                <TrendingUp size={12} />
                <span>+{stats.nuevos_este_mes} este mes</span>
              </div>
            </KpiCard>

            <KpiCard label="Adherencia Promedio" value={`${stats.adherencia_promedio}%`} icon={CheckCircle} iconColor="text-[#ac8aff]" valueColor="text-[#ac8aff]">
              <div className="w-full bg-[#262626] h-1 rounded-full overflow-hidden">
                <div className="bg-[#ac8aff] h-full transition-all duration-500" style={{ width: `${stats.adherencia_promedio}%` }} />
              </div>
            </KpiCard>

            <KpiCard label="Alertas Nutricionales" value={stats.alertas_nutricionales} icon={AlertTriangle} iconColor="text-[#ff7351]" valueColor="text-[#ff7351]">
              {stats.alertas_nutricionales > 0 && (
                <p className="text-[10px] text-[#d53d18] uppercase font-bold">Requiere revisión</p>
              )}
            </KpiCard>

            <KpiCard label="Planes Activos" value={stats.planes_activos} icon={FileText} iconColor="text-[#f3ffca]" valueColor="text-[#cafd00]">
              <div className="flex items-center gap-2 text-[10px] text-[#adaaaa]">
                <Clock size={12} />
                <span>Actualización automática</span>
              </div>
            </KpiCard>
          </section>

          <section className="col-span-12 lg:col-span-8 bg-[#1a1a1a] rounded-xl overflow-hidden flex flex-col">
            <div className="p-6 flex justify-between items-center border-b border-[#484847]/10">
              <div>
                <h2 className="text-xl font-headline font-bold">Seguimiento de Pacientes</h2>
                <p className="text-xs text-[#adaaaa] mt-1">Estado nutricional y cumplimiento reciente</p>
              </div>
              <div className="flex gap-2">
                <button className="p-2 bg-[#262626] rounded-lg text-[#adaaaa] hover:text-[#f3ffca] transition-colors">
                  <Filter size={14} />
                </button>
                <button className="p-2 bg-[#262626] rounded-lg text-[#adaaaa] hover:text-[#f3ffca] transition-colors">
                  <Download size={14} />
                </button>
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left">
                <thead className="bg-[#131313]">
                  <tr>
                    {['Paciente', 'Plan Actual', 'Estado', 'Último Registro', 'Acciones'].map((h, i) => (
                      <th
                        key={h}
                        className={`px-6 py-4 text-[10px] font-headline uppercase tracking-widest text-[#adaaaa] ${i === 4 ? 'text-right' : ''}`}
                      >
                        {h}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#484847]/5">
                  {data.pacientes.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="px-6 py-10 text-center text-sm text-[#adaaaa]">
                        Aún no hay pacientes asignados para mostrar.
                      </td>
                    </tr>
                  ) : (
                    data.pacientes.map((paciente) => {
                      const inAlert = paciente.estado === 'alerta';
                      return (
                        <tr key={paciente.id ?? paciente.nombre} className="hover:bg-[#20201f] transition-colors group">
                          <td className="px-6 py-4">
                            <div className="flex items-center gap-3">
                              <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold ${
                                inAlert ? 'bg-[#262626] text-[#adaaaa]' : 'bg-[#cafd00] text-[#0e0e0e]'
                              }`}>
                                {paciente.nombre?.charAt(0).toUpperCase()}
                              </div>
                              <span className={`text-sm font-medium ${inAlert ? 'text-[#adaaaa]' : ''}`}>
                                {paciente.nombre}
                              </span>
                            </div>
                          </td>

                          <td className="px-6 py-4">
                            <span className={`inline-block whitespace-nowrap px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-tight ${
                              inAlert ? 'bg-[#262626] text-[#adaaaa]' : 'bg-[#5516be] text-[#d9c8ff]'
                            }`}>
                              {paciente.plan_nombre}
                            </span>
                          </td>

                          <td className="px-6 py-4">
                            <div className="flex items-center gap-2">
                              {statusDot(paciente.estado)}
                              <span className={`text-xs ${inAlert ? 'text-[#ff7351]' : 'text-[#adaaaa]'}`}>
                                {paciente.estado_label}
                              </span>
                            </div>
                          </td>

                          <td className="px-6 py-4">
                            <div className="flex flex-col">
                              <span className={`text-sm font-headline ${inAlert ? 'text-[#adaaaa]' : ''}`}>
                                {paciente.ultimo_registro}
                              </span>
                              <span className="text-[10px] text-[#adaaaa]">{paciente.objetivo}</span>
                            </div>
                          </td>

                          <td className="px-6 py-4 text-right">
                            <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                              <button
                                onClick={() => navigate('/nutriologo/pacientes', { state: { patientId: paciente.id } })}
                                className="text-[10px] font-bold uppercase bg-[#262626] px-3 py-1.5 rounded hover:text-[#f3ffca] transition-colors"
                              >
                                Plan
                              </button>
                              <button
                                onClick={() => navigate('/nutriologo/pacientes', { state: { patientId: paciente.id } })}
                                className="text-[10px] font-bold uppercase bg-[#262626] px-3 py-1.5 rounded hover:text-[#ac8aff] transition-colors"
                              >
                                Seguimiento
                              </button>
                            </div>
                          </td>
                        </tr>
                      );
                    })
                  )}
                </tbody>
              </table>
            </div>

            <div className="mt-auto p-6 flex justify-between items-center text-[10px] text-[#adaaaa] font-headline uppercase tracking-widest border-t border-[#484847]/10">
              <span>Mostrando {data.pacientes.length} de {stats.total_pacientes} pacientes</span>
              <div className="flex gap-4">
                <button className="hover:text-[#f3ffca] transition-colors">Anterior</button>
                <button className="text-[#f3ffca] font-bold">Siguiente</button>
              </div>
            </div>
          </section>

          <section className="col-span-12 lg:col-span-4 bg-[#1a1a1a] rounded-xl p-6 flex flex-col h-full">
            <div className="flex items-center justify-between mb-8">
              <h2 className="text-xl font-headline font-bold">Actividad Reciente</h2>
              <History size={20} className="text-[#adaaaa]" />
            </div>

            <div className="space-y-8 relative">
              <div className="absolute left-3.5 top-2 bottom-2 w-0.5 bg-[#484847]/20" />

              {data.actividades.length === 0 ? (
                <p className="relative pl-2 text-sm text-[#adaaaa]">Sin actividad reciente por ahora.</p>
              ) : (
                data.actividades.map((actividad, idx) => {
                  const config = typeConfig[actividad.tipo] || typeConfig.nuevo_paciente;
                  const Icon = config.icon;

                  return (
                    <div key={`${actividad.cliente_nombre}-${idx}`} className={`relative pl-10 ${config.dim ? 'opacity-60' : ''}`}>
                      <div className={`absolute left-0 top-1 w-7 h-7 ${config.bg} rounded-full flex items-center justify-center ${config.text} ${config.glow}`}>
                        <Icon size={14} />
                      </div>
                      <div className="flex flex-col">
                        <p className="text-sm font-medium">
                          <span className={config.nameClass}>{actividad.cliente_nombre}</span>{' '}
                          {actividad.detalle}
                        </p>
                        <span className="text-[10px] text-[#adaaaa] uppercase tracking-wider mt-1">
                          {actividad.tiempo_hace}
                        </span>
                      </div>
                    </div>
                  );
                })
              )}
            </div>

            <button className="mt-auto w-full py-3 bg-[#262626] rounded-lg text-xs font-bold uppercase tracking-widest hover:bg-[#cafd00] hover:text-[#4a5e00] transition-all">
              Ver historial completo
            </button>
          </section>
        </>
      )}
    </div>
  );
}
