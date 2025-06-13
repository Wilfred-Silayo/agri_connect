import 'package:agri_connect/features/auth/models/user_model.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final UserModel recieverUser;

  const BottomChatField({super.key, required this.recieverUser});
  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  // void sendTextMessage(UserModel currentUser) async {
  //   if (isShowSendButton) {
  //     ref.read(messageControllerProvider.notifier).sendTextMessage(
  //         context: context,
  //         receiver: widget.recieverUser,
  //         sender: currentUser,
  //         text: _messageController.text.trim());
  //     setState(() {
  //       _messageController.text = '';
  //     });
  //   }
  // }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;

    return currentUser == null
        ? const SizedBox()
        : Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        maxHeight: 150,
                      ),
                      child: Scrollbar(
                        child: TextFormField(
                          controller: _messageController,
                          focusNode: focusNode,
                          maxLines: null,
                          style: const TextStyle(color: Colors.black),
                          onChanged: (val) {
                            setState(() {
                              isShowSendButton = val.trim().isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.grey[700]),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => {}, // sendTextMessage(currentUser),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF128C7E),
                      radius: 25,
                      child: Icon(
                        isShowSendButton ? Icons.send : null,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
  }
}
