import 'package:app/services/api_service.dart';
import 'package:app/widgets/common/common_layout.dart';
import 'package:app/widgets/common/theme_builder.dart';
import 'package:app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _notifyAtController = TextEditingController();

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool _allDay = false;

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) return;

    setState(() => _isLoading = true);

    final startDateTime = _allDay
        ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day, 0, 0)
        : DateTime(_startDate!.year, _startDate!.month, _startDate!.day,
            _startTime!.hour, _startTime!.minute);
    final endDateTime = _allDay
        ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59)
        : DateTime(_endDate!.year, _endDate!.month, _endDate!.day,
            _endTime!.hour, _endTime!.minute);

    final body = {
      'title': _titleController.text,
      'start_time': startDateTime.toIso8601String(),
      'end_time': endDateTime.toIso8601String(),
      'location': _locationController.text,
      if (_addressController.text.isNotEmpty)
        'address': _addressController.text,
      if (_notifyAtController.text.isNotEmpty)
        'notify_at': _notifyAtController.text,
    };

    final success = await ApiService.request(
      path: '/api/crud-schedule',
      method: 'POST',
      body: body,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('エラー'),
          content: const Text('スケジュールの追加に失敗しました。'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ),
      );
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate =
        isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(builder: (context, primaryColor) {
      return CommonLayout(
        appBar: AppBar(
          title: const Text('スケジュールを追加'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
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
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(
                      primaryColor,
                      Icons.title,
                      'タイトル *',
                      true,
                      _titleController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      primaryColor,
                      Icons.place,
                      '場所 *',
                      true,
                      _locationController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(primaryColor, Icons.home, '住所（任意）', false,
                        _addressController),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notifyAtController,
                      decoration: const InputDecoration(
                        labelText: '通知日時（ISO8601形式）',
                        prefixIcon: Icon(Icons.notifications_active),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('終日'),
                        Switch(
                          value: _allDay,
                          onChanged: (val) => setState(() => _allDay = val),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _pickDate(isStart: true),
                          label: Text(_startDate == null
                              ? '開始日を選択'
                              : DateFormat('yyyy/MM/dd').format(_startDate!)),
                        ),
                        if (!_allDay)
                          TextButton.icon(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _pickTime(isStart: true),
                            label: Text(_startTime == null
                                ? '開始時間'
                                : _startTime!.format(context)),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _pickDate(isStart: false),
                          label: Text(_endDate == null
                              ? '終了日を選択'
                              : DateFormat('yyyy/MM/dd').format(_endDate!)),
                        ),
                        if (!_allDay)
                          TextButton.icon(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _pickTime(isStart: false),
                            label: Text(_endTime == null
                                ? '終了時間'
                                : _endTime!.format(context)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                        text: '保存する',
                        onPressed: _submit,
                        isFullWidth: true,
                        isLoading: _isLoading),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTextField(Color primaryColor, IconData icon, String text,
      bool isRequired, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: text,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        prefixIcon: Icon(
          icon,
          size: 16,
          color: primaryColor,
        ),
      ),
    );
  }
}
