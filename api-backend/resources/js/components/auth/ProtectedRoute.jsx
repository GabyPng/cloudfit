import React, { useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { Loader2 } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { getNormalizedRoleFromSession, getRoleHomePathFromSession } from '../../lib/roleRouting';

export default function ProtectedRoute({ children, allowedRoles = [] }) {
  const [loading, setLoading] = useState(true);
  const [session, setSession] = useState(null);

  useEffect(() => {
    let active = true;

    supabase.auth.getSession().then(({ data: { session: nextSession } }) => {
      if (!active) return;
      setSession(nextSession);
      setLoading(false);
    });

    const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      if (!active) return;
      setSession(nextSession);
      setLoading(false);
    });

    return () => {
      active = false;
      listener.subscription.unsubscribe();
    };
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-[#0D0D0D] flex items-center justify-center">
        <Loader2 className="w-10 h-10 text-[#CCFF00] animate-spin" />
      </div>
    );
  }

  if (!session) return <Navigate to="/login" replace />;

  if (allowedRoles.length > 0) {
    const currentRole = getNormalizedRoleFromSession(session);
    if (!allowedRoles.includes(currentRole)) {
      return <Navigate to={getRoleHomePathFromSession(session)} replace />;
    }
  }

  return children;
}