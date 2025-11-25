class ParentDailyFlow {
  final String mainHeader;
  final String summary;
  final String studentName;
  final String detailedDescription;
  final String time;
  final String type;

  ParentDailyFlow(
      {required this.mainHeader,
      required this.summary,
      required this.studentName,
      required this.detailedDescription,
      required this.time,
      required this.type});

  @override
  String toString() {
    return summary;
  }

  @override
  bool operator ==(dynamic other) =>
      other != null &&
      other is ParentDailyFlow &&
      this.detailedDescription == other.detailedDescription;

  factory ParentDailyFlow.fromJson(Map<String, dynamic> json) {
    return ParentDailyFlow(
      mainHeader: json['mainHeader'],
      summary: json['summary'],
      studentName: json['studentName'],
      detailedDescription: json['detailedDescription'],
      time: json['time'],
      type: json['type'],
    );
  }
}
