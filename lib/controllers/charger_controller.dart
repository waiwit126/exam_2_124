import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/charger.dart';

class ChargerController {
  ChargerController._();

  static final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('chargers');

  // Read (เรียลไทม์)
  static Stream<QuerySnapshot<Map<String, dynamic>>> stream() =>
      _col.snapshots();

  // Create: ทั้ง Admin และ Operator ทำได้
  static Future<void> add(Charger c, AppUser by) {
    return _col.add({
      ...c.toMap(),
      'createdBy': by.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update / Delete: เฉพาะ Admin (ตรวจซ้ำที่ชั้น controller นอกเหนือจากการซ่อนปุ่ม)
  static Future<void> update(String docId, Charger c, AppUser by) {
    _requireAdmin(by);
    return _col.doc(docId).update({
      ...c.toMap(),
      'updatedBy': by.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> delete(String docId, AppUser by) {
    _requireAdmin(by);
    return _col.doc(docId).delete();
  }

  static void _requireAdmin(AppUser by) {
    if (!by.isAdmin) {
      throw Exception('สิทธิ์ไม่เพียงพอ: เฉพาะ Admin เท่านั้น');
    }
  }
}
