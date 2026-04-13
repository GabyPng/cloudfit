import React from 'react';
import { useNavigate } from 'react-router-dom';
import { LogOut } from 'lucide-react';
import { supabase } from '../lib/supabase';
import Chatbot from '../components/Chatbot';

export default function RoleIndexLayout({ title, subtitle, accentClass = 'text-[#CCFF00]' }) {
  const navigate = useNavigate();

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/login', { replace: true });
  };

  return (
    <div className="min-h-screen bg-[#0D0D0D] text-white">
      <header className="border-b border-[#2A2A2A] bg-[#141414]">
        <div className="mx-auto max-w-6xl px-6 py-5 flex items-center justify-between">
          <div>
            <p className="text-xs uppercase tracking-[0.2em] text-gray-500">CloudFit</p>
            <h1 className={`text-2xl font-black italic ${accentClass}`}>{title}</h1>
          </div>
          <button
            onClick={handleLogout}
            className="inline-flex items-center gap-2 rounded-lg border border-red-500/30 bg-red-500/10 px-4 py-2 text-sm font-semibold text-red-400 hover:bg-red-500/20"
          >
            <LogOut className="h-4 w-4" />
            Cerrar sesion
          </button>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-6 py-10">
        <div className="rounded-2xl border border-[#2A2A2A] bg-[#151515] p-8">
          <p className="text-lg text-gray-300 leading-relaxed">{subtitle}</p>
        </div>
      </main>

      <Chatbot />
    </div>
  );
}