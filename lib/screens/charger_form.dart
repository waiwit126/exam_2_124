import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../controllers/charger_controller.dart';
import '../models/app_user.dart';
import '../models/charger.dart';

// ฟอร์มใช้ร่วมกัน 2 โหมด: เพิ่มใหม่ (charger == null) และแก้ไข (มี charger + docId)
class ChargerForm extends StatefulWidget {
  const ChargerForm({
    super.key,
    required this.user,
    this.docId,
    this.charger,
    this.onSaved,
  });

  final AppUser user;
  final String? docId;
  final Charger? charger;
  final VoidCallback? onSaved;

  bool get isEdit => docId != null && charger != null;

  @override
  State<ChargerForm> createState() => _ChargerFormState();
}

class _ChargerFormState extends State<ChargerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _chargerId;
  late final TextEditingController _location;
  late final TextEditingController _email;
  late final TextEditingController _power;
  late final TextEditingController _price;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.charger;
    _chargerId = TextEditingController(text: c?.chargerId ?? '');
    _location = TextEditingController(text: c?.location ?? '');
    _email = TextEditingController(text: c?.engineerEmail ?? '');
    _power = TextEditingController(text: c?.powerLabel ?? '');
    _price = TextEditingController(text: c?.priceLabel ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _chargerId,
      _location,
      _email,
      _power,
      _price,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _numberValidator(String? v, String label, {bool allowZero = false}) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอก$label';
    final n = double.tryParse(v.trim());
    if (n == null) return '$labelต้องเป็นตัวเลข';
    if (allowZero ? n < 0 : n <= 0) {
      return allowZero ? '$labelต้องไม่ติดลบ' : '$labelต้องมากกว่า 0';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final charger = Charger(
        chargerId: _chargerId.text.trim(),
        location: _location.text.trim(),
        engineerEmail: _email.text.trim(),
        powerKw: double.parse(_power.text.trim()),
        price: double.parse(_price.text.trim()),
      );
      if (widget.isEdit) {
        await ChargerController.update(widget.docId!, charger, widget.user);
      } else {
        await ChargerController.add(charger, widget.user);
        for (final c in [_chargerId, _location, _email, _power, _price]) {
          c.clear();
        }
        _formKey.currentState?.reset();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? 'บันทึกการแก้ไขแล้ว' : 'ลงทะเบียนหัวชาร์จแล้ว'),
        ),
      );
      widget.onSaved?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')),
      );
    }
    if (mounted) setState(() => _saving = false);
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboard,
    String? suffix,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const number = TextInputType.numberWithOptions(decimal: true);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              controller: _chargerId,
              label: 'รหัสหัวจ่าย',
              hint: 'เช่น EVSE-BKK-09',
              icon: Icons.ev_station,
              validator:
                  RequiredValidator(errorText: 'กรุณากรอกรหัสหัวจ่าย').call,
            ),
            _field(
              controller: _location,
              label: 'ที่ตั้งสถานี',
              icon: Icons.place,
              validator:
                  RequiredValidator(errorText: 'กรุณากรอกที่ตั้งสถานี').call,
            ),
            _field(
              controller: _email,
              label: 'อีเมลวิศวกรผู้ดูแล',
              icon: Icons.email,
              keyboard: TextInputType.emailAddress,
              validator: MultiValidator([
                RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
              ]).call,
            ),
            _field(
              controller: _power,
              label: 'กำลังชาร์จ',
              hint: '50 / 120 / 360',
              icon: Icons.bolt,
              keyboard: number,
              suffix: 'กิโลวัตต์',
              validator: (v) => _numberValidator(v, 'กำลังชาร์จ'),
            ),
            _field(
              controller: _price,
              label: 'ราคา',
              icon: Icons.payments,
              keyboard: number,
              suffix: 'บาท',
              validator: (v) => _numberValidator(v, 'ราคา', allowZero: true),
            ),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(widget.isEdit ? 'บันทึกการแก้ไข' : 'ลงทะเบียน'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
