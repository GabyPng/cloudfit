import { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  Users, Dumbbell, CheckCircle, ChevronRight, Printer,
  User, Loader2, AlertCircle, X, Pause, RotateCcw,
} from 'lucide-react';
import { supabase } from '../../lib/supabase';

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

const STATUS_CFG = {
  active: { label: 'Activa',  bg: 'bg-[#cafd00]/10', text: 'text-[#cafd00]', border: 'border-[#cafd00]/20' },
  paused: { label: 'Pausada', bg: 'bg-amber-500/10', text: 'text-amber-400', border: 'border-amber-500/20' },
};

/* ─── Print helpers (open new window) ─────────────────────────────────── */

function printRoutines(client, assignments) {
  const relevant = assignments.filter(a => a.routine != null && a.status !== 'completed');
  const html = `<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<title>Rutinas — ${client.name}</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Arial,sans-serif;font-size:12px;color:#111;padding:18mm 22mm}
.hdr{border-bottom:3px solid #111;padding-bottom:10px;margin-bottom:18px}
.hdr h1{font-size:20px;font-weight:900;text-transform:uppercase;letter-spacing:-0.5px}
.meta{display:flex;gap:20px;margin-top:6px;color:#444;font-size:10px;flex-wrap:wrap}
.meta span strong{color:#111}
.routine{margin-bottom:26px;page-break-inside:avoid}
.rtitle{font-size:14px;font-weight:800;text-transform:uppercase;border-left:4px solid #111;padding-left:9px;margin-bottom:8px}
.rmeta{display:flex;gap:10px;font-size:10px;color:#555;margin-bottom:10px;flex-wrap:wrap}
.rmeta span{background:#f0f0f0;padding:2px 8px;border-radius:20px}
table{width:100%;border-collapse:collapse}
th{background:#111;color:#fff;text-align:left;padding:5px 9px;font-size:10px;text-transform:uppercase;letter-spacing:.5px}
td{padding:6px 9px;border-bottom:1px solid #e5e5e5;font-size:11px}
tr:nth-child(even) td{background:#f9f9f9}
.ftr{border-top:1px solid #ccc;padding-top:9px;margin-top:28px;font-size:9px;color:#999;display:flex;justify-content:space-between}
.empty{text-align:center;color:#888;padding:40px;font-size:13px}
</style></head><body>
<div class="hdr">
  <h1>Ficha de Rutinas</h1>
  <div class="meta">
    <span><strong>Cliente:</strong> ${client.name}</span>
    <span><strong>Objetivo:</strong> ${client.objective || 'No especificado'}</span>
    <span><strong>Email:</strong> ${client.email || '—'}</span>
    <span><strong>Fecha:</strong> ${new Date().toLocaleDateString('es-MX',{year:'numeric',month:'long',day:'numeric'})}</span>
  </div>
</div>
${relevant.length === 0
  ? '<p class="empty">No hay rutinas asignadas a este cliente.</p>'
  : relevant.map((a, idx) => `
<div class="routine">
  <div class="rtitle">${idx + 1}. ${a.routine?.name || 'Sin nombre'}</div>
  <div class="rmeta">
    ${a.routine?.trainingPlan ? `<span>Plan: ${a.routine.trainingPlan}</span>` : ''}
    <span>Dificultad: ${a.routine?.difficultyLabel || '—'}</span>
    <span>~${a.routine?.estDuration || 0} min</span>
    <span>Estado: ${STATUS_CFG[a.status]?.label || a.status}</span>
  </div>
  ${!a.routine?.exercises?.length
    ? '<p style="color:#888;font-size:11px">Sin ejercicios registrados.</p>'
    : `<table>
        <thead><tr><th>#</th><th>Ejercicio</th><th>Series</th><th>Reps</th><th>Peso</th><th>Descanso</th></tr></thead>
        <tbody>
          ${a.routine.exercises.map((ex, i) =>
            `<tr><td>${i+1}</td><td>${ex.name}</td><td>${ex.sets}</td><td>${ex.reps}</td><td>${ex.weight||'—'}</td><td>${ex.rest}</td></tr>`
          ).join('')}
        </tbody>
       </table>`
  }
</div>`).join('')}
<div class="ftr">
  <span>CloudFit — Sistema de Gestión Deportiva</span>
  <span>Generado el ${new Date().toLocaleDateString('es-MX')}</span>
</div>
</body></html>`;

  const win = window.open('', '_blank', 'width=820,height=640');
  win.document.write(html);
  win.document.close();
  win.focus();
  win.print();
}

