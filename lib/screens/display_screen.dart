import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../controllers/charger_controller.dart';
import '../models/app_user.dart';
import '../models/charger.dart';
import 'home_screen.dart' show ChargerDetailScreen;
import 'edit_screen.dart';

// แท็บที่ 2: แผงควบคุม (Read แบบเรียลไทม์ + Update/Delete เฉพาะ Admin)
class DisplayScreen extends StatelessWidget {
  const DisplayScreen({super.key, required this.user});

  final AppUser user;

  Future<void> _confirmDelete(BuildContext context, Charger c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการปิดหัวจ่าย'),
        content: Text('ต้องการลบหัวจ่าย ${c.chargerId} ออกจากระบบจริงหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ChargerController.delete(c.docId!, user);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบ ${c.chargerId} แล้ว')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบไม่สำเร็จ: $e')),
      );
    }
  }

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
          ..sort((a, b) => a.chargerId.compareTo(b.chargerId));
        if (items.isEmpty) {
          return const Center(child: Text('ยังไม่มีหัวจ่าย ไปลงทะเบียนที่แท็บแรก'));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('หัวจ่ายทั้งหมด ${items.length} หัว'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final c = items[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 28,
                        child: Text(
                          '${c.powerLabel}\nkW',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        c.chargerId,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${c.location}\nราคา ${c.priceLabel} บาท'),
                      isThreeLine: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChargerDetailScreen(charger: c),
                        ),
                      ),
                                            trailing: user.isAdmin
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'แก้ไข',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditScreen(user: user, charger: c),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'ลบ',
                                  icon: const Icon(Icons.delete),
                                  color: Theme.of(context).colorScheme.error,
                                  onPressed: () => _confirmDelete(context, c),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
