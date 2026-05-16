import 'dart:convert';
import 'package:http/http.dart' as http;

class ScriptureChapterData {
  final int chapterNumber;
  final String name;
  final String nameTranslation;
  final String nameTransliterated;
  final String nameMeaning;
  final String chapterSummary;
  final String chapterSummaryHindi;
  final int versesCount;
  final String imageName;

  const ScriptureChapterData({
    required this.chapterNumber,
    required this.name,
    required this.nameTranslation,
    required this.nameTransliterated,
    required this.nameMeaning,
    required this.chapterSummary,
    required this.chapterSummaryHindi,
    required this.versesCount,
    required this.imageName,
  });

  factory ScriptureChapterData.fromJson(Map<String, dynamic> j) {
    return ScriptureChapterData(
      chapterNumber: (j['chapter_number'] as num).toInt(),
      name: j['name'] as String? ?? '',
      nameTranslation: j['name_translation'] as String? ?? '',
      nameTransliterated: j['name_transliterated'] as String? ?? '',
      nameMeaning: j['name_meaning'] as String? ?? '',
      chapterSummary: j['chapter_summary'] as String? ?? '',
      chapterSummaryHindi: j['chapter_summary_hindi'] as String? ?? '',
      versesCount: (j['verses_count'] as num).toInt(),
      imageName: j['image_name'] as String? ?? '',
    );
  }
}

class ScriptureVerseData {
  final int chapterNumber;
  final int verseNumber;
  final String text;
  final String transliteration;
  final String wordMeanings;

  const ScriptureVerseData({
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    required this.transliteration,
    required this.wordMeanings,
  });

  factory ScriptureVerseData.fromJson(Map<String, dynamic> j) {
    return ScriptureVerseData(
      chapterNumber: (j['chapter_number'] as num).toInt(),
      verseNumber: (j['verse_number'] as num).toInt(),
      text: j['text'] as String? ?? '',
      transliteration: j['transliteration'] as String? ?? '',
      wordMeanings: j['word_meanings'] as String? ?? '',
    );
  }
}

class ScriptureTranslationData {
  final int chapterNumber;
  final int verseNumber;
  final String authorName;
  final String description;
  final String language;

  const ScriptureTranslationData({
    required this.chapterNumber,
    required this.verseNumber,
    required this.authorName,
    required this.description,
    required this.language,
  });

  factory ScriptureTranslationData.fromJson(Map<String, dynamic> j) {
    return ScriptureTranslationData(
      chapterNumber: (j['chapter_number'] as num? ?? 0).toInt(),
      verseNumber: (j['verse_number'] as num? ?? 0).toInt(),
      authorName: j['authorName'] as String? ?? '',
      description: j['description'] as String? ?? '',
      language: j['language'] as String? ?? 'en',
    );
  }
}

class UpanishadVerseData {
  final String upanishadName;
  final String verseText;
  final String translation;

  const UpanishadVerseData({
    required this.upanishadName,
    required this.verseText,
    required this.translation,
  });
}

class ScriptureService {
  static const String _gitaBase =
      'https://raw.githubusercontent.com/everydaycodings/Bhagavad-Gita/master/data/gita';
  static const String _indianScripturesBase =
      'https://raw.githubusercontent.com/hrgupta/indian-scriptures/master/data/raw';

  static const Duration _timeout = Duration(seconds: 15);

  static String verseRecitationUrl(int chapter, int verse) =>
      '$_gitaBase/audio/verse_recitation/$chapter/$verse.mp3';

  static String chapterSummaryAudioUrl(int chapter) =>
      '$_gitaBase/audio/chapters_summary/$chapter.mpga';

  static String get dhyanamAudioUrl =>
      '$_gitaBase/audio/Geeta-Dhyanam.m4a';

  Future<List<ScriptureChapterData>> fetchChapters() async {
    final response = await http
        .get(Uri.parse('$_gitaBase/chapters.json'))
        .timeout(_timeout);
    if (response.statusCode != 200) throw Exception('Failed to load chapters');
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => ScriptureChapterData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ScriptureVerseData>> fetchVerses() async {
    final response = await http
        .get(Uri.parse('$_gitaBase/verse.json'))
        .timeout(_timeout);
    if (response.statusCode != 200) throw Exception('Failed to load verses');
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => ScriptureVerseData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ScriptureTranslationData>> fetchTranslations() async {
    final response = await http
        .get(Uri.parse('$_gitaBase/translation.json'))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to load translations');
    }
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) =>
            ScriptureTranslationData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UpanishadVerseData>> fetchUpanishads() async {
    final response = await http
        .get(Uri.parse('$_indianScripturesBase/upanishads/upanishads.csv'))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to load upanishads');
    }
    return _parseUpanishadCsv(response.body);
  }

  List<UpanishadVerseData> _parseUpanishadCsv(String csvBody) {
    final lines = csvBody.split('\n');
    if (lines.length < 2) return [];
    final headers = _splitCsvLine(lines.first);
    final nameIdx = headers.indexWhere(
        (h) => h.toLowerCase().contains('upanishad') || h.toLowerCase().contains('name'));
    final verseIdx = headers.indexWhere(
        (h) => h.toLowerCase().contains('verse') || h.toLowerCase().contains('text') || h.toLowerCase().contains('sanskrit'));
    final transIdx = headers.indexWhere(
        (h) => h.toLowerCase().contains('translation') || h.toLowerCase().contains('english') || h.toLowerCase().contains('meaning'));

    final results = <UpanishadVerseData>[];
    for (int i = 1; i < lines.length; i++) {
      final cols = _splitCsvLine(lines[i]);
      if (cols.isEmpty) continue;
      results.add(UpanishadVerseData(
        upanishadName: nameIdx >= 0 && nameIdx < cols.length ? cols[nameIdx] : 'Upanishad',
        verseText: verseIdx >= 0 && verseIdx < cols.length ? cols[verseIdx] : '',
        translation: transIdx >= 0 && transIdx < cols.length ? cols[transIdx] : '',
      ));
    }
    return results;
  }

  List<String> _splitCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        inQuotes = !inQuotes;
      } else if (c == ',' && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(c);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }
}
