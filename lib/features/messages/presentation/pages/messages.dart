import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  List<String> selectedMessages = [];

  // void _deleteSelectedMessages(String currentUserId) {
  //   for (String messageId in selectedMessages) {
  //     ref
  //         .read(messageControllerProvider.notifier)
  //         .deleteMessage(messageId, currentUserId);
  //   }

  //   setState(() {
  //     selectedMessages.clear();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text('Conversations')),
      body: Center(child: Text('your conversations will appear here')),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Messages'),
    //     actions: selectedMessages.isNotEmpty
    //         ? currentUser == null
    //             ? null
    //             : [
    //                 IconButton(
    //                   icon: const Icon(Icons.delete),
    //                   onPressed: () {
    //                     _deleteSelectedMessages(currentUser.uid);
    //                   },
    //                 ),
    //               ]
    //         : null,
    //   ),
    //   body: currentUser == null
    //       ? const SizedBox()
    //       : ref.watch(usersChatProvider(currentUser.uid)).when(
    //             data: (data) {
    //               return ListView.builder(
    //                 shrinkWrap: true,
    //                 itemCount: data.length,
    //                 itemBuilder: (context, index) {
    //                   var userData = data[index];
    //                   return ref
    //                       .watch(userDetailsProvider(userData.contactId))
    //                       .when(
    //                           data: (user) {
    //                             final bool isSelected = selectedMessages
    //                                 .contains(userData.contactId);
    //                             return Column(
    //                               children: [
    //                                 InkWell(
    //                                   onTap: () {
    //                                     Navigator.push(
    //                                         context, ChatScreen.route(user));
    //                                   },
    //                                   onLongPress: () {
    //                                     setState(() {
    //                                       if (isSelected) {
    //                                         selectedMessages
    //                                             .remove(userData.contactId);
    //                                       } else {
    //                                         selectedMessages
    //                                             .add(userData.contactId);
    //                                       }
    //                                     });
    //                                   },
    //                                   child: Padding(
    //                                     padding:
    //                                         const EdgeInsets.only(bottom: 8.0),
    //                                     child: ListTile(
    //                                       title: Text(
    //                                         userData.name,
    //                                         style: const TextStyle(
    //                                           fontSize: 18,
    //                                         ),
    //                                       ),
    //                                       subtitle: Padding(
    //                                         padding:
    //                                             const EdgeInsets.only(top: 6.0),
    //                                         child: Text(
    //                                           userData.lastMessage,
    //                                           overflow: TextOverflow.ellipsis,
    //                                           style:
    //                                               const TextStyle(fontSize: 15),
    //                                         ),
    //                                       ),
    //                                       leading: CustomCircularAvator(
    //                                           photoUrl: userData.profilePic,
    //                                           radius: 30),
    //                                       trailing: isSelected
    //                                           ? const Icon(Icons.check)
    //                                           : Text(
    //                                               DateFormat.Hm().format(
    //                                                   userData.timeSent),
    //                                               style: const TextStyle(
    //                                                 color: Colors.grey,
    //                                                 fontSize: 13,
    //                                               ),
    //                                             ),
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 const Divider(
    //                                     color: Pallete.dividerColor,
    //                                     indent: 85),
    //                               ],
    //                             );
    //                           },
    //                           error: (error, st) => null,
    //                           loading: () => null);
    //                 },
    //               );
    //             },
    //             error: (error, stackTrace) => ErrorText(
    //               error: error.toString(),
    //             ),
    //             loading: () => const Loader(),
    //           ),
    // );
  }
}
