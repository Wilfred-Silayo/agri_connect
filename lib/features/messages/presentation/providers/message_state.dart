import 'package:flutter/foundation.dart';

@immutable
sealed class MessageState {
  const MessageState();
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {
  final String message;
  const MessageLoading(this.message);
}

class MessageSuccess extends MessageState {
  final String message;
  const MessageSuccess(this.message);
}

class MessageFailure extends MessageState {
  final String message;
  const MessageFailure(this.message);
}
