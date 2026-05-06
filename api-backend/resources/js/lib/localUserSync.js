const LOCAL_USER_STORAGE_KEY = 'cloudfit.local_user';

function normalizeRole(rawRole) {
  if (!rawRole) return 'cliente';

  const normalized = String(rawRole)
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');

  if (normalized === 'admin' || normalized === 'administrador') return 'admin';
  if (normalized === 'coach') return 'coach';
  if (normalized === 'nutriologo') return 'nutriologo';
  return 'cliente';
}

function buildSyncPayloadFromSession(session) {
  const metadata = session?.user?.user_metadata || {};
  const profile = metadata?.profile || {};
  const role = normalizeRole(metadata?.role || session?.user?.app_metadata?.role);

  return {
    name:
      metadata?.full_name ||
      metadata?.name ||
      metadata?.nombre ||
      session?.user?.email?.split('@')[0] ||
      'Usuario',
    role,
    avatar_url: metadata?.avatar_url || null,
    objective: metadata?.objective || null,
    profile: role === 'nutriologo'
      ? {
        ...profile,
        licenseNumber: profile?.licenseNumber || profile?.license_number || 'PENDIENTE',
        focus: profile?.focus || 'General',
      }
      : profile,
  };
}

export function getCachedLocalUser() {
  try {
    const raw = localStorage.getItem(LOCAL_USER_STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch (_) {
    return null;
  }
}

export function clearCachedLocalUser() {
  try {
    localStorage.removeItem(LOCAL_USER_STORAGE_KEY);
  } catch (_) {
    // Ignore storage errors to avoid breaking auth flow.
  }
}

export async function syncLocalUserProfile(session) {
  const token = session?.access_token;
  if (!token) return null;

  const headers = {
    Accept: 'application/json',
    Authorization: `Bearer ${token}`,
  };

  const response = await fetch('/api/me', {
    method: 'GET',
    headers,
  });

  if (!response.ok) {
    throw new Error(`No se pudo obtener /api/me (${response.status}).`);
  }

  const payload = await response.json();
  let localUser = payload?.local_user ?? null;
  const role = normalizeRole(session?.user?.user_metadata?.role || session?.user?.app_metadata?.role);
  const needsSync = !localUser || (role === 'nutriologo' && !localUser?.nutriologo_profile);

  if (needsSync) {
    const syncResponse = await fetch('/api/sync', {
      method: 'POST',
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(buildSyncPayloadFromSession(session)),
    });

    if (!syncResponse.ok) {
      throw new Error(`No se pudo sincronizar el usuario local (${syncResponse.status}).`);
    }

    const syncPayload = await syncResponse.json();
    localUser = syncPayload?.user ?? localUser;
  }

  try {
    localStorage.setItem(LOCAL_USER_STORAGE_KEY, JSON.stringify(localUser));
  } catch (_) {
    // Ignore storage errors to avoid breaking auth flow.
  }

  return localUser;
}