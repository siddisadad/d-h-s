class Employee {
  final String id;
  final String name;
  final String role;
  final String email;
  final String phone;
  final String salary;
  final String attendanceStatus; // Present, Absent, On Leave

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.salary,
    this.attendanceStatus = 'Present',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'salary': salary,
      'attendanceStatus': attendanceStatus,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      email: map['email'],
      phone: map['phone'],
      salary: map['salary'],
      attendanceStatus: map['attendanceStatus'] ?? 'Present',
    );
  }
}
