import 'package:flutter/material.dart';

import '../models/app_user.dart';

// หน้าผู้ใช้: แสดงชื่อ อีเมล และสิทธิ์ของบัญชีที่ล็อกอินอยู่
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});

  final AppUser user;

  String get _roleLabel =>
      user.isAdmin ? 'ผู้ดูแลระบบ (Admin)' : 'ผู้ปฏิบัติงาน (Operator)';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial =
        user.name.isEmpty ? '?' : String.fromCharCode(user.name.runes.first);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              initial.toUpperCase(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('ชื่อ'),
                subtitle: Text(user.name, style: _valueStyle),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('อีเมล'),
                subtitle: Text(user.email, style: _valueStyle),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  user.isAdmin ? Icons.admin_panel_settings : Icons.badge,
                ),
                title: const Text('สิทธิ์'),
                subtitle: Text(_roleLabel, style: _valueStyle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const TextStyle _valueStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
}
