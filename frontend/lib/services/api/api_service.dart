import 'dart:convert';
import 'package:app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static Future<Map<String, dynamic>?> request({
    required String path,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await AuthService.getIdToken();
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      final url = Uri.parse('$baseUrl$path');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      late http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response =
              await http.post(url, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response =
              await http.put(url, headers: headers, body: jsonEncode(body));
          break;
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('API Request Error: $e');
      return null;
    }
  }
}
