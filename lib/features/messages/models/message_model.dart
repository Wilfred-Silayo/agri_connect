class Message {
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
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'isSeen': isSeen,
      'isDeletedBySender': isDeletedBySender,
      'isDeletedByReceiver': isDeletedByReceiver,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      conversationId: map['conversationId'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      text: map['text'] as String,
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] as int),
      isSeen: map['isSeen'] as bool,
      isDeletedBySender: map['isDeletedBySender'] as bool,
      isDeletedByReceiver: map['isDeletedByReceiver'] as bool,
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
