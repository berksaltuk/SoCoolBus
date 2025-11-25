class AgandaEntry {
  final String agandaEntryId;
  final String mainHeader;
  final String summary;
  final DateTime date;
  final String description;

  const AgandaEntry(
      {required this.agandaEntryId,
      required this.mainHeader,
      required this.summary,
      required this.date,
      required this.description});

  factory AgandaEntry.fromJson(Map<dynamic, dynamic> json) {
    return AgandaEntry(
      agandaEntryId: json['_id'],
      mainHeader: json['mainHeader'],
      summary: json["summary"],
      description: json["detailedDescription"],
      date: DateTime.parse(json['date']),
    );
  }
}
