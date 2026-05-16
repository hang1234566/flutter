import 'package:flutter/material.dart';

import '../models/student.dart';

class DetailPage extends StatelessWidget {
  final Student student; // Nhận thông tin sinh viên từ HomePage
  const DetailPage({required this.student, super.key});

  void _showGrades(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (c) => Container(
        padding: const EdgeInsets.all(30),
        height: 350,
        child: Column(
          children: [
            const Text("BẢNG ĐIỂM CHI TIẾT", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00C59E))),
            const Divider(height: 30),
            _buildGradeRow("Giải thuật nâng cao", "9.0"),
            _buildGradeRow("Lập trình di động", "9.5"),
            _buildGradeRow("Quản trị hệ thống", "8.5"),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C59E), minimumSize: const Size(double.infinity, 50)),
              child: const Text("ĐÓNG", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGradeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontSize: 18)), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hồ sơ: ${student.fullName}")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Color(0xFF00C59E), child: Icon(Icons.person, size: 60, color: Colors.white)),
            const SizedBox(height: 20),
            Text(student.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildInfoRow(Icons.badge, "MSSV", student.id),
            _buildInfoRow(Icons.class_, "Lớp", student.lop),
            _buildInfoRow(Icons.email, "Email", student.email),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _showGrades(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C59E), minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text("XEM BẢNG ĐIỂM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(children: [Icon(icon, color: Colors.grey), const SizedBox(width: 15), Text("$label: ", style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}