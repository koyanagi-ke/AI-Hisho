import 'package:app/utils/date_format_utils.dart';
import 'package:app/utils/show_custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/preferences_provider.dart';
import '../services/api/event_api.dart';
import '../services/api/schedule_api.dart';
import '../models/schedule_event.dart';
import '../widgets/input/labeled_text_field.dart';
import '../widgets/input/date_time_picker_row.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

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
      final result =
          await EventApi.extractEvent(_naturalLanguageController.text);
      if (result != null) {
        final event = ScheduleEvent.fromJson(result);
        setState(() {
          _titleController.text = event.title;
          _locationController.text = event.location;
          _startDate = event.startTime;
          _startTime = TimeOfDay.fromDateTime(event.startTime);
          _endDate = event.endTime;
          _endTime = TimeOfDay.fromDateTime(event.endTime);

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

  Future<void> _selectDate(String type) async {
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

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        switch (type) {
          case 'start':
            _startDate = date;
            break;
          case 'end':
            _endDate = date;
            break;
          case 'notify':
            _notifyDate = date;
            break;
        }
      });
    }
  }

  Future<void> _selectTime(String type) async {
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

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time != null) {
      setState(() {
        switch (type) {
          case 'start':
            _startTime = time;
            break;
          case 'end':
            _endTime = time;
            break;
          case 'notify':
            _notifyTime = time;
            break;
        }
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
        title: const Text('予定を追加'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showManualForm) ...[
              Container(
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
                        Icon(Icons.auto_awesome, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'AI予定作成',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '予定を入力してください',
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _naturalLanguageController,
                      decoration: InputDecoration(
                        hintText: '例: 明日の午後3時から5時まで東京オフィスでミーティング',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _analyzeNaturalLanguage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              )
                            : const Text('AI解析'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'または',
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _showManualInput,
                      child: Text(
                        '手動で入力する',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_showManualForm) ...[
              Container(
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
                    const Text(
                      '開始日時 *',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DateTimePickerRow(
                      date: _startDate,
                      time: _startTime,
                      onDateTap: () => _selectDate('start'),
                      onTimeTap: () => _selectTime('start'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '終了日時 *',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DateTimePickerRow(
                      date: _endDate,
                      time: _endTime,
                      onDateTap: () => _selectDate('end'),
                      onTimeTap: () => _selectTime('end'),
                    ),
                    const SizedBox(height: 16),
                    LabeledTextField(
                      label: '場所 *',
                      controller: _locationController,
                      hintText: '場所を入力',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    LabeledTextField(
                      label: '住所（オプション）',
                      controller: _addressController,
                      hintText: '詳細な住所を入力',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '通知時間を設定',
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
                                // 開始時刻の1時間前をデフォルトに設定
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
                      const Text(
                        '通知日時',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DateTimePickerRow(
                        date: _notifyDate,
                        time: _notifyTime,
                        onDateTap: () => _selectDate('notify'),
                        onTimeTap: () => _selectTime('notify'),
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
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: primaryColor),
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
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
