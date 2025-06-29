import 'package:app/utils/date_format_utils.dart';
import 'package:app/utils/show_custom_toast.dart';
import 'package:app/widgets/ai_schedule_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../services/api/event_api.dart';
import '../services/api/schedule_api.dart';
import '../models/schedule_event.dart';
import '../widgets/input/labeled_text_field.dart';
import '../widgets/common/common_layout.dart';
import '../widgets/common/theme_builder.dart';

class AddScheduleScreen extends StatefulWidget {
  final ScheduleEvent? initialEvent;
  final bool showManualForm;
  const AddScheduleScreen({
    super.key,
    this.initialEvent,
    this.showManualForm = false,
  });

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final TextEditingController _naturalLanguageController =
      TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  bool _showManualForm = false;
  bool _isAnalyzed = false;
  bool _notificationEnabled = false;
  bool _isAllDay = false;

  DateTime _startDate = DateTime.now();
  late TimeOfDay _startTime;
  DateTime _endDate = DateTime.now();
  late TimeOfDay _endTime;
  late DateTime _notifyDate;
  late TimeOfDay _notifyTime;

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay.now();
    _endDate = _startDate;
    _notifyDate = _startDate;

    final now = TimeOfDay.now();
    _endTime = now.replacing(hour: (now.hour + 1) % 24);
    _notifyTime = now.replacing(hour: (now.hour - 1 + 24) % 24);
    _showManualForm = widget.showManualForm;
    if (widget.initialEvent != null) {
      final event = widget.initialEvent!;
      _titleController.text = event.title;
      _locationController.text = event.location;
      _startDate = event.startTime;
      _startTime = TimeOfDay.fromDateTime(event.startTime);
      _endDate = event.endTime;
      _endTime = TimeOfDay.fromDateTime(event.endTime);
      _isAllDay = _startTime.hour == 0 &&
          _startTime.minute == 0 &&
          _endTime.hour == 23 &&
          _endTime.minute == 59;
      final notifyDateTime = event.startTime.subtract(const Duration(hours: 1));
      _notifyDate = notifyDateTime;
      _notifyTime = TimeOfDay.fromDateTime(notifyDateTime);
      _showManualForm = widget.showManualForm;
      _isAnalyzed = true;
    }
  }

  @override
  void dispose() {
    _naturalLanguageController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _analyzeNaturalLanguage() async {
    if (_naturalLanguageController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await EventApi.extractEvent([
        {"role": "user", "text": _naturalLanguageController.text}
      ]);
      if (result != null) {
        final event = ScheduleEvent.fromJson(result);
        setState(() {
          _titleController.text = event.title;
          _locationController.text = event.location;
          _startDate = event.startTime;
          _startTime = TimeOfDay.fromDateTime(event.startTime);
          _endDate = event.endTime;
          _endTime = TimeOfDay.fromDateTime(event.endTime);

          _isAllDay = _startTime.hour == 0 &&
              _startTime.minute == 0 &&
              _endTime.hour == 23 &&
              _endTime.minute == 59;

          final notifyDateTime =
              event.startTime.subtract(const Duration(hours: 1));
          _notifyDate = notifyDateTime;
          _notifyTime = TimeOfDay.fromDateTime(notifyDateTime);

          _isAnalyzed = true;
          _showManualForm = true;
        });
      } else {
        _showErrorSnackBar('予定の解析に失敗しました。手動で入力してください。');
      }
    } catch (e) {
      _showErrorSnackBar('エラーが発生しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showManualInput() {
    setState(() {
      _showManualForm = true;
      _isAnalyzed = false;
    });
  }

  void _toggleAllDay(bool value) {
    setState(() {
      _isAllDay = value;
      if (value) {
        _startTime = const TimeOfDay(hour: 0, minute: 0);
        _endTime = const TimeOfDay(hour: 23, minute: 59);
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        final now = TimeOfDay.now();
        _startTime = now;
        _endTime = now.replacing(hour: (now.hour + 1) % 24);
      }
    });
  }

  void _updateStartTime(TimeOfDay time) {
    setState(() {
      _startTime = time;

      final startMinutes = time.hour * 60 + time.minute;
      final endMinutes = _endTime.hour * 60 + _endTime.minute;

      if (DateUtils.isSameDay(_startDate, _endDate) &&
          endMinutes <= startMinutes) {
        final newEndMinutes = startMinutes + 60;
        if (newEndMinutes >= 24 * 60) {
          _endTime = TimeOfDay(
              hour: (newEndMinutes ~/ 60) % 24, minute: newEndMinutes % 60);
          _endDate = _startDate.add(const Duration(days: 1));
        } else {
          _endTime =
              TimeOfDay(hour: newEndMinutes ~/ 60, minute: newEndMinutes % 60);
        }
      }
    });
  }

  void _updateEndTime(TimeOfDay time) {
    setState(() {
      _endTime = time;

      final startMinutes = _startTime.hour * 60 + _startTime.minute;
      final endMinutes = time.hour * 60 + time.minute;

      if (DateUtils.isSameDay(_startDate, _endDate) &&
          endMinutes <= startMinutes) {
        _endDate = _startDate.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _saveSchedule() async {
    if (_titleController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      _showErrorSnackBar('タイトルと場所は必須です');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      String? notifyAtString;
      if (_notificationEnabled) {
        final notifyDateTime = DateTime(
          _notifyDate.year,
          _notifyDate.month,
          _notifyDate.day,
          _notifyTime.hour,
          _notifyTime.minute,
        );
        notifyAtString = toIso8601WithOffset(notifyDateTime);
      }

      final success = await ScheduleApi.createSchedule(
        title: _titleController.text,
        startTime: toIso8601WithOffset(startDateTime),
        endTime: toIso8601WithOffset(endDateTime),
        location: _locationController.text,
        address:
            _addressController.text.isNotEmpty ? _addressController.text : null,
        notifyAt: notifyAtString,
      );

      if (success) {
        Navigator.of(context).pop();
        showCustomToast(
          context,
          '予定を保存しました',
          backgroundColor: Colors.green,
        );
      } else {
        _showErrorSnackBar('予定の保存に失敗しました');
      }
    } catch (e) {
      _showErrorSnackBar('エラーが発生しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    showCustomToast(
      context,
      message,
      backgroundColor: Colors.red,
    );
  }

  Future<void> _showCalendarPicker(String type, Color primaryColor) async {
    DateTime initialDate;
    switch (type) {
      case 'start':
        initialDate = _startDate;
        break;
      case 'end':
        initialDate = _endDate;
        break;
      case 'notify':
        initialDate = _notifyDate;
        break;
      default:
        initialDate = DateTime.now();
    }

    final date = await showDialog<DateTime>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 350,
          height: 450,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('キャンセル', style: TextStyle(color: primaryColor)),
                  ),
                  const Text(
                    '日付を選択',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(initialDate),
                    child: Text('完了', style: TextStyle(color: primaryColor)),
                  ),
                ],
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: primaryColor,
                        ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: initialDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateChanged: (date) {
                      initialDate = date;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (date != null) {
      setState(() {
        switch (type) {
          case 'start':
            _startDate = date;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate;
            }
            break;
          case 'end':
            _endDate = date;
            if (_endDate.isBefore(_startDate)) {
              _startDate = _endDate;
            }
            break;
          case 'notify':
            _notifyDate = date;
            break;
        }
      });
    }
  }

  Future<void> _showScrollableTimePicker(
      String type, Color primaryColor) async {
    TimeOfDay initialTime;
    switch (type) {
      case 'start':
        initialTime = _startTime;
        break;
      case 'end':
        initialTime = _endTime;
        break;
      case 'notify':
        initialTime = _notifyTime;
        break;
      default:
        initialTime = TimeOfDay.now();
    }

    int selectedHour = initialTime.hour;
    int selectedMinute = initialTime.minute;

    final time = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 300,
          height: 350,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('キャンセル', style: TextStyle(color: primaryColor)),
                  ),
                  const Text(
                    '時刻を選択',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(
                      TimeOfDay(hour: selectedHour, minute: selectedMinute),
                    ),
                    child: Text('完了', style: TextStyle(color: primaryColor)),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    // 時間選択
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 40,
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedHour,
                              ),
                              onSelectedItemChanged: (index) {
                                selectedHour = index;
                              },
                              children: List.generate(24, (index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 40,
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedMinute,
                              ),
                              onSelectedItemChanged: (index) {
                                selectedMinute = index;
                              },
                              children: List.generate(60, (index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (time != null) {
      setState(() {
        switch (type) {
          case 'start':
            _updateStartTime(time);
            break;
          case 'end':
            _updateEndTime(time);
            break;
          case 'notify':
            _notifyTime = time;
            break;
        }
      });
    }
  }

  Widget _buildDateTimeRow({
    required String label,
    required DateTime date,
    required TimeOfDay time,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: onDateTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: primaryColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          DateFormat('M/d（E）', 'ja').format(date),
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!_isAllDay) ...[
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: onTimeTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 16, color: primaryColor),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            time.format(context),
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(builder: (context, primaryColor) {
      return CommonLayout(
        appBar: AppBar(
          title: const Text('予定を追加'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_showManualForm) ...[
                AiScheduleInput(
                  controller: _naturalLanguageController,
                  isLoading: _isLoading,
                  onAnalyze: _analyzeNaturalLanguage,
                  onManualInput: _showManualInput,
                  primaryColor: primaryColor,
                ),
              ],
              if (_showManualForm) ...[
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isAnalyzed ? Icons.auto_awesome : Icons.edit,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isAnalyzed ? 'AI解析結果' : '予定の詳細',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        LabeledTextField(
                          label: 'タイトル *',
                          controller: _titleController,
                          hintText: '予定のタイトルを入力',
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 16),

                        SwitchListTile(
                          title: const Text('終日'),
                          value: _isAllDay,
                          onChanged: _toggleAllDay,
                          activeColor: primaryColor,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),

                        // 開始日時
                        _buildDateTimeRow(
                          label: '開始',
                          date: _startDate,
                          time: _startTime,
                          onDateTap: () =>
                              _showCalendarPicker('start', primaryColor),
                          onTimeTap: () =>
                              _showScrollableTimePicker('start', primaryColor),
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 16),

                        // 終了日時
                        _buildDateTimeRow(
                          label: '終了',
                          date: _endDate,
                          time: _endTime,
                          onDateTap: () =>
                              _showCalendarPicker('end', primaryColor),
                          onTimeTap: () =>
                              _showScrollableTimePicker('end', primaryColor),
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 16),

                        // 場所
                        LabeledTextField(
                          label: '場所 *',
                          controller: _locationController,
                          hintText: '場所を入力',
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 16),

                        // 住所
                        LabeledTextField(
                          label: '住所（オプション）',
                          controller: _addressController,
                          hintText: '詳細な住所を入力',
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 16),

                        // 通知設定
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '通知時間をカスタムする',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Switch(
                              value: _notificationEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationEnabled = value;
                                  if (value) {
                                    final startDateTime = DateTime(
                                      _startDate.year,
                                      _startDate.month,
                                      _startDate.day,
                                      _startTime.hour,
                                      _startTime.minute,
                                    );
                                    final notifyDateTime = startDateTime
                                        .subtract(const Duration(hours: 1));
                                    _notifyDate = notifyDateTime;
                                    _notifyTime =
                                        TimeOfDay.fromDateTime(notifyDateTime);
                                  }
                                });
                              },
                              activeColor: primaryColor,
                            ),
                          ],
                        ),

                        if (_notificationEnabled) ...[
                          const SizedBox(height: 8),
                          _buildDateTimeRow(
                            label: '通知日時',
                            date: _notifyDate,
                            time: _notifyTime,
                            onDateTap: () =>
                                _showCalendarPicker('notify', primaryColor),
                            onTimeTap: () => _showScrollableTimePicker(
                                'notify', primaryColor),
                            primaryColor: primaryColor,
                          ),
                        ],

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveSchedule,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    '予定を保存',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    });
  }
}
