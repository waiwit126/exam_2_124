// ผู้ใช้ระบบ เก็บใน collection `users` (uid, name, email, role)
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' หรือ 'operator'

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) {
    return AppUser(
      uid: uid,
      name: (m['name'] ?? '') as String,
      email: (m['email'] ?? '') as String,
      role: ((m['role'] ?? 'operator') as String).trim().toLowerCase(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
      };
}
