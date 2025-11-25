import 'package:flutter/material.dart';


class dropdown_menu extends StatefulWidget {

  final List<String> list;

  dropdown_menu({required this.list});

  @override
  State<dropdown_menu> createState() => _dropdown_menu_state(list: list);
}

class _dropdown_menu_state extends State<dropdown_menu> {

  final List<String> list;

_dropdown_menu_state({required this.list});

String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Color.fromARGB(255, 99, 54, 17)),
      underline: Container(
        height: 2,
        color: Color.fromARGB(255, 244, 161, 53),
      ),
      onChanged: (String? valuea) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = valuea!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}