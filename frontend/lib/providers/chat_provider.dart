import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final Uuid _uuid = const Uuid();
  String? _currentAIMessageId;
  String? _apiKey;

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
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
    if (_apiKey == null || _apiKey!.isEmpty) {
      _addAIMessage('申し訳ありません。APIキーが設定されていません。');
      return;
    }
    _isTyping = true;
    notifyListeners();
    try {
      _currentAIMessageId = _uuid.v4();
      final placeholder = ChatMessage(
        id: _currentAIMessageId!,
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(placeholder);
      notifyListeners();
      final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userMessage}
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final text = body['candidates']?[0]?['content']?['parts']?[0]
                ?['text'] ??
            '応答が得られませんでした。';

        _updateAIMessage(text);
      } else {
        print('Geminiエラー: ${response.body}');
        _updateAIMessage('エラーが発生しました。ステータス: ${response.statusCode}');
      }
    } catch (e) {
      print('REST呼び出しエラー: $e');
      _updateAIMessage('エラーが発生しました。しばらくしてからお試しください。');
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void _updateAIMessage(String text) {
    final index = _messages.indexWhere((msg) => msg.id == _currentAIMessageId);
    if (index != -1) {
      _messages[index] = ChatMessage(
        id: _currentAIMessageId!,
        text: text,
        isUser: false,
        timestamp: _messages[index].timestamp,
      );
    }
    _currentAIMessageId = null;
    notifyListeners();
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
