import '../../data/repositories/message_repository.dart';
import '../entities/message.dart';

abstract class SendMessage {
  Future<Message> call(String senderId, String receiverId, String content);
}

class SendMessageImpl implements SendMessage {
  final MessageRepository _repository;

  SendMessageImpl(this._repository);

  @override
  Future<Message> call(String senderId, String receiverId, String content) async {
    final message = Message(
      id: '', // Will be set by repository
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
    );

    return await _repository.sendMessage(message);
  }
}