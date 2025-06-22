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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Color indicator
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
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
                          const SizedBox(height: 8),
                          _buildTimeInfo(),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Location
                _buildLocationInfo(),

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
        : '$startDate $startTime 〜 ${DateFormat('M月d日 HH:mm', 'ja').format(schedule.endTime)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 16,
            color: primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            timeDisplay,
            style: TextStyle(
              fontSize: 14,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 16,
            color: AppColors.gray600,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              schedule.location,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistButton(BuildContext context) {
    return Container(
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
          Icons.checklist_rtl_rounded,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          '持ち物リストを確認',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }
}
