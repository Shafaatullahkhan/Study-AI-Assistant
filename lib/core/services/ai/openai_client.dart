import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAiClient {
  OpenAiClient({
    http.Client? client,
    this.baseUrl = 'https://api.openai.com/v1/responses',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<String> generateText({
    required String apiKey,
    required String model,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final response = await _client.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'input': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('OpenAI error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final outputText = data['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }
    throw Exception('OpenAI response did not include output_text.');
  }

  Stream<String> streamText({
    required String apiKey,
    required String model,
    required String systemPrompt,
    required String userPrompt,
  }) async* {
    final request = http.Request('POST', Uri.parse(baseUrl));
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    });
    request.body = jsonEncode({
      'model': model,
      'stream': true,
      'input': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
    });

    final streamed = await _client.send(request);
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      final body = await streamed.stream.bytesToString();
      throw Exception('OpenAI error: ${streamed.statusCode} $body');
    }

    final lines = streamed.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    final buffer = <String>[];
    await for (final line in lines) {
      if (line.isEmpty) {
        for (final entry in buffer) {
          final data = entry.trim();
          if (data.isEmpty || data == '[DONE]') continue;
          final decoded = jsonDecode(data) as Map<String, dynamic>;
          final type = decoded['type'];
          if (type == 'response.output_text.delta') {
            final delta = decoded['delta'];
            if (delta is String && delta.isNotEmpty) {
              yield delta;
            }
          }
        }
        buffer.clear();
        continue;
      }
      if (line.startsWith('data:')) {
        buffer.add(line.substring(5).trim());
      }
    }
  }
}
