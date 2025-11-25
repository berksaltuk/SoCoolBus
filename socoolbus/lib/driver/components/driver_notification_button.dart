import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/components/common_methods.dart';
import 'package:my_app/constants.dart';
import 'package:http/http.dart' as http;

class NotificationButton extends StatefulWidget {
  //final Gradient gradient;
  final String studentID;
  final Future<String> shiftID;

  NotificationButton(
      {required this.studentID, required this.shiftID, super.key});

  TextStyle basicStyle = const TextStyle(color: Colors.white, fontSize: 16);
  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  static const IconData notifications =
      IconData(0xe44f, fontFamily: 'MaterialIcons');

  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            if (!pressed) {
              pressed = !pressed;
              callParent(widget.shiftID, widget.studentID);
            }
          });
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                pressed ? Colors.green : Colors.orange),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ))),
        child: Row(
          children: [
            const Icon(
              notifications,
              color: Colors.black,
              size: 20.0,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              pressed ? "Çağrı OK" : "Çağrı At",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ));

/*     ElevatedButton.icon(
      icon: Icon(
        notifications,
        size: 20,
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: pressed ? Colors.green : Colors.orange),
      onPressed: () {
        setState(() {
          pressed = !pressed;
        });
      },
      label: Text(
        pressed ? "Çağrı OK" : "Çağrı At",
        style: TextStyle(fontSize: 10),
      ),
    ); */
  }

  void callParent(Future<String> shiftID, String studentID) async {
    var url = Uri.http(deployURL, 'sms/callParent');
    print(url);
    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getUserToken(),
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    }, body: {
      'shiftID': await shiftID,
      'studentID': studentID,
    });
    print(response.body);
  }
}
