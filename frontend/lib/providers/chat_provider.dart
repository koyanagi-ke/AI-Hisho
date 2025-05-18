import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final Uuid _uuid = const Uuid();
  AIService? _aiService;
  String? _currentAIMessageId;

  Future<void> setApiKey(String apiKey) async {
    _aiService = AIService(apiKey: apiKey);
  }

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  // ユーザーメッセージを追加
  void addUserMessage(String text) {
    final message = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(message);
    notifyListeners();

    // AIの応答を生成（ストリーミング）
    _generateAIResponseStream(text);
  }

  // AIの応答を生成（ストリーミング）
  Future<void> _generateAIResponseStream(String userMessage) async {
    if (_aiService == null) {
      _addAIMessage('申し訳ありません。AI機能が初期化されていません。');
      return;
    }

    _isTyping = true;
    notifyListeners();

    try {
      // 空のAIメッセージを作成
      _currentAIMessageId = _uuid.v4();
      final message = ChatMessage(
        id: _currentAIMessageId!,
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(message);
      notifyListeners();

      // ストリーミングで応答を取得
      final responseStream = _aiService!.generateResponseStream(userMessage);

      String fullResponse = '';

      await for (final chunk in responseStream) {
        fullResponse += chunk;

        // 既存のメッセージを更新
        final index =
            _messages.indexWhere((msg) => msg.id == _currentAIMessageId);
        if (index != -1) {
          final updatedMessage = ChatMessage(
            id: _currentAIMessageId!,
            text: fullResponse,
            isUser: false,
            timestamp: _messages[index].timestamp,
          );
          _messages[index] = updatedMessage;
          notifyListeners();
        }
      }

      _currentAIMessageId = null;
    } catch (e) {
      print('ストリーミングエラー: $e');
      _addAIMessage('エラーが発生しました。しばらくしてからもう一度お試しください。');
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // AIメッセージを追加（非ストリーミング用）
  void _addAIMessage(String text) {
    final message = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );

    _messages.add(message);
    notifyListeners();
  }

  // チャット履歴をクリア
  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
