class ProfileModel {
  final String name;
  final String imageUrl;
  final int level;
  final int workoutsCompleted;
  final String memberSince;

  ProfileModel({
    required this.name,
    required this.imageUrl,
    required this.level,
    required this.workoutsCompleted,
    required this.memberSince,
  });
}