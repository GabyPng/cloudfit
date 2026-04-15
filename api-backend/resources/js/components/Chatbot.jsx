import React, { useState, useRef, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { MessageCircle, X, Bot } from 'lucide-react';

const renderMessageContent = (content) => {
  const lines = content.split('\n').filter((l) => l !== '');
  if (lines.length <= 1) {
    return <p className="text-sm leading-relaxed">{content}</p>;
  }
  const hasBullets = lines.some((l) => l.startsWith('•') || l.startsWith('▸') || l.startsWith('-'));
  return (
    <div className="space-y-1.5">
      {lines.map((line, i) => {
        const isBullet = line.startsWith('•') || line.startsWith('▸') || (line.startsWith('-') && line.length > 1);
        const isHeader = !isBullet && i === 0 && hasBullets;
        if (isBullet) {
          const text = line.replace(/^[•▸\-]\s*/, '');
          return (
            <div key={i} className="flex gap-2 items-start">
              <span className="text-[#CCFF00] text-[8px] mt-[5px] leading-none flex-shrink-0">▶</span>
              <span className="text-sm text-gray-200 leading-snug">{text}</span>
            </div>
          );
        }
        if (isHeader) {
          return (
            <p key={i} className="text-[11px] font-semibold uppercase tracking-wider text-[#9ecf00] mb-0.5">
              {line}
            </p>
          );
        }
        return <p key={i} className="text-sm text-gray-300 leading-snug">{line}</p>;
      })}
    </div>
  );
};

const normalizeRole = (rawRole) => {
  const role = (rawRole || '').toString().trim().toLowerCase();
  if (role === 'administrador') return 'admin';
  if (role === 'nutriólogo') return 'nutriologo';
  return role || 'cliente';
};

const filterButtonsByRole = (buttons, role) => {
  const normalizedRole = normalizeRole(role);
  const prefixMap = {
    admin: 'admin.',
    coach: 'coach.',
    nutriologo: 'nutri.',
    cliente: 'client.',
  };

  const prefix = prefixMap[normalizedRole];
  if (!prefix) return [];

  return (Array.isArray(buttons) ? buttons : []).filter((btn) =>
    typeof btn?.intent === 'string' && btn.intent.startsWith(prefix)
  );
};

export default function Chatbot() {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState([
    { role: 'assistant', content: '¡Hola! Soy el asistente virtual de CloudFit impulsado por IA. ¿En qué te puedo ayudar hoy?' }
  ]);
  const [buttons, setButtons] = useState([]);
  const [clientOptions, setClientOptions] = useState([]);
  const [routineOptions, setRoutineOptions] = useState([]);
  const [planOptions, setPlanOptions] = useState([]);
  const [selectedClientId, setSelectedClientId] = useState('');
  const [selectedRoutineId, setSelectedRoutineId] = useState('');
  const [selectedPlanId, setSelectedPlanId] = useState('');
  const [loading, setLoading] = useState(false);
  const [currentRole, setCurrentRole] = useState('cliente');
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    loadButtons();
  }, []);

  const getToken = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    return session?.access_token || null;
  };

  const loadButtons = async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;
      if (!token) return;

      const role = normalizeRole(
        session?.user?.user_metadata?.role ||
        session?.user?.app_metadata?.role
      );
      setCurrentRole(role);

      const response = await fetch('/api/chatbot/buttons', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json',
        },
      });

      if (!response.ok) return;
      const data = await response.json();
      const resolvedRole = normalizeRole(data?.role || role);
      setCurrentRole(resolvedRole);
      setButtons(filterButtonsByRole(data.buttons, resolvedRole));
    } catch {
      // no-op
    }
  };

  const postMessage = async ({ intent = null, message = '', params = {} }) => {
    const token = await getToken();
    const response = await fetch('/api/chatbot/message', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify({
        ...(intent ? { intent } : {}),
        ...(message ? { message } : {}),
        ...(Object.keys(params).length ? { params } : {}),
      }),
    });

    return { response, data: await response.json() };
  };

  const normalizeArray = (payload) => {
    if (!payload) return [];
    if (Array.isArray(payload)) return payload;
    if (Array.isArray(payload?.data)) return payload.data;
    return [];
  };

  const updateSelectorData = (intent, payload) => {
    if (intent === 'coach.client_list' || intent === 'nutri.client_list') {
      const clients = normalizeArray(payload).map(item => ({
        id: item.id,
        label: item.name || item.email || `Cliente ${item.id}`,
      }));
      setClientOptions(clients);
      if (clients.length > 0 && !selectedClientId) {
        setSelectedClientId(String(clients[0].id));
      }
      return;
    }

    if (intent === 'coach.client_routines' || intent === 'client.my_routines') {
      const routines = normalizeArray(payload).map(item => ({
        id: item.id,
        label: item.name || `Rutina ${item.id}`,
      }));
      setRoutineOptions(routines);
      if (routines.length > 0 && !selectedRoutineId) {
        setSelectedRoutineId(String(routines[0].id));
      }
      return;
    }

    if (intent === 'nutri.client_plans') {
      const plans = normalizeArray(payload).map(item => ({
        id: item.id,
        label: item.title || `Plan ${item.id}`,
      }));
      setPlanOptions(plans);
      if (plans.length > 0 && !selectedPlanId) {
        setSelectedPlanId(String(plans[0].id));
      }
      return;
    }

    if (intent === 'client.my_nutrition' && payload && payload.id) {
      setPlanOptions([{ id: payload.id, label: payload.title || `Plan ${payload.id}` }]);
      if (!selectedPlanId) {
        setSelectedPlanId(String(payload.id));
      }
    }
  };

  const requiresClient = (intent) => ['coach.client_routines', 'coach.client_progress', 'nutri.client_plans', 'nutri.client_active_plan'].includes(intent);
  const requiresRoutine = (intent) => ['coach.routine_detail', 'client.routine_detail'].includes(intent);
  const requiresPlan = (intent) => ['nutri.plan_detail', 'nutri.plan_macros', 'nutri.meal_detail'].includes(intent);

  const ensureClientOptions = async (intent) => {
    if (clientOptions.length > 0) return true;
    const preloadIntent = intent.startsWith('nutri.') ? 'nutri.client_list' : 'coach.client_list';
    const { response, data } = await postMessage({ intent: preloadIntent, message: 'Cargar clientes' });
    if (response.ok) {
      updateSelectorData(preloadIntent, data.data);
      if (Array.isArray(data.buttons)) setButtons(data.buttons);
      return true;
    }
    return false;
  };

  const ensureRoutineOptions = async (intent, clientId) => {
    if (routineOptions.length > 0) return true;

    if (intent === 'coach.routine_detail') {
      if (!clientId) return false;
      const { response, data } = await postMessage({
        intent: 'coach.client_routines',
        message: 'Cargar rutinas del cliente',
        params: { client_id: Number(clientId) },
      });
      if (response.ok) {
        updateSelectorData('coach.client_routines', data.data);
        if (Array.isArray(data.buttons)) setButtons(data.buttons);
        return true;
      }
      return false;
    }

    if (intent === 'client.routine_detail') {
      const { response, data } = await postMessage({
        intent: 'client.my_routines',
        message: 'Cargar mis rutinas',
      });
      if (response.ok) {
        updateSelectorData('client.my_routines', data.data);
        if (Array.isArray(data.buttons)) setButtons(data.buttons);
        return true;
      }
      return false;
    }

    return false;
  };

  const ensurePlanOptions = async (intent, clientId) => {
    if (planOptions.length > 0) return true;

    if (intent.startsWith('nutri.')) {
      if (!clientId) return false;
      const { response, data } = await postMessage({
        intent: 'nutri.client_plans',
        message: 'Cargar planes del cliente',
        params: { client_id: Number(clientId) },
      });
      if (response.ok) {
        updateSelectorData('nutri.client_plans', data.data);
        if (Array.isArray(data.buttons)) setButtons(data.buttons);
        return true;
      }
      return false;
    }

    const { response, data } = await postMessage({
      intent: 'client.my_nutrition',
      message: 'Cargar mi plan',
    });
    if (response.ok) {
      updateSelectorData('client.my_nutrition', data.data);
      if (Array.isArray(data.buttons)) setButtons(data.buttons);
      return true;
    }

    return false;
  };

  const runIntent = async (intent, label) => {
    if (loading) return;
    setLoading(true);

    try {
      let params = {};

      if (requiresClient(intent)) {
        await ensureClientOptions(intent);
        if (!selectedClientId) {
          setMessages(prev => [...prev, { role: 'assistant', content: 'Selecciona primero un cliente para continuar.' }]);
          return;
        }
        params.client_id = Number(selectedClientId);
      }

      if (requiresRoutine(intent)) {
        await ensureRoutineOptions(intent, selectedClientId);
        if (!selectedRoutineId) {
          setMessages(prev => [...prev, { role: 'assistant', content: 'Selecciona una rutina para poder mostrar el detalle.' }]);
          return;
        }
        params.routine_id = Number(selectedRoutineId);
      }

      if (requiresPlan(intent)) {
        await ensurePlanOptions(intent, selectedClientId);
        if (!selectedPlanId) {
          setMessages(prev => [...prev, { role: 'assistant', content: 'Selecciona un plan para poder mostrar los detalles.' }]);
          return;
        }
        params.plan_id = Number(selectedPlanId);
      }

      setMessages(prev => [...prev, { role: 'user', content: label }]);
      const { response, data } = await postMessage({ intent, message: label, params });

      if (response.ok) {
        const resolvedRole = normalizeRole(data?.role || currentRole);
        setCurrentRole(resolvedRole);
        setMessages(prev => [...prev, { role: 'assistant', content: data.reply }]);
        if (Array.isArray(data.buttons)) setButtons(filterButtonsByRole(data.buttons, resolvedRole));
        updateSelectorData(intent, data.data);
      } else {
        const errorMsg = data.message || data.error || JSON.stringify(data);
        setMessages(prev => [...prev, { role: 'assistant', content: `Error API (${response.status}): ${errorMsg}` }]);
      }
    } catch (error) {
      setMessages(prev => [...prev, { role: 'assistant', content: `Error local: ${error.message}` }]);
    } finally {
      setLoading(false);
    }
  };

  const sendMessage = async (e) => {
    e.preventDefault();
  };

  return (
    <>
      {/* Botón flotante */}
      <button
        onClick={() => setIsOpen(true)}
        className={`fixed bottom-6 right-6 w-14 h-14 bg-[#CCFF00] text-black rounded-full flex items-center justify-center shadow-[0_0_0_4px_rgba(204,255,0,0.15),0_4px_24px_rgba(204,255,0,0.4)] hover:scale-110 transition-all duration-200 z-[9990] ${isOpen ? 'scale-0 opacity-0 pointer-events-none' : 'scale-100 opacity-100'}`}
        aria-label="Abrir asistente"
      >
        <MessageCircle className="w-6 h-6" />
      </button>

      {/* Ventana de chat */}
      <div
        className={`fixed bottom-6 right-6 flex flex-col bg-[#141414] border border-[#222] rounded-2xl shadow-[0_24px_64px_rgba(0,0,0,0.75),0_0_0_1px_rgba(204,255,0,0.06)] overflow-hidden z-[9999] transition-all duration-300 origin-bottom-right w-[360px] sm:w-[400px] ${isOpen ? 'scale-100 opacity-100' : 'scale-0 opacity-0 pointer-events-none'}`}
        style={{ height: '520px' }}
      >
        {/* Header */}
        <div className="flex-shrink-0 bg-[#0A0A0A] border-b border-[#1e1e1e] px-4 py-3 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="relative">
              <div className="w-9 h-9 rounded-full bg-[#CCFF00]/10 border border-[#CCFF00]/25 flex items-center justify-center">
                <Bot className="w-4.5 h-4.5 text-[#CCFF00]" style={{ width: 18, height: 18 }} />
              </div>
              <span className="absolute -bottom-0.5 -right-0.5 w-2.5 h-2.5 bg-[#CCFF00] rounded-full border-2 border-[#0A0A0A]" />
            </div>
            <div>
              <h3 className="text-white font-semibold text-sm leading-tight">Asistente CloudFit</h3>
              <p className="text-[11px] text-[#CCFF00]/60 leading-tight mt-0.5">En línea · Consultas por rol</p>
            </div>
          </div>
          <button
            onClick={() => setIsOpen(false)}
            className="w-7 h-7 flex items-center justify-center rounded-lg text-[#555] hover:text-white hover:bg-[#1e1e1e] transition-all"
            aria-label="Cerrar"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Context selectors */}
        {(clientOptions.length > 0 || routineOptions.length > 0 || planOptions.length > 0) && (
          <div className="flex-shrink-0 px-3 py-2.5 bg-[#0e0e0e] border-b border-[#1e1e1e] space-y-1.5">
            {clientOptions.length > 0 && (
              <select
                value={selectedClientId}
                onChange={(e) => {
                  setSelectedClientId(e.target.value);
                  setSelectedRoutineId('');
                  setSelectedPlanId('');
                  setRoutineOptions([]);
                  setPlanOptions([]);
                }}
                className="w-full text-[11px] bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg px-3 py-2 text-gray-200 focus:outline-none focus:border-[#CCFF00]/40 transition-colors"
              >
                <option value="">Selecciona un cliente…</option>
                {clientOptions.map((opt) => (
                  <option key={opt.id} value={opt.id}>{opt.label}</option>
                ))}
              </select>
            )}
            {routineOptions.length > 0 && (
              <select
                value={selectedRoutineId}
                onChange={(e) => setSelectedRoutineId(e.target.value)}
                className="w-full text-[11px] bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg px-3 py-2 text-gray-200 focus:outline-none focus:border-[#CCFF00]/40 transition-colors"
              >
                <option value="">Selecciona una rutina…</option>
                {routineOptions.map((opt) => (
                  <option key={opt.id} value={opt.id}>{opt.label}</option>
                ))}
              </select>
            )}
            {planOptions.length > 0 && (
              <select
                value={selectedPlanId}
                onChange={(e) => setSelectedPlanId(e.target.value)}
                className="w-full text-[11px] bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg px-3 py-2 text-gray-200 focus:outline-none focus:border-[#CCFF00]/40 transition-colors"
              >
                <option value="">Selecciona un plan…</option>
                {planOptions.map((opt) => (
                  <option key={opt.id} value={opt.id}>{opt.label}</option>
                ))}
              </select>
            )}
          </div>
        )}

        {/* Messages */}
        <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4 min-h-0">
          {messages.map((msg, idx) => (
            <div key={idx} className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start items-start gap-2'}`}>
              {msg.role === 'assistant' && (
                <div className="w-6 h-6 rounded-full bg-[#CCFF00]/10 border border-[#CCFF00]/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <Bot style={{ width: 12, height: 12 }} className="text-[#CCFF00]" />
                </div>
              )}
              <div
                className={`max-w-[80%] rounded-2xl px-4 py-3 ${
                  msg.role === 'user'
                    ? 'bg-[#CCFF00] text-black rounded-br-sm font-semibold text-sm shadow-[0_2px_16px_rgba(204,255,0,0.2)]'
                    : 'bg-[#1e1e1e] text-gray-200 rounded-tl-sm border border-[#2a2a2a]'
                }`}
              >
                {msg.role === 'user'
                  ? <p className="text-sm leading-relaxed">{msg.content}</p>
                  : renderMessageContent(msg.content)}
              </div>
            </div>
          ))}

          {loading && (
            <div className="flex justify-start items-start gap-2">
              <div className="w-6 h-6 rounded-full bg-[#CCFF00]/10 border border-[#CCFF00]/20 flex items-center justify-center flex-shrink-0">
                <Bot style={{ width: 12, height: 12 }} className="text-[#CCFF00]" />
              </div>
              <div className="bg-[#1e1e1e] border border-[#2a2a2a] rounded-2xl rounded-tl-sm px-4 py-3.5 flex items-center gap-1.5">
                <span className="w-1.5 h-1.5 rounded-full bg-[#CCFF00]/70 animate-bounce" style={{ animationDelay: '0ms' }} />
                <span className="w-1.5 h-1.5 rounded-full bg-[#CCFF00]/70 animate-bounce" style={{ animationDelay: '150ms' }} />
                <span className="w-1.5 h-1.5 rounded-full bg-[#CCFF00]/70 animate-bounce" style={{ animationDelay: '300ms' }} />
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Footer */}
        <div className="flex-shrink-0 bg-[#0A0A0A] border-t border-[#1e1e1e]">
          {buttons.length > 0 && (
            <div className="px-3 pt-3 pb-2">
              <p className="text-[9px] uppercase tracking-[0.22em] text-[#3a3a3a] mb-2 px-0.5">Consultas disponibles</p>
              <div className="flex flex-wrap gap-1.5 max-h-[90px] overflow-y-auto pr-0.5">
                {buttons.map((btn) => (
                  <button
                    key={btn.intent}
                    type="button"
                    onClick={() => runIntent(btn.intent, btn.label)}
                    disabled={loading}
                    className="text-[11px] px-3 py-1.5 rounded-full bg-[#1a1a1a] border border-[#2a2a2a] text-gray-300 hover:bg-[#CCFF00] hover:text-black hover:border-[#CCFF00] transition-all duration-150 disabled:opacity-40 disabled:cursor-not-allowed whitespace-nowrap"
                  >
                    {btn.label}
                  </button>
                ))}
              </div>
            </div>
          )}
          <p className="text-center text-[10px] text-[#2e2e2e] py-2.5">CloudFit · Asistente con IA</p>
        </div>
      </div>
    </>
  );
}
