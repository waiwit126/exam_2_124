import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../controllers/auth_controller.dart';

// หน้าเข้าสู่ระบบ / สมัครสมาชิก (สลับโหมดในหน้าเดียว)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // บัญชีทดสอบสำหรับกรรมการ (ต้องมีบัญชีนี้อยู่ใน Firebase Authentication แล้ว)
  static const _adminEmail = 'admin@gmail.com';
  static const _adminPassword = 'admin_123456';
  static const _operatorEmail = 'Operater@test.com';
  static const _operatorPassword = 'Operater@test.com';

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false;
  bool _hidePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _register = !_register;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_register) {
        await AuthController.register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
      } else {
        await AuthController.signIn(_email.text, _password.text);
      }
      // สำเร็จแล้ว AuthGate จะสลับไปหน้าหลักให้เอง
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AuthController.errorMessage(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  // กดปุ่มทดสอบ: กรอกอีเมล/รหัสผ่านให้ แล้วล็อกอินทันที
  Future<void> _quickLogin(String email, String password) async {
    setState(() {
      _register = false;
      _email.text = email;
      _password.text = password;
      _busy = true;
      _error = null;
    });
    try {
      await AuthController.signIn(email, password);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AuthController.errorMessage(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (!EmailValidator(errorText: '').isValid(email)) {
      setState(() => _error = 'กรอกอีเมลที่ใช้สมัครในช่องอีเมลก่อน แล้วกด "ลืมรหัสผ่าน"');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthController.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ส่งลิงก์ตั้งรหัสผ่านใหม่ไปที่ $email แล้ว')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AuthController.errorMessage(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/icon/ev1.png', height: 180),
                  const SizedBox(height: 8),
                  const Text(
                    'EVFleet',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _register
                        ? 'สมัครสมาชิกด้วยอีเมลของคุณ'
                        : 'เข้าสู่ระบบเพื่อจัดการหัวจ่ายไฟ EV',
                  ),
                  const SizedBox(height: 24),
                  if (_register) ...[
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อ-นามสกุล',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          RequiredValidator(errorText: 'กรุณากรอกชื่อ').call,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'อีเมล',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                      EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
                    ]).call,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: 'รหัสผ่าน',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
                      MinLengthValidator(
                        6,
                        errorText: 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร',
                      ),
                    ]).call,
                  ),
                  if (_register) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      obscureText: _hidePassword,
                      decoration: const InputDecoration(
                        labelText: 'ยืนยันรหัสผ่าน',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == _password.text ? null : 'รหัสผ่านไม่ตรงกัน',
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _submit,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(_register ? Icons.person_add : Icons.login),
                      label: Text(_register ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_register)
                    TextButton(
                      onPressed: _busy ? null : _forgotPassword,
                      child: const Text('ลืมรหัสผ่าน?'),
                    ),
                  TextButton(
                    onPressed: _busy ? null : _toggleMode,
                    child: Text(
                      _register
                          ? 'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ'
                          : 'ยังไม่มีบัญชี? สมัครสมาชิก',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'บัญชีทดสอบ (สำหรับตรวจงาน)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _quickLogin(_adminEmail, _adminPassword),
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('ทดสอบ Admin'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _quickLogin(
                                    _operatorEmail,
                                    _operatorPassword,
                                  ),
                          icon: const Icon(Icons.badge),
                          label: const Text('ทดสอบ Operator'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
