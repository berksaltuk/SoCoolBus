import 'package:my_app/my_enum.dart';

class FinanceAgandaEntry {
  final String agandaEntryId;
  final String mainHeader;
  final String summary;
  final DateTime date;
  final String amount;
  final FinanceStatus status;

  const FinanceAgandaEntry(
      {required this.agandaEntryId,
      required this.mainHeader,
      required this.summary,
      required this.date,
      required this.amount,
      this.status = FinanceStatus.requested});

  factory FinanceAgandaEntry.fromJson(Map<dynamic, dynamic> json) {
    int symbolIndex = json["summary"].indexOf("₺");
    String substring;
    if (symbolIndex != -1) {
      substring = json["summary"].substring(0, symbolIndex + 1);
    } else {
      substring = json["summary"];
    }
    return FinanceAgandaEntry(
        agandaEntryId: json['_id'],
        mainHeader: json['mainHeader'],
        summary: json["detailedDescription"],
        amount: substring,
        date: DateTime.parse(json['date']),
        status: getFinanceStatus(json['agendaEntryType']));
  }
}

FinanceStatus getFinanceStatus(String summary) {
  Map<String, FinanceStatus> typeToStatus = {
    "EXPENSE": FinanceStatus.expense,
    "PAYMENT": FinanceStatus.income,
    "SEND_IBAN": FinanceStatus.requested,
    "POSTPONE": FinanceStatus.postponed,
  };
  return typeToStatus[summary] ?? FinanceStatus.requested;
}
