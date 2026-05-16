class Student {
  final String id;
  final String fullName;
  final String lop;
  final String email;
  final String phone;
  final String status;

  Student({
    required this.id,
    required this.fullName,
    required this.lop,
    required this.email,
    this.phone = '0123 456 789',
    this.status = 'Hoạt động',
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      lop: json['lop'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '0123 456 789',
      status: json['status'] as String? ?? 'Hoạt động',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'lop': lop,
      'email': email,
      'phone': phone,
      'status': status,
    };
  }

  Student copyWith({
    String? id,
    String? fullName,
    String? lop,
    String? email,
    String? phone,
    String? status,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      lop: lop ?? this.lop,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
    );
  }
}
