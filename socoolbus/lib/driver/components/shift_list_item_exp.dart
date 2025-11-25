import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShiftListItemExp extends StatelessWidget {
  final VoidCallback buttonTakenAction;
  final VoidCallback buttonNotTakenAction;
  final VoidCallback buttonWaitedTakenAction;
  final VoidCallback buttonPermittedAction;

  const ShiftListItemExp({
    super.key,
    required this.buttonTakenAction,
    required this.buttonNotTakenAction,
    required this.buttonWaitedTakenAction,
    required this.buttonPermittedAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white30,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: CupertinoColors.extraLightBackgroundGray,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      fixedSize: Size.fromWidth(155)),
                                  onPressed: buttonTakenAction,
                                  child: Text("Zamanında Alındı")),
                            ),
                            SizedBox(width: 10),
                            Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      fixedSize: Size.fromWidth(155)),
                                  onPressed: buttonWaitedTakenAction,
                                  child: Text("Beklendi Alındı")),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.yellow,
                                      fixedSize: Size.fromWidth(155)),
                                  onPressed: buttonPermittedAction,
                                  child: Text("Velisi Bırakacak")),
                            ),
                            SizedBox(width: 10),
                            Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      fixedSize: Size.fromWidth(155)),
                                  onPressed: buttonNotTakenAction,
                                  child: Text("Beklendi Alınmadı")),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
