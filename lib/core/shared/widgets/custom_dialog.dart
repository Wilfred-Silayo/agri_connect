import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final void Function() onConfirm;
  final String title;
  final String content;

  const CustomDialog({
    super.key,
    required this.onConfirm,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
