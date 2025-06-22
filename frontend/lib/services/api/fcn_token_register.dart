import 'package:app/services/api/api_service.dart';

class FCNTokenRegister {
  static Future<Map<String, dynamic>?> registerToken(String token) {
    return ApiService.request(
      path: '/api/register-fcm-token',
      method: 'POST',
      body: {
        'fcm_token': token,
      },
    );
  }
}
