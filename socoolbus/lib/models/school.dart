import 'dart:convert';

class School extends Object {
  final String schoolId;
  final String name;
  final String address;
  final List<dynamic> schoolType;
  final int shiftCount;

  const School({
    required this.schoolId,
    required this.name,
    required this.address,
    required this.schoolType,
    required this.shiftCount,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    //json = json['result'];
    return School(
        schoolId: json['_id'],
        name: json['name'],
        address: json['address'],
        schoolType: json['schoolType'],
        shiftCount: json['shiftCount']);
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(dynamic other) =>
      other != null && other is School && this.schoolId == other.schoolId;

  @override
  int get hashCode => super.hashCode;
}
