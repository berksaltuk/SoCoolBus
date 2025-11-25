class Account {
  final String accountId;
  final String accountName;
  final String bankName;
  final String receiver;
  final String iban;

  const Account(
      {required this.accountId,
      required this.accountName,
      required this.bankName,
      required this.receiver,
      required this.iban});

        @override
  String toString() {
    return accountName;
  }

  @override
  bool operator ==(dynamic other) =>
      other != null && other is Account && this.accountId == other.accountId;

  factory Account.fromJson(Map<dynamic, dynamic> json) {
    return Account(
      accountId: json['_id'],
      accountName: json['accountName'],
      bankName: json['bankName'],
      receiver: json['receiver'],
      iban: json['iban'],
    );
  }
}
