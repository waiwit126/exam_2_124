import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';

// Android อ่านค่าจาก google-services.json, Web ใช้ firebase_options.dart
Future<FirebaseApp> _startFirebase() async {
  if (kIsWeb && DefaultFirebaseOptions.isPlaceholder) {
    throw StateError(
      'ยังไม่ได้ใส่ค่า Firebase Web: เปิด lib/firebase_options.dart '
      'แล้วแทน PASTE_WEB_API_KEY และ PASTE_WEB_APP_ID',
    );
  }
  return Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EvFleetApp());
}

class EvFleetApp extends StatelessWidget {
  const EvFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVFleet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF10)),
      ),
      home: const FirebaseBootstrap(),
    );
  }
}

// เริ่มต้น Firebase ด้วย FutureBuilder (ข้อกำหนดข้อสอบ)
class FirebaseBootstrap extends StatefulWidget {
  const FirebaseBootstrap({super.key});

  @override
  State<FirebaseBootstrap> createState() => _FirebaseBootstrapState();
}

class _FirebaseBootstrapState extends State<FirebaseBootstrap> {
  final Future<FirebaseApp> _init = _startFirebase();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'เชื่อมต่อ Firebase ไม่สำเร็จ\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const AuthGate();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
