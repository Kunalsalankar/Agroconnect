// language_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class LanguageService {
  final String apiKey = 'YOUR_API_KEY'; // Replace with your Google Cloud Translation API key.

  Future<String> translateText(String text, String targetLanguage) async {
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$apiKey');

    final response = await http.post(
      url,
      body: json.encode({
        'q': text,
        'target': targetLanguage,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['translations'][0]['translatedText'];
    } else {
      throw Exception('Failed to translate text: ${response.statusCode}');
    }
  }
}
