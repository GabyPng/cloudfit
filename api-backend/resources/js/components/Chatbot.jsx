import React, { useState, useRef, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { MessageCircle, X, Send, Loader2, Bot } from 'lucide-react';

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
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
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
      const token = await getToken();
      if (!token) return;

      const response = await fetch('/api/chatbot/buttons', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json',
        },
      });

      if (!response.ok) return;
      const data = await response.json();
      setButtons(Array.isArray(data.buttons) ? data.buttons : []);
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
        setMessages(prev => [...prev, { role: 'assistant', content: data.reply }]);
        if (Array.isArray(data.buttons)) setButtons(data.buttons);
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
    if (!input.trim() || loading) return;

    const userMessage = input.trim();
    setInput('');
    setMessages(prev => [...prev, { role: 'user', content: userMessage }]);
    setLoading(true);

    try {
      const { response, data } = await postMessage({ message: userMessage });

      if (response.ok) {
        setMessages(prev => [...prev, { role: 'assistant', content: data.reply }]);
        if (Array.isArray(data.buttons)) setButtons(data.buttons);
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

  return (
    <>
      {/* Botón Flotante */}
      <button
        onClick={() => setIsOpen(true)}
        className={`fixed bottom-6 right-6 w-14 h-14 bg-[#CCFF00] text-black rounded-full flex items-center justify-center shadow-[0_0_20px_rgba(204,255,0,0.3)] hover:scale-110 transition-transform z-40 ${isOpen ? 'scale-0' : 'scale-100'}`}
      >
        <MessageCircle className="w-6 h-6" />
      </button>

      {/* Ventana de Chat */}
      <div className={`fixed bottom-6 right-6 w-[350px] sm:w-[380px] h-[500px] bg-[#1A1A1A] border border-[#2A2A2A] rounded-2xl shadow-2xl flex flex-col overflow-hidden z-50 transition-all duration-300 origin-bottom-right ${isOpen ? 'scale-100 opacity-100' : 'scale-0 opacity-0 pointer-events-none'}`}>

        {/* Header */}
        <div className="bg-[#0D0D0D] p-4 flex items-center justify-between border-b border-[#2A2A2A]">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-[#CCFF00]/10 flex items-center justify-center text-[#CCFF00] border border-[#CCFF00]/20">
              <Bot className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-white font-bold text-sm tracking-wide">Asistente CloudFit</h3>
              <div className="flex items-center gap-1.5 mt-0.5">
                <span className="w-2 h-2 rounded-full bg-[#CCFF00] animate-pulse"></span>
                <p className="text-xs text-gray-400 font-medium">En línea (Gemini AI)</p>
              </div>
            </div>
          </div>
          <button
            onClick={() => setIsOpen(false)}
            className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-[#2A2A2A] text-gray-400 hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Context selectors */}
        {(clientOptions.length > 0 || routineOptions.length > 0 || planOptions.length > 0) && (
          <div className="px-3 py-2 bg-[#111] border-b border-[#2A2A2A] space-y-2">
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
                className="w-full text-xs bg-[#1A1A1A] border border-[#2A2A2A] rounded-lg px-2 py-2 text-gray-200"
              >
                <option value="">Selecciona cliente...</option>
                {clientOptions.map((opt) => (
                  <option key={opt.id} value={opt.id}>{opt.label}</option>
                ))}
              </select>
            )}

            {routineOptions.length > 0 && (
              <select
                value={selectedRoutineId}
                onChange={(e) => setSelectedRoutineId(e.target.value)}
                className="w-full text-xs bg-[#1A1A1A] border border-[#2A2A2A] rounded-lg px-2 py-2 text-gray-200"
              >
                <option value="">Selecciona rutina...</option>
                {routineOptions.map((opt) => (
                  <option key={opt.id} value={opt.id}>{opt.label}</option>
                ))}
              </select>
            )}

            {planOptions.length > 0 && (
              <select
                value={selectedPlanId}
                onChange={(e) => setSelectedPlanId(e.target.value)}
                className="w-full text-xs bg-[#1A1A1A] border border-[#2A2A2A] rounded-lg px-2 py-2 text-gray-200"
              >
                <option value="">Selecciona plan...</option>
                {planOptions.map((opt) => (
                  <option key={opt.id} value={opt.id}>{opt.label}</option>
                ))}
              </select>
            )}
          </div>
        )}

        {/* Intent buttons */}
        {buttons.length > 0 && (
          <div className="px-3 py-2 bg-[#101010] border-b border-[#2A2A2A] flex flex-wrap gap-2 max-h-[110px] overflow-y-auto">
            {buttons.map((btn) => (
              <button
                key={btn.intent}
                type="button"
                onClick={() => runIntent(btn.intent, btn.label)}
                disabled={loading}
                className="text-xs px-2.5 py-1.5 rounded-full border border-[#333] bg-[#1A1A1A] text-gray-200 hover:bg-[#242424] disabled:opacity-50"
              >
                {btn.label}
              </button>
            ))}
          </div>
        )}

        {/* Mensajes */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gradient-to-b from-[#1A1A1A] to-[#0D0D0D] custom-scrollbar">
          {messages.map((msg, idx) => (
            <div key={idx} className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}>
              <div
                className={`max-w-[85%] rounded-2xl px-4 py-2.5 text-sm leading-relaxed shadow-sm ${msg.role === 'user'
                    ? 'bg-[#CCFF00] text-black rounded-br-sm font-medium'
                    : 'bg-[#2A2A2A] text-gray-200 rounded-bl-sm border border-[#333]'
                  }`}
                style={{ whiteSpace: 'pre-wrap' }}
              >
                {msg.content}
              </div>
            </div>
          ))}
          {loading && (
            <div className="flex justify-start">
              <div className="max-w-[80%] bg-[#2A2A2A] rounded-2xl rounded-bl-sm px-4 py-3 border border-[#333] flex items-center gap-2">
                <Loader2 className="w-4 h-4 text-[#CCFF00] animate-spin" />
                <span className="text-xs text-gray-400 font-medium">El asistente está analizando...</span>
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Input */}
        <div className="p-3 bg-[#0D0D0D] border-t border-[#2A2A2A]">
          <form onSubmit={sendMessage} className="relative flex items-center rounded-xl bg-[#1A1A1A] border border-[#2A2A2A] focus-within:border-[#CCFF00] transition-colors overflow-hidden">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Pregúntame algo..."
              className="w-full bg-transparent text-white text-sm pl-4 pr-12 py-3.5 focus:outline-none placeholder-gray-500"
            />
            <button
              type="submit"
              disabled={!input.trim() || loading}
              className="absolute right-2 w-9 h-9 flex items-center justify-center bg-[#CCFF00] text-black rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-[#bbf000] focus:scale-95 transition-all"
            >
              <Send className="w-4 h-4 ml-0.5" />
            </button>
          </form>
        </div>
      </div>

    </>
  );
}
