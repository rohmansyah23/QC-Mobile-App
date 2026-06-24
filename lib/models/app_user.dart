class AppUser {
  final String id;
  final String fullName;
  final String? email;

  AppUser({required this.id, required this.fullName, this.email});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
    );
  }
}