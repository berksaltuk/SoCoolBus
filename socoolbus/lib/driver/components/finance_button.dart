import 'package:flutter/material.dart';
import 'package:my_app/constants.dart';

class FinanceButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  //final Gradient gradient;

  FinanceButton({required this.onPressed, required this.child});
  TextStyle basicStyle = const TextStyle(color: Colors.white, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: COLOR_ORANGE,
          padding: EdgeInsets.all(10),
          minimumSize: Size.fromHeight(size.height *
              0.04), // fromHeight use double.infinity as width and size * 0.04 is the button
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
