import 'package:app/services/api/api_service.dart';

class EventApi {
  static Future<Map<String, dynamic>?> extractEvent(String message) {
    final body = {
      "message": [
        {
          "role": "user",
          "parts": [
            {"text": message}
          ]
        }
      ]
    };

    return ApiService.request(
      path: '/api/message-schedule',
      method: 'POST',
      body: body,
    );
  }
}
