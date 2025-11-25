import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';

class DriverHomeAgenda extends StatelessWidget {
  DriverHomeAgenda({
    required this.title,
    required this.description,
    required this.source,
    required this.status,
  });

  final String title;
  final String description;
  final String source;
  final String status;

  Widget build(BuildContext context) {
    Color getTextColor(String status) {
      //Logic to be checked if there is + or - sign for amounts
      if (status.startsWith('+')) {
        return COLOR_GREEN_MONEY;
      } else if (status.startsWith('-')) {
        return COLOR_RED_MONEY;
      } else {
        return COLOR_BLACK;
      }
    }

    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6), color: COLOR_WHITE),
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
              ),
            ),
            Text(
              status,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.0,
                  color: getTextColor(status)),
            )
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: Text("$description - $source"),
          ),
        ),
      ]),
    );
  }
}
