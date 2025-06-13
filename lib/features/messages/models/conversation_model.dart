class Conversation {
  final String id;
  final String user1Id;
  final String user2Id;
  final String lastMessage;
  final DateTime lastUpdated;
  final bool isSeenByUser1;
  final bool isSeenByUser2;
  final bool isDeletedByUser1;
  final bool isDeletedByUser2;

  Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.lastMessage,
    required this.lastUpdated,
    required this.isSeenByUser1,
    required this.isSeenByUser2,
    required this.isDeletedByUser1,
    required this.isDeletedByUser2,
  });

  Conversation copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    String? lastMessage,
    DateTime? lastUpdated,
    bool? isSeenByUser1,
    bool? isSeenByUser2,
    bool? isDeletedByUser1,
    bool? isDeletedByUser2,
  }) {
    return Conversation(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSeenByUser1: isSeenByUser1 ?? this.isSeenByUser1,
      isSeenByUser2: isSeenByUser2 ?? this.isSeenByUser2,
      isDeletedByUser1: isDeletedByUser1 ?? this.isDeletedByUser1,
      isDeletedByUser2: isDeletedByUser2 ?? this.isDeletedByUser2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'lastMessage': lastMessage,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'isSeenByUser1': isSeenByUser1,
      'isSeenByUser2': isSeenByUser2,
      'isDeletedByUser1': isDeletedByUser1,
      'isDeletedByUser2': isDeletedByUser2,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      user1Id: map['user1Id'] as String,
      user2Id: map['user2Id'] as String,
      lastMessage: map['lastMessage'] as String,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        map['lastUpdated'] as int,
      ),
      isSeenByUser1: map['isSeenByUser1'] as bool,
      isSeenByUser2: map['isSeenByUser2'] as bool,
      isDeletedByUser1: map['isDeletedByUser1'] as bool,
      isDeletedByUser2: map['isDeletedByUser2'] as bool,
    );
  }

  @override
  String toString() {
    return 'Conversation(id: $id, user1Id: $user1Id, user2Id: $user2Id, lastMessage: $lastMessage, lastUpdated: $lastUpdated, isSeenByUser1: $isSeenByUser1, isSeenByUser2: $isSeenByUser2, isDeletedByUser1: $isDeletedByUser1, isDeletedByUser2: $isDeletedByUser2)';
  }

  @override
  bool operator ==(covariant Conversation other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user1Id == user1Id &&
        other.user2Id == user2Id &&
        other.lastMessage == lastMessage &&
        other.lastUpdated == lastUpdated &&
        other.isSeenByUser1 == isSeenByUser1 &&
        other.isSeenByUser2 == isSeenByUser2 &&
        other.isDeletedByUser1 == isDeletedByUser1 &&
        other.isDeletedByUser2 == isDeletedByUser2;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user1Id.hashCode ^
        user2Id.hashCode ^
        lastMessage.hashCode ^
        lastUpdated.hashCode ^
        isSeenByUser1.hashCode ^
        isSeenByUser2.hashCode ^
        isDeletedByUser1.hashCode ^
        isDeletedByUser2.hashCode;
  }
}
