import { useEffect, useState } from 'react';
import { supabase } from '../../lib/supabase';
import CoachLayout from './CoachLayout';
import Dashboard from './Dashboard';

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
      <Dashboard />
    </CoachLayout>
  );
}
