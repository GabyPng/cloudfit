const LOCAL_USER_STORAGE_KEY = 'cloudfit.local_user';

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

  const response = await fetch('/api/me', {
    method: 'GET',
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error(`No se pudo obtener /api/me (${response.status}).`);
  }

  const payload = await response.json();
  const localUser = payload?.local_user ?? null;

  try {
    localStorage.setItem(LOCAL_USER_STORAGE_KEY, JSON.stringify(localUser));
  } catch (_) {
    // Ignore storage errors to avoid breaking auth flow.
  }

  return localUser;
}