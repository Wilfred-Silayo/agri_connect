import 'package:uuid/uuid.dart';

class Message {
  static final Uuid _uuid = Uuid();

  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timeSent;
  final bool isSeen;
  final bool isDeletedBySender;
  final bool isDeletedByReceiver;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timeSent,
    required this.isSeen,
    required this.isDeletedBySender,
    required this.isDeletedByReceiver,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timeSent,
    bool? isSeen,
    bool? isDeletedBySender,
    bool? isDeletedByReceiver,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timeSent: timeSent ?? this.timeSent,
      isSeen: isSeen ?? this.isSeen,
      isDeletedBySender: isDeletedBySender ?? this.isDeletedBySender,
      isDeletedByReceiver: isDeletedByReceiver ?? this.isDeletedByReceiver,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'text': text,
      'time_sent': timeSent.toIso8601String(),
      'is_seen': isSeen,
      'is_deleted_by_sender': isDeletedBySender,
      'is_deleted_by_receiver': isDeletedByReceiver,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      text: map['text'] as String,
      timeSent: DateTime.parse(map['time_sent']),
      isSeen: map['is_seen'] as bool,
      isDeletedBySender: map['is_deleted_by_sender'] as bool,
      isDeletedByReceiver: map['is_deleted_by_receiver'] as bool,
    );
  }

  factory Message.create({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String text,
  }) {
    return Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      timeSent: DateTime.now(),
      isSeen: false,
      isDeletedBySender: false,
      isDeletedByReceiver: false,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, receiverId: $receiverId, text: $text, timeSent: $timeSent, isSeen: $isSeen, isDeletedBySender: $isDeletedBySender, isDeletedByReceiver: $isDeletedByReceiver)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.conversationId == conversationId &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.text == text &&
        other.timeSent == timeSent &&
        other.isSeen == isSeen &&
        other.isDeletedBySender == isDeletedBySender &&
        other.isDeletedByReceiver == isDeletedByReceiver;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        conversationId.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        text.hashCode ^
        timeSent.hashCode ^
        isSeen.hashCode ^
        isDeletedBySender.hashCode ^
        isDeletedByReceiver.hashCode;
  }
}
