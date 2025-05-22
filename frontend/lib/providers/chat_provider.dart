import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'dart:convert';

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

        final summaryResponse = await _model!
            .generateContent([Content.text('以下の会話を要約してください:\n$historyText')]);

        _conversationSummary = summaryResponse.text ?? '';
      }

      final prompt =
          '''これまでの会話の要点は次の通りです:\n$_conversationSummary\n\n以下がユーザーの最新の質問です:\n$userMessage\n\nこの情報を踏まえて、日本語で簡潔に回答してください。予定が含まれる場合は、次のJSONの形式で予定提案を返信の末尾に追加してください。：\n{\"title\":\"string\",\"start_time\":\"YYYY-MM-DDTHH:MM:SS\",\"end_time\":\"YYYY-MM-DDTHH:MM:SS\",\"location\":\"string or null\"}''';

      final stream = _model!.generateContentStream([Content.text(prompt)]);

      String fullResponse = '';

      await for (final response in stream) {
        if (response.text != null && response.text!.isNotEmpty) {
          print(response.text);
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

      _currentAIMessageId = null;
      _isTyping = false;

      // 要約の更新
      final updateSummaryResponse = await _model!.generateContent([
        Content.text(
            '要約:\n$_conversationSummary\n新しい会話:\nユーザー: $userMessage\nアシスタント: $fullResponse\n\nこの内容をもとに要約を更新してください')
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

  Map<String, dynamic>? extractJson(String text) {
    final regex = RegExp(r'{[\s\S]*?}');
    final match = regex.firstMatch(text);
    if (match != null) {
      try {
        return json.decode(match.group(0)!);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
