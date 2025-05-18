import 'package:app/constants/colors.dart';
import 'package:app/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/characters.dart';
import '../providers/chat_provider.dart';
import '../providers/preferences_provider.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isChatOpen = false;
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // APIキーを初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApiKey();
    });
  }

  Future<void> _initializeApiKey() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // ビルド時に注入されたAPIキーを使用
    if (_apiKey.isNotEmpty) {
      await chatProvider.setApiKey(_apiKey);
    } else {
      print('警告: GEMINI_API_KEYが設定されていません。APIキーを指定してビルドしてください。');
      // エラー処理をここに追加（例：ダイアログ表示など）
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
      if (_isChatOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addUserMessage(_textController.text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final prefsProvider = Provider.of<PreferencesProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final assistantCharacter =
        CharactersList.getById(prefsProvider.preferences.assistantCharacter);
    final themeColor =
        AppColors.themeColors[prefsProvider.preferences.themeColor] ??
            AppColors.themeColors['orange']!;

    return Stack(
      children: [
        // チャットウィンドウ
        if (_isChatOpen)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: 80,
            right: 16,
            left: 16,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: themeColor.withOpacity(0.3), width: 2),
                  ),
                  child: Column(
                    children: [
                      // チャットヘッダー
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              assistantCharacter.imagePath,
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AIアシスタント',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _toggleChat,
                              color: themeColor,
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),

                      // チャットメッセージ一覧
                      Expanded(
                        child: chatProvider.messages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      assistantCharacter.imagePath,
                                      width: 80,
                                      height: 80,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'こんにちは！何かお手伝いできることはありますか？',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                reverse: true,
                                itemCount: chatProvider.messages.length,
                                itemBuilder: (context, index) {
                                  final message = chatProvider.messages[
                                      chatProvider.messages.length - 1 - index];
                                  return _buildMessageBubble(
                                      message, themeColor);
                                },
                              ),
                      ),

                      // 入力中インジケーター
                      if (chatProvider.isTyping)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 8),
                          child: Row(
                            children: [
                              Image.asset(
                                assistantCharacter.imagePath,
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text('入力中...',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),

                      // メッセージ入力フィールド
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  hintText: 'メッセージを入力...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: themeColor,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.send, color: Colors.white),
                                onPressed: _sendMessage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // チャットボットアイコン
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: _toggleChat,
            child: _isChatOpen
                ? const SizedBox.shrink()
                : Stack(
                    children: [
                      // 吹き出し
                      Positioned(
                        bottom: 60,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '何か相談したいことはある？',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      // キャラクターアイコン
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(assistantCharacter.imagePath),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, Color themeColor) {
    final isUser = message.isUser;
    final time = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Image.asset(
              'assets/images/characters/${Provider.of<PreferencesProvider>(context).preferences.assistantCharacter}.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? themeColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
