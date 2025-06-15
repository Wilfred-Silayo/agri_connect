import 'package:equatable/equatable.dart';

class MessageStreamParams extends Equatable {
  final String conversationId;
  final String currentUserId;

  const MessageStreamParams({required this.conversationId,required this.currentUserId});

  @override
  List<Object?> get props => [conversationId, currentUserId];
}
