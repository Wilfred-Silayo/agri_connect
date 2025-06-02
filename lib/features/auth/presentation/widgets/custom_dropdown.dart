import 'package:agri_connect/core/utils/dropdown_controller.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final DropdownController controller;
  final String label;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.controller,
    this.label = 'User Type',
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.controller.value;
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          selectedValue = widget.controller.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items:
          widget.items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          widget.controller.selected = value;
        }
      },
    );
  }
}
