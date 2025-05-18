import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  final GenerativeModel _model;

  AIService({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash-001',
          apiKey: apiKey,
        );

  // 通常の応答生成（非ストリーミング）
  Future<String> generateResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '応答を生成できませんでした。';
    } catch (e) {
      print('AI応答生成エラー: $e');
      return 'エラーが発生しました。しばらくしてからもう一度お試しください。';
    }
  }

  // ストリーミング応答生成
  Stream<String> generateResponseStream(String prompt) async* {
    try {
      final content = [Content.text(prompt)];
      final responseStream = _model.generateContentStream(content);

      await for (final response in responseStream) {
        if (response.text != null && response.text!.isNotEmpty) {
          yield response.text!;
        }
      }
    } catch (e) {
      print('AI応答生成エラー: $e');
      yield 'エラーが発生しました。しばらくしてからもう一度お試しください。';
    }
  }
}
