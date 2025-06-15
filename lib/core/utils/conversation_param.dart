import 'package:equatable/equatable.dart';

class ConversationParams extends Equatable {
  final String senderId;
  final String receiverId;

  const ConversationParams({required this.senderId, required this.receiverId});

  @override
  List<Object> get props => [senderId, receiverId];
}
