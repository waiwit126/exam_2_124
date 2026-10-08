import 'package:flutter/material.dart';

import '../models/app_user.dart';
import 'charger_form.dart';

// แท็บที่ 1: ฟอร์มลงทะเบียนหัวชาร์จใหม่ (Create)
class FormScreen extends StatelessWidget {
  const FormScreen({super.key, required this.user, this.onSaved});

  final AppUser user;
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    return ChargerForm(user: user, onSaved: onSaved);
  }
}