function printClientCard(client, assignments) {
  const activeCount = assignments.filter(a => a.status === 'active').length;
  const age = client.birthDate
    ? Math.floor((Date.now() - new Date(client.birthDate)) / (365.25 * 86400000))
    : null;

  const html = `<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<title>Ficha Cliente — ${client.name}</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Arial,sans-serif;font-size:12px;color:#111;padding:20mm;display:flex;justify-content:center}
.card{width:360px;border:2px solid #111;padding:28px}
.badge{display:inline-block;background:#111;color:#fff;padding:3px 10px;font-size:9px;font-weight:900;letter-spacing:1px;text-transform:uppercase;margin-bottom:18px}
.avatar{width:56px;height:56px;background:#111;color:#fff;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:20px;font-weight:900;margin-bottom:13px}
h2{font-size:22px;font-weight:900;text-transform:uppercase;margin-bottom:3px}
.email{color:#555;font-size:11px;margin-bottom:18px}
.divider{border-top:1px solid #e5e5e5;margin:14px 0}
.field{display:flex;justify-content:space-between;margin-bottom:9px;align-items:baseline}
.label{color:#777;font-size:10px;text-transform:uppercase;letter-spacing:.5px}
.value{font-weight:700;font-size:12px}
.ftr{margin-top:26px;font-size:9px;color:#bbb;text-align:center}
</style></head><body>
<div class="card">
  <div class="badge">CloudFit</div><br>
  <div class="avatar">${client.avatar}</div>
  <h2>${client.name}</h2>
  <div class="email">${client.email || '—'}</div>
  <div class="divider"></div>
  <div class="field"><span class="label">Objetivo</span><span class="value">${client.objective || 'No especificado'}</span></div>
  ${client.height ? `<div class="field"><span class="label">Altura</span><span class="value">${client.height} cm</span></div>` : ''}
  ${age !== null ? `<div class="field"><span class="label">Edad</span><span class="value">${age} años</span></div>` : ''}
  ${client.birthDate ? `<div class="field"><span class="label">Nacimiento</span><span class="value">${new Date(client.birthDate).toLocaleDateString('es-MX')}</span></div>` : ''}
  <div class="divider"></div>
  <div class="field"><span class="label">Rutinas activas</span><span class="value">${activeCount}</span></div>
  <div class="field"><span class="label">Rutinas totales</span><span class="value">${assignments.length}</span></div>
  <div class="ftr">Ficha generada el ${new Date().toLocaleDateString('es-MX',{year:'numeric',month:'long',day:'numeric'})} — CloudFit</div>
</div>
</body></html>`;

  const win = window.open('', '_blank', 'width=500,height=580');
  win.document.write(html);
  win.document.close();
  win.focus();
  win.print();
}

function printClientsList(clients) {
  const html = `<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<title>Lista de Clientes — CloudFit</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Arial,sans-serif;font-size:12px;color:#111;padding:18mm 22mm}
.hdr{border-bottom:3px solid #111;padding-bottom:10px;margin-bottom:18px;display:flex;justify-content:space-between;align-items:flex-end}
.hdr h1{font-size:20px;font-weight:900;text-transform:uppercase;letter-spacing:-0.5px}
.hdr .meta{font-size:10px;color:#555}
table{width:100%;border-collapse:collapse}
th{background:#111;color:#fff;text-align:left;padding:7px 10px;font-size:10px;text-transform:uppercase;letter-spacing:.5px}
td{padding:8px 10px;border-bottom:1px solid #e5e5e5;font-size:11px;vertical-align:middle}
tr:nth-child(even) td{background:#f9f9f9}
.avatar{display:inline-flex;width:28px;height:28px;background:#111;color:#fff;border-radius:50%;align-items:center;justify-content:center;font-size:10px;font-weight:900;margin-right:8px;vertical-align:middle}
.ftr{border-top:1px solid #ccc;padding-top:9px;margin-top:28px;font-size:9px;color:#999;display:flex;justify-content:space-between}
</style></head><body>
<div class="hdr">
  <h1>Lista de Clientes</h1>
  <div class="meta">Total: ${clients.length} clientes &nbsp;|&nbsp; ${new Date().toLocaleDateString('es-MX',{year:'numeric',month:'long',day:'numeric'})}</div>
</div>
<table>
  <thead>
    <tr><th>#</th><th>Cliente</th><th>Objetivo</th></tr>
  </thead>
  <tbody>
    ${clients.map((c, i) => `
      <tr>
        <td>${i + 1}</td>
        <td><span class="avatar">${c.avatar}</span>${c.name}</td>
        <td>${c.objective || '—'}</td>
      </tr>`).join('')}
  </tbody>
</table>
<div class="ftr">
  <span>CloudFit — Sistema de Gestión Deportiva</span>
  <span>Generado el ${new Date().toLocaleDateString('es-MX')}</span>
</div>
</body></html>`;

  const win = window.open('', '_blank', 'width=820,height=600');
  win.document.write(html);
  win.document.close();
  win.focus();
  win.print();
}

