import 'package:agri_connect/core/exceptions/server_exceptions.dart';
import 'package:agri_connect/features/messages/models/conversation_model.dart';
import 'package:agri_connect/features/messages/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class MessageRemote {
  Stream<List<Message>> fetchMessages(String conversationId, String? query);
  Future<void> sendMessage(Message message);
  Future<void> markMessageAsSeen(String messageId);
  Future<void> deleteMessage(String messageId, String userId);

  Stream<List<Conversation>> fetchConversations(String userId);
  Future<void> deleteConversation(String conversationId, String userId);
  Future<void> updateLastMessage({
    required String conversationId,
    required String message,
    required DateTime timeSent,
  });
  Future<Conversation> getConversationBetween(String userId1, String userId2);

  Future<Conversation> createConversation(String userId1, String userId2);
}

class MessageRemoteDataSourceImpl implements MessageRemote {
  final SupabaseClient supabaseClient;
  const MessageRemoteDataSourceImpl(this.supabaseClient);

  // Stream all messages in a conversation
  @override
  Stream<List<Message>> fetchMessages(String conversationId, String? query) {
    return supabaseClient
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversationId', conversationId)
        .order('timeSent')
        .map((rows) => rows.map((e) => Message.fromMap(e)).toList());
  }

  //  Send message
  @override
  Future<void> sendMessage(Message message) async {
    final response = await supabaseClient
        .from('messages')
        .insert(message.toMap());
    if (response.error != null) throw ServerException(response.error!.message);
  }

  // Mark a message as seen
  @override
  Future<void> markMessageAsSeen(String messageId) async {
    final response = await supabaseClient
        .from('messages')
        .update({'isSeen': true})
        .eq('id', messageId);
    if (response.error != null) throw ServerException(response.error!.message);
  }

  //  Soft-delete message by user
  @override
  Future<void> deleteMessage(String messageId, String userId) async {
    final message =
        await supabaseClient
            .from('messages')
            .select()
            .eq('id', messageId)
            .single();

    if (message['senderId'] == userId) {
      await supabaseClient
          .from('messages')
          .update({'isDeletedBySender': true})
          .eq('id', messageId);
    } else if (message['receiverId'] == userId) {
      await supabaseClient
          .from('messages')
          .update({'isDeletedByReceiver': true})
          .eq('id', messageId);
    }
  }

  // Stream conversations
  @override
  Stream<List<Conversation>> fetchConversations(String userId) {
    return supabaseClient
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('lastUpdated', ascending: false)
        .map(
          (rows) =>
              rows
                  .map((e) => Conversation.fromMap(e))
                  .where((c) => c.user1Id == userId || c.user2Id == userId)
                  .toList(),
        );
  }

  // Soft-delete conversation for a user
  @override
  Future<void> deleteConversation(String conversationId, String userId) async {
    final conversation =
        await supabaseClient
            .from('conversations')
            .select()
            .eq('id', conversationId)
            .single();

    final updates = <String, dynamic>{};
    if (conversation['user1Id'] == userId) {
      updates['isDeletedByUser1'] = true;
    } else if (conversation['user2Id'] == userId) {
      updates['isDeletedByUser2'] = true;
    }

    if (updates.isNotEmpty) {
      await supabaseClient
          .from('conversations')
          .update(updates)
          .eq('id', conversationId);
    }
  }

  // Update last message info
  @override
  Future<void> updateLastMessage({
    required String conversationId,
    required String message,
    required DateTime timeSent,
  }) async {
    await supabaseClient
        .from('conversations')
        .update({
          'lastMessage': message,
          'lastUpdated': timeSent.toIso8601String(),
        })
        .eq('id', conversationId);
  }

  @override
  Future<Conversation> getConversationBetween(
    String userId1,
    String userId2,
  ) async {
    final response =
        await supabaseClient
            .from('conversations')
            .select()
            .or(
              'and(user1Id.eq.$userId1,user2Id.eq.$userId2),and(user1Id.eq.$userId2,user2Id.eq.$userId1)',
            )
            .maybeSingle();

    return Conversation.fromMap(response as Map<String, dynamic>);
  }

  @override
  Future<Conversation> createConversation(
    String userId1,
    String userId2,
  ) async {
    final now = DateTime.now().toIso8601String();

    final insertData = {
      'user1Id': userId1,
      'user2Id': userId2,
      'lastMessage': '',
      'lastUpdated': now,
      'isDeletedByUser1': false,
      'isDeletedByUser2': false,
    };

    final response =
        await supabaseClient
            .from('conversations')
            .insert(insertData)
            .select()
            .single();

    return Conversation.fromMap(response);
  }
}
