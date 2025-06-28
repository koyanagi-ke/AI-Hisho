import 'package:app/models/chat_message.dart';
import 'package:app/widgets/common/theme_builder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  OverlayEntry? _overlayEntry;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.initializeModel();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleChat() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _animationController.reverse();
    } else {
      _animationController.forward();
      _overlayEntry = OverlayEntry(
        builder: (_) => _ChatOverlay(
          animation: _scaleAnimation,
          textController: _textController,
          focusNode: _focusNode,
          onClose: _toggleChat,
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);

      Future.delayed(const Duration(milliseconds: 300), () {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsProvider = Provider.of<PreferencesProvider>(context);
    final assistantCharacter =
        CharactersList.getById(prefsProvider.preferences.assistantCharacter);

    return GestureDetector(
      onTap: _toggleChat,
      child: Container(
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
    );
  }
}

class _ChatOverlay extends StatelessWidget {
  final Animation<double> animation;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onClose;

  const _ChatOverlay({
    required this.animation,
    required this.textController,
    required this.focusNode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(builder: (context, primaryColor) {
      final prefsProvider = Provider.of<PreferencesProvider>(context);
      final chatProvider = Provider.of<ChatProvider>(context);
      final assistantCharacter =
          CharactersList.getById(prefsProvider.preferences.assistantCharacter);
      final mediaQuery = MediaQuery.of(context);
      final screenHeight = mediaQuery.size.height;
      final keyboardHeight = mediaQuery.viewInsets.bottom;
      final topPadding = mediaQuery.padding.top;
      final safeAvailableHeight =
          screenHeight - keyboardHeight - topPadding - 32;

      return Positioned.fill(
        child: Stack(
          children: [
            GestureDetector(
              onTap: onClose,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Positioned(
              bottom: keyboardHeight > 0 ? keyboardHeight + 16 : 112,
              left: 16,
              right: 16,
              child: ScaleTransition(
                scale: animation,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: safeAvailableHeight.clamp(0.0, screenHeight * 0.6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: primaryColor.withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(assistantCharacter.imagePath,
                                  width: 32, height: 32),
                              const SizedBox(width: 8),
                              Text(
                                'AIアシスタント',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: onClose,
                                color: primaryColor,
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: chatProvider.messages.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(assistantCharacter.imagePath,
                                          width: 80, height: 80),
                                      const SizedBox(height: 16),
                                      Text(
                                        'こんにちは！\n何かお手伝いできることはありますか？',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
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
                                        chatProvider.messages.length -
                                            1 -
                                            index];
                                    return _buildMessageBubble(
                                      message,
                                      primaryColor,
                                      chatProvider.isTyping,
                                      prefsProvider
                                          .preferences.assistantCharacter,
                                    );
                                  },
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border(
                                top: BorderSide(color: Colors.grey[200]!)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: textController,
                                  focusNode: focusNode,
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
                                  onSubmitted: (_) =>
                                      FocusScope.of(context).unfocus(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundColor: primaryColor,
                                child: IconButton(
                                  icon: const Icon(Icons.send,
                                      color: Colors.white),
                                  onPressed: () {
                                    final chatProvider =
                                        Provider.of<ChatProvider>(context,
                                            listen: false);
                                    if (textController.text.trim().isNotEmpty) {
                                      chatProvider
                                          .addUserMessage(textController.text);
                                      textController.clear();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMessageBubble(ChatMessage message, Color themeColor,
      bool isTyping, String assistantCharacter) {
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
              'assets/images/characters/$assistantCharacter.png',
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
                    !isUser && isTyping && message.text.isEmpty
                        ? '...'
                        : !isUser && !isTyping
                            ? message.text.trimRight()
                            : message.text,
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
