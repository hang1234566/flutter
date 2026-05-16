import 'dart:async';

import '../models/student.dart';

class ApiService {
  ApiService._privateConstructor();
  static final ApiService instance = ApiService._privateConstructor();

  final List<Student> _students = [
    Student(id: '106010', fullName: 'Hồ Thị Hằng', lop: 'ST23A1', email: 'hanght@donga.edu.vn'),
    Student(id: '106245', fullName: 'Lê Văn Anh', lop: 'ST23A1', email: 'anhlv@donga.edu.vn'),
    Student(id: '104652', fullName: 'Trần Lệ Dương', lop: 'ST23B2', email: 'duongtl@donga.edu.vn'),
    Student(id: '105999', fullName: 'Nguyễn Minh Khôi', lop: 'ST23A1', email: 'khoinm@donga.edu.vn'),
  ];

  // API 1: Login endpoint
  Future<bool> login(String studentId, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return studentId == '106010' && password == '123456';
  }

  // API 2: Get all students
  Future<List<Student>> getStudents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<Student>.from(_students);
  }

  // API 3: Get student details by ID
  Future<Student?> getStudentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final result = _students.where((student) => student.id == id).toList();
    return result.isEmpty ? null : result.first;
  }

  // API 4: Search students
  Future<List<Student>> searchStudents(String query, {String lop = 'Tất cả'}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase().trim();
    final matched = _students.where((student) {
      final matchesQuery = q.isEmpty || student.fullName.toLowerCase().contains(q) || student.id.contains(q) || student.email.toLowerCase().contains(q);
      final matchesLop = lop == 'Tất cả' || student.lop == lop;
      return matchesQuery && matchesLop;
    }).toList();
    return matched;
  }

  // API 5: Filter students by class
  Future<List<Student>> filterStudentsByClass(String lop) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (lop == 'Tất cả') {
      return await getStudents();
    }
    return _students.where((student) => student.lop == lop).toList();
  }

  // API 6: Add a new student
  Future<Student> addStudent(Student student) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _students.add(student);
    return student;
  }

  // API 7: Update an existing student
  Future<Student?> updateStudent(Student student) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _students.indexWhere((item) => item.id == student.id);
    if (index < 0) return null;
    _students[index] = student;
    return _students[index];
  }

  // API 8: Delete student
  Future<bool> deleteStudent(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final beforeCount = _students.length;
    _students.removeWhere((student) => student.id == id);
    return _students.length < beforeCount;
  }

  // API 9: Forgot password support
  Future<String> forgotPassword(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final exists = _students.any((student) => student.id == studentId);
    if (exists) {
      return 'Yêu cầu lấy lại mật khẩu đã được gửi. Vui lòng kiểm tra email hoặc liên hệ 0123 456 789.';
    }
    return 'Không tìm thấy MSSV. Vui lòng kiểm tra lại thông tin.';
  }

  // API 10: Export student list as CSV
  Future<String> exportStudentList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final header = 'id,fullName,lop,email,phone,status';
    final rows = _students.map((student) =>
      '${student.id},${student.fullName},${student.lop},${student.email},${student.phone},${student.status}'
    );
    return ([header, ...rows]).join('\n');
  }

  // Extra API: Class summary
  Future<Map<String, int>> getClassSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final summary = <String, int>{'ST23A1': 0, 'ST23B2': 0};
    for (var student in _students) {
      summary[student.lop] = (summary[student.lop] ?? 0) + 1;
    }
    summary['total'] = _students.length;
    return summary;
  }
}
