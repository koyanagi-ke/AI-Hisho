import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../providers/preferences_provider.dart';
import '../services/api/schedule_api.dart';
import '../models/schedule.dart';
import '../widgets/schedule_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final schedules = await ScheduleApi.getDaySchedules(_selectedDate);
      if (schedules != null) {
        setState(() {
          _schedules = schedules;
        });
      } else {
        setState(() {
          _error = 'スケジュールの取得に失敗しました';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'エラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final prefsProvider = Provider.of<PreferencesProvider>(context);
    final themeColor = prefsProvider.preferences.themeColor;
    final primaryColor =
        AppColors.themeColors[themeColor] ?? AppColors.themeColors['orange']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy年M月d日（E）', 'ja').format(_selectedDate)),
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
      body: _buildBody(primaryColor),
    );
  }

  Widget _buildBody(Color primaryColor) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
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
              _error!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSchedules,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date info header
            _buildDateHeader(primaryColor),
            const SizedBox(height: 20),

            if (_schedules.isEmpty) ...[
              _buildEmptyState(),
            ] else ...[
              Text(
                'スケジュール (${_schedules.length}件)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 16),
              ..._schedules.map((schedule) => ScheduleCard(
                    schedule: schedule,
                    primaryColor: primaryColor,
                    showChecklistButton: true,
                  )),
            ],

            const SizedBox(height: 100), // ボトムナビゲーション用のスペース
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(Color primaryColor) {
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'この日の予定はありません',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ゆっくりお過ごしください',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
