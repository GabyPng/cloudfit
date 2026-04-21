import { useEffect, useState } from 'react';
import { Users, CheckCircle, AlertTriangle, FileText, TrendingUp, Clock, Loader2 } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import KpiCard from './components/KpiCard';
import ClientTable from './components/ClientTable';
import ActivityFeed from './components/ActivityFeed';

const EMPTY_DATA = {
  totalAtletas: 0,
  nuevosEsteMes: 0,
  porcentajeCumplimiento: 0,
  alertasInactividad: 0,
  planesActivos: 0,
  clientes: [],
  actividades: [],
};

export default function Dashboard() {
  const [data, setData] = useState(EMPTY_DATA);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchDashboard() {
      try {
        const { data: sessionData } = await supabase.auth.getSession();
        const token = sessionData?.session?.access_token;
        if (!token) {
          setError('No hay sesión activa');
          setLoading(false);
          return;
        }

        const res = await fetch('/api/coach/dashboard', {
          headers: {
            Authorization: `Bearer ${token}`,
            Accept: 'application/json',
          },
        });

        if (!res.ok) {
          throw new Error(`Error ${res.status}`);
        }

        const json = await res.json();
        setData(json);
      } catch (err) {
        console.error('Error fetching dashboard:', err);
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    fetchDashboard();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 size={32} className="animate-spin text-[#cafd00]" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-[#ff7351] text-sm">Error al cargar dashboard: {error}</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-12 gap-8">
      {/* ── KPIs ── */}
      <section className="col-span-12 grid grid-cols-1 md:grid-cols-4 gap-6">
        <KpiCard label="Total Atletas" value={data.totalAtletas} icon={Users} valueColor="text-[#cafd00]">
          <div className="flex items-center gap-2 text-[10px] text-[#f3ffca]">
            <TrendingUp size={12} />
            <span>+{data.nuevosEsteMes} este mes</span>
          </div>
        </KpiCard>

        <KpiCard label="Cumplimiento Diario" value={`${data.porcentajeCumplimiento}%`} icon={CheckCircle} iconColor="text-[#ac8aff]" valueColor="text-[#ac8aff]">
          <div className="w-full bg-[#262626] h-1 rounded-full overflow-hidden">
            <div className="bg-[#ac8aff] h-full transition-all duration-500" style={{ width: `${data.porcentajeCumplimiento}%` }} />
          </div>
        </KpiCard>

        <KpiCard label="Alertas Inactividad" value={data.alertasInactividad} icon={AlertTriangle} iconColor="text-[#ff7351]" valueColor="text-[#ff7351]">
          {data.alertasInactividad > 0 && (
            <p className="text-[10px] text-[#d53d18] uppercase font-bold">Requiere acción inmediata</p>
          )}
        </KpiCard>

        <KpiCard label="Planes Activos" value={data.planesActivos} icon={FileText} iconColor="text-[#f3ffca]" valueColor="text-[#cafd00]">
          <div className="flex items-center gap-2 text-[10px] text-[#adaaaa]">
            <Clock size={12} />
            <span>Actualizado hace 1h</span>
          </div>
        </KpiCard>
      </section>

      {/* ── Client Table ── */}
      <div className="col-span-12 lg:col-span-8">
        <ClientTable clientes={data.clientes} totalAtletas={data.totalAtletas} />
      </div>

      {/* ── Side Panel ── */}
      <div className="col-span-12 lg:col-span-4 flex flex-col gap-6">
        <ActivityFeed actividades={data.actividades} />
      </div>
    </div>
  );
}
