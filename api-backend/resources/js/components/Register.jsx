import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { Mail, Lock, User, Loader2 } from 'lucide-react';

export default function Register() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(null);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleRegister = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setMessage(null);

    // 1. Crear en Supabase Auth
    const { data, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          nombre: name,
          role: 'cliente'
        }
      }
    });

    if (authError) {
      setError(authError.message);
      setLoading(false);
      return;
    }

    if (data.session) {
      // 2. Sincronizar en base de datos local de Laravel
      try {
        const response = await fetch('/api/sync', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${data.session.access_token}`
          },
          body: JSON.stringify({ name, role: 'cliente' })
        });
        
        if (!response.ok) {
            console.error('Error sincronizando la DB', await response.text());
        }
      } catch (err) {
        console.error('Fetch error:', err);
      }
      
      navigate('/');
    } else {
      setMessage('Registro exitoso. Revisa tu correo electrónico para verificar la cuenta si es necesario, y luego inicia sesión.');
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#0D0D0D] text-white overflow-hidden relative font-sans p-4">
      {/* Background blobs for aesthetics */}
      <div className="absolute top-[-10%] left-[-10%] w-96 h-96 bg-[#CCFF00] rounded-full mix-blend-multiply filter blur-[128px] opacity-20 pointer-events-none"></div>
      <div className="absolute bottom-[-10%] right-[-10%] w-96 h-96 bg-blue-600 rounded-full mix-blend-multiply filter blur-[128px] opacity-20 pointer-events-none"></div>

      <div className="w-full max-w-md p-8 bg-[#1A1A1A]/80 backdrop-blur-xl rounded-3xl border border-[#2A2A2A] shadow-2xl z-10">
        <div className="text-center mb-10">
          <h1 className="text-4xl font-black italic text-[#CCFF00] tracking-tighter mb-2">CLOUDFIT</h1>
          <p className="text-gray-400 text-sm font-medium">Crear nueva cuenta</p>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-500/10 border border-red-500/50 rounded-xl text-red-500 text-sm font-medium">
            {error}
          </div>
        )}

        {message && (
          <div className="mb-6 p-4 bg-green-500/10 border border-green-500/50 rounded-xl text-green-400 text-sm font-medium">
            {message}
          </div>
        )}

        <form onSubmit={handleRegister} className="space-y-6">
          <div className="space-y-2">
            <label className="text-xs font-semibold text-gray-400 uppercase tracking-widest">Nombre completo</label>
            <div className="relative group">
              <User className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500 w-5 h-5 group-focus-within:text-[#CCFF00] transition-colors" />
              <input 
                type="text" 
                value={name}
                onChange={e => setName(e.target.value)}
                className="w-full bg-[#0D0D0D] border border-[#2A2A2A] rounded-xl py-3.5 pl-12 pr-4 focus:outline-none focus:border-[#CCFF00] transition-all text-white placeholder-gray-600"
                placeholder="Juan Pérez"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-semibold text-gray-400 uppercase tracking-widest">Correo Electrónico</label>
            <div className="relative group">
              <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500 w-5 h-5 group-focus-within:text-[#CCFF00] transition-colors" />
              <input 
                type="email" 
                value={email}
                onChange={e => setEmail(e.target.value)}
                className="w-full bg-[#0D0D0D] border border-[#2A2A2A] rounded-xl py-3.5 pl-12 pr-4 focus:outline-none focus:border-[#CCFF00] transition-all text-white placeholder-gray-600"
                placeholder="ejemplo@correo.com"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-semibold text-gray-400 uppercase tracking-widest">Contraseña</label>
            <div className="relative group">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500 w-5 h-5 group-focus-within:text-[#CCFF00] transition-colors" />
              <input 
                type="password" 
                value={password}
                onChange={e => setPassword(e.target.value)}
                className="w-full bg-[#0D0D0D] border border-[#2A2A2A] rounded-xl py-3.5 pl-12 pr-4 focus:outline-none focus:border-[#CCFF00] transition-all text-white placeholder-gray-600"
                placeholder="••••••••"
                required
                minLength={6}
              />
            </div>
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="w-full bg-[#CCFF00] text-black font-black py-4 rounded-xl hover:bg-[#bbf000] focus:ring-4 focus:ring-[#CCFF00]/30 transition-all flex items-center justify-center disabled:opacity-70 mt-2"
          >
            {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : 'REGISTRARSE'}
          </button>
        </form>

        <div className="mt-6 text-center">
            <Link to="/login" className="text-sm text-gray-400 hover:text-white transition-colors">
                ¿Ya tienes una cuenta? <span className="text-[#CCFF00] font-semibold underline decoration-[#CCFF00]/50 underline-offset-4">Inicia sesión</span>
            </Link>
        </div>
      </div>
    </div>
  );
}
