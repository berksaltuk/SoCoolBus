import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/models/account.dart';

/*
onChanged: (value) {
            setState(() {
              selectedValue = value as String;
            });
          },
*/

class DropdownAccount extends StatefulWidget {
  final List<Account> list;
  final double width;
  String previewText = "Hesap Seç";
  String searchText = "Hesap Ara";
  Function(Account?) onChanged;
  Account? selectedValue;

  DropdownAccount(
      {required this.list,
      required this.onChanged,
      this.selectedValue,
      this.width = double.infinity,
      this.previewText = "Seç",
      this.searchText = "Ara",
      super.key});

  @override
  State<DropdownAccount> createState() => _DropdownButtonSchool();
}

class _DropdownButtonSchool extends State<DropdownAccount> {
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
      //height: 50,
      height: MediaQuery.of(context).size.height * 0.05,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: const Color.fromARGB(40, 44, 36, 36),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Account>(
          searchInnerWidgetHeight: MediaQuery.of(context).size.height * 0.05,
          dropdownDecoration: BoxDecoration(
              border: Border.all(color: COLOR_DARK_GREY),
              color: COLOR_GREY,
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
              .map((item) => DropdownMenuItem<Account>(
                    value: item,
                    child: Text(
                      item.accountName,
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
  }
}
