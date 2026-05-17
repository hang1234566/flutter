import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/student.dart';
import '../services/api_service.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> students = [];
  List<Student> filtered = [];
  Map<String, int> _summary = {};
  final TextEditingController _search = TextEditingController();
  final ApiService _api = ApiService.instance;
  String selectedLop = 'Tất cả';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _loading = true);
    students = await _api.getStudents();
    _summary = await _api.getClassSummary();
    await _applyFilter();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _applyFilter() async {
    final q = _search.text.trim();
    if (q.isNotEmpty) {
      filtered = await _api.searchStudents(q, lop: selectedLop);
    } else if (selectedLop != 'Tất cả') {
      filtered = await _api.filterStudentsByClass(selectedLop);
    } else {
      filtered = List<Student>.from(students);
    }
    if (mounted) setState(() {});
  }

  Future<void> _openClassFilter() async {
    final lops = ['Tất cả', 'ST23A1', 'ST23B2'];
    final picked = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Lọc theo lớp (API 5)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...lops.map(
              (lop) => ListTile(
                title: Text(lop),
                trailing: selectedLop == lop ? const Icon(Icons.check, color: Color(0xFF8E24AA)) : null,
                onTap: () => Navigator.pop(ctx, lop),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() => selectedLop = picked);
      await _applyFilter();
    }
  }

  Future<void> _addStudent() async {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final lopCtrl = TextEditingController(text: 'ST23A1');
    final emailCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm sinh viên (API 6)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'MSSV')),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Họ tên')),
              TextField(controller: lopCtrl, decoration: const InputDecoration(labelText: 'Lớp')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Thêm')),
        ],
      ),
    );
    if (ok != true) return;

    final newStudent = Student(
      id: idCtrl.text.trim(),
      fullName: nameCtrl.text.trim(),
      lop: lopCtrl.text.trim(),
      email: emailCtrl.text.trim(),
    );
    if (newStudent.id.isEmpty || newStudent.fullName.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập MSSV và họ tên')),
      );
      return;
    }

    await _api.addStudent(newStudent);
    await _loadStudents();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thêm sinh viên thành công')),
    );
  }

  Future<void> _exportList() async {
    final csv = await _api.exportStudentList();
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xuất danh sách (API 10)'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: Text(csv, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csv));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép CSV')),
              );
            },
            child: const Text('Sao chép'),
          ),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  Future<void> _openDetail(Student s) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (c) => DetailPage(studentId: s.id, initial: s),
      ),
    );
    if (changed == true) await _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    final lops = <String>{'Tất cả', ...students.map((s) => s.lop)}.toList();
    final total = _summary['total'] ?? students.length;
    final classA = _summary['ST23A1'] ?? 0;
    final classB = _summary['ST23B2'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FC),
      appBar: AppBar(
        title: const Text('Quản lý ST23', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8E24AA),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !widget.embedded,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFB39DDB), Color(0xFFD7B7F9)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _summaryTile('Tổng', '$total', Icons.group),
                  _summaryTile('ST23A1', '$classA', Icons.class_),
                  _summaryTile('ST23B2', '$classB', Icons.class_),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => _applyFilter(),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      hintText: 'Tìm kiếm (API 4)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Lọc lớp (API 5)',
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF8E24AA)),
                  onPressed: _openClassFilter,
                  icon: const Icon(Icons.filter_list, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: lops.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final lop = lops[i];
                  final selected = lop == selectedLop;
                  return FilterChip(
                    label: Text(lop, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    onSelected: (_) async {
                      setState(() => selectedLop = lop);
                      await _applyFilter();
                    },
                    selectedColor: const Color(0xFF8E24AA).withValues(alpha: 0.25),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ActionChip(
                  label: const Text('Thêm', style: TextStyle(fontSize: 12)),
                  avatar: const Icon(Icons.person_add, size: 16),
                  onPressed: _addStudent,
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Xuất CSV', style: TextStyle(fontSize: 12)),
                  avatar: const Icon(Icons.download, size: 16),
                  onPressed: _exportList,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadStudents,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 40),
                              Center(child: Text('Không có sinh viên')),
                            ],
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final s = filtered[index];
                              return Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF00C59E),
                                    child: Text(
                                      s.fullName.isNotEmpty ? s.fullName[0] : '?',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  subtitle: Text('${s.id} · ${s.lop}', style: const TextStyle(fontSize: 11)),
                                  trailing: const Icon(Icons.chevron_right, size: 20),
                                  onTap: () => _openDetail(s),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
