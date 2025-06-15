import 'package:flutter/material.dart';

class ReceiverMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final bool isSeen;
  final VoidCallback? onLongPress;

  const ReceiverMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.isSeen,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Colors.blue[100],
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 30, top: 5, bottom: 20),
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.done_all,
                        size: 20,
                        color: isSeen ? Colors.blue : Colors.black38,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
