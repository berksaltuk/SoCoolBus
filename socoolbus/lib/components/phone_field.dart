import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:my_app/constants.dart';
import 'package:my_app/models/student.dart';

class PhoneField extends StatefulWidget {
  TextEditingController controller = TextEditingController();
  Color color = Colors.white;
  bool readOnly;

  PhoneField({required this.controller, required this.color, this.readOnly = false, super.key});

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  @override
  void dispose() {
    //textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: widget.controller,
      readOnly: widget.readOnly,
      disableLengthCheck: false,
      invalidNumberMessage: 'Geçersiz telefon numarası',
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.color,
        counterText: '',
        hintText: 'Telefon',
        enabled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: COLOR_DARK_GREY),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: COLOR_LIGHT_GREY),
        ),
      ),
      initialCountryCode: 'TR',
      onChanged: (phone) {},
    );
  }
}
