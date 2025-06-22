import 'package:app/models/schedule.dart';
import 'package:app/services/api/api_service.dart';

class ScheduleApi {
  static Future<bool> createSchedule({
    required String title,
    required String startTime,
    required String endTime,
    required String location,
    String? address,
    String? notifyAt,
  }) async {
    final body = {
      "title": title,
      "start_time": startTime,
      "end_time": endTime,
      "location": location,
      if (address != null) "address": address,
      if (notifyAt != null) "notify_at": notifyAt,
    };

    final result = await ApiService.request(
      path: '/api/crud-schedule',
      method: 'POST',
      body: body,
    );

    return result != null;
  }

  // 指定期間のスケジュールを取得
  static Future<List<Schedule>?> getSchedules({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final body = {
      "start_time": startTime.toIso8601String(),
      "end_time": endTime.toIso8601String(),
    };

    final result = await ApiService.request(
      path: '/api/schedules',
      method: 'POST',
      body: body,
    );

    if (result != null && result is List<dynamic>) {
      try {
        return result
            .cast<Map<String, dynamic>>()
            .map((item) => Schedule.fromJson(item))
            .toList();
      } catch (e) {
        print('Error parsing schedules: $e');
        return null;
      }
    }
    return null;
  }

  // 特定の日のスケジュールを取得
  static Future<List<Schedule>?> getDaySchedules(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await getSchedules(
      startTime: startOfDay,
      endTime: endOfDay,
    );
  }
}
