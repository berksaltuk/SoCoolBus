import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/my_enum.dart';

class FinanceList extends StatelessWidget {
  const FinanceList(
      {super.key,
      required this.name,
      required this.operation,
      required this.amount,
      required this.status});

  final String name;
  final String operation;
  final String amount;
  final FinanceStatus status;

  Widget build(BuildContext context) {
    Color getTextColor(String str) {
      //Logic to be checked if there is + or - sign for amounts
      if (str == FinanceStatus.income.toString()) {
        return COLOR_GREEN_MONEY;
      } else if (str == FinanceStatus.expense.toString()) {
        return COLOR_RED_MONEY;
      } else if (str == FinanceStatus.postponed.toString()) {
        return COLOR_BLUE_MONEY;
      } else if (str == FinanceStatus.requested.toString()) {
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
                      child: Container(
                        child: Text(
                          name,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins'),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Text(
                          operation,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Poppins'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0,
                      color: getTextColor(status.toString()),
                    ),
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
