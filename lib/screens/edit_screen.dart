import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/charger.dart';
import 'charger_form.dart';

// หน้าแก้ไขหัวจ่าย (เฉพาะ Admin) แก้ไขข้อมูลหัวจ่าย
class EditScreen extends StatelessWidget {
  const EditScreen({super.key, required this.user, required this.charger});

  final AppUser user;
  final Charger charger;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('แก้ไข ${charger.chargerId}')),
      body: ChargerForm(
        user: user,
        docId: charger.docId,
        charger: charger,
        onSaved: () => Navigator.pop(context),
      ),
    );
  }
}
