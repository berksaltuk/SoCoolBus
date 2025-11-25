import 'package:flutter/services.dart';
class TurkishPlateNumberFormatter extends TextInputFormatter {
  static const int maxLength = 13;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = formatPlateNumber(newValue.text);
    return TextEditingValue(
      text: formattedText,
      selection: getSelection(formattedText, newValue.selection),
      composing: TextRange.empty,
    );
  }

  String formatPlateNumber(String inputText) {
    inputText = inputText.replaceAll(' ', '');

    List<String> parts = [];
    int startIndex = 0;

    // Format the city code part
    if (inputText.length >= 2) {
      parts.add(inputText.substring(0, 2));
      startIndex = 2;
    }

    // Format the second part (any characters, capitalized)
    if (inputText.length > startIndex) {
      String secondPart = inputText.substring(startIndex);
      String formattedSecondPart = secondPart.toUpperCase();
      parts.add(formattedSecondPart);
      startIndex += (formattedSecondPart.length);
    }

    // Format the last part (at least 2 digits)
    if (inputText.length >= startIndex) {
      String lastPart = inputText.substring(startIndex);
      String formattedLastPart = lastPart.replaceAll(RegExp(r'[^0-9]'), '');
      parts.add(formattedLastPart);
    }

    return parts.join(' ');
  }

  TextSelection getSelection(String formattedText, TextSelection currentSelection) {
    int start = currentSelection.start;
    int end = currentSelection.end;
    int formattedLength = formattedText.length;
    if (start > formattedLength) {
      start = formattedLength;
    }
    if (end > formattedLength) {
      end = formattedLength;
    }
    return TextSelection(
      baseOffset: start,
      extentOffset: end,
    );
  }
}

