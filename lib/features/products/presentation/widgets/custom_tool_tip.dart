import 'package:flutter/material.dart';

class CustomToolTip extends StatelessWidget {
  const CustomToolTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Only buyers can add items to cart',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.yellow.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.yellow.shade700),
        ),
        child: const Text(
          'Login as a buyer to add to cart',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
