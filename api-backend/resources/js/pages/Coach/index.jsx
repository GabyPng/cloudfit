import { useEffect, useState } from 'react';
import { Routes, Route } from 'react-router-dom';
import { supabase } from '../../lib/supabase';
import CoachLayout from './CoachLayout';
import Dashboard from './Dashboard';
import Rutinas from './Rutinas';
import MisClientes from './MisClientes';
import Progreso from './Progreso';

export default function CoachIndexPage() {
  const [coachName, setCoachName] = useState('Coach');

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      const name =
        session?.user?.user_metadata?.full_name ||
        session?.user?.user_metadata?.name ||
        session?.user?.email?.split('@')[0] ||
        'Coach';
      setCoachName(name);
    });
  }, []);

  return (
    <CoachLayout coachName={coachName}>
      <Routes>
        <Route index element={<Dashboard />} />
        <Route path="clientes" element={<MisClientes />} />
        <Route path="rutinas" element={<Rutinas />} />
        <Route path="progreso" element={<Progreso />} />
      </Routes>
    </CoachLayout>
  );
}
