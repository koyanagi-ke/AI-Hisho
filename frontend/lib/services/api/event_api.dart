import 'package:app/services/api/api_service.dart';

class EventApi {
  static Future<Map<String, dynamic>?> extractEvent(
      List<Map<String, String>> messages) {
    final body = {
      "message": messages.map((msg) {
        return {
          "role": msg['role'],
          "parts": [
            {"text": msg['text']}
          ]
        };
      }).toList()
    };

    return ApiService.request(
      path: '/api/message-schedule',
      method: 'POST',
      body: body,
    );
  }
}
