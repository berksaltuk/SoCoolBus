import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';

class PaymentReportListItem extends StatelessWidget {

  const PaymentReportListItem(
      {super.key,
      required this.name,
      required this.month,
      required this.yearlyFee,
      required this.paid,
      required this.remainingFee});

  final String name;
  final String month;
  final String yearlyFee;
  final String paid;
  final String remainingFee;

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6), color: COLOR_WHITE),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: SizedBox(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '$month Ay',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "$yearlyFee₺",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "$paid₺",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "$remainingFee₺",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
