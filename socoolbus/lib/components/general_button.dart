import 'package:flutter/material.dart';

class GeneralButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  //final Gradient gradient;

  GeneralButton({required this.onPressed, required this.child});
  TextStyle basicStyle = const TextStyle(color: Colors.white, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      elevation: 5.0,
      height: 40,
      color: Colors.orange,
      onPressed: onPressed,
      splashColor: Color.fromRGBO(255, 235, 59, 1),
      padding: const EdgeInsets.all(10),
      child: child,
    );
  }
}
