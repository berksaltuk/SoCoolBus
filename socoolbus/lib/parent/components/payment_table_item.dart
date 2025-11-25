import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/my_enum.dart';

class PaymentTableItem extends StatelessWidget {
  final int installmentTotal = 9;

  PaymentTableItem(
      {super.key,
      required this.name,
      required this.contract,
      required this.amount,
      required this.monthly,
      required this.status});

  final String? name;
  final String? contract;
  final int amount;
  final int monthly;
  final String status;

  @override
  Widget build(BuildContext context) {
    PaymentStatus statusEnum;
    if (status == 'paid') {
      statusEnum = PaymentStatus.paid;
    } else if (status == 'unpaid') {
      statusEnum = PaymentStatus.unpaid;
    } else if (status == 'postponed') {
      statusEnum = PaymentStatus.postponed;
    } else {
      statusEnum = PaymentStatus.requested;
    }

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
                        name ?? "İsim Bulunamadı...",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Taşıma: $contract',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Aylık",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '$monthly',
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
                          'Toplam $amount₺',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                            color: getTextColor(statusEnum),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          statusEnum.getEnum(),
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