/* ─── Component ───────────────────────────────────────────────────────── */

export default function MisClientes() {
  const navigate = useNavigate();
  const location = useLocation();
  const [clients, setClients] = useState([]);
  const [selectedClientId, setSelectedClientId] = useState(null);
  const [clientData, setClientData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [error, setError] = useState(null);
  const [toast, setToast] = useState(null);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 4000);
  };

  useEffect(() => {
    const params = new URLSearchParams(location.search);
    const clientIdFromUrl = params.get('clientId');

    apiFetch('/rutinas/clients')
      .then(data => {
        setClients(data);
        if (clientIdFromUrl) {
          setSelectedClientId(Number(clientIdFromUrl));
        } else if (data.length > 0) {
          setSelectedClientId(data[0].id);
        }
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    if (!selectedClientId) return;
    setLoadingDetail(true);
    setClientData(null);
    apiFetch(`/rutinas/clients/${selectedClientId}/routines`)
      .then(setClientData)
      .catch(() => showToast('Error al cargar datos del cliente', 'error'))
      .finally(() => setLoadingDetail(false));
  }, [selectedClientId]);

  const handleStatusChange = async (assignmentId, newStatus) => {
    try {
      await apiFetch(`/rutinas/assignments/${assignmentId}/status`, {
        method: 'PATCH',
        body: { status: newStatus },
      });
      const updated = await apiFetch(`/rutinas/clients/${selectedClientId}/routines`);
      setClientData(updated);
      showToast('Estado actualizado');
    } catch {
      showToast('Error al actualizar estado', 'error');
    }
  };

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

  const selectedClient = clientData?.client ?? null;
  const assignments = clientData?.assignments ?? [];
  const activeCount = assignments.filter(a => a.status === 'active').length;

  return (
    <div className="max-w-7xl mx-auto space-y-8 relative">

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
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <h1 className="text-4xl font-black tracking-tight text-white uppercase font-headline">Mis Clientes</h1>
          <p className="text-[#adaaaa] mt-2 max-w-lg text-sm">
            Administra las rutinas de tus atletas, visualiza sus programas e imprime fichas de entrenamiento.
          </p>
        </div>
        <button
          onClick={() => printClientsList(clients)}
          disabled={clients.length === 0}
          className="flex items-center gap-2 px-5 py-3 bg-[#1a1a1a] border border-[#484847] text-[#adaaaa] hover:text-white hover:border-[#cafd00]/50 rounded-xl text-sm font-bold transition-all disabled:opacity-40 disabled:cursor-not-allowed flex-shrink-0"
        >
          <Printer size={16} />
          Imprimir Lista de Clientes
        </button>
      </div>

      <div className="grid grid-cols-12 gap-6">

        {/* ── Left: Client List ── */}
        <section className="col-span-12 lg:col-span-4">
          <div className="bg-[#131313] rounded-2xl p-6 border border-[#484847]/10">
            <div className="flex items-center justify-between mb-6">
              <h3 className="font-headline font-bold text-lg">Clientes</h3>
              <span className="text-xs font-headline text-[#ac8aff] px-2 py-1 bg-[#ac8aff]/10 rounded">
                {clients.length} registrados
              </span>
            </div>
            <div className="space-y-3 max-h-[600px] overflow-y-auto pr-1">
              {clients.length === 0 && (
                <p className="text-center text-[#adaaaa] text-sm py-8">Sin clientes registrados.</p>
              )}
              {clients.map(client => {
                const isActive = selectedClientId === client.id;
                return (
                  <button
                    key={client.id}
                    onClick={() => setSelectedClientId(client.id)}
                    className={`w-full p-4 rounded-xl flex items-center gap-4 cursor-pointer transition-all text-left ${
                      isActive
                        ? 'bg-[#262626] border-l-4 border-[#cafd00] shadow-sm'
                        : 'bg-[#1a1a1a] border-l-4 border-transparent hover:bg-[#262626] group'
                    }`}
                  >
                    <div className="w-12 h-12 rounded-full bg-[#262626] flex items-center justify-center text-sm font-bold text-[#cafd00] flex-shrink-0">
                      {client.avatar}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-bold text-sm truncate">{client.name}</p>
                      <p className="text-xs text-[#adaaaa] truncate">{client.objective || 'Sin objetivo'}</p>
                    </div>
                    {isActive
                      ? <CheckCircle size={18} className="text-[#cafd00] flex-shrink-0" />
                      : <ChevronRight size={18} className="text-[#767575] group-hover:text-[#cafd00] transition-colors flex-shrink-0" />
                    }
                  </button>
                );
              })}
            </div>
          </div>
        </section>

        {/* ── Right: Client Detail ── */}
        <section className="col-span-12 lg:col-span-8">
          {loadingDetail ? (
            <div className="flex items-center justify-center h-64">
              <Loader2 size={28} className="animate-spin text-[#cafd00]" />
            </div>
          ) : !selectedClient ? (
            <div className="flex flex-col items-center justify-center h-64 text-[#adaaaa]">
              <Users size={48} className="mb-4 opacity-20" />
              <p className="text-sm">Selecciona un cliente para ver sus rutinas</p>
            </div>
          ) : (
            <div className="space-y-6">

              {/* Client Header Card */}
              <div className="bg-[#131313] rounded-2xl p-6 border border-[#484847]/10">
                <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                  <div className="flex items-center gap-4">
                    <div className="w-16 h-16 rounded-2xl bg-[#5516be]/20 flex items-center justify-center text-xl font-black text-[#ac8aff] flex-shrink-0">
                      {selectedClient.avatar}
                    </div>
                    <div>
                      <h2 className="text-2xl font-black font-headline text-white">{selectedClient.name}</h2>
                      <p className="text-[#adaaaa] text-sm">{selectedClient.email}</p>
                      <div className="flex items-center gap-3 mt-1 flex-wrap">
                        {selectedClient.objective && (
                          <span className="text-xs text-[#cafd00] bg-[#cafd00]/10 border border-[#cafd00]/20 px-2 py-0.5 rounded-full">
                            {selectedClient.objective}
                          </span>
                        )}
                        {selectedClient.height && (
                          <span className="text-xs text-[#adaaaa]">{selectedClient.height} cm</span>
                        )}
                        {selectedClient.birthDate && (
                          <span className="text-xs text-[#adaaaa]">
                            {Math.floor((Date.now() - new Date(selectedClient.birthDate)) / (365.25 * 86400000))} años
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Print buttons */}
                  <div className="flex gap-2 flex-shrink-0">
                    <button
                      onClick={() => printRoutines(selectedClient, assignments)}
                      className="flex items-center gap-2 px-4 py-2.5 bg-[#1a1a1a] border border-[#484847] text-[#adaaaa] hover:text-white hover:border-[#cafd00]/50 rounded-xl text-sm font-bold transition-all"
                    >
                      <Printer size={15} />
                      Rutinas
                    </button>
                    <button
                      onClick={() => printClientCard(selectedClient, assignments)}
                      className="flex items-center gap-2 px-4 py-2.5 bg-[#1a1a1a] border border-[#484847] text-[#adaaaa] hover:text-white hover:border-[#ac8aff]/50 rounded-xl text-sm font-bold transition-all"
                    >
                      <User size={15} />
                      Ficha
                    </button>
                  </div>
                </div>

                {/* Stats row */}
                <div className="grid grid-cols-2 gap-4 mt-6 pt-6 border-t border-[#484847]/10">
                  <div className="text-center">
                    <p className="text-2xl font-black text-[#cafd00]">{activeCount}</p>
                    <p className="text-[10px] uppercase tracking-widest text-[#adaaaa] mt-1">Activas</p>
                  </div>
                  <div className="text-center">
                    <p className="text-2xl font-black text-amber-400">
                      {assignments.filter(a => a.status === 'paused').length}
                    </p>
                    <p className="text-[10px] uppercase tracking-widest text-[#adaaaa] mt-1">Pausadas</p>
                  </div>
                </div>
              </div>

              {/* Routines List */}
              <div className="bg-[#131313] rounded-2xl border border-[#484847]/10 overflow-hidden">
                <div className="flex items-center justify-between p-6 pb-4">
                  <h3 className="font-headline font-bold text-lg">Rutinas Asignadas</h3>
                  <button
                    onClick={() => navigate(`/coach/rutinas?clientId=${selectedClient.id}`)}
                    className="flex items-center gap-2 px-4 py-2 bg-[#5516be] text-[#d9c8ff] rounded-lg text-xs font-bold hover:bg-[#5516be]/80 transition-colors"
                  >
                    <Dumbbell size={14} />
                    Asignar rutina
                  </button>
                </div>

                {assignments.length === 0 ? (
                  <div className="flex flex-col items-center justify-center py-16 text-[#adaaaa]">
                    <Dumbbell size={40} className="mb-4 opacity-20" />
                    <p className="text-sm font-bold">Sin rutinas asignadas</p>
                    <p className="text-xs mt-1 opacity-60">Usa el botón de arriba para asignar una rutina</p>
                  </div>
                ) : (
                  <div className="divide-y divide-[#484847]/10">
                    {assignments.map(a => {
                      const st = STATUS_CFG[a.status] ?? STATUS_CFG.active;
                      const routine = a.routine;
                      if (!routine) return null;
                      return (
                        <div key={a.assignmentId} className="p-6 hover:bg-[#1a1a1a] transition-colors">
                          <div className="flex flex-col sm:flex-row sm:items-start gap-4">
                            <div className="flex-1 min-w-0">
                              <div className="flex items-center gap-3 mb-1 flex-wrap">
                                <h4 className="font-bold text-white">{routine.name}</h4>
                                <span className={`text-[10px] font-black px-2 py-0.5 rounded-full border ${st.bg} ${st.text} ${st.border} whitespace-nowrap`}>
                                  {st.label}
                                </span>
                              </div>
                              <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-[#adaaaa]">
                                {routine.trainingPlan && <span>{routine.trainingPlan}</span>}
                                <span>{routine.difficultyLabel}</span>
                                <span>{routine.exercises?.length ?? 0} ejercicios</span>
                                <span>~{routine.estDuration} min</span>
                                {a.assignedAt && (
                                  <span>Asignada: {new Date(a.assignedAt).toLocaleDateString('es-MX')}</span>
                                )}
                              </div>
                              {/* Difficulty bar */}
                              <div className="mt-3 flex items-center gap-2 max-w-xs">
                                <div className="flex-1 h-1 bg-[#262626] rounded-full overflow-hidden">
                                  <div
                                    className="h-full rounded-full transition-all"
                                    style={{ width: `${routine.difficulty}%`, backgroundColor: routine.accentColor || '#cafd00' }}
                                  />
                                </div>
                                <span className="text-[10px] text-[#adaaaa] whitespace-nowrap">{routine.difficulty}%</span>
                              </div>
                            </div>

                            {/* Status action buttons */}
                            <div className="flex items-center gap-2 flex-shrink-0">
                              {a.status === 'active' && (
                                <button
                                  onClick={() => handleStatusChange(a.assignmentId, 'paused')}
                                  title="Pausar"
                                  className="p-2 bg-[#262626] hover:bg-amber-500/20 text-[#adaaaa] hover:text-amber-400 rounded-lg transition-colors"
                                >
                                  <Pause size={15} />
                                </button>
                              )}
                              {a.status === 'paused' && (
                                <button
                                  onClick={() => handleStatusChange(a.assignmentId, 'active')}
                                  title="Reactivar"
                                  className="p-2 bg-[#262626] hover:bg-[#cafd00]/10 text-[#adaaaa] hover:text-[#cafd00] rounded-lg transition-colors"
                                >
                                  <RotateCcw size={15} />
                                </button>
                              )}
                            </div>
                          </div>

                          {/* Exercises preview */}
                          {(routine.exercises?.length ?? 0) > 0 && (
                            <div className="mt-4 pt-4 border-t border-[#484847]/10">
                              <p className="text-[10px] font-black uppercase tracking-widest text-[#adaaaa] mb-3">Ejercicios</p>
                              <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                                {routine.exercises.slice(0, 6).map((ex, idx) => (
                                  <div key={ex.id} className="flex items-center gap-2 bg-[#262626] rounded-lg px-3 py-2">
                                    <span className="text-[10px] font-black text-[#cafd00] w-4 flex-shrink-0">{idx + 1}</span>
                                    <div className="min-w-0">
                                      <p className="text-xs font-bold truncate">{ex.name}</p>
                                      <p className="text-[10px] text-[#adaaaa]">
                                        {ex.sets}×{ex.reps}{ex.weight ? ` @ ${ex.weight}` : ''}
                                      </p>
                                    </div>
                                  </div>
                                ))}
                                {routine.exercises.length > 6 && (
                                  <div className="flex items-center justify-center bg-[#262626]/50 rounded-lg px-3 py-2">
                                    <p className="text-xs text-[#adaaaa]">+{routine.exercises.length - 6} más</p>
                                  </div>
                                )}
                              </div>
                            </div>
                          )}
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            </div>
          )}
        </section>
      </div>
    </div>
  );
}
