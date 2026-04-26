import { Filter, Download, Dumbbell, Zap, Heart } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const ICON_MAP = { dumbbell: Dumbbell, zap: Zap, heart: Heart };

const statusDot = (estado) => {
  if (estado === 'inactivo') {
    return <span className="w-2 h-2 bg-[#ff7351] rounded-full inline-block" />;
  }
  return <span className="w-2 h-2 bg-[#cafd00] rounded-full inline-block shadow-[0_0_8px_#cafd00]" />;
};

const statusLabel = (cliente) => {
  if (cliente.estado === 'inactivo') {
    return <span className="text-xs text-[#ff7351]">{cliente.estado_label || 'Inactivo'}</span>;
  }
  return <span className="text-xs text-[#adaaaa]">{cliente.estado_label || 'Entrenado'}</span>;
};

function RutinasBadges({ rutinas = [], inactive }) {
  if (!rutinas.length) {
    return <span className="text-[10px] text-[#adaaaa]/60 italic">Sin rutinas</span>;
  }

  const visible = rutinas.slice(0, 2);
  const extra = rutinas.length - 2;

  return (
    <div className="flex flex-col gap-1.5">
      {visible.map((r) => {
        const Icon = ICON_MAP[r.iconType] || Dumbbell;
        const color = inactive ? '#adaaaa' : (r.accentColor || '#cafd00');
        return (
          <span
            key={r.id}
            className="inline-flex items-center gap-1.5 px-2 py-1 rounded-lg text-[10px] font-bold uppercase tracking-tight w-fit max-w-[160px]"
            style={{
              backgroundColor: `${color}18`,
              color,
              border: `1px solid ${color}30`,
            }}
          >
            <Icon size={10} style={{ flexShrink: 0 }} />
            <span className="truncate">{r.name}</span>
          </span>
        );
      })}
      {extra > 0 && (
        <span className="text-[10px] text-[#adaaaa] font-bold pl-1">
          +{extra} más
        </span>
      )}
    </div>
  );
}

export default function ClientTable({ clientes = [], totalAtletas = 0 }) {
  const navigate = useNavigate();

  return (
    <section className="bg-[#1a1a1a] rounded-xl overflow-hidden flex flex-col">
      {/* Header */}
      <div className="p-6 flex justify-between items-center border-b border-[#484847]/10">
        <h2 className="text-xl font-headline font-bold">Monitoreo de Clientes</h2>
        <div className="flex gap-2">
          <button className="p-2 bg-[#262626] rounded-lg text-[#adaaaa] hover:text-[#f3ffca] transition-colors">
            <Filter size={14} />
          </button>
          <button className="p-2 bg-[#262626] rounded-lg text-[#adaaaa] hover:text-[#f3ffca] transition-colors">
            <Download size={14} />
          </button>
        </div>
      </div>

      {/* Table */}
      <div className="overflow-x-auto">
        <table className="w-full text-left">
          <thead className="bg-[#131313]">
            <tr>
              {['Cliente', 'Rutinas', 'Estado Hoy', 'Última Métrica', 'Acciones'].map((h, i) => (
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
            {clientes.map((cliente, idx) => {
              const inactive = cliente.estado === 'inactivo';
              return (
                <tr key={cliente.id || idx} className="hover:bg-[#20201f] transition-colors group">
                  {/* Cliente */}
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      {cliente.avatar ? (
                        <img
                          src={cliente.avatar}
                          alt={cliente.nombre}
                          className={`w-8 h-8 rounded-full object-cover ${inactive ? 'grayscale opacity-60' : ''}`}
                        />
                      ) : (
                        <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 ${
                          inactive ? 'bg-[#262626] text-[#adaaaa]' : 'bg-[#cafd00] text-[#0e0e0e]'
                        }`}>
                          {cliente.nombre?.charAt(0).toUpperCase()}
                        </div>
                      )}
                      <div className="min-w-0">
                        <span className={`text-sm font-medium block truncate ${inactive ? 'text-[#adaaaa]' : ''}`}>
                          {cliente.nombre}
                        </span>
                        {(cliente.rutinas?.length ?? 0) > 0 && (
                          <span className="text-[10px] text-[#adaaaa]">
                            {cliente.rutinas.length} {cliente.rutinas.length === 1 ? 'rutina' : 'rutinas'}
                          </span>
                        )}
                      </div>
                    </div>
                  </td>

                  {/* Rutinas */}
                  <td className="px-6 py-4">
                    <RutinasBadges rutinas={cliente.rutinas} inactive={inactive} />
                  </td>

                  {/* Estado */}
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      {statusDot(cliente.estado)}
                      {statusLabel(cliente)}
                    </div>
                  </td>

                  {/* Métrica */}
                  <td className="px-6 py-4">
                    <div className="flex flex-col">
                      <span className={`text-sm font-headline ${inactive ? 'text-[#adaaaa]' : ''}`}>
                        {cliente.peso ? `${cliente.peso} kg` : '—'}
                      </span>
                      <span className="text-[10px] text-[#adaaaa]">
                        {cliente.grasa ? `Grasa: ${cliente.grasa}%` : '—'}
                      </span>
                    </div>
                  </td>

                  {/* Acciones */}
                  <td className="px-6 py-4 text-right">
                    <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        onClick={() => navigate(`/coach/clientes?clientId=${cliente.id}`)}
                        className="text-[10px] font-bold uppercase bg-[#262626] px-3 py-1.5 rounded hover:text-[#f3ffca] transition-colors"
                      >
                        Rutinas
                      </button>
                      <button className="text-[10px] font-bold uppercase bg-[#262626] px-3 py-1.5 rounded hover:text-[#ac8aff] transition-colors">
                        Evolución
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Footer */}
      <div className="mt-auto p-6 flex justify-between items-center text-[10px] text-[#adaaaa] font-headline uppercase tracking-widest border-t border-[#484847]/10">
        <span>Mostrando {clientes.length} de {totalAtletas} clientes</span>
        <div className="flex gap-4">
          <button className="hover:text-[#f3ffca] transition-colors">Anterior</button>
          <button className="text-[#f3ffca] font-bold">Siguiente</button>
        </div>
      </div>
    </section>
  );
}
