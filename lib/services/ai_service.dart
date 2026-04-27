import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:string_stats/string_stats.dart'; // Optional: Similarity ke liye use kar sakte hain

class AIService {
  static const String _apiKey = String.fromEnvironment('GEMINI_AI_API_KEY');
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // Cache memory for performance
  Map<String, String>? _localDataCache;

  /// CSV Data Load aur Parse karne ka sabse behtar tarika
  Future<void> _initLocalData() async {
    if (_localDataCache != null) return;

    try {
      final rawData = await rootBundle.loadString('assets/data/training_data.csv');
      
      // 'eol' parameter ensure karta hai ki bade essays sahi se read hon
      List<List<dynamic>> csvTable = const CsvToListConverter(
        eol: '\n', 
        shouldParseNumbers: false
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
      _logError("CSV Loading Error: $e");
    }
  }

  /// Har tarah ke input ke liye smarter response logic
  Future<String> getSmartResponse(String userPrompt) async {
    await _initLocalData();
    
    if (userPrompt.isEmpty) return "Kripya kuch sawal puchein.";
    
    final query = userPrompt.trim().toLowerCase();

    // Strategy 1: Exact Match (Fastest)
    if (_localDataCache!.containsKey(query)) {
      return _localDataCache![query]!;
    }

    // Strategy 2: Keyword Similarity (Smarter Search)
    String? bestMatch;
    for (var key in _localDataCache!.keys) {
      // Agar user ka sawal CSV ke kisi key ka hissa hai ya vice-versa
      if (query.contains(key) || key.contains(query)) {
        bestMatch = _localDataCache![key];
        break; 
      }
    }

    if (bestMatch != null) return bestMatch;

    // Strategy 3: Fallback to Gemini AI
    return await _fetchFromGemini(userPrompt);
  }

  /// Secure API calling with timeout and better error messages
  Future<String> _fetchFromGemini(String prompt) async {
    if (_apiKey.isEmpty) {
      return "System Error: API key missing. Build environment check karein.";
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'role': 'user',
            'parts': [{'text': prompt}]
          }],
          'generationConfig': {
            'temperature': 0.6, // Thoda creative par accurate
            'maxOutputTokens': 1000,
            'topP': 0.9,
          }
        }),
      ).timeout(const Duration(seconds: 15)); // 15 sec timeout taaki app hang na ho

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]['content']?['parts']?[0]['text'];
        return text ?? "Kshama karein, main iska uttar nahi dhoond paaya.";
      } else {
        return _handleHttpError(response.statusCode);
      }
    } catch (e) {
      return "Network error: Connection check karein ya baad mein koshish karein.";
    }
  }

  /// Errors ko handle karne ke liye helper function
  String _handleHttpError(int statusCode) {
    if (statusCode == 429) return "Bahut saare requests! Thoda intezaar karein.";
    if (statusCode >= 500) return "Server abhi vyast hai, kripya pratiksha karein.";
    return "Kuch takniki kharabi hai. (Error: $statusCode)";
  }

  void _logError(String message) {
    // Isse aap baad mein debugging ke liye use kar sakte hain
    print("LOG: $message");
  }
}
