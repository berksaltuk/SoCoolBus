
import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';

class ParentReportItem extends StatelessWidget {
  const ParentReportItem({
    super.key,
    required this.mainHeader,
    required this.summary,
    required this.studentName,
    required this.detailedDescription,
    required this.dateof,
  });
  final String mainHeader;
  final String summary;
  final String studentName;
  final String detailedDescription;
  final String dateof;

  @override
  Widget build(BuildContext context) {


    Color getTextColor(String sts) {
      //Logic to be checked if there is + or - sign for amounts
      if (sts == "Zamanında Alındı") {
        return COLOR_GREEN_MONEY;
      } else if (sts == "Servise Binmedi") {
        return COLOR_RED_MONEY;
      } else if (sts == "Servise Bindi") {
        return COLOR_BLUE_MONEY;
      }
      return COLOR_BLACK;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(height: 50, width: 10, child: Container(
                                            decoration: BoxDecoration(
                                                color: getTextColor(mainHeader)),
                                          ),),
              SizedBox(
                height: 80,
                child: _Description(
                  mainHeader: mainHeader,
                  summary: summary,
                  studentName: studentName,
                  detailedDescription: detailedDescription,
                  dateof: dateof,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    required this.mainHeader,
    required this.summary,
    required this.studentName,
    required this.detailedDescription,
    required this.dateof,
  });

  final String mainHeader;
  final String summary;
  final String studentName;
  final String detailedDescription;
  final String dateof;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            mainHeader,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            summary,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            studentName,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            detailedDescription,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            '$dateof',
            style: const TextStyle(fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}



