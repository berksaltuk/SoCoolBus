class Student {
  final String studentId;
  final String secondPhone;
  final String name;
  final String address;
  final String addressDirections;
  String addressLink;

Student({
    required this.studentId,
    required this.secondPhone,
    required this.name,
    required this.address,
    required this.addressDirections,
    this.addressLink = "https://www.google.com/maps/search/?api=1&query=0,0"
  });
  
  @override
  String toString(){
    return name;
  }

  @override
  bool operator ==(dynamic other) =>
      other != null && other is Student && this.studentId == other.studentId;

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['_id'],
      name: json['name'],
      secondPhone: json['secondPhoneNumber'],
      address: json['address'],
      addressDirections: json['addressDirections'],
      addressLink: json['link'] ?? "https://www.google.com/maps/search/?api=1&query=0,0",
    );
  }
}