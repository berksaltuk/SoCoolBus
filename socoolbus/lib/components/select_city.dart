import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:my_app/constants.dart';

const List<String> list = cityList;

class DropdownButtonCity extends StatefulWidget {
  void Function(String?)? onChange;
  String? value;
  DropdownButtonCity({required this.onChange, required this.value, super.key});

  @override
  State<DropdownButtonCity> createState() => _DropdownButtonCityState();
}

const List<String> items = list;

class _DropdownButtonCityState extends State<DropdownButtonCity> {
  String dropdownValue = list.first;
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        width: double.infinity,
        //width: MediaQuery.of(context).size.width * 0.70,
        //height: 50,
        height: 36,

        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              'Şehir Seç',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
            items: items
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
            value: widget.value,
            onChanged: widget.onChange,
            buttonHeight: 40,
            buttonWidth: 200,
            itemHeight: 40,
            dropdownMaxHeight: 200,
            searchController: textEditingController,

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
      ),
    );
  }
}
