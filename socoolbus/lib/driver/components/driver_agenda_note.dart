import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/constants.dart';

class DriverAgendaNote extends StatelessWidget {
  DriverAgendaNote({
    required this.person,
    required this.school,
    required this.issuedby,
    required this.note,
    required this.date,
  });

  final String person;
  final String school;
  final String issuedby;
  final String note;
  final DateTime date;

  Widget build(BuildContext context) {
    String dateFormat = DateFormat('dd/MM/yyyy').format(date);
    return Column(children: [
      Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6), color: COLOR_WHITE),
        margin: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  Text(
                    school,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    '$issuedby',
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
            SizedBox(
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
                      note,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 5),
                    Text(
                      '$dateFormat',
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
