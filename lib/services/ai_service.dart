import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class AIService {
  static const String _apiKey = String.fromEnvironment('GEMINI_AI_API_KEY');
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String _backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: '',
  );

  Map<String, String>? _localDataCache;

  Future<void> _initLocalData() async {
    if (_localDataCache != null) return;

    try {
      final rawData =
          await rootBundle.loadString('assets/data/training_data.csv');
      List<List<dynamic>> csvTable = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(rawData);

      _localDataCache = {};
      for (var i = 1; i < csvTable.length; i++) {
        var row = csvTable[i];
        if (row.length >= 3) {
          String question = row[1].toString().trim().toLowerCase();
          String answer = row[2].toString().trim();
          if (question.isNotEmpty) {
            _localDataCache![question] = answer;
          }
        }
      }
    } catch (e) {
      _localDataCache = {};
      debugPrint("CSV Loading Error: \$e");
    }
  }

  Future<String> getSmartResponse(String userPrompt) async {
    await _initLocalData();

    if (userPrompt.isEmpty) return "Please ask a question.";

    final query = userPrompt.trim().toLowerCase();

    if (_localDataCache!.containsKey(query)) {
      return _localDataCache![query]!;
    }

    String? bestMatch;
    for (var key in _localDataCache!.keys) {
      if (query.contains(key) || key.contains(query)) {
        bestMatch = _localDataCache![key];
        break;
      }
    }

    if (bestMatch != null) return bestMatch;

    // Try unified backend first
    final backendReply = await _fetchFromBackend(userPrompt);
    if (backendReply.isNotEmpty) return backendReply;

    // Fallback to direct Gemini
    return await _fetchFromGemini(userPrompt);
  }

  Future<String> _fetchFromBackend(String prompt) async {
    if (_backendUrl.isEmpty) return '';

    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/ask'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query': prompt,
              'persona': 'aira',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? '';
      }
    } catch (e) {
      debugPrint("Backend error: \$e");
    }
    return '';
  }

  Future<String> _fetchFromGemini(String prompt) async {
    if (_apiKey.isEmpty) {
      return "AI service unavailable. Please configure an API key.";
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_apiUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'role': 'user',
                  'parts': [{'text': prompt}]
                }
              ],
              'generationConfig': {
                'temperature': 0.6,
                'maxOutputTokens': 1000,
                'topP': 0.9,
              }
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]['content']?['parts']?[0]['text'];
        return text ?? "Could not find an answer.";
      } else {
        return _handleHttpError(response.statusCode);
      }
    } catch (e) {
      return "Network error. Please check your connection and try again.";
    }
  }

  String _handleHttpError(int statusCode) {
    if (statusCode == 429) return "Too many requests. Please wait a moment.";
    if (statusCode >= 500) return "Server busy. Please try again shortly.";
    return "Technical issue. (Error: \$statusCode)";
  }
}
