import { useEffect, useState } from 'react';
import {
  AlertCircle,
  AtSign,
  BadgeCheck,
  CheckCircle2,
  ChevronDown,
  ChevronUp,
  Clock,
  Edit3,
  Eye,
  EyeOff,
  Globe,
  Link,
  Loader2,
  Mail,
  MapPin,
  MessageSquare,
  Phone,
  Save,
  Star,
  TrendingUp,
  UserCheck,
  UserX,
  Users,
  X,
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import NutriologoLayout from './NutriologoLayout';

// ─── Constants ───────────────────────────────────────────────────────────────

const SPECIALTIES_OPTIONS = [
  'Deportiva', 'Clínica', 'Pediátrica', 'Geriátrica',
  'Control de peso', 'Vegana/Vegetariana', 'Diabetes',
  'Oncológica', 'Renal', 'Trastornos alimenticios',
];

const GOAL_LABELS = {
  lose_weight:   'Bajar de peso',
  gain_muscle:   'Ganar músculo',
  maintain:      'Mantener peso',
  improve_health:'Mejorar salud',
  increase_endurance: 'Resistencia',
};

const REQUEST_STATUS_BADGE = {
  pending:  'bg-[#3b2e08] text-[#fce047] border border-[#fce047]/30',
  accepted: 'bg-[#10261d] text-[#7ef0b3] border border-[#7ef0b3]/30',
  rejected: 'bg-[#3a1712] text-[#ff7351] border border-[#ff7351]/30',
};

const REQUEST_STATUS_LABEL = {
  pending:  'Pendiente',
  accepted: 'Aceptada',
  rejected: 'Rechazada',
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

function timeAgo(isoStr) {
  if (!isoStr) return '';
  const diff = Math.floor((Date.now() - new Date(isoStr)) / 1000);
  if (diff < 60) return 'Hace un momento';
  if (diff < 3600) return `Hace ${Math.floor(diff / 60)} min`;
  if (diff < 86400) return `Hace ${Math.floor(diff / 3600)} h`;
  return `Hace ${Math.floor(diff / 86400)} días`;
}

// ─── Sub-components ───────────────────────────────────────────────────────────

function StatBadge({ icon: Icon, label, value, color = '#cafd00' }) {
  return (
    <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl px-5 py-4 flex items-center gap-4">
      <div className="w-10 h-10 rounded-full flex items-center justify-center shrink-0"
        style={{ backgroundColor: color + '18', border: `1px solid ${color}40` }}>
        <Icon size={18} style={{ color }} />
      </div>
      <div>
        <p className="text-xl font-black text-white">{value ?? '—'}</p>
        <p className="text-[11px] uppercase tracking-widest text-[#adaaaa]">{label}</p>
      </div>
    </div>
  );
}

function RequestCard({ request, onRespond, responding }) {
  const [open, setOpen] = useState(false);
  const [responseText, setResponseText] = useState('');

  const handleAccept = () => onRespond(request.id, 'accepted', responseText);
  const handleReject = () => onRespond(request.id, 'rejected', responseText);

  return (
    <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl overflow-hidden">
      <div className="px-5 py-4 flex items-start gap-4">
        <div className="w-10 h-10 rounded-full bg-[#262626] flex items-center justify-center text-sm font-bold text-[#cafd00] shrink-0 overflow-hidden border border-[#2a2a2a]">
          {request.client_avatar
            ? <img src={request.client_avatar} alt="" className="w-full h-full object-cover" />
            : (request.client_name?.charAt(0).toUpperCase() ?? '?')}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <p className="text-sm font-bold text-white">{request.client_name}</p>
            <span className={`text-[10px] px-2 py-0.5 rounded-full ${REQUEST_STATUS_BADGE[request.status]}`}>
              {REQUEST_STATUS_LABEL[request.status]}
            </span>
          </div>
          <p className="text-xs text-[#adaaaa] mt-0.5">{request.client_email}</p>
          <div className="flex items-center gap-2 mt-1.5 flex-wrap">
            {request.client_goal && (
              <span className="text-[10px] bg-[#1a1a1a] border border-[#2a2a2a] rounded px-2 py-0.5 text-[#ac8aff]">
                {GOAL_LABELS[request.client_goal] ?? request.client_goal}
              </span>
            )}
            {request.client_age != null && (
              <span className="text-[10px] text-[#6f6f6f]">{request.client_age} años</span>
            )}
          </div>
          {request.message && (
            <p className="text-sm text-[#adaaaa] mt-2 leading-relaxed line-clamp-2">{request.message}</p>
          )}
          <p className="text-[10px] text-[#6f6f6f] mt-1">{timeAgo(request.created_at)}</p>
        </div>
        {request.status === 'pending' && (
          <button
            onClick={() => setOpen(v => !v)}
            className="text-[#adaaaa] hover:text-white transition-colors shrink-0"
          >
            {open ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
          </button>
        )}
      </div>

      {request.status === 'pending' && open && (
        <div className="border-t border-[#2a2a2a] px-5 py-4">
          <label className="block text-[10px] uppercase tracking-widest text-[#adaaaa] mb-2">
            Respuesta (opcional)
          </label>
          <textarea
            rows={2}
            value={responseText}
            onChange={e => setResponseText(e.target.value)}
            placeholder="Agrega un mensaje al cliente..."
            className="w-full bg-[#0e0e0e] border border-[#2a2a2a] rounded-lg px-3 py-2 text-sm text-white placeholder-[#6f6f6f] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/50 resize-none mb-3"
          />
          <div className="flex gap-2 justify-end">
            <button
              onClick={handleReject}
              disabled={responding}
              className="flex items-center gap-1.5 px-4 py-2 bg-[#3a1712] text-[#ff7351] border border-[#ff7351]/30 text-xs font-semibold rounded-sm hover:opacity-80 transition-opacity disabled:opacity-40"
            >
              {responding ? <Loader2 size={12} className="animate-spin" /> : <UserX size={13} />}
              Rechazar
            </button>
            <button
              onClick={handleAccept}
              disabled={responding}
              className="flex items-center gap-1.5 px-4 py-2 bg-[#10261d] text-[#7ef0b3] border border-[#7ef0b3]/30 text-xs font-semibold rounded-sm hover:opacity-80 transition-opacity disabled:opacity-40"
            >
              {responding ? <Loader2 size={12} className="animate-spin" /> : <UserCheck size={13} />}
              Aceptar
            </button>
          </div>
        </div>
      )}

      {request.status !== 'pending' && request.nutriologo_response && (
        <div className="border-t border-[#2a2a2a] px-5 py-3">
          <p className="text-xs text-[#adaaaa]">
            <span className="text-[#6f6f6f] uppercase tracking-widest text-[9px] mr-2">Tu respuesta</span>
            {request.nutriologo_response}
          </p>
        </div>
      )}
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────

export default function NutriologoPerfilPage() {
  const [nutriologoName, setNutriologoName] = useState('Nutriólogo');
  const [profile, setProfile]   = useState(null);
  const [loading, setLoading]   = useState(true);
  const [loadError, setLoadError] = useState('');
  const [editing, setEditing]   = useState(false);
  const [saving, setSaving]     = useState(false);
  const [msg, setMsg]           = useState('');

  const [solicitudes, setSolicitudes]     = useState([]);
  const [loadingSolic, setLoadingSolic]   = useState(true);
  const [solicFilter, setSolicFilter]     = useState('pending');
  const [responding, setResponding]       = useState(false);

  const [form, setForm] = useState(null);

  const getToken = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    return session?.access_token;
  };

  // ── Boot ───────────────────────────────────────────────────────────────────
  useEffect(() => {
    let ignore = false;
    const boot = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!ignore && user?.email) setNutriologoName(user.email.split('@')[0]);

      const token = await getToken();
      try {
        const res = await fetch('/api/nutriologo/perfil', {
          headers: { Accept: 'application/json', Authorization: `Bearer ${token}` },
        });
        const payload = await res.json();
        if (!ignore) {
          if (!res.ok) {
            setLoadError(payload.error ?? payload.message ?? 'Error al cargar el perfil.');
          } else if (payload.data) {
            setProfile(payload.data);
            if (payload.data.name) setNutriologoName(payload.data.name.split(' ')[0]);
            initForm(payload.data);
          }
        }
      } catch (err) {
        if (!ignore) setLoadError('No se pudo conectar con el servidor.');
      } finally {
        if (!ignore) setLoading(false);
      }
    };
    boot();
    return () => { ignore = true; };
  }, []);

  // ── Load solicitudes ───────────────────────────────────────────────────────
  useEffect(() => {
    let ignore = false;
    const load = async () => {
      setLoadingSolic(true);
      const token = await getToken();
      try {
        const res = await fetch(`/api/nutriologo/perfil/solicitudes?status=${solicFilter}`, {
          headers: { Accept: 'application/json', Authorization: `Bearer ${token}` },
        });
        const payload = await res.json();
        if (!ignore) {
          if (!res.ok) {
            console.error('[Solicitudes] API error', res.status, payload);
            setMsg(payload?.error ?? payload?.message ?? `Error ${res.status} al cargar solicitudes`);
          }
          setSolicitudes(res.ok ? (payload.data ?? []) : []);
        }
      } finally {
        if (!ignore) setLoadingSolic(false);
      }
    };
    load();
    return () => { ignore = true; };
  }, [solicFilter]);

  const initForm = (data) => setForm({
    bio:                data.bio ?? '',
    specialties:        data.specialties ?? [],
    experience_years:   data.experience_years ?? '',
    location:           data.location ?? '',
    consultation_price: data.consultation_price ?? '',
    profile_visible:    data.profile_visible ?? true,
    phone:              data.phone ?? '',
    focus:              data.focus ?? '',
    social_instagram:   data.social_links?.instagram ?? '',
    social_website:     data.social_links?.website ?? '',
    social_facebook:    data.social_links?.facebook ?? '',
  });

  const toggleSpecialty = (s) => {
    setForm(f => ({
      ...f,
      specialties: f.specialties.includes(s)
        ? f.specialties.filter(x => x !== s)
        : [...f.specialties, s],
    }));
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    setMsg('');
    const token = await getToken();
    const body = {
      bio:                form.bio || null,
      specialties:        form.specialties,
      experience_years:   form.experience_years !== '' ? Number(form.experience_years) : null,
      location:           form.location || null,
      consultation_price: form.consultation_price !== '' ? Number(form.consultation_price) : null,
      profile_visible:    form.profile_visible,
      phone:              form.phone || null,
      focus:              form.focus || null,
      social_links: {
        instagram: form.social_instagram || null,
        website:   form.social_website || null,
        facebook:  form.social_facebook || null,
      },
    };
    try {
      const res = await fetch('/api/nutriologo/perfil', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(body),
      });
      const payload = await res.json();
      if (!res.ok) throw new Error(payload.message ?? 'Error al guardar');
      setProfile(prev => ({ ...prev, ...body, social_links: body.social_links }));
      setEditing(false);
      setMsg('Perfil actualizado correctamente.');
    } catch (err) {
      setMsg(err.message);
    } finally {
      setSaving(false);
    }
  };

  const handleRespond = async (id, status, response) => {
    setResponding(true);
    const token = await getToken();
    try {
      const res = await fetch(`/api/nutriologo/perfil/solicitudes/${id}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ status, response }),
      });
      const payload = await res.json();
      if (!res.ok) throw new Error(payload.error ?? 'Error');
      setSolicitudes(prev => prev.map(s =>
        s.id === id ? { ...s, status, nutriologo_response: response, responded_at: new Date().toISOString() } : s
      ));
      if (solicFilter === 'pending') {
        setSolicitudes(prev => prev.filter(s => s.id !== id));
      }
      if (status === 'accepted') {
        setProfile(prev => ({
          ...prev,
          stats: {
            ...prev.stats,
            pending_requests: Math.max(0, (prev.stats?.pending_requests ?? 1) - 1),
          },
        }));
      }
    } catch (err) {
      setMsg(err.message);
    } finally {
      setResponding(false);
    }
  };

  // ─── Render ────────────────────────────────────────────────────────────────
  if (loading) {
    return (
      <NutriologoLayout nutriologoName={nutriologoName}>
        <div className="flex justify-center items-center min-h-[60vh]">
          <Loader2 size={28} className="animate-spin text-[#adaaaa]" />
        </div>
      </NutriologoLayout>
    );
  }

  if (loadError) {
    return (
      <NutriologoLayout nutriologoName={nutriologoName}>
        <div className="flex flex-col items-center justify-center min-h-[60vh] gap-3 text-center">
          <AlertCircle size={36} className="text-[#ff7351] opacity-60" />
          <p className="text-sm text-[#ff7351]">{loadError}</p>
          <button
            onClick={() => { setLoadError(''); setLoading(true); window.location.reload(); }}
            className="text-xs text-[#adaaaa] hover:text-white underline transition-colors"
          >
            Reintentar
          </button>
        </div>
      </NutriologoLayout>
    );
  }

  const p = profile ?? {};
  const stats = p.stats ?? {};

  return (
    <NutriologoLayout nutriologoName={nutriologoName}>

      {/* ── Page header ──────────────────────────────────────────────────── */}
      <div className="flex items-start justify-between mb-8 gap-4">
        <div className="flex items-center gap-5">
          <div className="w-16 h-16 rounded-full bg-[#262626] border-2 border-[#cafd00]/30 flex items-center justify-center text-2xl font-black text-[#cafd00]">
            {p.name?.charAt(0).toUpperCase() ?? 'N'}
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-black text-white tracking-tight">{p.name}</h1>
              {p.profile_visible
                ? <Eye size={15} className="text-[#7ef0b3]" />
                : <EyeOff size={15} className="text-[#adaaaa]" />}
            </div>
            <p className="text-sm text-[#adaaaa]">{p.email}</p>
            <div className="flex items-center gap-3 mt-1 flex-wrap">
              {p.license_number && (
                <span className="text-[11px] text-[#adaaaa] flex items-center gap-1">
                  <BadgeCheck size={12} className="text-[#cafd00]" />
                  Cédula: {p.license_number}
                </span>
              )}
              {p.focus && (
                <span className="text-[11px] bg-[#1a1a1a] border border-[#2a2a2a] rounded px-2 py-0.5 text-[#adaaaa]">
                  {p.focus}
                </span>
              )}
              {p.location && (
                <span className="text-[11px] text-[#adaaaa] flex items-center gap-1">
                  <MapPin size={11} /> {p.location}
                </span>
              )}
            </div>
          </div>
        </div>
        <button
          onClick={() => { setEditing(v => !v); setMsg(''); if (!editing) initForm(p); }}
          className={`flex items-center gap-2 px-4 py-2 text-sm font-bold rounded-sm transition-all ${
            editing
              ? 'bg-[#1a1a1a] text-[#adaaaa] border border-[#2a2a2a]'
              : 'bg-[#cafd00] text-[#3a4a00]'
          }`}
        >
          {editing ? <X size={15} /> : <Edit3 size={15} />}
          {editing ? 'Cancelar' : 'Editar perfil'}
        </button>
      </div>

      {/* ── Stats ────────────────────────────────────────────────────────── */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-8">
        <StatBadge icon={Users}      label="Pacientes totales"  value={stats.total_patients}   color="#cafd00" />
        <StatBadge icon={TrendingUp} label="Pacientes activos"  value={stats.active_patients}  color="#7ef0b3" />
        <StatBadge icon={Star}       label="Planes creados"     value={stats.total_plans}      color="#ac8aff" />
        <StatBadge icon={Clock}      label="Solicitudes nuevas" value={stats.pending_requests} color="#fce047" />
      </div>

      {/* ── Feedback message ─────────────────────────────────────────────── */}
      {msg && (
        <div className={`mb-6 flex items-center gap-2 text-sm rounded-lg px-4 py-3 ${
          msg.includes('Error') || msg.includes('error')
            ? 'bg-[#3a1712] text-[#ff7351] border border-[#ff7351]/30'
            : 'bg-[#10261d] text-[#7ef0b3] border border-[#7ef0b3]/30'
        }`}>
          {msg.includes('Error') || msg.includes('error')
            ? <AlertCircle size={15} />
            : <CheckCircle2 size={15} />}
          {msg}
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-5 gap-6">

        {/* ── Left: Profile card / Edit form ───────────────────────────── */}
        <div className="xl:col-span-3 space-y-4">

          {!editing ? (
            /* ── View mode ──────────────────────────────────────────────── */
            <>
              {/* Bio */}
              <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl p-5">
                <p className="text-[10px] uppercase tracking-widest text-[#adaaaa] mb-3">Acerca de mí</p>
                {p.bio
                  ? <p className="text-sm text-white leading-relaxed">{p.bio}</p>
                  : <p className="text-sm text-[#6f6f6f] italic">Sin biografía. Edita tu perfil para añadir una.</p>
                }
              </div>

              {/* Specialties */}
              {(p.specialties?.length > 0) && (
                <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl p-5">
                  <p className="text-[10px] uppercase tracking-widest text-[#adaaaa] mb-3">Especialidades</p>
                  <div className="flex flex-wrap gap-2">
                    {p.specialties.map(s => (
                      <span key={s} className="text-xs bg-[#1a1a1a] border border-[#2a2a2a] rounded-full px-3 py-1 text-[#cafd00]">
                        {s}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {/* Details */}
              <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl p-5">
                <p className="text-[10px] uppercase tracking-widest text-[#adaaaa] mb-3">Información</p>
                <div className="space-y-2.5">
                  {p.experience_years != null && (
                    <div className="flex items-center gap-3">
                      <Star size={14} className="text-[#ac8aff] shrink-0" />
                      <span className="text-sm text-white">{p.experience_years} años de experiencia</span>
                    </div>
                  )}
                  {p.consultation_price != null && (
                    <div className="flex items-center gap-3">
                      <BadgeCheck size={14} className="text-[#cafd00] shrink-0" />
                      <span className="text-sm text-white">${Number(p.consultation_price).toFixed(2)} por consulta</span>
                    </div>
                  )}
                  {p.phone && (
                    <div className="flex items-center gap-3">
                      <Phone size={14} className="text-[#adaaaa] shrink-0" />
                      <span className="text-sm text-white">{p.phone}</span>
                    </div>
                  )}
                  {p.email && (
                    <div className="flex items-center gap-3">
                      <Mail size={14} className="text-[#adaaaa] shrink-0" />
                      <span className="text-sm text-white">{p.email}</span>
                    </div>
                  )}
                </div>
              </div>

              {/* Social links */}
              {(p.social_links?.instagram || p.social_links?.website || p.social_links?.facebook) && (
                <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl p-5">
                  <p className="text-[10px] uppercase tracking-widest text-[#adaaaa] mb-3">Redes y contacto</p>
                  <div className="flex gap-3 flex-wrap">
                    {p.social_links?.instagram && (
                      <span className="flex items-center gap-1.5 text-xs text-white bg-[#1a1a1a] border border-[#2a2a2a] rounded px-3 py-1.5">
                        <AtSign size={13} className="text-[#e1306c]" /> @{p.social_links.instagram}
                      </span>
                    )}
                    {p.social_links?.website && (
                      <span className="flex items-center gap-1.5 text-xs text-white bg-[#1a1a1a] border border-[#2a2a2a] rounded px-3 py-1.5">
                        <Globe size={13} className="text-[#cafd00]" /> {p.social_links.website}
                      </span>
                    )}
                    {p.social_links?.facebook && (
                      <span className="flex items-center gap-1.5 text-xs text-white bg-[#1a1a1a] border border-[#2a2a2a] rounded px-3 py-1.5">
                        <Link size={13} className="text-[#1877f2]" /> {p.social_links.facebook}
                      </span>
                    )}
                  </div>
                </div>
              )}
            </>
          ) : (
            /* ── Edit mode ──────────────────────────────────────────────── */
            form && (
              <form onSubmit={handleSave} className="space-y-4">

                {/* Visibility toggle */}
                <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl p-5 flex items-center justify-between">
                  <div>
                    <p className="text-sm font-semibold text-white">Perfil público</p>
                    <p className="text-xs text-[#adaaaa] mt-0.5">Los clientes pueden encontrarte</p>
                  </div>
                  <button
                    type="button"
                    onClick={() => setForm(f => ({ ...f, profile_visible: !f.profile_visible }))}
                    className={`w-12 h-6 rounded-full transition-colors relative ${form.profile_visible ? 'bg-[#cafd00]' : 'bg-[#2a2a2a]'}`}
                  >
                    <span className={`absolute top-1 w-4 h-4 rounded-full bg-[#0e0e0e] transition-all ${form.profile_visible ? 'left-7' : 'left-1'}`} />
                  </button>
                </div>

                {/* Focus & Location */}
                <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl p-5 space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-[10px] uppercase tracking-widest text-[#adaaaa] mb-1">Área de enfoque</label>
                      <input type="text" value={form.focus}
                        onChange={e => setForm(f => ({ ...f, focus: e.target.value }))}
                        placeholder="Ej: Nutrición deportiva"
                        className="w-full bg-[#0e0e0e] border border-[#2a2a2a] rounded-lg px-3 py-2 text-sm text-white placeholder-[#6f6f6f] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/50" />
                    </div>
                    <div>
                      <label className="block text-[10px] uppercase tracking-widest text-[#adaaaa] mb-1">Ciudad / Estado</label>
                      <input type="text" value={form.location}
                        onChange={e => setForm(f => ({ ...f, location: e.target.value }))}
                        placeholder="Ej: Guadalajara, Jalisco"
                        className="w-full bg-[#0e0e0e] border border-[#2a2a2a] rounded-lg px-3 py-2 text-sm text-white placeholder-[#6f6f6f] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/50" />
                    </div>
                    <div>
                      <label className="block text-[10px] uppercase tracking-widest text-[#adaaaa] mb-1">Años de experiencia</label>
                      <input type="number" min="0" max="50" value={form.experience_years}
                        onChange={e => setForm(f => ({ ...f, experience_years: e.target.value }))}
                        placeholder="5"
                        className="w-full bg-[#0e0e0e] border border-[#2a2a2a] rounded-lg px-3 py-2 text-sm text-white placeholder-[#6f6f6f] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/50" />
                    </div>
                    <div>
                      <label className="block text-[10px] uppercase tracking-widest text-[#adaaaa] mb-1">Precio por consulta ($)</label>
                      <input type="number" min="0" step="0.01" value={form.consultation_price}
                        onChange={e => setForm(f => ({ ...f, consultation_price: e.target.value }))}
                        placeholder="500.00"
                        className="w-full bg-[#0e0e0e] border border-[#2a2a2a] rounded-lg px-3 py-2 text-sm text-white placeholder-[#6f6f6f] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/50" />
                    </div>
                  </div>
                  <div>
                    <label className="block text-[10px] uppercase tracking-widest text-[#adaaaa] mb-1">Teléfono</label>
                    <input type="text" value={form.phone}
                      onChange={e => setForm(f => ({ ...f, phone: e.target.value }))}
                      placeholder="+52 33 1234 5678"
                      className="w-full bg-[#0e0e0e] border border-[#2a2a2a] rounded-lg px-3 py-2 text-sm text-white placeholder-[#6f6f6f] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/50" />
                  </div>
                </div>

                {/* Bio */}
                <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl p-5">
                  <label className="block text-[10px] uppercase tracking-widest text-[#adaaaa] mb-2">Acerca de mí</label>
                  <textarea rows={5} value={form.bio}
                    onChange={e => setForm(f => ({ ...f, bio: e.target.value }))}
                    placeholder="Cuéntale a tus futuros pacientes sobre tu enfoque, metodología y lo que los hace elegirte..."
                    className="w-full bg-[#0e0e0e] border border-[#2a2a2a] rounded-lg px-3 py-2 text-sm text-white placeholder-[#6f6f6f] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/50 resize-none" />
                </div>

                {/* Specialties */}
                <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl p-5">
                  <label className="block text-[10px] uppercase tracking-widest text-[#adaaaa] mb-3">Especialidades</label>
                  <div className="flex flex-wrap gap-2">
                    {SPECIALTIES_OPTIONS.map(s => (
                      <button
                        key={s}
                        type="button"
                        onClick={() => toggleSpecialty(s)}
                        className={`text-xs rounded-full px-3 py-1.5 border transition-colors ${
                          form.specialties.includes(s)
                            ? 'bg-[#cafd00]/10 border-[#cafd00]/50 text-[#cafd00]'
                            : 'bg-[#1a1a1a] border-[#2a2a2a] text-[#adaaaa] hover:border-[#4a4a4a]'
                        }`}
                      >
                        {s}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Social links */}
                <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl p-5 space-y-3">
                  <p className="text-[10px] uppercase tracking-widest text-[#adaaaa]">Redes y contacto</p>
                  <div className="flex items-center gap-3">
                    <AtSign size={16} className="text-[#e1306c] shrink-0" />
                    <input type="text" value={form.social_instagram}
                      onChange={e => setForm(f => ({ ...f, social_instagram: e.target.value }))}
                      placeholder="usuario (sin @)"
                      className="flex-1 bg-[#0e0e0e] border border-[#2a2a2a] rounded-lg px-3 py-2 text-sm text-white placeholder-[#6f6f6f] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/50" />
                  </div>
                  <div className="flex items-center gap-3">
                    <Globe size={16} className="text-[#cafd00] shrink-0" />
                    <input type="url" value={form.social_website}
                      onChange={e => setForm(f => ({ ...f, social_website: e.target.value }))}
                      placeholder="https://mipagina.com"
                      className="flex-1 bg-[#0e0e0e] border border-[#2a2a2a] rounded-lg px-3 py-2 text-sm text-white placeholder-[#6f6f6f] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/50" />
                  </div>
                  <div className="flex items-center gap-3">
                    <Link size={16} className="text-[#1877f2] shrink-0" />
                    <input type="text" value={form.social_facebook}
                      onChange={e => setForm(f => ({ ...f, social_facebook: e.target.value }))}
                      placeholder="perfil o página"
                      className="flex-1 bg-[#0e0e0e] border border-[#2a2a2a] rounded-lg px-3 py-2 text-sm text-white placeholder-[#6f6f6f] focus:outline-none focus:ring-1 focus:ring-[#cafd00]/50" />
                  </div>
                </div>

                <div className="flex justify-end">
                  <button type="submit" disabled={saving}
                    className="flex items-center gap-2 px-6 py-2.5 bg-[#cafd00] text-[#3a4a00] font-black text-sm rounded-sm hover:opacity-90 transition-opacity disabled:opacity-50">
                    {saving ? <Loader2 size={14} className="animate-spin" /> : <Save size={14} />}
                    Guardar cambios
                  </button>
                </div>
              </form>
            )
          )}
        </div>

        {/* ── Right: Solicitudes de contacto ───────────────────────────── */}
        <div className="xl:col-span-2 space-y-4">
          <div className="bg-[#131313] border border-[#2a2a2a] rounded-xl overflow-hidden">
            <div className="px-5 py-4 border-b border-[#2a2a2a]">
              <div className="flex items-center gap-2 mb-3">
                <MessageSquare size={15} className="text-[#cafd00]" />
                <h2 className="text-sm font-bold text-white uppercase tracking-widest">Solicitudes</h2>
                {stats.pending_requests > 0 && (
                  <span className="text-[10px] bg-[#3b2e08] text-[#fce047] border border-[#fce047]/30 rounded-full px-2 py-0.5">
                    {stats.pending_requests} nuevas
                  </span>
                )}
              </div>
              <div className="flex gap-1">
                {['pending', 'accepted', 'rejected', 'all'].map(f => (
                  <button
                    key={f}
                    onClick={() => setSolicFilter(f)}
                    className={`text-[10px] uppercase tracking-widest px-2.5 py-1 rounded transition-colors ${
                      solicFilter === f
                        ? 'bg-[#cafd00]/10 text-[#cafd00] border border-[#cafd00]/30'
                        : 'text-[#adaaaa] hover:text-white'
                    }`}
                  >
                    {{ pending: 'Nuevas', accepted: 'Aceptadas', rejected: 'Rechazadas', all: 'Todas' }[f]}
                  </button>
                ))}
              </div>
            </div>

            <div className="overflow-y-auto max-h-[600px]">
              {loadingSolic ? (
                <div className="flex justify-center py-10">
                  <Loader2 size={20} className="animate-spin text-[#adaaaa]" />
                </div>
              ) : solicitudes.length === 0 ? (
                <div className="text-center py-10 text-[#adaaaa]">
                  <MessageSquare size={28} className="mx-auto mb-2 opacity-20" />
                  <p className="text-sm">Sin solicitudes {{ pending: 'nuevas', accepted: 'aceptadas', rejected: 'rechazadas', all: '' }[solicFilter]}</p>
                  <p className="text-xs mt-1 text-[#6f6f6f]">Los clientes que te encuentren podrán contactarte</p>
                </div>
              ) : (
                <div className="p-3 space-y-2">
                  {solicitudes.map(req => (
                    <RequestCard
                      key={req.id}
                      request={req}
                      onRespond={handleRespond}
                      responding={responding}
                    />
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Info box */}
          <div className="bg-[#0e0e0e] border border-[#2a2a2a] rounded-xl p-4">
            <div className="flex gap-2">
              <Eye size={14} className="text-[#adaaaa] shrink-0 mt-0.5" />
              <div>
                <p className="text-xs font-semibold text-white mb-1">Visibilidad del perfil</p>
                <p className="text-[11px] text-[#6f6f6f] leading-relaxed">
                  {p.profile_visible
                    ? 'Tu perfil es visible. Los clientes te pueden encontrar en el directorio de nutriólogos y enviarte solicitudes de contacto.'
                    : 'Perfil oculto. No aparecerás en búsquedas de clientes.'}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </NutriologoLayout>
  );
}
