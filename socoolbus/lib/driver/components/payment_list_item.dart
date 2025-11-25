import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/my_enum.dart';

class PaymentListItem extends StatelessWidget {
  final int installmentTotal = 9;

  const PaymentListItem(
      {super.key,
      required this.name,
      required this.paymentNumber,
      required this.amount,
      required this.status});

  final String name;
  final String paymentNumber;
  final int amount;
  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    Color getTextColor(PaymentStatus sts) {
      //Logic to be checked if there is + or - sign for amounts
      if (sts == PaymentStatus.paid) {
        return COLOR_GREEN_MONEY;
      } else if (sts == PaymentStatus.unpaid) {
        return COLOR_RED_MONEY;
      } else if (sts == PaymentStatus.postponed) {
        return COLOR_BLUE_MONEY;
      } else if (sts == PaymentStatus.requested) {
        return COLOR_DARK_GREY;
      }  else if (sts == PaymentStatus.late) {
        return COLOR_RED_MONEY;
      } else {
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
                        'Taksit: $paymentNumber',
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
                            color: getTextColor(status),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          status.getEnum(),
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
