import 'package:app/models/schedule.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Schedule? scheduleEvent;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.scheduleEvent,
  });

  // コピーコンストラクタ
  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    Schedule? scheduleEvent,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      scheduleEvent: scheduleEvent ?? this.scheduleEvent,
    );
  }
}
