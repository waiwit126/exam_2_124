import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/auth_controller.dart';
import '../controllers/charger_controller.dart';
import '../models/app_user.dart';
import '../models/charger.dart';
import 'display_screen.dart';
import 'form_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // แถบบน: แสดงชื่อผู้ใช้ + role ทั้ง Admin และ Operator
  AppBar _appBar(ColorScheme scheme, {PreferredSizeWidget? bottom}) {
    return AppBar(
      backgroundColor: scheme.primaryContainer,
      toolbarHeight: 64,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EVFleet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            '${widget.user.name} • ${widget.user.role.toUpperCase()}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: AuthController.signOut,
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
        ),
      ],
      bottom: bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAdmin = widget.user.isAdmin;

    // ทั้งสองสิทธิ์: ลงทะเบียนหัวชาร์จ (Create) / รายการหัวจ่าย (Read) / ผู้ใช้
    // Admin: รายการมีปุ่ม แก้ไข/ลบ   Operator: ดูรายการและรายละเอียดเท่านั้น
    const tabs = [
      Tab(icon: Icon(Icons.ev_station), text: 'ลงทะเบียนหัวชาร์จ'),
      Tab(icon: Icon(Icons.dashboard), text: 'รายการหัวจ่าย'),
      Tab(icon: Icon(Icons.person), text: 'ผู้ใช้'),
    ];
    final pages = [
      FormScreen(user: widget.user, onSaved: () => _tab.animateTo(1)),
      isAdmin ? DisplayScreen(user: widget.user) : const OperatorScreen(),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      appBar: _appBar(scheme, bottom: TabBar(controller: _tab, tabs: tabs)),
      body: TabBarView(controller: _tab, children: pages),
    );
  }
}

// มุมมอง Operator: เห็นแค่รายการว่ามีหัวจ่ายไฟที่ไหนบ้าง กดเข้าไปดูรายละเอียด/แผนที่
class OperatorScreen extends StatelessWidget {
  const OperatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ChargerController.stream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!.docs
            .map((d) => Charger.fromMap(d.id, d.data()))
            .toList()
          ..sort((a, b) => a.location.compareTo(b.location));
        if (items.isEmpty) {
          return const Center(child: Text('ยังไม่มีหัวจ่ายไฟในระบบ'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final c = items[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.place),
                title: Text(
                  c.location,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(c.chargerId),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChargerDetailScreen(charger: c),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// รายละเอียดหัวจ่าย (ใช้ร่วมกันทั้ง Admin และ Operator) + ปุ่มเปิด Google Maps
class ChargerDetailScreen extends StatelessWidget {
  const ChargerDetailScreen({super.key, required this.charger});

  final Charger charger;

  Future<void> _openMap(BuildContext context) async {
    var ok = false;
    try {
      ok = await MapLauncher.open(charger.location);
    } catch (_) {}
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปิด Google Maps ไม่สำเร็จ')),
      );
    }
  }

  Widget _row(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = charger;
    return Scaffold(
      appBar: AppBar(title: Text(c.chargerId)),
      body: ListView(
        children: [
          _row(Icons.ev_station, 'รหัสหัวจ่าย', c.chargerId),
          _row(Icons.place, 'ที่ตั้งสถานี', c.location),
          _row(Icons.email, 'วิศวกรผู้ดูแล', c.engineerEmail),
          _row(Icons.bolt, 'กำลังชาร์จ', '${c.powerLabel} กิโลวัตต์'),
          _row(Icons.payments, 'ราคา', '${c.priceLabel} บาท'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () => _openMap(context),
                icon: const Icon(Icons.map),
                label: const Text('เปิดใน Google Maps'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// เปิดตำแหน่งสถานีใน Google Maps (แอป Google Maps ถ้ามี ไม่งั้นเปิดเว็บ)
// ถ้า location เป็นพิกัด เช่น "13.7563, 100.5018" จะปักหมุดตรงตำแหน่ง
// ถ้าเป็นข้อความ (ชื่อสถานที่/ที่อยู่) จะค้นหาใน Google Maps ให้
class MapLauncher {
  MapLauncher._();

  static final RegExp _latLng =
      RegExp(r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$');

  static Uri uriFor(String location) {
    final m = _latLng.firstMatch(location);
    final query = m != null ? '${m.group(1)},${m.group(2)}' : location.trim();
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
  }

  static Future<bool> open(String location) =>
      launchUrl(uriFor(location), mode: LaunchMode.externalApplication);
}
