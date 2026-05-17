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
  static Flight _mk(
    String id,
    String from,
    String to,
    int dayOffset,
    int hour,
    int minute,
    int durationMin,
    double price,
    int seats,
  ) {
    final base = DateTime.now();
    final depart = DateTime(base.year, base.month, base.day + dayOffset, hour, minute);
    return Flight(
      id: id,
      from: from,
      to: to,
      depart: depart,
      arrive: depart.add(Duration(minutes: durationMin)),
      price: price,
      seatsAvailable: seats,
    );
  }

  final List<Flight> _flights = [
    _mk('F001', 'Hanoi', 'Ho Chi Minh', 1, 6, 0, 150, 89, 22),
    _mk('F002', 'Hanoi', 'Ho Chi Minh', 1, 14, 30, 150, 95, 18),
    _mk('F003', 'Hanoi', 'Ho Chi Minh', 2, 8, 15, 150, 110, 30),
    _mk('F004', 'Hanoi', 'Da Nang', 1, 7, 0, 80, 65, 28),
    _mk('F005', 'Hanoi', 'Da Nang', 2, 16, 45, 80, 72, 20),
    _mk('F006', 'Hanoi', 'Phu Quoc', 3, 9, 30, 130, 135, 14),
    _mk('F007', 'Hanoi', 'Nha Trang', 2, 11, 0, 105, 98, 16),
    _mk('F008', 'Hanoi', 'Hue', 1, 10, 20, 55, 58, 32),
    _mk('F009', 'Hanoi', 'Can Tho', 2, 13, 0, 95, 88, 19),
    _mk('F010', 'Hanoi', 'Hai Phong', 1, 18, 0, 40, 42, 40),
    _mk('F011', 'Ho Chi Minh', 'Hanoi', 1, 7, 30, 150, 92, 24),
    _mk('F012', 'Ho Chi Minh', 'Hanoi', 3, 19, 0, 150, 105, 15),
    _mk('F013', 'Ho Chi Minh', 'Da Nang', 1, 9, 0, 70, 68, 26),
    _mk('F014', 'Ho Chi Minh', 'Phu Quoc', 2, 14, 0, 55, 145, 12),
    _mk('F015', 'Ho Chi Minh', 'Phu Quoc', 4, 6, 45, 55, 128, 20),
    _mk('F016', 'Ho Chi Minh', 'Nha Trang', 1, 12, 30, 50, 75, 22),
    _mk('F017', 'Ho Chi Minh', 'Can Tho', 1, 17, 15, 45, 48, 35),
    _mk('F018', 'Ho Chi Minh', 'Quy Nhon', 2, 8, 0, 60, 82, 18),
    _mk('F019', 'Da Nang', 'Hanoi', 1, 11, 0, 80, 70, 21),
    _mk('F020', 'Da Nang', 'Ho Chi Minh', 2, 15, 30, 70, 66, 27),
    _mk('F021', 'Da Nang', 'Hue', 1, 9, 15, 35, 45, 38),
    _mk('F022', 'Da Nang', 'Nha Trang', 2, 10, 0, 50, 62, 24),
    _mk('F023', 'Da Nang', 'Da Lat', 3, 13, 45, 45, 55, 16),
    _mk('F024', 'Da Nang', 'Quy Nhon', 1, 16, 0, 40, 52, 20),
    _mk('F025', 'Phu Quoc', 'Ho Chi Minh', 2, 10, 0, 55, 138, 14),
    _mk('F026', 'Phu Quoc', 'Hanoi', 4, 11, 30, 130, 155, 10),
    _mk('F027', 'Nha Trang', 'Hanoi', 2, 14, 0, 105, 102, 17),
    _mk('F028', 'Nha Trang', 'Ho Chi Minh', 1, 8, 30, 50, 72, 25),
    _mk('F029', 'Hue', 'Hanoi', 1, 12, 0, 55, 56, 30),
    _mk('F030', 'Hue', 'Ho Chi Minh', 3, 7, 45, 95, 108, 13),
    _mk('F031', 'Can Tho', 'Ho Chi Minh', 1, 6, 30, 45, 46, 28),
    _mk('F032', 'Hai Phong', 'Hanoi', 1, 9, 0, 40, 38, 42),
    _mk('F033', 'Da Lat', 'Ho Chi Minh', 2, 11, 15, 50, 78, 19),
    _mk('F034', 'Da Lat', 'Da Nang', 3, 15, 0, 45, 60, 15),
    _mk('F035', 'Quy Nhon', 'Hanoi', 2, 13, 30, 60, 85, 21),
    _mk('F036', 'Quy Nhon', 'Ho Chi Minh', 1, 18, 0, 60, 79, 23),
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
