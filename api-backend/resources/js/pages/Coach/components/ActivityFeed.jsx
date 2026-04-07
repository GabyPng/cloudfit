import { CheckCircle, Weight, Star, UserPlus, History } from 'lucide-react';

const typeConfig = {
  rutina_completada: {
    icon: CheckCircle,
    bg: 'bg-[#cafd00]',
    text: 'text-[#4a5e00]',
    glow: 'shadow-[0_0_12px_rgba(202,253,0,0.3)]',
    nameClass: 'text-[#cafd00]',
    dim: false,
  },
  peso_registrado: {
    icon: Weight,
    bg: 'bg-[#5516be]',
    text: 'text-[#d9c8ff]',
    glow: '',
    nameClass: 'text-[#ac8aff]',
    dim: false,
  },
  record_personal: {
    icon: Star,
    bg: 'bg-[#fce047]',
    text: 'text-[#5d5000]',
    glow: '',
    nameClass: 'text-[#ffeea5]',
    dim: false,
  },
  nuevo_cliente: {
    icon: UserPlus,
    bg: 'bg-[#262626]',
    text: 'text-[#adaaaa]',
    glow: '',
    nameClass: 'text-white',
    dim: true,
  },
};

export default function ActivityFeed({ actividades = [] }) {
  return (
    <div className="bg-[#1a1a1a] rounded-xl p-6 flex flex-col h-full">
      <div className="flex items-center justify-between mb-8">
        <h2 className="text-xl font-headline font-bold">Actividad Reciente</h2>
        <History size={20} className="text-[#adaaaa]" />
      </div>

      <div className="space-y-8 relative">
        {/* Vertical timeline line */}
        <div className="absolute left-3.5 top-2 bottom-2 w-0.5 bg-[#484847]/20" />

        {actividades.map((actividad, idx) => {
          const config = typeConfig[actividad.tipo] || typeConfig.nuevo_cliente;
          const Icon = config.icon;

          return (
            <div key={idx} className={`relative pl-10 ${config.dim ? 'opacity-60' : ''}`}>
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
        })}
      </div>

      <button className="mt-auto w-full py-3 bg-[#262626] rounded-lg text-xs font-bold uppercase tracking-widest hover:bg-[#cafd00] hover:text-[#4a5e00] transition-all">
        Ver todo el historial
      </button>
    </div>
  );
}
