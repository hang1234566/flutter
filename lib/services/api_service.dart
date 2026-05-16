import 'dart:async';

import '../models/student.dart';
import '../models/flight.dart';
import '../models/booking.dart';

class ApiService {
  ApiService._privateConstructor();
  static final ApiService instance = ApiService._privateConstructor();

  final List<Student> _students = [
    Student(id: '106010', fullName: 'Hồ Thị Hằng', lop: 'ST23A1', email: 'hanght@donga.edu.vn'),
    Student(id: '106245', fullName: 'Lê Văn Anh', lop: 'ST23A1', email: 'anhlv@donga.edu.vn'),
    Student(id: '104652', fullName: 'Trần Lệ Dương', lop: 'ST23B2', email: 'duongtl@donga.edu.vn'),
    Student(id: '105999', fullName: 'Nguyễn Minh Khôi', lop: 'ST23A1', email: 'khoinm@donga.edu.vn'),
  ];

  // API 1: Login endpoint (demo - accept any non-empty email/password)
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final e = email.trim();
    final p = password.trim();
    if (e.isEmpty || p.isEmpty) return false;
    return true;
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
  Future<String> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final cleanedEmail = email.trim();
    if (cleanedEmail.isEmpty) {
      return 'Vui lòng nhập email hợp lệ để tiếp tục.';
    }
    return 'Yêu cầu lấy lại mật khẩu đã được gửi tới $cleanedEmail. Vui lòng kiểm tra email hoặc liên hệ 0123 456 789.';
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

  // --- Flight booking APIs (in-memory sample data) ---
  final List<Flight> _flights = [
    Flight(
      id: 'F001',
      from: 'Hanoi',
      to: 'Ho Chi Minh',
      depart: DateTime.now().add(const Duration(days: 1, hours: 9)),
      arrive: DateTime.now().add(const Duration(days: 1, hours: 11, minutes: 30)),
      price: 120.0,
      seatsAvailable: 18,
    ),
    Flight(
      id: 'F002',
      from: 'Hanoi',
      to: 'Da Nang',
      depart: DateTime.now().add(const Duration(days: 2, hours: 7)),
      arrive: DateTime.now().add(const Duration(days: 2, hours: 8, minutes: 40)),
      price: 80.0,
      seatsAvailable: 25,
    ),
    Flight(
      id: 'F003',
      from: 'Ho Chi Minh',
      to: 'Phu Quoc',
      depart: DateTime.now().add(const Duration(days: 3, hours: 14)),
      arrive: DateTime.now().add(const Duration(days: 3, hours: 15, minutes: 20)),
      price: 150.0,
      seatsAvailable: 12,
    ),
  ];

  final List<Booking> _bookings = [];

  Future<List<Flight>> getFlights() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Flight>.from(_flights);
  }

  Future<List<Flight>> searchFlights(String from, String to, {DateTime? departDate, double? minPrice, double? maxPrice, int? minSeats}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final f = from.toLowerCase().trim();
    final t = to.toLowerCase().trim();
    return _flights.where((flight) {
      final matchFrom = f.isEmpty || flight.from.toLowerCase().contains(f);
      final matchTo = t.isEmpty || flight.to.toLowerCase().contains(t);
      final matchDate = departDate == null || (flight.depart.year == departDate.year && flight.depart.month == departDate.month && flight.depart.day == departDate.day);
      final matchMinPrice = minPrice == null || flight.price >= minPrice;
      final matchMaxPrice = maxPrice == null || flight.price <= maxPrice;
      final matchSeats = minSeats == null || flight.seatsAvailable >= minSeats;
      return matchFrom && matchTo && matchDate && matchMinPrice && matchMaxPrice && matchSeats;
    }).toList();
  }

  Future<Booking> bookFlight(String flightId, String passengerName, int seats) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final flight = _flights.firstWhere((f) => f.id == flightId);
    if (flight.seatsAvailable < seats) throw Exception('Not enough seats');
    flight.seatsAvailable -= seats;
    final booking = Booking(
      id: 'B${DateTime.now().millisecondsSinceEpoch}',
      flightId: flightId,
      passengerName: passengerName,
      bookedAt: DateTime.now(),
      seats: seats,
    );
    _bookings.add(booking);
    return booking;
  }

  Future<List<Booking>> getBookings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Booking>.from(_bookings);
  }

  Future<bool> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) return false;
    final booking = _bookings[index];
    if (booking.status == 'cancelled') return false;
    final flight = _flights.firstWhere((f) => f.id == booking.flightId, orElse: () => throw Exception('Flight not found'));
    flight.seatsAvailable += booking.seats;
    booking.status = 'cancelled';
    return true;
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
