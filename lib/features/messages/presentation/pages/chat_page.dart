import 'package:agri_connect/core/shared/widgets/custom_profile_image.dart';
import 'package:agri_connect/features/auth/models/user_model.dart';
import 'package:agri_connect/features/messages/presentation/widgets/bottom_chat_field.dart';
import 'package:agri_connect/features/messages/presentation/widgets/chat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerWidget {
  final UserModel receiver;
  const ChatPage({super.key, required this.receiver});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar:AppBar(
        centerTitle: false,
        title:ListTile(
          leading:CustomProfileImage(url: receiver.avatarUrl, radius: 25,),
          title:Text(receiver.fullName),
        ),),
       body: Column(
          children: [
            Expanded(
              child: ChatList(
                recieverUserId: receiver.id,
              ),
            ),
            BottomChatField(
              recieverUser: receiver,
            ),
          ],
        ),
    );
  }
}
