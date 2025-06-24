import 'package:app/utils/show_custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../providers/preferences_provider.dart';
import '../services/api/reminder_api.dart';
import '../models/schedule_detail.dart';

class ChecklistDetailScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const ChecklistDetailScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends State<ChecklistDetailScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  ScheduleDetail? _scheduleDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadScheduleDetail();
  }

  Future<void> _loadScheduleDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail = await ReminderApi.getScheduleDetail(widget.eventId);
      if (detail != null) {
        setState(() {
          _scheduleDetail = detail;
        });
      } else {
        setState(() {
          _error = 'スケジュール詳細の取得に失敗しました';
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

  Future<void> _toggleChecklistItem(ChecklistItem item) async {
    try {
      final result = await ReminderApi.toggleChecklistItem(
        eventId: widget.eventId,
        checklistId: item.id,
        checked: !item.checked,
      );

      if (result != null && result['status'] == 'success') {
        setState(() {
          final itemIndex =
              _scheduleDetail!.checklists.indexWhere((i) => i.id == item.id);
          if (itemIndex != -1) {
            _scheduleDetail!.checklists[itemIndex] =
                item.copyWith(checked: !item.checked);
          }

          if (result['next_check_due'] != null) {
            _scheduleDetail = ScheduleDetail(
              id: _scheduleDetail!.id,
              title: _scheduleDetail!.title,
              startTime: _scheduleDetail!.startTime,
              endTime: _scheduleDetail!.endTime,
              location: _scheduleDetail!.location,
              nextCheckDue: DateTime.parse(result['next_check_due']).toLocal(),
              checklists: _scheduleDetail!.checklists,
              weatherInfo: _scheduleDetail!.weatherInfo,
              weatherAdvice: _scheduleDetail!.weatherAdvice,
            );
          }
        });
        showCustomToast(
          context,
          !item.checked ? '${item.item}の準備を完了しました' : '${item.item}を未完了にしました',
          backgroundColor: !item.checked ? Colors.green : Colors.orange,
        );
      } else {
        showCustomToast(
          context,
          'チェックリストの更新に失敗しました',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      showCustomToast(
        context,
        'エラーが発生しました: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsProvider = Provider.of<PreferencesProvider>(context);
    final themeColor = prefsProvider.preferences.themeColor;
    final primaryColor =
        AppColors.themeColors[themeColor] ?? AppColors.themeColors['orange']!;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.eventTitle),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: primaryColor),
              onPressed: _loadScheduleDetail,
            ),
          ],
        ),
        body: _buildBody(primaryColor),
      ),
    );
  }

  Widget _buildBody(Color primaryColor) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor),
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
              onPressed: _loadScheduleDetail,
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

    if (_scheduleDetail == null) {
      return const Center(
        child: Text('データが見つかりません'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadScheduleDetail,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScheduleInfoCard(primaryColor),
            const SizedBox(height: 20),
            if (_scheduleDetail!.weatherAdvice != null ||
                _scheduleDetail!.weatherInfo != null) ...[
              _buildWeatherCard(primaryColor),
              const SizedBox(height: 20),
            ],
            _buildChecklistCard(primaryColor),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfoCard(Color primaryColor) {
    final schedule = _scheduleDetail!;
    final completedCount =
        schedule.checklists.where((item) => item.checked).length;
    final totalCount = schedule.checklists.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final startDate = DateFormat('M月d日（E）').format(schedule.startTime);
    final startTime = DateFormat('HH:mm').format(schedule.startTime);
    final endTime = DateFormat('HH:mm').format(schedule.endTime);
    final isSameDay = DateUtils.isSameDay(schedule.startTime, schedule.endTime);
    final timeDisplay = isSameDay
        ? '$startDate $startTime 〜 $endTime'
        : '$startDate 〜 ${DateFormat('M月d日（E）').format(schedule.endTime)}';

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  schedule.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.gray500, size: 16),
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
              const Icon(Icons.location_on, color: AppColors.gray500, size: 16),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '準備進捗: $completedCount / $totalCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(Color primaryColor) {
    final weather = _scheduleDetail!.weatherInfo;
    final weatherAdvice = _scheduleDetail!.weatherAdvice;

    IconData weatherIcon = Icons.wb_sunny;
    Color weatherColor = Colors.orange;
    Color backgroundColor = Colors.orange[50]!;
    Color borderColor = Colors.orange[200]!;

    if (weather?.condition != null) {
      final condition = weather!.condition!.toLowerCase();
      if (condition.contains('雨') || condition.contains('rain')) {
        weatherIcon = Icons.umbrella;
        weatherColor = Colors.blue[600]!;
        backgroundColor = Colors.blue[50]!;
        borderColor = Colors.blue[200]!;
      } else if (condition.contains('雪') || condition.contains('snow')) {
        weatherIcon = Icons.ac_unit;
        weatherColor = Colors.lightBlue[600]!;
        backgroundColor = Colors.lightBlue[50]!;
        borderColor = Colors.lightBlue[200]!;
      } else if (condition.contains('曇') || condition.contains('cloud')) {
        weatherIcon = Icons.wb_cloudy;
        weatherColor = Colors.grey[600]!;
        backgroundColor = Colors.grey[100]!;
        borderColor = Colors.grey[300]!;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: weatherColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: weatherColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    weatherIcon,
                    color: weatherColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '天気情報',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray700,
                        ),
                      ),
                      if (weather?.condition != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          weather!.condition!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (weather?.temperature != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${weather!.temperature!.round()}°C',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: weatherColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (weatherAdvice != null && weatherAdvice.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: weatherColor.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: weatherColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ミライフからのアドバイス',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: weatherColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weatherAdvice,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChecklistCard(Color primaryColor) {
    final checklists = _scheduleDetail!.checklists;

    if (checklists.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
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
        child: const Center(
          child: Text(
            '持ち物リストはありません',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray600,
            ),
          ),
        ),
      );
    }

    final requiredItems = checklists.where((item) => item.required).toList();
    final optionalItems = checklists.where((item) => !item.required).toList();

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.checklist, color: primaryColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '持ち物チェックリスト',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
          if (requiredItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.priority_high, color: Colors.red[600], size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    '必須アイテム',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...requiredItems
                .map((item) => _buildChecklistItem(item, primaryColor, true)),
          ],
          if (optionalItems.isNotEmpty) ...[
            if (requiredItems.isNotEmpty) const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    '任意アイテム',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...optionalItems
                .map((item) => _buildChecklistItem(item, primaryColor, false)),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
      ChecklistItem item, Color primaryColor, bool isRequired) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: InkWell(
        onTap: () => _toggleChecklistItem(item),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                item.checked ? primaryColor.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: item.checked
                  ? primaryColor.withOpacity(0.3)
                  : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.checked ? primaryColor : Colors.transparent,
                  border: Border.all(
                    color: item.checked ? primaryColor : Colors.grey[400]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: item.checked
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.item,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: item.checked
                            ? AppColors.gray600
                            : AppColors.gray900,
                        decoration:
                            item.checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (item.prepareBefore > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${item.prepareBefore}日前に準備',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.checked
                              ? AppColors.gray500
                              : AppColors.gray600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isRequired)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '必須',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
