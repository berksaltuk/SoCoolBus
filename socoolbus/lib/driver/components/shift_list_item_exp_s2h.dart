import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShiftListItemExpS2HNotStarted extends StatelessWidget {
  final VoidCallback buttonInVehicleAction;
  final VoidCallback buttonNotInVehicleAction;

  const ShiftListItemExpS2HNotStarted({
    super.key,
    required this.buttonInVehicleAction,
    required this.buttonNotInVehicleAction,
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
                                      fixedSize: const Size.fromWidth(155)),
                                  onPressed: buttonInVehicleAction,
                                  child: const Text("Araca Bindi")),
                            ),
                            const SizedBox(width: 10),
                            Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      fixedSize: const Size.fromWidth(155)),
                                  onPressed: buttonNotInVehicleAction,
                                  child: const Text("Binmedi")),
                            ),
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

class ShiftListItemExpS2HStarted extends StatelessWidget {
  final VoidCallback buttonDroppedHomeAction;
  final VoidCallback buttonDroppedLocationAction;

  const ShiftListItemExpS2HStarted({
    super.key,
    required this.buttonDroppedHomeAction,
    required this.buttonDroppedLocationAction,
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
                                      fixedSize: const Size.fromWidth(155)),
                                  onPressed: buttonDroppedHomeAction,
                                  child: const Text("Eve Bırakıldı")),
                            ),
                            const SizedBox(width: 10),
                            Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      fixedSize: const Size.fromWidth(155)),
                                  onPressed: buttonDroppedLocationAction,
                                  child: const Text("Konuma Bırakıldı")),
                            ),
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