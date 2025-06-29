import 'package:app/models/chat_message.dart';
import 'package:app/models/chat_option.dart';
import 'package:app/models/schedule_event.dart';
import 'package:app/models/schedule.dart';
import 'package:app/widgets/common/theme_builder.dart';
import 'package:app/services/api/event_api.dart';
import 'package:app/services/api/schedule_api.dart';
import 'package:app/utils/date_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/characters.dart';
import '../providers/chat_provider.dart';
import '../providers/preferences_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
      // チャットを閉じる時にリセット
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.clearChat();

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

class _ChatOverlay extends StatefulWidget {
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
  State<_ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<_ChatOverlay> {
  // 選択肢のデータ
  final List<ChatOption> _chatOptions = const [
    ChatOption(
      title: '今日の予定を確認',
      icon: Icons.today,
      action: 'check_today',
    ),
    ChatOption(
      title: '明日の予定を確認',
      icon: Icons.today,
      action: 'check_tomorrow',
    ),
    ChatOption(
      title: '会話をリセット',
      icon: Icons.refresh,
      action: 'reset_chat',
    ),
    ChatOption(
      title: 'この内容で予定を追加',
      icon: Icons.event_note,
      action: 'add_schedule',
    ),
  ];

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
              onTap: widget.onClose,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Positioned(
              bottom: keyboardHeight > 0 ? keyboardHeight + 16 : 112,
              left: 16,
              right: 16,
              child: ScaleTransition(
                scale: widget.animation,
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
                                onPressed: widget.onClose,
                                color: primaryColor,
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ),
                        // メッセージ表示部分
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
                        // 選択肢部分
                        _buildChatOptions(primaryColor, chatProvider),
                        // メッセージ入力部分
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
                                  controller: widget.textController,
                                  focusNode: widget.focusNode,
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
                                    if (widget.textController.text
                                        .trim()
                                        .isNotEmpty) {
                                      chatProvider.addUserMessage(
                                          widget.textController.text);
                                      widget.textController.clear();
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

  // 選択肢を構築するウィジェット
  Widget _buildChatOptions(Color primaryColor, ChatProvider chatProvider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _chatOptions.length,
        itemBuilder: (context, index) {
          final option = _chatOptions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildOptionChip(option, primaryColor, chatProvider),
          );
        },
      ),
    );
  }

