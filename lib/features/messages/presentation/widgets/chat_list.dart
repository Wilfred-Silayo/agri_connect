import 'package:agri_connect/core/utils/conversation_param.dart';
import 'package:agri_connect/core/utils/message_param.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/messages/presentation/providers/message_provider.dart';
import 'package:agri_connect/features/messages/presentation/widgets/receiver_message_card.dart';
import 'package:agri_connect/features/messages/presentation/widgets/sender_message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUserId;
  const ChatList({super.key, required this.recieverUserId});

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void scrollToBottomIfNeeded() {
    if (!messageController.hasClients) return;
    final distanceFromBottom =
        messageController.position.maxScrollExtent - messageController.offset;
    if (distanceFromBottom < 100) {
      messageController.jumpTo(messageController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    if (currentUser == null) return const SizedBox();

    final conversationAsync = ref.watch(
      conversationProvider(
        ConversationParams(
          senderId: currentUser.id,
          receiverId: widget.recieverUserId,
        ),
      ),
    );

    return conversationAsync.when(
      data: (conversation) {
        if (conversation == null) {
          return const Center(child: Text('Start a conversation...'));
        }

        final messageStream = ref.watch(
          messageStreamProvider(
            MessageStreamParams(
              conversationId: conversation.id,
              query: widget.recieverUserId,
            ),
          ),
        );

        return messageStream.when(
          data: (messages) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              scrollToBottomIfNeeded();
            });

            return ListView.builder(
              controller: messageController,
              itemCount: messages.length,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemBuilder: (context, index) {
                final message = messages[index];
                final timeSent = DateFormat.Hm().format(message.timeSent);

                // Mark as seen if receiver and not seen
                if (!message.isSeen && message.receiverId == currentUser.id) {
                  ref
                      .read(messageNotifierProvider.notifier)
                      .markMessageAsSeen(message.id);
                }

                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text('Delete Message'),
                            content: const Text(
                              'Do you want to delete this message?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(messageNotifierProvider.notifier)
                                      .deleteMessage(
                                        message.id,
                                        currentUser.id,
                                      );
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                    );
                  },
                  child:
                      message.senderId == currentUser.id
                          ? ReceiverMessageCard(
                            message: message.text,
                            date: timeSent,
                            isSeen: message.isSeen,
                          )
                          : SenderMessageCard(
                            message: message.text,
                            date: timeSent,
                          ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: ${err.toString()}')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: ${err.toString()}')),
    );
  }
}
