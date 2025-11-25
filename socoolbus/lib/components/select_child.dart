import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:my_app/models/student.dart';

/*
onChanged: (value) {
            setState(() {
              selectedValue = value as String;
            });
          },
*/

class DropdownButtonChild extends StatefulWidget {
  final List<Student> list;
  final double width;
  String previewText = "Öğrenci Seç";
  String searchText = "Öğrenci Ara";
  Function(Student?) onChanged;
  Student? selectedValue;

  DropdownButtonChild(
      {required this.list,
      required this.onChanged,
      this.selectedValue,
      this.width = double.infinity,
      this.previewText = "Öğrenci Seç",
      this.searchText = "Öğrenci Ara",
      super.key});

  @override
  State<DropdownButtonChild> createState() => _DropdownButtonChildState();
}

class _DropdownButtonChildState extends State<DropdownButtonChild> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    //textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: MediaQuery.of(context).size.height * 0.05,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: const Color.fromARGB(40, 44, 36, 36),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Student>(
          searchInnerWidgetHeight: MediaQuery.of(context).size.height * 0.05,
          dropdownDecoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: const Color.fromARGB(255, 213, 216, 219),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          isExpanded: true,
          hint: Text(
            widget.previewText,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: widget.list
              .map((item) => DropdownMenuItem<Student>(
                    value: item,
                    child: Text(
                      item.name,
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
                hintText: widget.searchText,
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          searchMatchFn: (item, searchValue) {
            return (item.value
                .toString()
                .toUpperCase()
                .contains(searchValue.toUpperCase()));
          },
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
