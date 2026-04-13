import { Users, CheckCircle, AlertTriangle, FileText, TrendingUp, Clock } from 'lucide-react';
import KpiCard from './components/KpiCard';
import ClientTable from './components/ClientTable';
import ActivityFeed from './components/ActivityFeed';

// ── Demo data (used until the API endpoints are wired up) ──────────
const DEMO_DATA = {
  totalAtletas: 24,
  nuevosEsteMes: 2,
  porcentajeCumplimiento: 78,
  alertasInactividad: 3,
  planesActivos: 18,
  clientes: [
    { id: 1, nombre: 'Carlos Ruiz', avatar: null, plan_nombre: 'Fuerza Max', estado: 'activo', estado_label: 'Entrenado', peso: 82.5, grasa: 14 },
    { id: 2, nombre: 'Ana G.', avatar: null, plan_nombre: 'Cardio HIIT', estado: 'activo', estado_label: 'Sesión Activa', peso: 64.0, grasa: 19 },
    { id: 3, nombre: 'Pedro S.', avatar: null, plan_nombre: 'Resistencia', estado: 'inactivo', estado_label: 'Inactivo 48h', peso: 91.2, grasa: 22 },
  ],
  actividades: [
    { tipo: 'rutina_completada', cliente_nombre: 'Carlos Ruiz', detalle: 'completó su rutina', tiempo_hace: 'Hace 5 min • Pierna A' },
    { tipo: 'peso_registrado', cliente_nombre: 'Ana G.', detalle: 'registró nuevo peso: 64kg', tiempo_hace: 'Hace 22 min' },
    { tipo: 'record_personal', cliente_nombre: 'Pedro S.', detalle: 'récord personal detectado', tiempo_hace: 'Hace 1 hora • Press Banca' },
    { tipo: 'nuevo_cliente', cliente_nombre: 'Laura M.', detalle: 'nuevo cliente asignado', tiempo_hace: 'Hace 3 horas' },
  ],
};

// TODO: Replace DEMO_DATA with real API call using supabase.auth.getSession()
// and fetch('/api/coach/dashboard', { headers: { Authorization: `Bearer ${token}` } })

export default function Dashboard() {
  const data = DEMO_DATA;

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
