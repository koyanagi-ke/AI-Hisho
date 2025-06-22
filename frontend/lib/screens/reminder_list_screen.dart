import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../providers/preferences_provider.dart';
import '../services/api/reminder_api.dart';
import '../models/schedule.dart';
import 'checklist_detail_screen.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReminderSchedules();
  }

  Future<void> _loadReminderSchedules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final schedules = await ReminderApi.getReminderSchedules();
      if (schedules != null) {
        setState(() {
          _schedules = schedules;
        });
      } else {
        setState(() {
          _error = 'リマインダーの取得に失敗しました';
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

  @override
  Widget build(BuildContext context) {
    final prefsProvider = Provider.of<PreferencesProvider>(context);
    final themeColor = prefsProvider.preferences.themeColor;
    final primaryColor =
        AppColors.themeColors[themeColor] ?? AppColors.themeColors['orange']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日の準備リスト'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: _loadReminderSchedules,
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
              onPressed: _loadReminderSchedules,
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

    if (_schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              '今日準備が必要な予定はありません',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'お疲れ様でした！',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReminderSchedules,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '準備が必要な予定 (${_schedules.length}件)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 12),
            ..._schedules
                .map((schedule) => _buildScheduleCard(schedule, primaryColor)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule, Color primaryColor) {
    final startDate = DateFormat('M月d日（E）', 'ja').format(schedule.startTime);
    final startTime = DateFormat('HH:mm').format(schedule.startTime);
    final endTime = DateFormat('HH:mm').format(schedule.endTime);

    final isSameDay = DateUtils.isSameDay(schedule.startTime, schedule.endTime);
    final timeDisplay = isSameDay
        ? '$startDate $startTime 〜 $endTime'
        : '$startDate 〜 ${DateFormat('M月d日（E）', 'ja').format(schedule.endTime)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.gray500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    timeDisplay,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.gray500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    schedule.location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChecklistDetailScreen(
                        eventId: schedule.eventId,
                        eventTitle: schedule.title,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.checklist_rtl,
                  size: 20,
                  color: Colors.white,
                ),
                label: const Text(
                  '持ち物リストを確認',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
