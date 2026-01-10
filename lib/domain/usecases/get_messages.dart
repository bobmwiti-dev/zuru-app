import '../../data/repositories/message_repository.dart';
import '../entities/message.dart';

abstract class GetMessages {
  Future<List<Message>> call(String userId1, String userId2, {int limit = 50});
}

class GetMessagesImpl implements GetMessages {
  final MessageRepository _repository;

  GetMessagesImpl(this._repository);

  @override
  Future<List<Message>> call(String userId1, String userId2, {int limit = 50}) async {
    return await _repository.getMessages(userId1, userId2, limit: limit);
  }
}