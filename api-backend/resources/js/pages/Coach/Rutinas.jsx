import { useState, useEffect, useCallback, useRef } from 'react';
import {
  Dumbbell, Zap, Heart, PlusCircle,
  CheckCircle, Search, Sparkles, X, GripHorizontal, ChevronDown,
  Loader2, Edit, Trash, AlertCircle, ArrowLeft,
} from 'lucide-react';
import { supabase } from '../../lib/supabase';

const ICON_MAP = { dumbbell: Dumbbell, zap: Zap, heart: Heart };
const REST_OPTIONS = ['30s','45s','60s','90s','120s','150s','180s'];
const SETS_OPTIONS = [1,2,3,4,5,6,7,8];
const REPS_OPTIONS = [1,2,3,4,5,6,8,10,12,15,20,25,30];
const PLAN_OPTIONS = ['Fuerza Max','Cardio Hit','Hipertrofia Funcional','Resistencia Elite'];

function CustomSelect({ value, onChange, options }) {
  const [open, setOpen] = useState(false);
  const ref = useRef(null);

  useEffect(() => {
    const handler = (e) => { if (ref.current && !ref.current.contains(e.target)) setOpen(false); };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  return (
    <div ref={ref} className="relative">
      <button
        type="button"
        onClick={() => setOpen(o => !o)}
        className={`w-full bg-[#262626]/40 rounded-lg py-2.5 px-3 text-sm text-white focus:outline-none transition-all cursor-pointer flex items-center justify-center gap-1.5 ${open ? 'ring-1 ring-[#cafd00]' : 'hover:bg-[#262626]/60'}`}
      >
        <span className="font-bold">{value}</span>
        <ChevronDown size={12} className={`text-[#adaaaa] transition-transform duration-200 flex-shrink-0 ${open ? 'rotate-180 text-[#cafd00]' : ''}`} />
      </button>
      {open && (
        <div className="absolute z-50 mt-1.5 left-0 right-0 bg-[#131313] border border-[#484847]/40 rounded-xl shadow-2xl shadow-black/60 overflow-y-auto max-h-44 py-1">
          {options.map(opt => {
            const isActive = String(value) === String(opt);
            return (
              <button
                key={opt}
                type="button"
                onClick={() => { onChange(opt); setOpen(false); }}
                className={`w-full px-3 py-2 text-sm text-center transition-colors font-bold ${isActive ? 'bg-[#cafd00]/10 text-[#cafd00]' : 'text-[#adaaaa] hover:bg-[#262626] hover:text-white'}`}
              >
                {opt}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}

async function apiFetch(path, opts = {}) {
  const { data: s } = await supabase.auth.getSession();
  const token = s?.session?.access_token;
  const res = await fetch(`/api/coach/rutinas${path}`, {
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

export default function Rutinas() {
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [filterLevel, setFilterLevel] = useState('all');
  const [routineName, setRoutineName] = useState('');
  const [trainingPlan, setTrainingPlan] = useState('Fuerza Max');
  const [exercises, setExercises] = useState([]);
  const [routines, setRoutines] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [editingRoutineId, setEditingRoutineId] = useState(null);
  const [difficulty, setDifficulty] = useState(50);
  const [toast, setToast] = useState(null);
  const [confirmDelete, setConfirmDelete] = useState({ isOpen: false, id: null });

  const loadData = useCallback(async (level = 'all') => {
    try {
      setLoading(true);
      const r = await apiFetch(`/routines?level=${level}`);
      setRoutines(r);
    } catch (e) { setError(e.message); } finally { setLoading(false); }
  }, []);

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 4000);
  };

  useEffect(() => { loadData(); }, []);

  const changeFilter = (lvl) => { setFilterLevel(lvl); loadData(lvl); };

  const updateExercise = (id, field, value) => {
    setExercises(prev => prev.map(e => (e.id === id ? { ...e, [field]: value } : e)));
  };
  const addEmptyExercise = () => {
    setExercises(prev => [...prev, { id: Date.now(), name: '', sets: 4, reps: 10, weight: '', rest: '60s' }]);
  };
  const removeExercise = (id) => { setExercises(prev => prev.filter(e => e.id !== id)); };

  const totalVolume = exercises.reduce((s, e) => s + (Number(e.sets)||0)*(Number(e.reps)||0), 0);
  const estDuration = exercises.length * 15;

  const openNewForm = () => {
    setEditingRoutineId(null);
    setRoutineName('');
    setTrainingPlan('Fuerza Max');
    setExercises([]);
    setDifficulty(50);
    setIsFormOpen(true);
  };

  const closeForm = () => {
    setIsFormOpen(false);
    setEditingRoutineId(null);
    setRoutineName('');
    setExercises([]);
    setDifficulty(50);
  };

  const handleSaveRoutine = async () => {
    if (!routineName.trim()) return showToast('El nombre de la rutina es obligatorio.', 'error');
    try {
      setSaving(true);
      const difficultyLabel = difficulty <= 40 ? 'Basico' : difficulty <= 70 ? 'Intermedio' : 'Avanzado';
      await apiFetch(editingRoutineId ? `/routines/${editingRoutineId}` : '/routines', {
        method: editingRoutineId ? 'PUT' : 'POST',
        body: {
          name: routineName,
          training_plan: trainingPlan,
          difficulty,
          difficulty_label: difficultyLabel,
          exercises: exercises.map(e => ({ name: e.name, sets: e.sets, reps: e.reps, weight: e.weight || null, rest: e.rest })),
        },
      });
      showToast(editingRoutineId ? 'Rutina actualizada exitosamente' : 'Rutina creada exitosamente');
      closeForm();
      await loadData(filterLevel);
    } catch (e) { showToast('Error al guardar: ' + e.message, 'error'); } finally { setSaving(false); }
  };

  const handleEditRoutine = (routine) => {
    setEditingRoutineId(routine.id);
    setRoutineName(routine.name);
    setTrainingPlan(routine.trainingPlan || 'Fuerza Max');
    setExercises(routine.exercises || []);
    setDifficulty(routine.difficulty || 50);
    setIsFormOpen(true);
  };

  const handleDeleteRoutine = (id) => setConfirmDelete({ isOpen: true, id });

  const executeDelete = async () => {
    const id = confirmDelete.id;
    if (!id) return;
    try {
      await apiFetch(`/routines/${id}`, { method: 'DELETE' });
      showToast('Rutina eliminada correctamente');
      await loadData(filterLevel);
    } catch (e) { showToast('Error al eliminar: ' + e.message, 'error'); }
    finally { setConfirmDelete({ isOpen: false, id: null }); }
  };

  if (loading) return <div className="flex items-center justify-center h-64"><Loader2 size={32} className="animate-spin text-[#cafd00]" /></div>;
  if (error) return <div className="flex items-center justify-center h-64"><p className="text-[#ff7351] text-sm">Error: {error}</p></div>;

  return (
    <div className="max-w-7xl mx-auto space-y-8 relative">

      {/* Confirmation Modal */}
      {confirmDelete.isOpen && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/80 backdrop-blur-sm" onClick={() => setConfirmDelete({ isOpen: false, id: null })} />
          <div className="bg-[#1a1a1a] border border-white/5 rounded-[2rem] p-8 max-w-sm w-full relative z-10 shadow-2xl">
            <div className="w-16 h-16 bg-[#ff7351]/10 rounded-2xl flex items-center justify-center text-[#ff7351] mb-6 mx-auto">
              <Trash size={32} />
            </div>
            <h3 className="text-xl font-bold text-center mb-2">¿Eliminar Rutina?</h3>
            <p className="text-[#adaaaa] text-center text-sm mb-8 leading-relaxed">
              Esta acción no se puede deshacer. La rutina se eliminará permanentemente de tu catálogo.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setConfirmDelete({ isOpen: false, id: null })}
                className="flex-1 px-6 py-3 rounded-xl border border-[#484847] text-white font-bold text-sm hover:bg-white/5 transition-colors"
              >
                Cancelar
              </button>
              <button
                onClick={executeDelete}
                className="flex-1 px-6 py-3 rounded-xl bg-[#ff7351] text-white font-bold text-sm hover:brightness-110 shadow-lg shadow-[#ff7351]/20 transition-all"
              >
                Eliminar
              </button>
            </div>
          </div>
        </div>
      )}

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
            <div>
              <p className="text-[10px] font-black uppercase tracking-widest opacity-60 mb-0.5">{toast.type === 'success' ? 'Éxito' : 'Error'}</p>
              <p className="text-sm font-bold">{toast.message}</p>
            </div>
            <button onClick={() => setToast(null)} className="ml-2 hover:opacity-70 transition-opacity"><X size={16} /></button>
          </div>
        </div>
      )}

      {/* ── BROWSE MODE ── */}
      {!isFormOpen && (
        <>
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
            <div>
              <h1 className="text-4xl font-black tracking-tight text-white uppercase font-headline">Mis Rutinas</h1>
              <p className="text-[#adaaaa] mt-2 max-w-lg text-sm">
                Crea y gestiona tus planes de entrenamiento personalizados.
              </p>
            </div>
            <div className="flex items-center gap-3">
              <div className="flex gap-2">
                {['all','basics','advanced'].map(lvl => (
                  <button key={lvl} onClick={() => changeFilter(lvl)} className={`text-[10px] font-bold uppercase px-3 py-2 rounded-lg transition-all ${filterLevel===lvl?'bg-[#cafd00] text-[#4a5e00]':'border border-[#767575] text-white hover:border-[#cafd00]'}`}>
                    {lvl==='all'?'Todos':lvl==='basics'?'Básico':'Avanzado'}
                  </button>
                ))}
              </div>
              <button
                onClick={openNewForm}
                className="flex items-center gap-2 px-6 py-3 bg-[#cafd00] text-[#3a4a00] rounded-xl font-black uppercase text-sm shadow-lg shadow-[#cafd00]/10 hover:brightness-110 transition-all"
              >
                <PlusCircle size={16} />
                Nueva Rutina
              </button>
            </div>
          </div>

          {routines.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-24 gap-4 text-[#adaaaa]">
              <Dumbbell size={48} className="opacity-20" />
              <p className="text-sm font-bold">Sin rutinas creadas aún</p>
              <p className="text-xs opacity-60">Usa el botón de arriba para crear tu primera rutina</p>
              <button onClick={openNewForm} className="mt-2 px-6 py-3 bg-[#cafd00] text-[#3a4a00] rounded-xl font-black uppercase text-sm hover:brightness-110 transition-all">
                Crear primera rutina
              </button>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {routines.map(routine => {
                const Icon = ICON_MAP[routine.iconType] || Dumbbell;
                return (
                  <div key={routine.id} className="relative bg-[#131313] rounded-2xl overflow-hidden border border-[#484847]/10 hover:border-[#484847]/30 transition-all group">
                    <div className="absolute top-3 right-3 flex gap-2 z-10 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        onClick={() => handleEditRoutine(routine)}
                        className="p-2 bg-[#262626] hover:bg-[#cafd00] text-[#adaaaa] hover:text-[#131313] rounded-lg shadow transition-colors"
                      >
                        <Edit size={14} />
                      </button>
                      <button
                        onClick={() => handleDeleteRoutine(routine.id)}
                        className="p-2 bg-[#262626] hover:bg-[#ff7351] text-[#adaaaa] hover:text-white rounded-lg shadow transition-colors"
                      >
                        <Trash size={14} />
                      </button>
                    </div>
                    <div className="p-5">
                      <div className="flex justify-between items-start mb-4">
                        <span className="p-2.5 rounded-xl" style={{ backgroundColor: `${routine.accentColor}15`, color: routine.accentColor }}>
                          <Icon size={22} />
                        </span>
                        <span className="text-[10px] font-black tracking-widest text-[#adaaaa] pr-20">{routine.tag}</span>
                      </div>
                      <h4 className="font-bold text-lg mb-1 pr-20">{routine.name}</h4>
                      {routine.trainingPlan && (
                        <p className="text-xs text-[#adaaaa] mb-1">{routine.trainingPlan}</p>
                      )}
                      <p className="text-xs text-[#adaaaa] mb-4">{routine.exercises?.length ?? 0} ejercicios · ~{routine.estDuration} min</p>
                      <div className="flex items-center gap-2">
                        <div className="flex-1 bg-[#262626] h-1 rounded-full overflow-hidden">
                          <div className="h-full rounded-full" style={{ width: `${routine.difficulty}%`, backgroundColor: routine.accentColor }} />
                        </div>
                        <span className="text-[10px] font-bold whitespace-nowrap text-[#adaaaa]">{routine.difficultyLabel}</span>
                      </div>
                    </div>
                  </div>
                );
              })}
              {/* New routine card */}
              <button
                onClick={openNewForm}
                className="p-5 rounded-2xl border-2 border-dashed border-[#484847]/30 flex flex-col justify-center items-center gap-3 hover:border-[#cafd00]/50 hover:bg-[#cafd00]/5 transition-all group min-h-[180px]"
              >
                <PlusCircle size={36} className="text-[#adaaaa]/30 group-hover:text-[#cafd00]/60 transition-colors" />
                <p className="text-xs font-bold text-[#adaaaa] uppercase tracking-widest">Nueva Rutina</p>
              </button>
            </div>
          )}
        </>
      )}

      {/* ── FORM MODE ── */}
      {isFormOpen && (
        <>
          <div className="flex items-center gap-4">
            <button
              onClick={closeForm}
              className="flex items-center gap-2 text-[#adaaaa] hover:text-white transition-colors text-sm font-bold"
            >
              <ArrowLeft size={18} />
              Mis Rutinas
            </button>
            <span className="text-[#484847]">/</span>
            <h1 className="text-2xl font-black tracking-tight text-white uppercase font-headline">
              {editingRoutineId ? 'Editar Rutina' : 'Nueva Rutina'}
            </h1>
          </div>

          <div className="grid grid-cols-12 gap-8">
            <section className="col-span-12 lg:col-span-8 space-y-8">
              <div className="bg-[#1a1a1a] rounded-2xl p-8 border border-[#484847]/10 space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] px-1">Nombre de la Rutina</label>
                    <input
                      type="text"
                      value={routineName}
                      onChange={e => setRoutineName(e.target.value)}
                      placeholder="Ej: Explosión de Pierna A"
                      className="w-full bg-[#131313] border-none rounded-xl py-4 px-4 text-white placeholder-[#262626] focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black uppercase tracking-[0.2em] text-[#adaaaa] px-1">Seleccionar Plan</label>
                    <div className="relative">
                      <select
                        value={trainingPlan}
                        onChange={e => setTrainingPlan(e.target.value)}
                        className="w-full bg-[#131313] border-none rounded-xl py-4 px-4 text-white focus:outline-none focus:ring-2 focus:ring-[#cafd00]/30 transition-all appearance-none"
                      >
                        {PLAN_OPTIONS.map(p => (<option key={p}>{p}</option>))}
                      </select>
                      <ChevronDown size={16} className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-[#adaaaa]" />
                    </div>
                  </div>
                </div>
              </div>

              <div className="space-y-6">
                <div className="flex items-center justify-between px-2">
                  <h3 className="text-xl font-bold font-headline uppercase tracking-tight">Añadir Ejercicios</h3>
                  <span className="text-[10px] font-bold text-[#cafd00] bg-[#cafd00]/10 px-3 py-1 rounded-full uppercase tracking-widest border border-[#cafd00]/20">
                    {exercises.length} Ejercicios
                  </span>
                </div>
                <div className="space-y-4">
                  {exercises.map((ex, idx) => (
                    <div key={ex.id} className={`bg-[#131313] p-6 rounded-2xl group relative transition-all hover:bg-[#1a1a1a] border border-[#484847]/5 ${idx===0?'border-l-4 border-l-[#cafd00]':'border-l-4 border-l-transparent'}`}>
                      <div className="grid grid-cols-12 gap-4">
                        <div className="col-span-12 md:col-span-4 space-y-1">
                          <label className="text-[10px] font-black uppercase text-[#adaaaa] tracking-wider">Nombre del Ejercicio</label>
                          <div className="relative">
                            <input
                              type="text"
                              value={ex.name}
                              onChange={e => updateExercise(ex.id,'name',e.target.value)}
                              className="w-full bg-[#262626]/40 border-none rounded-lg py-2.5 px-3 text-sm text-white focus:outline-none focus:ring-1 focus:ring-[#cafd00] transition-all"
                            />
                            <Search size={14} className="absolute right-2 top-1/2 -translate-y-1/2 text-[#adaaaa]" />
                          </div>
                        </div>
                        <div className="col-span-3 md:col-span-2 space-y-1 text-center">
                          <label className="text-[10px] font-black uppercase text-[#adaaaa] tracking-wider">Series</label>
                          <CustomSelect value={ex.sets} onChange={v => updateExercise(ex.id,'sets',v)} options={SETS_OPTIONS} />
                        </div>
                        <div className="col-span-3 md:col-span-2 space-y-1 text-center">
                          <label className="text-[10px] font-black uppercase text-[#adaaaa] tracking-wider">Reps</label>
                          <CustomSelect value={ex.reps} onChange={v => updateExercise(ex.id,'reps',v)} options={REPS_OPTIONS} />
                        </div>
                        <div className="col-span-3 md:col-span-2 space-y-1 text-center">
                          <label className="text-[10px] font-black uppercase text-[#adaaaa] tracking-wider">Intensidad (Kg)</label>
                          <input
                            type="text"
                            value={ex.weight}
                            onChange={e => updateExercise(ex.id,'weight',e.target.value)}
                            placeholder="Ej: 80 Kg"
                            className="w-full bg-[#262626]/40 border-none rounded-lg py-2.5 px-3 text-sm text-center text-white placeholder-[#767575] focus:outline-none focus:ring-1 focus:ring-[#cafd00] transition-all"
                          />
                        </div>
                        <div className="col-span-3 md:col-span-2 space-y-1 text-center">
                          <label className="text-[10px] font-black uppercase text-[#adaaaa] tracking-wider">Descanso</label>
                          <CustomSelect value={ex.rest} onChange={v => updateExercise(ex.id,'rest',v)} options={REST_OPTIONS} />
                        </div>
                      </div>
                      <button
                        onClick={() => removeExercise(ex.id)}
                        className="absolute -right-3 -top-3 w-7 h-7 bg-[#ff7351] text-white rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all shadow-lg scale-75 group-hover:scale-100"
                      >
                        <X size={14} />
                      </button>
                    </div>
                  ))}
                  <button
                    onClick={addEmptyExercise}
                    className="w-full border-2 border-dashed border-[#484847]/30 rounded-2xl py-8 flex flex-col items-center justify-center gap-2 text-[#adaaaa] hover:border-[#cafd00]/50 hover:text-[#cafd00] hover:bg-[#cafd00]/5 transition-all group"
                  >
                    <PlusCircle size={36} className="group-hover:scale-110 transition-transform" />
                    <span className="text-xs font-black uppercase tracking-[0.2em]">Añadir ejercicio</span>
                  </button>
                </div>
              </div>

              <div className="flex items-center gap-4 pt-6">
                <button
                  onClick={handleSaveRoutine}
                  disabled={saving}
                  className="px-10 py-4 bg-[#cafd00] text-[#3a4a00] font-black uppercase tracking-tighter text-sm rounded shadow-xl shadow-[#cafd00]/10 hover:brightness-110 active:scale-95 transition-all disabled:opacity-50"
                >
                  {saving ? 'Guardando...' : (editingRoutineId ? 'Actualizar Rutina' : 'Guardar Rutina')}
                </button>
                <button
                  onClick={closeForm}
                  className="px-10 py-4 border border-[#484847] text-[#adaaaa] font-bold uppercase tracking-tighter text-sm rounded hover:bg-[#262626] hover:text-white transition-all"
                >
                  Cancelar
                </button>
              </div>
            </section>

            <aside className="hidden lg:block lg:col-span-4 space-y-6">
              <div className="bg-[#20201f] rounded-2xl overflow-hidden shadow-2xl border border-[#484847]/10">
                <div className="h-32 w-full relative bg-gradient-to-br from-[#1a1a1a] to-[#0e0e0e]">
                  <div className="absolute inset-0 bg-gradient-to-t from-[#20201f] via-[#20201f]/40 to-transparent" />
                  <div className="absolute bottom-4 left-6">
                    <h4 className="text-[10px] font-black uppercase tracking-[0.2em] text-[#cafd00] mb-1">Resumen de Rutina</h4>
                    <p className="text-xl font-black font-headline">VISTA PREVIA</p>
                  </div>
                </div>
                <div className="p-6 space-y-6">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="bg-[#131313] p-4 rounded-xl border border-[#484847]/5">
                      <p className="text-[10px] font-black uppercase text-[#adaaaa] mb-1 tracking-wider">Duración Est.</p>
                      <p className="text-2xl font-black font-headline text-white">{estDuration}<span className="text-xs ml-1 text-[#cafd00] uppercase font-bold">min</span></p>
                    </div>
                    <div className="bg-[#131313] p-4 rounded-xl border border-[#484847]/5">
                      <p className="text-[10px] font-black uppercase text-[#adaaaa] mb-1 tracking-wider">Volumen Total</p>
                      <p className="text-2xl font-black font-headline text-white">{totalVolume}<span className="text-xs ml-1 text-[#cafd00] uppercase font-bold">Reps</span></p>
                    </div>
                  </div>
                  <div className="space-y-3">
                    <div className="flex justify-between items-center px-1">
                      <p className="text-[10px] font-black uppercase text-[#adaaaa] tracking-widest">Nivel de Intensidad</p>
                      <span className="text-[10px] bg-[#5516be]/40 text-[#ac8aff] px-3 py-1 rounded-full font-black uppercase border border-[#ac8aff]/20">
                        {difficulty <= 40 ? 'Basico' : difficulty <= 70 ? 'Intermedio' : 'Avanzado'}
                      </span>
                    </div>
                    <div className="relative pt-1">
                      <input
                        type="range"
                        min="0"
                        max="100"
                        value={difficulty}
                        onChange={(e) => setDifficulty(Number(e.target.value))}
                        className="w-full h-2 bg-[#262626] rounded-full appearance-none cursor-pointer accent-[#cafd00]"
                      />
                      <div className="h-2 w-full bg-[#262626] rounded-full overflow-hidden flex absolute top-1 -z-10">
                        <div className="h-full bg-[#cafd00] transition-all duration-300" style={{ width: `${difficulty}%`, boxShadow: '0 0 10px rgba(202,253,0,0.4)' }} />
                      </div>
                    </div>
                  </div>
                  <div className="space-y-3">
                    <p className="text-[10px] font-black uppercase text-[#adaaaa] px-1 tracking-widest">Estructura de Bloque</p>
                    <div className="space-y-2 max-h-[260px] overflow-y-auto pr-1">
                      {exercises.map((ex, idx) => (
                        <div key={ex.id} className="flex items-center gap-3 p-3 bg-[#000000] border border-[#484847]/10 rounded-xl hover:bg-[#1a1a1a] transition-colors group cursor-grab">
                          <div className="w-8 h-8 flex-shrink-0 bg-[#262626] rounded-lg flex items-center justify-center font-black text-[#cafd00] text-xs">{String(idx+1).padStart(2,'0')}</div>
                          <div className="flex-1 min-w-0">
                            <p className="text-xs font-bold truncate">{ex.name||'Sin nombre'}</p>
                            <p className="text-[10px] text-[#adaaaa]">{ex.sets} x {ex.reps} @ {ex.weight||'Kg ?'}</p>
                          </div>
                          <GripHorizontal size={14} className="text-[#484847] group-hover:text-white transition-colors" />
                        </div>
                      ))}
                      <div className="flex items-center gap-3 p-3 bg-[#000000] border border-dashed border-[#484847]/30 rounded-xl">
                        <div className="w-8 h-8 flex-shrink-0 bg-[#262626]/50 rounded-lg flex items-center justify-center font-black text-[#adaaaa]/30 text-xs">{String(exercises.length+1).padStart(2,'0')}</div>
                        <div className="flex-1"><p className="text-[10px] text-[#adaaaa]/40 italic">Añadiendo...</p></div>
                      </div>
                    </div>
                  </div>
                  <div className="p-4 bg-[#cafd00]/5 rounded-2xl border border-[#cafd00]/10">
                    <div className="flex items-start gap-3">
                      <Sparkles size={18} className="text-[#cafd00] flex-shrink-0 mt-0.5" />
                      <div>
                        <p className="text-[10px] font-black text-[#cafd00] mb-1 uppercase tracking-widest">Optimización por IA</p>
                        <p className="text-[10px] text-[#adaaaa] leading-relaxed">Este plan enfocado en hipertrofia tiene un balance de volumen óptimo para recuperación de 48h.</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </aside>
          </div>
        </>
      )}
    </div>
  );
}
