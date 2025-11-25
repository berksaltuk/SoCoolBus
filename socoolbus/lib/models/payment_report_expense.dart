class ExpenseReport {
  final String expenseId;
  final String type;
  final DateTime date;
  final String description;
  final int amount;

  const ExpenseReport(
      {required this.expenseId,
      required this.type,
      required this.date,
      required this.description,
      required this.amount});

  factory ExpenseReport.fromJson(Map<dynamic, dynamic> json) {
    return ExpenseReport(
      expenseId: json['_id'],
      type: json['expenseType'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      amount: json['amount'].toInt(),
    );
  }
}
