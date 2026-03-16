class UserProfileModel {
  final String name;
  final String email;
  final String level;
  final int totalXP;
  final String memberSince;

  UserProfileModel({
    required this.name, 
    required this.email, 
    required this.level, 
    required this.totalXP, 
    required this.memberSince
  });
}