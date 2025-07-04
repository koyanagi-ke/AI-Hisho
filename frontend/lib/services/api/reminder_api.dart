import 'package:app/services/api/api_service.dart';
import 'package:flutter/material.dart';
import '../../models/schedule.dart';
import '../../models/schedule_detail.dart';

class ReminderApi {
  static Future<List<Schedule>?> getReminderSchedules() async {
    final result = await ApiService.request<List<dynamic>>(
      path: '/api/reminder',
      method: 'GET',
    );

    if (result != null) {
      try {
        final List<Map<String, dynamic>> list = result.map((e) {
          return Map<String, dynamic>.from(e as Map);
        }).toList();

        return list.map(Schedule.fromJson).toList();
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  static Future<Map<String, dynamic>?> toggleChecklistItem({
    required String eventId,
    required String checklistId,
    required bool checked,
  }) async {
    final body = {
      "event_id": eventId,
      "checklist_id": checklistId,
      "checked": checked,
    };

    return await ApiService.request(
      path: '/api/checklist-toggle',
      method: 'POST',
      body: body,
    );
  }
}
