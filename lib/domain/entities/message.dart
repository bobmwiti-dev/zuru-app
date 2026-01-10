import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
  });

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [id, senderId, receiverId, content, timestamp, isRead, type];
}

enum MessageType {
  text,
  image,
  system,
}

class Conversation extends Equatable {
  final String id;
  final List<String> participantIds;
  final Message? lastMessage;
  final DateTime lastActivity;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    required this.lastActivity,
    this.unreadCount = 0,
  });

  Conversation copyWith({
    String? id,
    List<String>? participantIds,
    Message? lastMessage,
    DateTime? lastActivity,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [id, participantIds, lastMessage, lastActivity, unreadCount];
}