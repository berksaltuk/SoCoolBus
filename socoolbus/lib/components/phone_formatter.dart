import 'package:flutter/services.dart';

class TurkishPhoneNumberFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final List<String> segments = <String>[];
    final String inputText =
        newValue.text.replaceAll('+90', '').replaceAll(' ', '');
    segments.addAll(_splitString(inputText, 3));
    final String formatted = '+90 ' + segments.join(' ');
    return TextEditingValue(
      text: formatted,
      selection: _updateCursorPosition(formatted, newValue),
      composing: TextRange.empty,
    );
  }

  List<String> _splitString(String value, int chunkSize) {
    final List<String> chunks = [];
    for (var i = 0; i < value.length; i += chunkSize) {
      chunks.add(value.substring(i, i + chunkSize));
    }
    return chunks;
  }

  TextSelection _updateCursorPosition(
      String formattedValue, TextEditingValue editingValue) {
    final int newTextLength = formattedValue.length;
    final int oldTextLength = editingValue.text.length;
    final int cursorPosition = editingValue.selection.start;

    final int selectionBefore = editingValue.selection.baseOffset;
    final int selectionAfter = editingValue.selection.extentOffset;
    final int selectionDelta = selectionAfter - selectionBefore;

    final int newPosition =
        cursorPosition + newTextLength - oldTextLength + selectionDelta;
    return TextSelection.collapsed(offset: newPosition);
  }
}
