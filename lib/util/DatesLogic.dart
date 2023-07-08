import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef StateUpdateCallback = void Function();

class DateLogic {
  DateTime? selectedDate;
  StateUpdateCallback? stateUpdateCallback;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (stateUpdateCallback != null) {
      if (pickedDate != null) {
        selectedDate = pickedDate;
        stateUpdateCallback!();
      } else {
        selectedDate = DateTime.now();
        stateUpdateCallback!();
      }
    }
  }
}
