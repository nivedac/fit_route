import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final uri = Uri.parse('https://integrate.api.nvidia.com/v1/chat/completions');
  // First, let's try a known model: meta/llama-3.1-70b-instruct
  final body = jsonEncode({
    'model': 'meta/llama-3.1-70b-instruct',
    'messages': [
      {'role': 'user', 'content': 'Test'}
    ],
    'max_tokens': 10,
  });

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: body,
    );
    print('Status: ' + response.statusCode.toString());
    print('Body: ' + response.body);
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
