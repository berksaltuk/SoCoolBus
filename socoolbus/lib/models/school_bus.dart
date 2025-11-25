class SchoolBus extends Object {
  final String schoolBusId;
  final String plate;
  final String phone;
  final String name;
  final String companyToken;
  final int seatCount;

  const SchoolBus({
    required this.schoolBusId,
    required this.plate,
    required this.phone,
    required this.name,
    required this.companyToken,
    required this.seatCount,
  });

  factory SchoolBus.fromJson(Map<String, dynamic> json) {
    //json = json['result'];
    return SchoolBus(
        schoolBusId: json['_id'],
        plate: json['plate'],
        phone: json['phone'],
        name: json['name'],
        companyToken: json['companyToken'],
        seatCount: json['seatCount']);
  }

  @override
  String toString() {
    return plate;
  }

  @override
  bool operator ==(dynamic other) =>
      other != null &&
      other is SchoolBus &&
      this.schoolBusId == other.schoolBusId;

  @override
  int get hashCode => super.hashCode;
}
