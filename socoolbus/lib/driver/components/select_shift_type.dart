import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

const List<String> list = <String>[
  'Mehmetçik Ortaokulu - Evden Okula',
  'Bilfen Koleji - Evden Okula',
  'Egebil Koleji - Evden Okula',
  'Mehmetçik Ortaokulu - Okuldan Eve'
];

class DropdownShiftTypeButton extends StatefulWidget {
  const DropdownShiftTypeButton({super.key});

  @override
  State<DropdownShiftTypeButton> createState() =>
      _DropdownShiftTypeButtonState();
}

final List<String> items = [
  'Sabah Okul Giriş',
  'Öğlen Okul Giriş',
  'Öğlen Okul Çıkış',
  'Akşam Okul Çıkış'
];

class _DropdownShiftTypeButtonState extends State<DropdownShiftTypeButton> {
  String dropdownValue = items.first;
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      //width: MediaQuery.of(context).size.width * 0.70,
      //height: 50,
      height: MediaQuery.of(context).size.height * 0.05,
      margin: new EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(5),
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
            'Servis Tipi Seç...',
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
          value: selectedValue,
          onChanged: (value) {
            setState(() {
              selectedValue = value as String;
            });
          },
          buttonHeight: 40,
          buttonWidth: 200,
          itemHeight: 40,
          dropdownMaxHeight: 200,
          searchController: textEditingController,

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
  }
}
