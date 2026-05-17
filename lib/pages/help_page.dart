import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Làm sao đổi ngày bay?', 'Vào Vé của tôi → chọn vé → Hủy và đặt lại chuyến mới, hoặc gọi hotline.'),
      ('Hành lý được bao nhiêu kg?', 'Hạng tiêu chuẩn: xách tay 7kg, ký gửi mua thêm tại quầy.'),
      ('Hoàn tiền khi hủy vé?', 'Hủy trước 24h: hoàn 80% giá vé; sau 24h: theo điều kiện vé.'),
      ('Check-in online?', 'Mở từ 24h trước giờ bay trong mục Vé của tôi.'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Trợ giúp'),
        backgroundColor: const Color(0xFF00A884),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !embedded,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('10 API đã tích hợp', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('1 login · 2 getStudents · 3 getStudentById\n4 searchStudents · 5 filterByClass\n6 addStudent · 7 updateStudent · 8 deleteStudent\n9 forgotPassword · 10 exportCSV', style: TextStyle(fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(item.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(item.$2, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
