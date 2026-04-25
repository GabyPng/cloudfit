import { useNavigate, useLocation } from 'react-router-dom';
import { supabase } from '../../lib/supabase';
import Chatbot from '../../components/Chatbot';
import {
  LayoutDashboard,
  Users,
  Dumbbell,
  TrendingUp,
  User,
  LogOut,
} from 'lucide-react';

const navItems = [
  { icon: LayoutDashboard, label: 'Inicio', path: '/coach' },
  { icon: Users, label: 'Mis Clientes', path: '/coach/clientes' },
  { icon: Dumbbell, label: 'Rutinas', path: '/coach/rutinas' },
  { icon: TrendingUp, label: 'Progreso Físico', path: '/coach/progreso' },
  { icon: User, label: 'Mi Perfil', path: '/coach/perfil' },
];

export default function CoachLayout({ children, coachName = 'Coach', coachRole = 'Senior Coach' }) {
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/login', { replace: true });
  };

  return (
    <div className="min-h-screen bg-[#0e0e0e] text-white overflow-hidden">
      {/* Sidebar */}
      <aside className="fixed left-0 top-0 flex flex-col h-screen w-64 bg-[#0e0e0e] z-50 font-headline tracking-tight">
        <div className="p-8">
          <h1 className="text-2xl font-black text-[#f3ffca] tracking-tighter uppercase font-headline">CloudFit</h1>
          <p className="text-xs text-[#adaaaa] mt-1 opacity-60">Coach Dashboard</p>
        </div>

        <nav className="flex-1 px-4 space-y-2">
          {navItems.map((item) => {
            const active =
              item.path === '/coach'
                ? location.pathname === '/coach'
                : location.pathname.startsWith(item.path);
            const Icon = item.icon;
            return (
              <button
                key={item.path}
                onClick={() => navigate(item.path)}
                className={`flex items-center gap-4 px-4 py-3 w-full text-left transition-colors ${
                  active
                    ? 'text-[#f3ffca] font-bold border-r-4 border-[#f3ffca] bg-[#1a1a1a]'
                    : 'text-[#a1a1a1] hover:bg-[#1a1a1a] hover:text-[#f3ffca]'
                }`}
              >
                <Icon size={20} />
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>

        {/* Coach profile footer */}
        <div className="p-6 mt-auto bg-[#131313] flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-[#cafd00] flex items-center justify-center text-[#0e0e0e] font-bold text-sm">
            {coachName.charAt(0).toUpperCase()}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-bold text-white truncate">{coachName}</p>
            <p className="text-[10px] uppercase tracking-widest text-[#f3ffca]">{coachRole}</p>
          </div>
          <button onClick={handleLogout} className="text-[#a1a1a1] hover:text-red-400 transition-colors" title="Cerrar sesión">
            <LogOut size={16} />
          </button>
        </div>
      </aside>

      {/* Top Header */}
<<<<<<< Updated upstream
      <header className="fixed top-0 right-0 left-64 flex justify-between items-center px-8 h-20 z-40 bg-[#0e0e0e]/80 backdrop-blur-xl border-b border-[#cafd00]/15 shadow-2xl shadow-black/50">
        <div className="flex items-center gap-6">
          <div className="relative">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#adaaaa]" />
            <input
              type="text"
              placeholder="Buscar cliente..."
              className="bg-[#131313] border-none rounded-lg pl-10 pr-4 py-2 text-sm text-white placeholder-[#adaaaa] focus:outline-none focus:ring-1 focus:ring-[#f3ffca] w-64 transition-all"
            />
          </div>
        </div>
        <div className="flex items-center gap-6">

          <div className="relative">
            <Bell size={20} className="text-[#adaaaa] hover:text-[#f3ffca] cursor-pointer transition-colors" />
            <span className="absolute -top-1 -right-1 w-2 h-2 bg-[#ff7351] rounded-full"></span>
          </div>
        </div>
      </header>
=======
      <header className="fixed top-0 right-0 left-64 flex items-center px-8 h-20 z-40 bg-[#0e0e0e]/80 backdrop-blur-xl border-b border-[#cafd00]/15 shadow-2xl shadow-black/50" />
>>>>>>> Stashed changes

      {/* Main Canvas */}
      <main className="ml-64 pt-24 p-8 min-h-screen bg-[#0e0e0e]">
        {children}
      </main>

      <Chatbot />
    </div>
  );
}
