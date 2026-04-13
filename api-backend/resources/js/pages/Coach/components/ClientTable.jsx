import { Filter, Download } from 'lucide-react';

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

export default function ClientTable({ clientes = [], totalAtletas = 0 }) {
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
              {['Cliente', 'Plan Actual', 'Estado Hoy', 'Última Métrica', 'Acciones'].map((h, i) => (
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
                        <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold ${
                          inactive ? 'bg-[#262626] text-[#adaaaa]' : 'bg-[#cafd00] text-[#0e0e0e]'
                        }`}>
                          {cliente.nombre?.charAt(0).toUpperCase()}
                        </div>
                      )}
                      <span className={`text-sm font-medium ${inactive ? 'text-[#adaaaa]' : ''}`}>
                        {cliente.nombre}
                      </span>
                    </div>
                  </td>

                  {/* Plan */}
                  <td className="px-6 py-4">
                    <span className={`inline-block whitespace-nowrap px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-tight ${
                      inactive
                        ? 'bg-[#262626] text-[#adaaaa]'
                        : 'bg-[#5516be] text-[#d9c8ff]'
                    }`}>
                      {cliente.plan_nombre}
                    </span>
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
                        {cliente.peso} kg
                      </span>
                      <span className="text-[10px] text-[#adaaaa]">Grasa: {cliente.grasa}%</span>
                    </div>
                  </td>

                  {/* Acciones */}
                  <td className="px-6 py-4 text-right">
                    <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button className="text-[10px] font-bold uppercase bg-[#262626] px-3 py-1.5 rounded hover:text-[#f3ffca] transition-colors">
                        Rutina
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
