class DriverDueDateConfig {
  final String dueDateConfigId;
  final String phone;
  final String school;
  final String date;

  const DriverDueDateConfig({
    required this.dueDateConfigId,
    required this.phone,
    required this.school,
    required this.date
  });

  factory DriverDueDateConfig.fromJson(Map<dynamic, dynamic> json) {
    return DriverDueDateConfig(
      dueDateConfigId: json['_id'],
      phone: json['driverPhone'],
      school: json['school'],
      date: json['dueDate'].toString(),
    );
  }
}