import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Android ใช้ android/app/google-services.json จึงคืนค่า null
// Web (Chrome) ต้องใช้ค่าตั้งต้นด้านล่าง: ไปที่ Firebase Console > Project settings
// > Your apps > Add app > Web (</>) แล้วนำ apiKey และ appId มาแทน PASTE_...
// (หรือรัน `flutterfire configure --project=exam-2-124` จะสร้างไฟล์นี้ให้อัตโนมัติ)
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions? get currentPlatform => kIsWeb ? web : null;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCZFZrjFSRxzIeF_VmB1MOaprSc-8R0W5c',
    appId: '1:608049235014:web:ac61ae7c16b4a38e2a7647',
    messagingSenderId: '608049235014',
    projectId: 'exam-2-124',
    authDomain: 'exam-2-124.firebaseapp.com',
    storageBucket: 'exam-2-124.firebasestorage.app',
  );

  static bool get isPlaceholder =>
      web.apiKey.startsWith('PASTE') || web.appId.startsWith('PASTE');
}
