import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  EmployeeModel({
    required super.id,
    required super.name,
    required super.role,
    required super.email,
    required super.phone,
    required super.salary,
    super.attendanceStatus,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      salary: json['salary'] as String,
      attendanceStatus: json['attendanceStatus'] as String? ?? 'Present',
    );
  }

  Map<String, dynamic> toJson() {
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
}
