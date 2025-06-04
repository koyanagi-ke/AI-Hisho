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
}