  // 個別の選択肢チップを構築するウィジェット
  Widget _buildOptionChip(
      ChatOption option, Color primaryColor, ChatProvider chatProvider) {
    return GestureDetector(
      onTap: () => _handleOptionTap(option, chatProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 16,
              color: primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              option.title,
              style: TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 選択肢がタップされた時の処理
  void _handleOptionTap(ChatOption option, ChatProvider chatProvider) async {
    switch (option.action) {
      case 'add_schedule':
        await _handleAddSchedule(chatProvider);
        break;
      case 'check_today':
        await _handleCheckSchedule(chatProvider, DateTime.now(), '今日の予定を確認');
        break;
      case 'check_tomorrow':
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        await _handleCheckSchedule(chatProvider, tomorrow, '明日の予定を確認');
        break;
      case 'reset_chat':
        _handleResetChat(chatProvider);
        break;
    }
  }

  // 会話リセット処理
  void _handleResetChat(ChatProvider chatProvider) {
    // ユーザーメッセージとして表示（AIレスポンスは生成しない）
    chatProvider.addUserMessageWithoutResponse('会話をリセット');

    // 少し遅延してからリセット（ユーザーメッセージが表示されるように）
    Future.delayed(const Duration(milliseconds: 500), () {
      chatProvider.clearChat();
    });
  }

  // 予定確認処理
  Future<void> _handleCheckSchedule(
      ChatProvider chatProvider, DateTime date, String userMessage) async {
    // ユーザーメッセージとして表示（AIレスポンスは生成しない）
    chatProvider.addUserMessageWithoutResponse(userMessage);

    try {
      // ScheduleApiを呼び出し
      final schedules = await ScheduleApi.getDaySchedules(date);

      if (schedules != null && schedules.isNotEmpty) {
        // 予定が見つかった場合
        _displaySchedules(chatProvider, schedules, date);
      } else {
        // 予定がない場合
        final dateStr = date.day == DateTime.now().day ? '今日' : '明日';
        chatProvider.addAssistantMessage('${dateStr}の予定はありません。');
      }
    } catch (e) {
      chatProvider.addAssistantMessage('予定の取得中にエラーが発生しました。もう一度お試しください。');
    }
  }

  // 予定一覧を表示
  void _displaySchedules(
      ChatProvider chatProvider, List<Schedule> schedules, DateTime date) {
    final dateStr = date.day == DateTime.now().day ? '今日' : '明日';
    final dateFormat = DateFormat('yyyy年MM月dd日(E)', 'ja_JP');
    final timeFormat = DateFormat('HH:mm');

    String scheduleText = '${dateStr}（${dateFormat.format(date)}）の予定：\n\n';

    for (int i = 0; i < schedules.length; i++) {
      final schedule = schedules[i];

      if (schedule.title.isNotEmpty) {
        scheduleText += '📅 **${schedule.title}**\n\n';
      }

      scheduleText +=
          '🕐 ${timeFormat.format(schedule.startTime)} - ${timeFormat.format(schedule.endTime)}\n\n';

      final duration = schedule.endTime.difference(schedule.startTime);
      scheduleText += '⏱️ ${_formatDuration(duration)}\n\n';

      if (schedule.location.isNotEmpty) {
        scheduleText += '📍 ${schedule.location}\n\n';
      }

      if (i < schedules.length - 1) {
        scheduleText += '\n\n';
      }
    }

    chatProvider.addAssistantMessage(scheduleText);
  }

  // 予定追加処理
  Future<void> _handleAddSchedule(ChatProvider chatProvider) async {
    if (chatProvider.messages.isEmpty) {
      // エラーメッセージをボットのレスポンスとして追加
      chatProvider
          .addAssistantMessage('申し訳ございませんが、会話履歴がありません。まず何か会話をしてから予定を追加してください。');
      return;
    }

    // ユーザーメッセージとして表示（AIレスポンスは生成しない）
    chatProvider.addUserMessageWithoutResponse('この内容で予定を追加してください');

    try {
      // 会話履歴をAPI用の形式に変換
      final messages = chatProvider.messages
          .where((message) => message.text != 'この内容で予定を追加してください')
          .map((message) {
        return {
          'role': 'user',
          'text': message.text,
        };
      }).toList();

      // EventApiを呼び出し
      final result = await EventApi.extractEvent(messages);

      if (result != null) {
        // ScheduleEventにパース
        final scheduleEvent = ScheduleEvent.fromJson(result);

        // 予定確認メッセージをボットのレスポンスとして追加
        _addScheduleConfirmationMessage(chatProvider, scheduleEvent);
      } else {
        chatProvider.addAssistantMessage(
            '申し訳ございませんが、内容から予定を抽出できませんでした。もう少し具体的な情報を教えていただけますか？');
      }
    } catch (e) {
      chatProvider.addAssistantMessage('エラーが発生しました。もう一度お試しください。');
    }
  }

  // 予定確認メッセージを追加
  void _addScheduleConfirmationMessage(
      ChatProvider chatProvider, ScheduleEvent event) {
    final dateFormat = DateFormat('yyyy年MM月dd日(E)', 'ja_JP');
    final timeFormat = DateFormat('HH:mm');

    String confirmationText = '以下の予定を抽出しました：\n\n';

    if (event.title.isNotEmpty) {
      confirmationText += '📅 **${event.title}**\n\n';
    }

    confirmationText +=
        '🕐 ${dateFormat.format(event.startTime)} ${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}\n\n';
    confirmationText +=
        '⏱️ 所要時間: ${_formatDuration(event.endTime.difference(event.startTime))}\n\n';

    if (event.location.isNotEmpty) {
      confirmationText += '📍 ${event.location}\n\n';
    }

    confirmationText += '\n\nこの予定をカレンダーに追加しますか？';

    // 特別なメッセージタイプとして予定データを含めて追加
    chatProvider.addScheduleConfirmationMessage(confirmationText, event);
  }

  // 所要時間をフォーマットする
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}時間${minutes}分';
    } else if (hours > 0) {
      return '${hours}時間';
    } else {
      return '${minutes}分';
    }
  }

  // 予定をカレンダーに追加
  Future<void> _addEventToCalendar(
      ScheduleEvent event, Color primaryColor) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // ユーザーメッセージとして表示（AIレスポンスは生成しない）
    chatProvider.addUserMessageWithoutResponse('予定を追加して');

    try {
      // ScheduleApiを呼び出し
      final success = await ScheduleApi.createSchedule(
        title: event.title,
        startTime: toIso8601WithOffset(event.startTime),
        endTime: toIso8601WithOffset(event.endTime),
        location: event.location,
        address: event.address,
        notifyAt: event.notifyAt != null
            ? toIso8601WithOffset(event.notifyAt!)
            : null,
      );

      if (success) {
        chatProvider.addAssistantMessage('登録しました');
      } else {
        chatProvider
            .addAssistantMessage('申し訳ございませんが、予定の登録に失敗しました。もう一度お試しください。');
      }
    } catch (e) {
      chatProvider.addAssistantMessage('エラーが発生しました。もう一度お試しください。');
    }
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
                  if (!isUser)
                    MarkdownBody(
                      data: isTyping && message.text.isEmpty
                          ? '...'
                          : !isTyping
                              ? message.text.trimRight()
                              : message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        strong: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        em: const TextStyle(
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        code: TextStyle(
                          backgroundColor: Colors.grey[100],
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.4,
                        ),
                        blockquote: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        h1: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        h2: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        h3: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      shrinkWrap: true,
                    )
                  else
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  if (!isUser && message.scheduleEvent != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _addEventToCalendar(
                          message.scheduleEvent!, themeColor),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('追加'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
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
