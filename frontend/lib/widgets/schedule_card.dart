import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../models/schedule.dart';
import '../../screens/checklist_detail_screen.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final Color primaryColor;
  final bool showChecklistButton;
  final VoidCallback? onTap;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.primaryColor,
    this.showChecklistButton = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTimeInfo(),
                          const SizedBox(height: 8),
                          _buildLocationInfo(),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showChecklistButton) ...[
                  const SizedBox(height: 20),
                  _buildChecklistButton(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo() {
    final startDate = DateFormat('M月d日（E）', 'ja').format(schedule.startTime);
    final startTime = DateFormat('HH:mm').format(schedule.startTime);
    final endTime = DateFormat('HH:mm').format(schedule.endTime);

    final isSameDay = DateUtils.isSameDay(schedule.startTime, schedule.endTime);
    final timeDisplay = isSameDay
        ? '$startDate $startTime 〜 $endTime'
        : '$startDate 〜 ${DateFormat('M月d日（E）', 'ja').format(schedule.endTime)}';

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
            schedule.location,
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

  Widget _buildChecklistButton(BuildContext context) {
    return SizedBox(
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
        ),
        label: const Text(
          '持ち物リストを確認',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
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
    );
  }
}
