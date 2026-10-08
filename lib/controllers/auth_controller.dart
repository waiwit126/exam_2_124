import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthController {
  AuthController._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// กำหนดเฉพาะ "ไอดีแอดมิน" ที่นี่ที่เดียว (อีเมลจริงที่ใช้สมัคร เขียนเป็นตัวพิมพ์เล็ก)
  /// ใครสมัครด้วยอีเมลนี้จะได้ role = admin
  /// ผู้ใช้อื่นทุกคนที่สมัครด้วยอีเมลจริงจะได้ role = operator อัตโนมัติ
  static const Set<String> adminEmails = {'admin@gmail.com'};

  // ชื่อที่กรอกตอนสมัคร ส่งต่อให้ loadProfile ใช้สร้างเอกสารใน users
  // (authStateChanges ทำงานทันทีหลังสมัคร จึงต้องเก็บชื่อไว้ก่อนเรียก createUser)
  static String? _pendingName;

  static bool isAdminEmail(String email) {
    final e = email.trim().toLowerCase();
    return adminEmails.any((a) => a.toLowerCase() == e);
  }

  static Stream<User?> get authChanges => _auth.authStateChanges();

  static Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final displayName = name.trim();
    _pendingName = displayName;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(displayName);
    } catch (_) {
      _pendingName = null;
      rethrow;
    }
  }

  static Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  static Future<void> signOut() => _auth.signOut();

  // อ่าน role จาก users/{uid}; ถ้ายังไม่มี (สมัครใหม่) จะสร้างให้
  // อีเมลที่อยู่ใน adminEmails = admin, อื่นๆ = operator
  static Future<AppUser> loadProfile(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    final data = snap.data();
    final email = user.email ?? '';
    final shouldBeAdmin = isAdminEmail(email);

    if (snap.exists && data != null) {
      var profile = AppUser.fromMap(user.uid, data);
      if (shouldBeAdmin && !profile.isAdmin) {
        await ref.update({'role': 'admin'});
        profile = AppUser(
          uid: profile.uid,
          name: profile.name,
          email: profile.email,
          role: 'admin',
        );
      }
      return profile;
    }

    final shown = user.displayName?.trim() ?? '';
    final name = _pendingName ??
        (shown.isNotEmpty ? shown : email.split('@').first);
    _pendingName = null;
    final profile = AppUser(
      uid: user.uid,
      name: name,
      email: email,
      role: shouldBeAdmin ? 'admin' : 'operator',
    );
    await ref.set(profile.toMap());
    return profile;
  }

  static String errorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'รูปแบบอีเมลไม่ถูกต้อง';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        case 'email-already-in-use':
          return 'อีเมลนี้ถูกใช้สมัครแล้ว กรุณาเข้าสู่ระบบแทน';
        case 'weak-password':
          return 'รหัสผ่านอ่อนเกินไป (อย่างน้อย 6 ตัวอักษร)';
        case 'user-disabled':
          return 'บัญชีนี้ถูกปิดใช้งาน';
        case 'too-many-requests':
          return 'ทำรายการบ่อยเกินไป กรุณาลองใหม่ภายหลัง';
        case 'network-request-failed':
          return 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';
        case 'operation-not-allowed':
        case 'configuration-not-found':
          return 'ยังไม่ได้เปิด Email/Password ใน Firebase Console '
              '(Authentication > Sign-in method)';
      }
      return 'ดำเนินการไม่สำเร็จ (${e.code})';
    }
    return e.toString();
  }
}
