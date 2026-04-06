export function normalizeRole(rawRole) {
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

export function getRoleHomePathFromRole(role) {
  const normalizedRole = normalizeRole(role);
  return {
    admin: '/admin',
    coach: '/coach',
    nutriologo: '/nutriologo',
    cliente: '/cliente',
  }[normalizedRole];
}

export function getRoleHomePathFromSession(session) {
  const role = session?.user?.user_metadata?.role
    || session?.user?.app_metadata?.role
    || 'cliente';

  return getRoleHomePathFromRole(role);
}

export function getNormalizedRoleFromSession(session) {
  const role = session?.user?.user_metadata?.role
    || session?.user?.app_metadata?.role
    || 'cliente';

  return normalizeRole(role);
}