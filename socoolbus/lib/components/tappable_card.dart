import 'package:flutter/material.dart';

class tappable_card extends StatelessWidget {
  final VoidCallback onTap;
  final String month;
  final String name;
  final String status;
  final String delayStatus;

  tappable_card(
      {required this.onTap,
      required this.month,
      required this.name,
      required this.status,
      required this.delayStatus});

  @override
  Widget build(BuildContext context) {
      Color delayColor;
    if(status == "Yapılmadı")
      delayColor=Colors.red;
      else if (status == "Ertelendi")
      delayColor = Colors.blue;
      else
      delayColor=Colors.green;

    return Center(
      child: Card(
        child: InkWell(
            splashColor: Color.fromARGB(255, 157, 146, 54).withAlpha(30),
            onTap: onTap,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      children: [Text("Ay"), Text(month, style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
            ),)],
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      children: [Text("Öğrenci Adı"), Text(name, style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
            ),)],
                    ),
                    decoration: BoxDecoration(
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      children: [Text("Durumu"), Text(status, style: TextStyle(
                        color: delayColor,
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
            ),)],
                    ),
                    decoration: BoxDecoration(
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      children: [Text("Gecikme"), Text(delayStatus, style: TextStyle(
                        color: delayColor,
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
            ),)],
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
