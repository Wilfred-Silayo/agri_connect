import 'package:flutter/material.dart';

class DropdownController extends ValueNotifier<String> {
  DropdownController(super.value);

  String get selected => value;

  set selected(String newValue) {
    value = newValue;
  }
}
