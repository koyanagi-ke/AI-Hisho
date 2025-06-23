import 'package:app/utils/show_custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../models/schedule.dart';
import '../../screens/checklist_detail_screen.dart';
import '../../services/api/schedule_api.dart';

class ScheduleCard extends StatefulWidget {
  final Schedule schedule;
  final Color primaryColor;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.primaryColor,
  });

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  bool _isDeleted = false;
  bool _isDeleting = false;

  // 時間帯に基づいてボーダー色を決定
  Color _getBorderColor() {
    final startHour = widget.schedule.startTime.hour;
    final endHour = widget.schedule.endTime.hour;
    final isSameDay =
        DateUtils.isSameDay(widget.schedule.startTime, widget.schedule.endTime);

    if (!isSameDay) {
      return Colors.purple[600]!;
    }

    final duration =
        widget.schedule.endTime.difference(widget.schedule.startTime).inHours;
    if (duration >= 8) {
      return Colors.red[600]!;
    }

    if (endHour <= 12) {
      return Colors.blue[600]!;
    }

    if (startHour >= 12) {
      return Colors.orange[600]!;
    }

    return Colors.green[600]!;
  }

  Future<bool> _deleteSchedule() async {
    if (_isDeleting || _isDeleted) return false;

    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await ScheduleApi.deleteSchedule(widget.schedule.eventId);

      if (success) {
        setState(() {
          _isDeleted = true;
          _isDeleting = false;
        });

        if (mounted) {
          showCustomToast(
            context,
            '「${widget.schedule.title}」を削除しました',
            backgroundColor: Colors.green,
          );
        }
        return true;
      } else {
        setState(() {
          _isDeleting = false;
        });

        if (mounted) {
          showCustomToast(
            context,
            '予定の削除に失敗しました',
            backgroundColor: Colors.red,
          );
        }
        return false;
      }
    } catch (e) {
      print('Delete error: $e');
      setState(() {
        _isDeleting = false;
      });

      if (mounted) {
        showCustomToast(
          context,
          'エラーが発生しました: $e',
          backgroundColor: Colors.red,
        );
      }
      return false;
    }
  }

  void _navigateToDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChecklistDetailScreen(
          eventId: widget.schedule.eventId,
          eventTitle: widget.schedule.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 削除済みの場合は非表示
    if (_isDeleted) {
      return const SizedBox.shrink();
    }

    final borderColor = _getBorderColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key('schedule_${widget.schedule.eventId}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          // 削除処理を実行し、結果に基づいてDismissibleの動作を決定
          return await _deleteSchedule();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(height: 4),
              Text(
                '削除',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        child: AnimatedOpacity(
          opacity: _isDeleting ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isDeleting ? null : _navigateToDetail,
                borderRadius: BorderRadius.circular(12),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // 左側のカラーボーダー
                      Container(
                        width: 6,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.schedule.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray900,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 時間情報
                              _buildTimeInfo(),
                              const SizedBox(height: 8),

                              // 場所情報
                              _buildLocationInfo(),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.gray400,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.chevron_right,
                                color: AppColors.gray400,
                                size: 24,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo() {
    final startTime = DateFormat('HH:mm').format(widget.schedule.startTime);
    final endTime = DateFormat('HH:mm').format(widget.schedule.endTime);

    final isSameDay =
        DateUtils.isSameDay(widget.schedule.startTime, widget.schedule.endTime);
    final timeDisplay = isSameDay
        ? '$startTime - $endTime'
        : '${DateFormat('M月d日', 'ja').format(widget.schedule.startTime)} - ${DateFormat('M月d日', 'ja').format(widget.schedule.endTime)}';

    return Row(
      children: [
        const Icon(
          Icons.access_time_rounded,
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_rounded,
          size: 16,
          color: AppColors.gray500,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.schedule.location,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
