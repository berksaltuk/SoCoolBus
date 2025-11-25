class Expense {
  final String expenseId;
  final int amount;
  final String type;
  final DateTime date;
  final String description;

  const Expense(
      {required this.expenseId,
      required this.amount,
      required this.type,
      required this.date,
      required this.description});

  factory Expense.fromJson(Map<dynamic, dynamic> json) {
    return Expense(
      expenseId: json['_id'],
      amount: json['amount'],
      type: json['expenseType'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}
