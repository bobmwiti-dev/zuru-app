import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';
import '../models/message_model.dart';

abstract class MessageRepository {
  // Send a message
  Future<Message> sendMessage(Message message);

  // Get messages between two users
  Future<List<Message>> getMessages(String userId1, String userId2, {int limit = 50});

  // Get conversation list for a user
  Future<List<Conversation>> getConversations(String userId);

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId);

  // Listen to real-time messages
  Stream<List<Message>> listenToMessages(String userId1, String userId2);

  // Listen to conversation updates
  Stream<List<Conversation>> listenToConversations(String userId);
}

class MessageRepositoryImpl implements MessageRepository {
  final FirebaseFirestore _firestore;

  MessageRepositoryImpl(this._firestore);

  @override
  Future<Message> sendMessage(Message message) async {
    try {
      final messageModel = MessageModel.fromEntity(message);
      final conversationId = _getConversationId(message.senderId, message.receiverId);

      // Add message to messages collection
      final messageRef = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(messageModel.toJson());

      // Update conversation metadata
      await _firestore.collection('conversations').doc(conversationId).set({
        'participants': [message.senderId, message.receiverId],
        'lastMessage': messageModel.toJson(),
        'lastActivity': Timestamp.fromDate(message.timestamp),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      // Update unread count for receiver
      await _updateUnreadCount(conversationId, message.receiverId);

      return message.copyWith(id: messageRef.id);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<List<Message>> getMessages(String userId1, String userId2, {int limit = 50}) async {
    try {
      final conversationId = _getConversationId(userId1, userId2);

      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()).toEntity())
          .toList()
          .reversed
          .toList(); // Reverse to get chronological order
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<List<Conversation>> getConversations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .orderBy('lastActivity', descending: true)
          .get();

      final conversations = <Conversation>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] as List);
        final lastMessageData = data['lastMessage'];

        Message? lastMessage;
        if (lastMessageData != null) {
          lastMessage = MessageModel.fromJson(lastMessageData).toEntity();
        }

        final conversation = Conversation(
          id: doc.id,
          participantIds: participants,
          lastMessage: lastMessage,
          lastActivity: (data['lastActivity'] as Timestamp).toDate(),
          unreadCount: await _getUnreadCount(doc.id, userId),
        );

        conversations.add(conversation);
      }

      return conversations;
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      final batch = _firestore.batch();

      final messagesRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false);

      final snapshot = await messagesRef.get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Reset unread count
      final unreadCountRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('unreadCounts')
          .doc(userId);

      batch.set(unreadCountRef, {'count': 0}, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  @override
  Stream<List<Message>> listenToMessages(String userId1, String userId2) {
    final conversationId = _getConversationId(userId1, userId2);

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()).toEntity())
            .toList());
  }

  @override
  Stream<List<Conversation>> listenToConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastActivity', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final conversations = <Conversation>[];

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final participants = List<String>.from(data['participants'] as List);
            final lastMessageData = data['lastMessage'];

            Message? lastMessage;
            if (lastMessageData != null) {
              lastMessage = MessageModel.fromJson(lastMessageData).toEntity();
            }

            final conversation = Conversation(
              id: doc.id,
              participantIds: participants,
              lastMessage: lastMessage,
              lastActivity: (data['lastActivity'] as Timestamp).toDate(),
              unreadCount: await _getUnreadCount(doc.id, userId),
            );

            conversations.add(conversation);
          }

          return conversations;
        });
  }

  String _getConversationId(String userId1, String userId2) {
    // Create consistent conversation ID by sorting user IDs
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _updateUnreadCount(String conversationId, String userId) async {
    final unreadCountRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('unreadCounts')
        .doc(userId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(unreadCountRef);
      final currentCount = snapshot.data()?['count'] as int? ?? 0;
      transaction.set(unreadCountRef, {'count': currentCount + 1}, SetOptions(merge: true));
    });
  }

  Future<int> _getUnreadCount(String conversationId, String userId) async {
    final snapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('unreadCounts')
        .doc(userId)
        .get();

    return snapshot.data()?['count'] as int? ?? 0;
  }
}