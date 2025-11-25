class Location {
  final double lat;
  final double lon;
  final String studentID;
  final String name;
  final String currentShift;
  final DateTime lastUpdate;

  const Location(
      {required this.lat,
      required this.lon,
      required this.studentID,
      required this.name,
      required this.currentShift,
      required this.lastUpdate
      });

  factory Location.fromJson(Map<dynamic, dynamic> json) {
    return Location(
      lat: json['lat'],
      lon: json['lon'],
      studentID: json['_id'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      name: json['name'],
      currentShift: json['currentShift'],
    );
  }
}
