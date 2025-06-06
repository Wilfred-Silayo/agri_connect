import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final Object error;
  const ErrorDisplay({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error: $error'));
  }
}
