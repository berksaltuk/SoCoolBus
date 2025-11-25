import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:my_app/constants.dart';

class DropdownGeneral extends StatefulWidget {
  final List<String> list;
  final double width;
  String previewText = "Seç";
  String searchText = "Ara";
  Function(String?) onChanged;
  String? selectedValue;
  bool searchable;

  DropdownGeneral(
      {required this.list,
      required this.onChanged,
      required this.selectedValue,
      required this.searchable,
      this.width = double.infinity,
      this.previewText = "Seç",
      this.searchText = "Ara",
      super.key});

  @override
  State<DropdownGeneral> createState() => _DropdownButtonGeneral();
}

class _DropdownButtonGeneral extends State<DropdownGeneral> {
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchable) {
      return Container(
        //width: double.infinity,
        width: widget.width,
        //height: 50,
        height: MediaQuery.of(context).size.height * 0.1,
        margin: new EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: COLOR_LIGHT_GREY,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            dropdownDecoration: BoxDecoration(
                border: Border.all(color: COLOR_GREY),
                color: COLOR_GREY,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.previewText,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            items: widget.list
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
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
                  .toLowerCase()
                  .contains(searchValue.toLowerCase()));
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
    } else {
      return Container(
        //width: double.infinity,
        width: widget.width,
        //height: 50,
        height: MediaQuery.of(context).size.height * 0.05,
        margin: new EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Color.fromARGB(40, 44, 36, 36),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            dropdownDecoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Color.fromARGB(255, 213, 216, 219),
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
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
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
          ),
        ),
      );
    }
  }
}

/*
onChanged: (value) {
            setState(() {
              selectedValue = value as String;
            });
          },
*/
