import 'package:agri_connect/core/shared/providers/supabase_client_provider.dart';
import 'package:agri_connect/core/utils/conversation_param.dart';
import 'package:agri_connect/core/utils/message_param.dart';
import 'package:agri_connect/features/messages/datasources/message_remote.dart';
import 'package:agri_connect/features/messages/models/conversation_model.dart';
import 'package:agri_connect/features/messages/models/message_model.dart';
import 'package:agri_connect/features/messages/presentation/providers/message_state.dart';
import 'package:agri_connect/features/messages/repository/message_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageRemoteProvider = Provider<MessageRemote>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MessageRemoteDataSourceImpl(client);
});

final messageRepoProvider = Provider<MessageRepository>((ref) {
  final remote = ref.watch(messageRemoteProvider);
  return MessageRepository(remote);
});

final messageNotifierProvider =
    StateNotifierProvider<MessageNotifier, MessageState>((ref) {
      final repo = ref.watch(messageRepoProvider);
      return MessageNotifier(repo);
    });

// Message stream provider (by conversationId + optional query)
final messageStreamProvider = StreamProvider.family
    .autoDispose<List<Message>, MessageStreamParams>((ref, params) {
      final notifier = ref.read(messageNotifierProvider.notifier);
      return notifier.fetchMessages(params.conversationId, params.query);
    });

final conversationsProvider = StreamProvider.family<List<Conversation>, String>(
  (ref, userId) {
    return ref
        .read(messageNotifierProvider.notifier)
        .fetchConversations(userId);
  },
);

final conversationProvider =
    FutureProvider.family<Conversation?, ConversationParams>((ref, params) {
      return ref
          .read(messageNotifierProvider.notifier)
          .getConversationBetween(params.senderId, params.receiverId);
    });

class MessageNotifier extends StateNotifier<MessageState> {
  final MessageRepository _repository;
  MessageNotifier(this._repository) : super(MessageInitial());

  Stream<List<Message>> fetchMessages(String conversationId, String? query) {
    return _repository.fetchMessages(conversationId, query).map((either) {
      return either.fold(
        (failure) => throw Exception(failure.message),
        (messages) => messages,
      );
    });
  }

  Future<void> sendMessage(Message message) async {
    final result = await _repository.sendMessage(message);
    result.fold(
      (failure) => state = MessageFailure(failure.message),
      (_) => state = MessageSuccess("Message sent"),
    );
  }

  Future<void> markMessageAsSeen(String messageId) async {
    await _repository.markAsSeen(messageId);
  }

  Future<void> deleteMessage(String messageId, String userId) async {
    await _repository.deleteMessage(messageId, userId);
  }

  Stream<List<Conversation>> fetchConversations(String userId) {
    return _repository.fetchConversations(userId).map((either) {
      return either.fold(
        (failure) => throw Exception(failure.message),
        (conversations) => conversations,
      );
    });
  }

  Future<void> deleteConversation(String conversationId, String userId) async {
    await _repository.deleteConversation(conversationId, userId);
  }

  Future<Conversation?> getConversationBetween(
    String userId1,
    String userId2,
  ) async {
    final result = await _repository.getConversationBetween(userId1, userId2);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (conversation) => conversation,
    );
  }

  Future<Conversation> createConversation(
    String userId1,
    String userId2,
  ) async {
    final result = await _repository.createConversation(userId1, userId2);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (conversation) => conversation,
    );
  }
}
