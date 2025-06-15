import 'package:agri_connect/core/shared/widgets/custom_profile_image.dart';
import 'package:agri_connect/core/shared/widgets/error_display.dart';
import 'package:agri_connect/core/shared/widgets/loader.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/messages/presentation/pages/chat_page.dart';
import 'package:agri_connect/features/messages/presentation/providers/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  List<String> selectedMessages = [];

  void _deleteSelectedMessages(String currentUserId) {
    for (String messageId in selectedMessages) {
      ref
          .read(messageNotifierProvider.notifier)
          .deleteMessage(messageId, currentUserId);
    }

    setState(() {
      selectedMessages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: selectedMessages.isNotEmpty
            ? currentUser == null
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteSelectedMessages(currentUser.id);
                      },
                    ),
                  ]
            : null,
      ),
      body: currentUser == null
          ? const SizedBox()
          : ref.watch(conversationsProvider(currentUser.id)).when(
                data: (data) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var conversation = data[index];
                      var receiverId = currentUser.id != conversation.user1Id? conversation.user1Id:conversation.user2Id;
                      return ref
                          .watch(userDetailsProvider(receiverId))
                          .when(
                              data: (user) {
                                if(user == null){return const SizedBox();}
                                final bool isSelected = selectedMessages
                                    .contains(conversation.id);
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context)=>ChatPage(receiver: user)));
                                      },
                                      onLongPress: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedMessages
                                                .remove(conversation.id);
                                          } else {
                                            selectedMessages
                                                .add(conversation.id);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: ListTile(
                                          title: Text(
                                            user.fullName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          subtitle: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 6.0),
                                            child: Text(
                                              conversation.lastMessage,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                          ),
                                          leading: CustomProfileImage(
                                              url: user.avatarUrl,
                                              radius: 30),
                                          trailing: isSelected
                                              ? const Icon(Icons.check)
                                              : Text(
                                                  DateFormat.Hm().format(
                                                      conversation.lastUpdated),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                        color: Colors.blueGrey,
                                        indent: 85),
                                  ],
                                );
                              },
                              error: (error, st) => null,
                              loading: () => null);
                    },
                  );
                },
                error: (error, stackTrace) => ErrorDisplay(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
              ),
    );
  }
}
