import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  EmployeeModel({
    required super.id,
    required super.name,
    required super.role,
    required super.email,
    required super.phone,
    required super.salary,
    required super.lastUpdated,
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
      lastUpdated: json['lastUpdated'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...super.toMap(),
    };
  }
}
