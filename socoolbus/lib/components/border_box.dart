import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';

class BorderBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double width, height;

  const BorderBox(
      {Key? key,
      required this.padding,
      required this.width,
      required this.height,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: COLOR_WHITE,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: COLOR_GREY, width: 2),
      ),
      child: Center(child: child),
    );
  }
}
