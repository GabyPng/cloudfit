import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { LogOut, Activity, Users, Utensils, MessageSquare, Loader2 } from 'lucide-react';
import Chatbot from './Chatbot';

export default function Dashboard() {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (!session) {
        navigate('/login');
      } else {
        setSession(session);
        setLoading(false);
      }
    });

    const { data: authListener } = supabase.auth.onAuthStateChange((event, session) => {
      if (!session) navigate('/login');
      else setSession(session);
    });

    return () => authListener.subscription.unsubscribe();
  }, [navigate]);

  const handleLogout = async () => {
    await supabase.auth.signOut();
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#0D0D0D] flex items-center justify-center">
        <Loader2 className="w-10 h-10 text-[#CCFF00] animate-spin" />
      </div>
    );
  }

  const userEmail = session?.user?.email || 'Usuario';
  const role = session?.user?.user_metadata?.role || session?.user?.app_metadata?.role || 'Administrador';

  return (
    <div className="min-h-screen bg-[#0D0D0D] text-white font-sans selection:bg-[#CCFF00] selection:text-black">
      {/* Navbar */}
      <nav className="border-b border-[#2A2A2A] bg-[#1A1A1A]/80 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-20 items-center">
            <div className="flex items-center gap-2 cursor-pointer transition-transform hover:scale-105" onClick={() => navigate('/')}>
              <div className="w-8 h-8 rounded-full bg-[#CCFF00] flex items-center justify-center font-black text-black">
                C
              </div>
              <span className="text-2xl font-black italic text-white tracking-tighter">CLOUDFIT</span>
            </div>
            
            <div className="flex items-center gap-6">
              <div className="text-right hidden sm:block">
                <p className="text-sm font-bold text-white">{userEmail}</p>
                <p className="text-xs text-[#CCFF00] font-medium tracking-wider uppercase">{role}</p>
              </div>
              <button 
                onClick={handleLogout}
                className="p-2.5 rounded-xl bg-red-500/10 text-red-500 hover:bg-red-500 hover:text-white transition-colors border border-red-500/20"
                title="Cerrar sesión"
              >
                <LogOut className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        {/* Welcome Section */}
        <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-[#1A1A1A] to-[#0D0D0D] border border-[#2A2A2A] p-8 sm:p-12 mb-10 shadow-2xl group">
          <div className="absolute top-0 right-0 w-64 h-64 bg-[#CCFF00] rounded-full mix-blend-multiply filter blur-3xl opacity-5 group-hover:opacity-10 transition-opacity duration-700"></div>
          
          <div className="relative z-10 flex flex-col sm:flex-row items-center gap-8">
            <div className="w-24 h-24 rounded-full bg-[#CCFF00] flex items-center justify-center text-5xl flex-shrink-0 shadow-[0_0_30px_rgba(204,255,0,0.3)]">
              👋
            </div>
            <div className="text-center sm:text-left">
              <h1 className="text-4xl sm:text-5xl font-black mb-3 text-white tracking-tight">
                Bienvenido, <span className="text-[#CCFF00]">CloudFit</span>
              </h1>
              <p className="text-xl text-gray-400 font-medium">Panel de control de {role.toLowerCase()}.</p>
            </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatCard icon={<Activity />} title="Entrenamiento" value="Ver planes" color="text-[#CCFF00]" bg="bg-[#CCFF00]/10" />
            <StatCard icon={<Utensils />} title="Nutrición" value="Dietas" color="text-green-500" bg="bg-green-500/10" />
            <StatCard icon={<Users />} title="Clientes" value="Métricas" color="text-blue-500" bg="bg-blue-500/10" />
            <StatCard icon={<MessageSquare />} title="Soporte" value="Tickets" color="text-purple-500" bg="bg-purple-500/10" />
        </div>
      </main>

      {/* Floating Chatbot Widget */}
      <Chatbot />
    </div>
  );
}

function StatCard({ icon, title, value, color, bg }) {
  return (
    <div className="bg-[#1A1A1A] border border-[#2A2A2A] rounded-3xl p-6 hover:shadow-2xl hover:border-gray-700 hover:-translate-y-1 transition-all duration-300 cursor-pointer group">
      <div className={`w-14 h-14 rounded-2xl ${bg} ${color} flex items-center justify-center mb-6 shrink-0 group-hover:scale-110 transition-transform`}>
        {React.cloneElement(icon, { className: 'w-7 h-7' })}
      </div>
      <h3 className="text-gray-400 font-medium tracking-wide uppercase text-sm mb-1">{title}</h3>
      <p className="text-2xl font-bold text-white">{value}</p>
    </div>
  );
}
