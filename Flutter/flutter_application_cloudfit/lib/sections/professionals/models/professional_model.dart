class ProfessionalModel {
  final int userId;
  final String name;
  final String specialty;
  final String rating;
  final bool isOnline;
  final String? avatarUrl;
  final int roleId;
  final String? objective;
  // Campos extra de nutriologos
  final String? licenseNumber;
  final String? focus;
  final dynamic certificateUploads;

  ProfessionalModel({
    required this.userId,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.isOnline,
    this.avatarUrl,
    required this.roleId,
    this.objective,
    this.licenseNumber,
    this.focus,
    this.certificateUploads,
  });

  factory ProfessionalModel.fromMap(Map<String, dynamic> map) {
    final roleId = map['role_id'] as int;
    final specialty = roleId == 2 ? 'Coach' : 'Nutriólogo';

    final nutriData = map['nutriologos'] as Map<String, dynamic>?;

    return ProfessionalModel(
      userId: map['user_id'] as int,
      name: map['name'] ?? 'Sin nombre',
      specialty: specialty,
      rating: '4.8',
      isOnline: false,
      avatarUrl: map['avatar_url'],
      roleId: roleId,
      objective: map['objective'],
      licenseNumber: nutriData?['license_number'],
      focus: nutriData?['focus'],
      certificateUploads: nutriData?['certificate_uploads'],
    );
  }
}