class Subscription {
  final String subscriptionId;
  final DateTime startDate;
  final DateTime endDate;
  final int maxSchoolNumber;
  final String type;
  final int fee;

Subscription({
    required this.subscriptionId,
    required this.startDate,
    required this.endDate,
    required this.maxSchoolNumber,
    required this.type,
    required this.fee,
  });

  @override
  bool operator ==(dynamic other) =>
      other != null && other is Subscription && this.subscriptionId == other.subscriptionId;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      subscriptionId: json['_id'],
      startDate: DateTime.parse(json['starts']),
      endDate: DateTime.parse(json['ends']),
      maxSchoolNumber: json['maxSchoolNumber'],
      type: json['subscriptionType'],
      fee: json['subscriptionFee'],
    );
  }
}