import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
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
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;

    return Center(child: Text("message list"));

    // return currentUser == null
    //     ? const SizedBox()
    //     : StreamBuilder(
    //         stream: ref
    //             .read(messageControllerProvider.notifier)
    //             .chatStream(currentUser.uid, widget.recieverUserId),
    //         builder: (context, snapshot) {
    //           if (snapshot.connectionState == ConnectionState.waiting) {
    //             return const SizedBox();
    //           }

    //           SchedulerBinding.instance.addPostFrameCallback((_) {
    //             messageController
    //                 .jumpTo(messageController.position.maxScrollExtent);
    //           });
    //           return ListView.builder(
    //             controller: messageController,
    //             itemCount: snapshot.data!.length,
    //             itemBuilder: (context, index) {
    //               final messageData = snapshot.data![index];
    //               var timeSent = DateFormat.Hm().format(messageData.timeSent);

    //               if (!messageData.isSeen &&
    //                   messageData.receiverid == currentUser.uid) {
    //                 ref
    //                     .read(messageControllerProvider.notifier)
    //                     .setChatMessageSeen(
    //                       widget.recieverUserId,
    //                       currentUser.uid,
    //                       messageData.id,
    //                     );
    //               }
    //               if (messageData.senderId == currentUser.uid) {
    //                 return MyMessageCard(
    //                   message: messageData.text,
    //                   date: timeSent,
    //                   isSeen: messageData.isSeen,
    //                 );
    //               }
    //               return SenderMessageCard(
    //                 message: messageData.text,
    //                 date: timeSent,
    //               );
    //             },
    //           );
    //         });
  }
}
