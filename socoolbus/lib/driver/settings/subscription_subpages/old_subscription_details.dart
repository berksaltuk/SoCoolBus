import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/my_enum.dart';

class SubscriptionDetails extends StatelessWidget {
  const SubscriptionDetails({super.key, 
    required this.subscriptionId,
    required this.startDate,
    required this.endDate,
    required this.maxSchoolNumber,
    required this.type,
    required this.fee,
  });

  final String subscriptionId;
  final DateTime startDate;
  final DateTime endDate;
  final int maxSchoolNumber;
  final String type;
  final int fee;

  @override
  Widget build(BuildContext context) {
    String startDateFormat = DateFormat('dd/MM/yyyy').format(startDate);
    String endDateFormat = DateFormat('dd/MM/yyyy').format(endDate);
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6), color: COLOR_WHITE),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeToString[type] ?? "Ücretli",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    "Ücret: $fee₺",
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Flexible(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Maksimum okul sayısı: $maxSchoolNumber",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$startDateFormat - $endDateFormat',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
