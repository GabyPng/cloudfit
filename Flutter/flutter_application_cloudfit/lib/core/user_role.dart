enum UserRole { admin, coach, nutriologo, cliente }

UserRole parseUserRole(String? rawRole) {
  if (rawRole == null || rawRole.isEmpty) {
    return UserRole.cliente;
  }

  final normalized = rawRole
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  if (normalized == 'admin' || normalized == 'administrador') {
    return UserRole.admin;
  }

  if (normalized == 'coach') {
    return UserRole.coach;
  }

  if (normalized == 'nutriologo') {
    return UserRole.nutriologo;
  }

  return UserRole.cliente;
}

String roleHomeRoute(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.coach:
      return '/coach';
    case UserRole.nutriologo:
      return '/nutriologo';
    case UserRole.cliente:
      return '/cliente';
  }
}
