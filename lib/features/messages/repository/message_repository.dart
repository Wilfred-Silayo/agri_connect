import 'package:agri_connect/core/exceptions/failures.dart';
import 'package:agri_connect/features/messages/datasources/message_remote.dart';
import 'package:agri_connect/features/messages/models/conversation_model.dart';
import 'package:agri_connect/features/messages/models/message_model.dart';
import 'package:fpdart/fpdart.dart';

class MessageRepository {
  final MessageRemote remoteDataSource;
  const MessageRepository(this.remoteDataSource);

  Stream<Either<Failure, List<Message>>> fetchMessages(
    String conversationId,
    String? query,
  ) async* {
    try {
      await for (final messages in remoteDataSource.fetchMessages(
        conversationId,
        query,
      )) {
        yield right(messages);
      }
    } catch (e) {
      yield left(Failure("Error fetching messages"));
    }
  }

  Future<Either<Failure, void>> sendMessage(Message message) async {
    try {
      await remoteDataSource.sendMessage(message);
      await remoteDataSource.updateLastMessage(
        conversationId: message.conversationId,
        message: message.text,
        timeSent: message.timeSent,
      );
      return right(null);
    } catch (e) {
      return left(Failure("Failed to send message"));
    }
  }

  Future<Either<Failure, void>> markAsSeen(String messageId) async {
    try {
      await remoteDataSource.markMessageAsSeen(messageId);
      return right(null);
    } catch (e) {
      return left(Failure("Failed to mark message as seen"));
    }
  }

  Future<Either<Failure, void>> deleteMessage(
    String messageId,
    String userId,
  ) async {
    try {
      await remoteDataSource.deleteMessage(messageId, userId);
      return right(null);
    } catch (e) {
      return left(Failure("Failed to delete message"));
    }
  }

  Stream<Either<Failure, List<Conversation>>> fetchConversations(
    String userId,
  ) async* {
    try {
      await for (final conversations in remoteDataSource.fetchConversations(
        userId,
      )) {
        yield right(conversations);
      }
    } catch (e) {
      yield left(Failure("Failed to fetch conversations"));
    }
  }

  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
    String userId,
  ) async {
    try {
      await remoteDataSource.deleteConversation(conversationId, userId);
      return right(null);
    } catch (e) {
      return left(Failure("Failed to delete conversation"));
    }
  }

  Future<Either<Failure, Conversation>> getConversationBetween(
    String userId1,
    String userId2,
  ) async {
    try {
      final conversation = await remoteDataSource.getConversationBetween(
        userId1,
        userId2,
      );
      return right(conversation);
    } catch (e) {
      return left(Failure('Failed to get conversation: $e'));
    }
  }

  Future<Either<Failure, Conversation>> createConversation(
    String userId1,
    String userId2,
  ) async {
    try {
      final conversation = await remoteDataSource.createConversation(
        userId1,
        userId2,
      );
      return right(conversation);
    } catch (e) {
      return left(Failure('Failed to create conversation: $e'));
    }
  }
}
