import { useEffect, useState } from 'react';
import { supabase } from '../../lib/supabase';
import NutriologoLayout from './NutriologoLayout';
import Dashboard from './Dashboard';

export default function NutriologoIndexPage() {
  const [nutriologoName, setNutriologoName] = useState('Nutriólogo');

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      const name =
        session?.user?.user_metadata?.full_name ||
        session?.user?.user_metadata?.name ||
        session?.user?.email?.split('@')[0] ||
        'Nutriólogo';
      setNutriologoName(name);
    });
  }, []);

  return (
    <NutriologoLayout nutriologoName={nutriologoName}>
      <Dashboard />
    </NutriologoLayout>
  );
}
