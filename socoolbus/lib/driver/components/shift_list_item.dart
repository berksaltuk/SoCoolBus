import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';

class ShiftListItem extends StatelessWidget {
  const ShiftListItem(
      {super.key,
      required this.thumbnail,
      required this.title,
      required this.user,
      required this.dateof,
      required this.payment,
      required this.notification});

  final Widget thumbnail;
  final String title;
  final String user;
  final DateTime dateof;
  final String payment;
  final Widget notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: COLOR_LIGHT_GREY,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: CupertinoColors.extraLightBackgroundGray,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: 10,
                          child: thumbnail),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: _Description(
                          title: title,
                          user: user,
                          payment: payment,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: notification),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    required this.title,
    required this.user,
    required this.payment,
  });

  final String title;
  final String user;
  final String payment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 10.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            user,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14.0),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Text(
                  payment,
                  style: const TextStyle(fontSize: 10.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
