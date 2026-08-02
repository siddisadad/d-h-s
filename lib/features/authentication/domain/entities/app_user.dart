class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String role; // Admin, Manager, Employee

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      role: json['role'] ?? 'Employee',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role,
    };
  }
}
