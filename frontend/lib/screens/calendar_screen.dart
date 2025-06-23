import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../services/api/schedule_api.dart';
import '../models/schedule.dart';
import '../widgets/schedule_card.dart';
import '../widgets/common/common_layout.dart';
import '../widgets/common/theme_builder.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  List<Schedule> _selectedDateSchedules = [];
  Map<String, List<Schedule>> _monthSchedules = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMonthSchedules();
    _loadSelectedDateSchedules();
  }

  Future<void> _loadMonthSchedules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final startOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final endOfMonth =
          DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

      final schedules = await ScheduleApi.getSchedules(
        startTime: startOfMonth,
        endTime: endOfMonth,
      );

      if (schedules != null) {
        final Map<String, List<Schedule>> schedulesMap = {};

        for (final schedule in schedules) {
          final dateKey = DateFormat('yyyy-MM-dd').format(schedule.startTime);
          if (schedulesMap[dateKey] == null) {
            schedulesMap[dateKey] = [];
          }
          schedulesMap[dateKey]!.add(schedule);
        }

        setState(() {
          _monthSchedules = schedulesMap;
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

  Future<void> _loadSelectedDateSchedules() async {
    try {
      final schedules = await ScheduleApi.getDaySchedules(_selectedDate);
      setState(() {
        _selectedDateSchedules = schedules ?? [];
      });
    } catch (e) {
      print('Error loading selected date schedules: $e');
    }
  }

  void _changeMonth(int monthOffset) {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + monthOffset);
    });
    _loadMonthSchedules();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadSelectedDateSchedules();
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    // カレンダーの開始日（月曜日から開始）
    final startDate =
        firstDay.subtract(Duration(days: (firstDay.weekday - 1) % 7));

    // カレンダーの終了日（6週間分表示）
    final endDate = startDate.add(const Duration(days: 41));

    final days = <DateTime>[];
    for (var date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      days.add(date);
    }

    return days;
  }

  bool _hasScheduleOnDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return _monthSchedules[dateKey]?.isNotEmpty ?? false;
  }

  int _getScheduleCountOnDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return _monthSchedules[dateKey]?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(builder: (context, primaryColor) {
      return CommonLayout(
        appBar: AppBar(
          title: Text(DateFormat('yyyy年M月', 'ja').format(_currentMonth)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: primaryColor),
            onPressed: () => _changeMonth(-1),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.chevron_right, color: primaryColor),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
        disableScroll: true,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              height: 330,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCalendarGrid(primaryColor),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: _selectedDateSchedules.isEmpty
                    ? _buildSelectedDateSchedules(primaryColor)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
                        itemCount: _selectedDateSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = _selectedDateSchedules[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ScheduleCard(
                              schedule: schedule,
                              primaryColor: primaryColor,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCalendarGrid(Color primaryColor) {
    final days = _getDaysInMonth();
    final weekdays = ['月', '火', '水', '木', '金', '土', '日'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: weekdays.map((weekday) {
                final isWeekend = weekday == '土' || weekday == '日';
                return Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isWeekend
                            ? Colors.red[50]
                            : primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isWeekend ? Colors.red[600] : primaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.all(4),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        return _buildCalendarDay(day, primaryColor);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, Color primaryColor) {
    final isCurrentMonth = day.month == _currentMonth.month;
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    final isSelected = DateUtils.isSameDay(day, _selectedDate);
    final hasSchedule = _hasScheduleOnDate(day);
    final scheduleCount = _getScheduleCountOnDate(day);
    final isWeekend = day.weekday == 6 || day.weekday == 7;

    Color textColor = AppColors.gray900;
    Color backgroundColor = Colors.transparent;

    if (!isCurrentMonth) {
      textColor = AppColors.gray300;
    } else if (isSelected) {
      backgroundColor = primaryColor;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = primaryColor.withOpacity(0.15);
      textColor = primaryColor;
    } else if (isWeekend) {
      textColor = Colors.red[400]!;
    }

    return GestureDetector(
      onTap: () => _selectDate(day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: primaryColor, width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              day.day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
            if (hasSchedule) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : primaryColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scheduleCount.toString(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? primaryColor : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateSchedules(Color primaryColor) {
    if (_selectedDateSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.event_available_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'この日の予定はありません',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ゆっくりお過ごしください',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _selectedDateSchedules.length,
      itemBuilder: (context, index) {
        final schedule = _selectedDateSchedules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: ScheduleCard(
            schedule: schedule,
            primaryColor: primaryColor,
          ),
        );
      },
    );
  }
}
