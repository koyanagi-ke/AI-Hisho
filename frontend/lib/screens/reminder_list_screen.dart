import 'package:app/widgets/common/common_layout.dart';
import 'package:app/widgets/common/theme_builder.dart';
import 'package:app/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api/reminder_api.dart';
import '../models/schedule.dart';
import '../widgets/schedule_card.dart';

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
    return ThemeBuilder(builder: (context, primaryColor) {
      return CommonLayout(
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
        child: _buildBody(primaryColor),
      );
    });
  }

  Widget _buildBody(Color primaryColor) {
    if (_isLoading) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: CircularProgressIndicator(color: primaryColor)));
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
      return EmptyState(
        icon: Icons.check_circle_outline,
        title: '今日準備が必要なことはありません',
        subtitle: 'お疲れ様でした！',
        iconColor: primaryColor,
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
            const SizedBox(height: 16),
            ..._schedules.map((schedule) => ScheduleCard(
                  schedule: schedule,
                  primaryColor: primaryColor,
                )),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
