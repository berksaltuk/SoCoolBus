class PaymentReport {
  final String paymentId;
  final String name;
  final String serviceTimeInMonths;
  final int paidAmount;
  final int leftAmount;
  final int totalAmount;

  const PaymentReport(
      {required this.paymentId,
      required this.totalAmount,
      required this.name,
      required this.serviceTimeInMonths,
      required this.paidAmount,
      required this.leftAmount});

  factory PaymentReport.fromJson(Map<dynamic, dynamic> json) {
    return PaymentReport(
      paymentId: json['_id'],
      leftAmount: json['leftAmount'].toInt(),
      name: json['name'],
      totalAmount: json['total'].toInt(),
      serviceTimeInMonths: json['serviceTimeInMonths'].toString(),
      paidAmount: json['paidAmount'],
    );
  }
}
