import React, { useState, useRef, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { MessageCircle, X, Send, Loader2, Bot } from 'lucide-react';

export default function Chatbot() {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState([
    { role: 'assistant', content: '¡Hola! Soy el asistente virtual de CloudFit impulsado por IA. ¿En qué te puedo ayudar hoy?' }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const sendMessage = async (e) => {
    e.preventDefault();
    if (!input.trim() || loading) return;

    const userMessage = input.trim();
    setInput('');
    setMessages(prev => [...prev, { role: 'user', content: userMessage }]);
    setLoading(true);

    try {
      const { data: { session } } = await supabase.auth.getSession();
      console.log('Token:', session?.access_token); // ¿Es null o undefined?
      const response = await fetch('/api/chatbot/message', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${session?.access_token}`,
        },
        body: JSON.stringify({ message: userMessage })
      });

      const data = await response.json();

      if (response.ok) {
        setMessages(prev => [...prev, { role: 'assistant', content: data.reply }]);
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
