import 'package:flutter/material.dart';

class CustomRadioButton extends StatefulWidget {
  int selected;
  String text;
  String name;
  int index;
  Function() onPressed;
  CustomRadioButton(
      {required this.selected,
      required this.index,
      required this.name,
      required this.text,
      required this.onPressed,
      super.key});
  @override
  State<CustomRadioButton> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<CustomRadioButton> {
  late int value;

  @override
  Widget build(BuildContext context) {
    value = widget.selected;
    Color color = Colors.green;
    if (widget.index != 0) {
      color = Colors.red;
    }
    return OutlinedButton(
        onPressed: widget.onPressed,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.topLeft,
          fixedSize: Size.fromWidth(MediaQuery.of(context).size.width * 0.92),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side:
              BorderSide(color: (value == widget.index) ? color : Colors.black),
        ),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.width * 0.1,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: (value == widget.index) ? color : Colors.grey),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.1,
              child: Center(
                child: //[
                    Text(
                  widget.text,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                /*Text(
                    name,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  )*/
                //],
              ),
            )
          ],
        ));
  }
}
