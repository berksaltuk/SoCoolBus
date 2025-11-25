import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/my_enum.dart';

class RequestPaymentListItem extends StatelessWidget {
  final int installmentTotal = 9;

  const RequestPaymentListItem(
      {super.key,
      required this.check,
      required this.name,
      required this.installmentInfo,
      required this.amount,
      required this.status});

  final Widget check;
  final String name;
  final String installmentInfo;
  final int amount;
  final PaymentStatus status;

  Widget build(BuildContext context) {
    final String printStatus = status.getEnum();
    Color getTextColor(String str) {
      //Logic to be checked if there is + or - sign for amounts
      if (str == PaymentStatus.paid.toString()) {
        return COLOR_GREEN_MONEY;
      } else if (str == PaymentStatus.unpaid.toString()) {
        return COLOR_RED_MONEY;
      } else if (str == PaymentStatus.postponed.toString()) {
        return COLOR_BLUE_MONEY;
      } else if (str == PaymentStatus.requested.toString()) {
        return COLOR_DARK_GREY;
      } else if (str == PaymentStatus.late.toString()) {
        return COLOR_RED_MONEY;
      }else {
        return COLOR_BLACK;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6), color: COLOR_WHITE),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              check,
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Taksit: $installmentInfo',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$amount₺',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                            color: getTextColor(status.toString()),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          printStatus,
                          style: Theme.of(context).textTheme.bodyText1,
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
