import 'package:app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api/schedule_api.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (_error != null) ...[
                _buildErrorState(primaryColor),
              ] else if (_schedules.isEmpty) ...[
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
                    )),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildErrorState(Color primaryColor) {
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
