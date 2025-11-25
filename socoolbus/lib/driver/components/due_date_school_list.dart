import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DueDateSchoolListItem extends StatelessWidget {
  const DueDateSchoolListItem(
      {super.key,
      required this.dueId,
      required this.title,
      required this.school,
      required this.paymentInfo,
      required this.edit});

  final String dueId;
  final String title;
  final String school;
  final String paymentInfo;
  final Widget edit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white30,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: CupertinoColors.extraLightBackgroundGray,
              width: MediaQuery.of(context).size.width * 0.90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      SizedBox(
                        height: 50,
                        child: _DescriptionDue(
                          title: title,
                          school: school,
                          paymentInfo: paymentInfo,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40, width: 40, child: edit)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DescriptionDue extends StatelessWidget {
  const _DescriptionDue(
      {required this.title, required this.school, required this.paymentInfo});

  final String title;
  final String school;
  final String paymentInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            school,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14.0, color: Colors.black26),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 15.0)),
              Text(
                paymentInfo,
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
