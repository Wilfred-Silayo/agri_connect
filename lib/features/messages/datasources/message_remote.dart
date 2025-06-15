import 'package:agri_connect/core/exceptions/server_exceptions.dart';
import 'package:agri_connect/features/messages/models/conversation_model.dart';
import 'package:agri_connect/features/messages/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class MessageRemote {
  Stream<List<Message>> fetchMessages(
    String conversationId,
    String currentUserId,
  );
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
  Future<Conversation?> getConversationBetween(String userId1, String userId2);

  Future<Conversation> createConversation(String userId1, String userId2);
}

class MessageRemoteDataSourceImpl implements MessageRemote {
  final SupabaseClient supabaseClient;
  const MessageRemoteDataSourceImpl(this.supabaseClient);

  // Stream all messages in a conversation
  @override
  Stream<List<Message>> fetchMessages(
    String conversationId,
    String currentUserId,
  ) {
    return supabaseClient
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('time_sent', ascending: true)
        .map((rows) {
          return rows.map((e) => Message.fromMap(e)).where((message) {
            final isSender = message.senderId == currentUserId;
            if (isSender) {
              return message.isDeletedBySender == false;
            } else {
              return message.isDeletedByReceiver == false;
            }
          }).toList();
        });
  }

  //  Send message
  @override
  Future<void> sendMessage(Message message) async {
    try {
      await supabaseClient.from('messages').insert(message.toMap());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Mark a message as seen
  @override
  Future<void> markMessageAsSeen(String messageId) async {
    await supabaseClient
        .from('messages')
        .update({'is_seen': true})
        .eq('id', messageId);
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

    if (message['sender_id'] == userId) {
      await supabaseClient
          .from('messages')
          .update({'is_deleted_by_sender': true})
          .eq('id', messageId);
    } else if (message['receiver_id'] == userId) {
      await supabaseClient
          .from('messages')
          .update({'is_deleted_by_receiver': true})
          .eq('id', messageId);
    }
  }

  // Stream conversations
  @override
  Stream<List<Conversation>> fetchConversations(String userId) {
    return supabaseClient
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('last_updated', ascending: false)
        .map(
          (rows) =>
              rows.map((e) => Conversation.fromMap(e)).where((c) {
                final isUser1 = c.user1Id == userId;
                final isUser2 = c.user2Id == userId;

                if (isUser1 && !c.isDeletedByUser1) return true;
                if (isUser2 && !c.isDeletedByUser2) return true;
                return false;
              }).toList(),
        );
  }

  // Soft-delete conversation and its messages for a user
  @override
  Future<void> deleteConversation(String conversationId, String userId) async {
    final conversation =
        await supabaseClient
            .from('conversations')
            .select()
            .eq('id', conversationId)
            .single();

    final updates = <String, dynamic>{};
    final messageUpdates = <String, dynamic>{};

    final isUser1 = conversation['user1_id'] == userId;
    final isUser2 = conversation['user2_id'] == userId;

    if (isUser1) {
      updates['is_deleted_by_user1'] = true;
      messageUpdates['is_deleted_by_sender'] = true;
    } else if (isUser2) {
      updates['is_deleted_by_user2'] = true;
      messageUpdates['is_deleted_by_receiver'] = true;
    }

    if (updates.isNotEmpty) {
      await supabaseClient
          .from('conversations')
          .update(updates)
          .eq('id', conversationId);

      await supabaseClient
          .from('messages')
          .update(messageUpdates)
          .eq('conversation_id', conversationId)
          .eq(isUser1 ? 'sender_id' : 'receiver_id', userId);
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
          'last_message': message,
          'last_updated': timeSent.toIso8601String(),
        })
        .eq('id', conversationId);
  }

  @override
  Future<Conversation?> getConversationBetween(
    String userId1,
    String userId2,
  ) async {
    final response =
        await supabaseClient
            .from('conversations')
            .select()
            .or(
              'and(user1_id.eq.$userId1,user2_id.eq.$userId2),and(user1_id.eq.$userId2,user2_id.eq.$userId1)',
            )
            .maybeSingle();

    if (response == null) return null;

    return Conversation.fromMap(response);
  }

  @override
  Future<Conversation> createConversation(
    String userId1,
    String userId2,
  ) async {
    final now = DateTime.now().toIso8601String();

    final insertData = {
      'user1_id': userId1,
      'user2_id': userId2,
      'last_message': '',
      'last_updated': now,
      'is_seen_by_user1': false,
      'is_seen_by_user2': false,
      'is_deleted_by_user1': false,
      'is_deleted_by_user2': false,
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
