import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/my_enum.dart';

class ExpenseListItem extends StatelessWidget {
  final int installmentTotal = 9;

  const ExpenseListItem({
    super.key,
    required this.title,
    required this.date,
    required this.driver,
    required this.amount,
    required this.note,
  });

  final String title;
  final String date;
  final String driver;
  final int amount;
  final String note;

  Widget build(BuildContext context) {
    //String dateStr = DateFormat.yMMMd().format(DateTime.now());
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
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '$date $driver',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(children: [
                    Text(
                      '$amount₺',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0,
                          color: COLOR_RED_MONEY),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info),
                      color: COLOR_DARK_GREY,
                      onPressed: () {
                        if (note != "") {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                elevation: 16,
                                child: Container(
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 20),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Açıklama:',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                note,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline2,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
