import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = String.fromEnvironment('GEMINI_AI_API_KEY');
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey';

  Future<List<Map<String, String>>> loadLocalTrainingData() async {
    try {
      final rawData = await rootBundle.loadString('assets/data/training_data.csv');
      List<String> lines = rawData.split('\n');
      List<String> headers = lines[0].split(',');

      return lines.skip(1).map((line) {
        List<String> values = line.split(',');
        return {
          'topic': values[0].trim(),
          'question': values[1].trim(),
          'answer': values[2].trim(),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> getAIResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': prompt}]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
      return "Pranam! Abhi server vyast hai.";
    } catch (e) {
      return "Connection error!";
    }
  }
}
