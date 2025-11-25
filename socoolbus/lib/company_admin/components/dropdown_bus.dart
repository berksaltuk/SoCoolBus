import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/models/school.dart';

import '../../models/school_bus.dart';

class DropdownButtonSchoolBus extends StatefulWidget {
  final List<SchoolBus> list;
  final double width;
  String previewText = "Araç Seç";
  Function(SchoolBus?) onChanged;
  SchoolBus? selectedValue;

  DropdownButtonSchoolBus(
      {required this.list,
      required this.onChanged,
      this.selectedValue,
      this.width = double.infinity,
      this.previewText = "Araç Seç",
      super.key});

  @override
  State<DropdownButtonSchoolBus> createState() => _DropdownButtonSchoolBus();
}

class _DropdownButtonSchoolBus extends State<DropdownButtonSchoolBus> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    //textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: double.infinity,
      width: widget.width,
      height: 50,
      //height: MediaQuery.of(context).size.height * 0.05,
      margin: new EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: COLOR_DARK_GREY),
          color: COLOR_WHITE,
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<SchoolBus>(
          searchInnerWidgetHeight: MediaQuery.of(context).size.height * 0.05,
          dropdownDecoration: BoxDecoration(
              border: Border.all(color: COLOR_GREY),
              color: COLOR_GREY,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          isExpanded: true,
          hint: Text(
            widget.previewText,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: widget.list
              .map((item) => DropdownMenuItem<SchoolBus>(
                    value: item,
                    child: Text(
                      item.plate,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
              .toList(),
          value: widget.selectedValue,
          onChanged: widget.onChanged,
          buttonHeight: 40,
          buttonWidth: 200,
          itemHeight: 40,
          dropdownMaxHeight: 200,
          searchController: textEditingController,
          searchInnerWidget: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 4,
              right: 8,
              left: 8,
            ),
            child: TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          //This to clear the search value when you close the menu
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              textEditingController.clear();
            }
          },
        ),
      ),
    );
  }
}
