import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/api_service.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> students = [];
  List<Student> filtered = [];
  final TextEditingController _search = TextEditingController();
  final ApiService _apiService = ApiService.instance;
  String selectedLop = 'Tất cả';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _loading = true);
    students = await _apiService.getStudents();
    filtered = await _apiService.searchStudents(_search.text, lop: selectedLop);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _filter(String query) async {
    filtered = await _apiService.searchStudents(query, lop: selectedLop);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _refresh() async {
    await _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    final lops = <String>{'Tất cả', ...students.map((s) => s.lop)}.toList();

    final totalStudents = students.length;
    final classA = students.where((s) => s.lop == 'ST23A1').length;
    final classB = students.where((s) => s.lop == 'ST23B2').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("DANH SÁCH LỚP ST23", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF8E24AA),
        centerTitle: true,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFB39DDB), Color(0xFFD7B7F9)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.08), blurRadius: 12, offset: Offset(0, 6)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng quan lớp', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text('ST23A / ST23B', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSummaryTile('Sinh viên', totalStudents.toString(), Icons.group, Colors.white),
                        const SizedBox(width: 12),
                        _buildSummaryTile('ST23A1', classA.toString(), Icons.class_, Colors.white),
                        const SizedBox(width: 12),
                        _buildSummaryTile('ST23B2', classB.toString(), Icons.class_, Colors.white),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        Chip(label: Text('Hoạt động mới')), 
                        Chip(label: Text('Khóa học chuyên ngành')),
                        Chip(label: Text('Cập nhật điểm')), 
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: _filter,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Tìm theo tên, MSSV hoặc email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Tooltip(
                  message: 'Bộ lọc nhanh',
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E24AA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    ),
                    child: const Icon(Icons.filter_list),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  final lop = lops[i];
                  final selected = lop == selectedLop;
                  return ChoiceChip(
                    label: Text(lop),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => selectedLop = lop);
                      _filter(_search.text);
                    },
                    selectedColor: const Color(0xFF00C59E),
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemCount: lops.length,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Thêm sinh viên'),
                    avatar: const Icon(Icons.person_add, size: 18, color: Colors.white),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final newStudent = Student(
                        id: '107000',
                        fullName: 'Nguyễn Thanh Tâm',
                        lop: 'ST23A1',
                        email: 'tamtv@donga.edu.vn',
                      );
                      await _apiService.addStudent(newStudent);
                      await _loadStudents();
                      if (!mounted) return;
                      messenger.showSnackBar(const SnackBar(content: Text('Thêm sinh viên thành công')));
                    },
                    backgroundColor: const Color(0xFF6A1B9A),
                    labelStyle: const TextStyle(color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  ActionChip(
                    label: const Text('Xuất DS'),
                    avatar: const Icon(Icons.download, size: 18, color: Color(0xFF6A1B9A)),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final csv = await _apiService.exportStudentList();
                      if (!mounted) return;
                      messenger.showSnackBar(SnackBar(content: Text('Xuất DS thành công (${csv.split('\n').length - 1} bản ghi)')));
                    },
                    backgroundColor: Colors.white,
                    labelStyle: const TextStyle(color: Color(0xFF6A1B9A)),
                    side: const BorderSide(color: Color(0xFF6A1B9A)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                    ? ListView(children: [const SizedBox(height: 40), const Center(child: Text('Không tìm thấy sinh viên'))])
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: const Color(0xFF00C59E),
                                      child: Text(s.fullName.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 4),
                                          Text('MSSV: ${s.id}', style: const TextStyle(color: Colors.black87)),
                                          const SizedBox(height: 4),
                                          Text(s.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12)),
                                      child: Text(s.lop, style: const TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Chip(label: const Text('Điểm cao')), 
                                    Chip(label: const Text('Hoạt động')), 
                                    Chip(label: const Text('Khóa chính')),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (c) => DetailPage(student: s)));
                                        },
                                        icon: const Icon(Icons.info_outline),
                                        label: const Text('Chi tiết'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gửi email tới ${s.email}')));
                                      },
                                      icon: const Icon(Icons.email, color: Color(0xFF8E24AA)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
}

Widget _buildSummaryTile(String label, String value, IconData icon, Color iconColor) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: Color.fromRGBO(255, 255, 255, 0.1), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    ),
  );
}
