import 'package:agri_connect/features/auth/models/user_model.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/messages/models/message_model.dart';
import 'package:agri_connect/features/messages/presentation/providers/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final UserModel recieverUser;

  const BottomChatField({super.key, required this.recieverUser});

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isShowSendButton = false;
  bool isLoading = false;

  void sendTextMessage(User currentUser) async {
    setState(() => isLoading = true);

    final trimmed = _messageController.text.trim();
    if (trimmed.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    var conversation = await ref
        .read(messageNotifierProvider.notifier)
        .getConversationBetween(currentUser.id, widget.recieverUser.id);

    conversation ??= await ref
        .read(messageNotifierProvider.notifier)
        .createConversation(currentUser.id, widget.recieverUser.id);

    final message = Message.create(
      conversationId: conversation.id,
      senderId: currentUser.id,
      receiverId: widget.recieverUser.id,
      text: trimmed,
    );

    await ref.read(messageNotifierProvider.notifier).sendMessage(message);

    _messageController.clear();
    setState(() {
      isLoading = false;
      isShowSendButton = false;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  @override
  void dispose() {
    _messageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;

    if (currentUser == null) return const SizedBox();

    return Column(
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
                      style: const TextStyle(color: Colors.black87),
                      onChanged: (val) {
                        setState(
                          () => isShowSendButton = val.trim().isNotEmpty,
                        );
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
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                        onTap: () => sendTextMessage(currentUser),
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFF128C7E),
                          radius: 25,
                          child: Icon(
                            isShowSendButton ? Icons.send : Icons.mic,
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
