import 'package:equatable/equatable.dart';

class MessageStreamParams extends Equatable {
  final String conversationId;
  final String? query;

  const MessageStreamParams({required this.conversationId, this.query});

  @override
  List<Object?> get props => [conversationId, query];
}
