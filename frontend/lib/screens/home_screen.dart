import 'package:app/constants/colors.dart';
import 'package:app/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api/schedule_api.dart';
import '../services/api/reminder_api.dart';
import '../models/schedule.dart';
import '../widgets/schedule_card.dart';
import '../widgets/common/common_layout.dart';
import '../widgets/common/theme_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 1000);
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _reminderSectionKeys = {};

  DateTime _selectedDate = DateTime.now();
  List<Schedule> _schedules = [];
  List<Schedule> _reminderSchedules = [];
  bool _isLoadingSchedules = true;
  bool _isLoadingReminders = true;
  String? _schedulesError;
  String? _remindersError;
  int _currentPageIndex = 1000;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadSchedules(),
      _loadReminderSchedules(),
    ]);
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoadingSchedules = true;
      _schedulesError = null;
    });

    try {
      final schedules = await ScheduleApi.getDaySchedules(_selectedDate);
      if (schedules != null) {
        setState(() {
          _schedules = schedules;
        });
      } else {
        setState(() {
          _schedulesError = 'スケジュールの取得に失敗しました';
        });
      }
    } catch (e) {
      setState(() {
        _schedulesError = 'エラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isLoadingSchedules = false;
      });
    }
  }

  Future<void> _loadReminderSchedules() async {
    // 今日の場合のみリマインダー一覧を読み込み
    if (!DateUtils.isSameDay(_selectedDate, DateTime.now())) {
      setState(() {
        _reminderSchedules = [];
        _isLoadingReminders = false;
        _remindersError = null;
      });
      return;
    }

    setState(() {
      _isLoadingReminders = true;
      _remindersError = null;
    });

    try {
      final schedules = await ReminderApi.getReminderSchedules();
      if (schedules != null) {
        setState(() {
          _reminderSchedules = schedules;
        });
      } else {
        setState(() {
          _remindersError = 'リマインダーの取得に失敗しました';
        });
      }
    } catch (e) {
      setState(() {
        _remindersError = 'エラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isLoadingReminders = false;
      });
    }
  }

  void _onPageChanged(int page) {
    final dayOffset = page - _currentPageIndex;
    if (dayOffset != 0) {
      setState(() {
        _selectedDate = _selectedDate.add(Duration(days: dayOffset));
        _currentPageIndex = page;
      });
      _loadData();
    }
  }

  void _changeDate(int days) {
    final newPage = _currentPageIndex + days;
    _pageController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToReminderSection() {
    final key = _reminderSectionKeys[_currentPageIndex];
    final context = key?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _removeSchedule(String eventId) {
    setState(() {
      _schedules.removeWhere((schedule) => schedule.eventId == eventId);
    });
  }

  void _removeReminderSchedule(String eventId) {
    setState(() {
      _reminderSchedules.removeWhere((schedule) => schedule.eventId == eventId);
    });
  }

  Widget _buildPageContent(Color primaryColor, GlobalKey reminderKey) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日の予定セクション
            _buildSchedulesSection(primaryColor),

            // 今日準備するべきことセクション（今日の場合のみ）
            if (isToday) ...[
              const SizedBox(height: 32),
              _buildReminderSection(primaryColor, reminderKey),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesSection(Color primaryColor) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションヘッダー
        Text(
          isToday
              ? '今日の予定'
              : DateFormat('M月d日（E）の予定', 'ja').format(_selectedDate),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        if (_schedules.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '${_schedules.length}件',
            style: TextStyle(
              fontSize: 14,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (_isLoadingSchedules) ...[
          Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(color: primaryColor)))
        ] else if (_schedulesError != null) ...[
          _buildErrorState(primaryColor, _schedulesError!, _loadSchedules),
        ] else if (_schedules.isEmpty) ...[
          EmptyState(
            icon: Icons.event_available_rounded,
            title: 'この日の予定はありません',
            subtitle: 'ゆっくりお過ごしください',
            iconColor: primaryColor,
          ),
        ] else ...[
          ..._schedules.map((schedule) => ScheduleCard(
                schedule: schedule,
                primaryColor: primaryColor,
                onDeleted: () => _removeSchedule(schedule.eventId),
              )),
        ],
      ],
    );
  }

  Widget _buildReminderSection(Color primaryColor, GlobalKey key) {
    return Container(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日準備が必要なこと',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          if (_reminderSchedules.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${_reminderSchedules.length}件',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_isLoadingReminders) ...[
            Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: CircularProgressIndicator(color: primaryColor)))
          ] else if (_remindersError != null) ...[
            _buildErrorState(
                Colors.blue, _remindersError!, _loadReminderSchedules),
          ] else if (_reminderSchedules.isEmpty) ...[
            EmptyState(
              icon: Icons.check_circle_outline,
              title: '今日準備が必要なことはありません',
              subtitle: 'お疲れ様でした！',
              iconColor: primaryColor,
            ),
          ] else ...[
            ..._reminderSchedules.map((schedule) => ScheduleCard(
                  schedule: schedule,
                  primaryColor: Colors.blue,
                  onDeleted: () => _removeReminderSchedule(schedule.eventId),
                )),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final isYesterday = DateUtils.isSameDay(
        _selectedDate, DateTime.now().subtract(const Duration(days: 1)));
    final isTomorrow = DateUtils.isSameDay(
        _selectedDate, DateTime.now().add(const Duration(days: 1)));

    String dateLabel;
    if (isToday) {
      dateLabel = '今日';
    } else if (isYesterday) {
      dateLabel = '昨日';
    } else if (isTomorrow) {
      dateLabel = '明日';
    } else {
      dateLabel = DateFormat('M月d日（E）', 'ja').format(_selectedDate);
    }

    return ThemeBuilder(builder: (context, primaryColor) {
      return CommonLayout(
        disableScroll: true,
        appBar: AppBar(
          title: Text(dateLabel),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: primaryColor),
            onPressed: () => _changeDate(-1),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.chevron_right, color: primaryColor),
              onPressed: () => _changeDate(1),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (_, pageIndex) {
                  final key = _reminderSectionKeys.putIfAbsent(
                      pageIndex, () => GlobalKey());
                  return _buildPageContent(primaryColor, key);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildErrorState(
      Color primaryColor, String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}
