import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/api_service.dart';

class DetailPage extends StatefulWidget {
  final String studentId;
  final Student? initial;

  const DetailPage({super.key, required this.studentId, this.initial});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ApiService _api = ApiService.instance;
  Student? _student;
  bool _loading = true;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _student = widget.initial;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final s = await _api.getStudentById(widget.studentId);
    if (!mounted) return;
    setState(() {
      _student = s ?? widget.initial;
      _loading = false;
    });
  }

  Future<void> _edit() async {
    final s = _student;
    if (s == null) return;
    final nameCtrl = TextEditingController(text: s.fullName);
    final emailCtrl = TextEditingController(text: s.email);
    final lopCtrl = TextEditingController(text: s.lop);
    final phoneCtrl = TextEditingController(text: s.phone);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật sinh viên'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Họ tên')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: lopCtrl, decoration: const InputDecoration(labelText: 'Lớp')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'SĐT')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final updated = s.copyWith(
      fullName: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      lop: lopCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
    );
    final result = await _api.updateStudent(updated);
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _student = result;
        _changed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy sinh viên để cập nhật')),
      );
    }
  }

  Future<void> _delete() async {
    final s = _student;
    if (s == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sinh viên?'),
        content: Text('Xóa hồ sơ ${s.fullName} (${s.id})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final success = await _api.deleteStudent(s.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa sinh viên (API 8)')),
      );
      Navigator.pop(context, true);
    }
  }

  void _showGrades() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => Container(
        padding: const EdgeInsets.all(24),
        height: 320,
        child: Column(
          children: [
            const Text(
              'BẢNG ĐIỂM CHI TIẾT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00C59E)),
            ),
            const Divider(height: 24),
            _gradeRow('Giải thuật nâng cao', '9.0'),
            _gradeRow('Lập trình di động', '9.5'),
            _gradeRow('Quản trị hệ thống', '8.5'),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.pop(c),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00C59E),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sinh viên')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final s = _student;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sinh viên')),
        body: const Center(child: Text('Không tìm thấy sinh viên (API 3)')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.fullName, style: const TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => Navigator.pop(context, _changed)),
        actions: [
          IconButton(tooltip: 'Sửa', onPressed: _edit, icon: const Icon(Icons.edit_outlined)),
          IconButton(tooltip: 'Xóa', onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFF00C59E),
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(s.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _info(Icons.badge, 'MSSV', s.id),
            _info(Icons.class_, 'Lớp', s.lop),
            _info(Icons.email, 'Email', s.email),
            _info(Icons.phone, 'SĐT', s.phone),
            _info(Icons.info_outline, 'Trạng thái', s.status),
            const Spacer(),
            FilledButton(
              onPressed: _showGrades,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00C59E),
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text('XEM BẢNG ĐIỂM'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
