import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Loader2 } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { getRoleHomePathFromSession } from '../lib/roleRouting';
import { syncLocalUserProfile } from '../lib/localUserSync';

export default function RoleRedirect() {
  const navigate = useNavigate();

  useEffect(() => {
    let active = true;

    supabase.auth.getSession().then(({ data: { session } }) => {
      if (!active) return;

      if (!session) {
        navigate('/login', { replace: true });
        return;
      }

      syncLocalUserProfile(session)
        .catch(() => null)
        .finally(() => {
          navigate(getRoleHomePathFromSession(session), { replace: true });
        });
    });

    return () => {
      active = false;
    };
  }, [navigate]);

  return (
    <div className="min-h-screen bg-[#0D0D0D] flex items-center justify-center">
      <Loader2 className="w-10 h-10 text-[#CCFF00] animate-spin" />
    </div>
  );
}