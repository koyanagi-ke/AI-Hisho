import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/schedule_event.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final Uuid _uuid = const Uuid();
  GenerativeModel? _model;
  String? _currentAIMessageId;
  String? _conversationSummary;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  Future<void> initializeModel() async {
    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.0-flash',
    );
  }

  void addUserMessage(String text) {
    final message = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
    notifyListeners();
    _generateAIResponseStream(text);
  }

  // AIレスポンスを生成しないユーザーメッセージ追加（新規追加）
  void addUserMessageWithoutResponse(String text) {
    final message = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
    notifyListeners();
    // _generateAIResponseStreamは呼び出さない
  }

  // アシスタントメッセージを追加
  void addAssistantMessage(String text) {
    final message = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
    notifyListeners();
  }

  // 予定確認メッセージを追加
  void addScheduleConfirmationMessage(String text, ScheduleEvent event) {
    final message = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      scheduleEvent: event,
    );
    _messages.add(message);
    notifyListeners();
  }

  Future<void> _generateAIResponseStream(String userMessage) async {
    if (_model == null) {
      _addAIMessage('申し訳ありません。AI機能が初期化されていません。');
      return;
    }

    _isTyping = true;
    notifyListeners();

    try {
      _currentAIMessageId = _uuid.v4();
      _messages.add(ChatMessage(
        id: _currentAIMessageId!,
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();

      if (_conversationSummary == null) {
        final historyText = _messages.map((m) {
          final speaker = m.isUser ? 'ユーザー' : 'アシスタント';
          return '$speaker: ${m.text}';
        }).join('\n');

        final summaryResponse = await _model!.generateContent(
            [Content.text('以下の会話の要点を簡潔に日本語でまとめてください:\n$historyText')]);

        _conversationSummary = summaryResponse.text ?? '';
      }

      final finalPrompt =
          '''これまでの会話の要点は次の通りです:\n$_conversationSummary\n\n以下がユーザーの最新の質問です:\n$userMessage\n\nこの情報を踏まえて、適切に日本語で回答してください。''';

      final stream = _model!.generateContentStream([Content.text(finalPrompt)]);

      String fullResponse = '';

      await for (final response in stream) {
        if (response.text != null && response.text!.isNotEmpty) {
          fullResponse += response.text!;

          final index =
              _messages.indexWhere((msg) => msg.id == _currentAIMessageId);
          if (index != -1) {
            _messages[index] = ChatMessage(
              id: _currentAIMessageId!,
              text: fullResponse,
              isUser: false,
              timestamp: _messages[index].timestamp,
            );
            notifyListeners();
          }
        }
      }

      _isTyping = false;
      _currentAIMessageId = null;

      // 回答後に要点を更新
      final updateSummaryResponse = await _model!.generateContent([
        Content.text(
            '前回の要点：\n$_conversationSummary\n\n以下の新しいやり取りを踏まえて、要点を更新してください:\nユーザー: $userMessage\nアシスタント: $fullResponse')
      ]);

      _conversationSummary = updateSummaryResponse.text ?? _conversationSummary;
    } catch (e) {
      print('ストリーミングエラー: $e');
      _addAIMessage('エラーが発生しました。しばらくしてからもう一度お試しください。');
    } finally {
      notifyListeners();
    }
  }

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

  void clearChat() {
    _messages.clear();
    _conversationSummary = null;
    notifyListeners();
  }
}
