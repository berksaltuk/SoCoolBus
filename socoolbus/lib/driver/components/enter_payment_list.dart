import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/driver/components/driver_edit_payment_button.dart';

class EnterPaymentListItem extends StatelessWidget {
  const EnterPaymentListItem(
      {super.key,
      required this.paymentId,
      required this.title,
      required this.user,
      required this.paymentAmount,
      required this.paymentInfo});

  final String paymentId;
  final String title;
  final String user;
  final int paymentAmount;
  final String paymentInfo;

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
              width: MediaQuery.of(context).size.width * 0.88,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      SizedBox(
                        height: 50,
                        child: _Description(
                          title: title,
                          user: user,
                          paymentAmount: paymentAmount.toString(),
                          paymentInfo: paymentInfo,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40, width: 40, child: EditPaymentButton(paymentId: paymentId, leftAmount: paymentAmount))
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
  const _Description(
      {required this.title,
      required this.user,
      required this.paymentAmount,
      required this.paymentInfo});

  final String title;
  final String user;
  final String paymentAmount;
  final String paymentInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            user,
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
              const Padding(padding: EdgeInsets.symmetric(horizontal: 6.0)),
              Text(
                paymentAmount,
                style: const TextStyle(fontSize: 14.0),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 6.0)),
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
