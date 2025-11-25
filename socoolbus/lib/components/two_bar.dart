import 'package:flutter/material.dart';

class two_bar extends StatelessWidget {

  final String text1, text2;

  two_bar({required this.text1, required this.text2});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(

      
      initialIndex: 0,
      length: 2,
      child: Column(children: [
        TabBar(
            tabs: <Widget>[
              Tab(
                text: text1,
              ),
              Tab(
                text: text2,
              ),
            ],
          ),
          
      ],)
    );
  }
}