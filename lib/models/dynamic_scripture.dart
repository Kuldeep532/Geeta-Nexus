/// Shared models for dynamic scripture loading (unlimited text support).

class DynamicChapter {
  final int? number;
  final String? name;
  final String? summary;
  final int? verseCount;

  const DynamicChapter({
    this.number,
    this.name,
    this.summary,
    this.verseCount,
  });

  factory DynamicChapter.fromJson(Map<String, dynamic> j) {
    return DynamicChapter(
      number: (j['chapter_number'] as num? ?? j['number'] as num? ?? 0).toInt(),
      name: j['name'] as String? ?? j['title'] as String? ?? j['name_translation'] as String? ?? 'Untitled',
      summary: j['chapter_summary'] as String? ?? j['summary'] as String? ?? '',
      verseCount: (j['verses_count'] as num? ?? j['verse_count'] as num? ?? 0).toInt(),
    );
  }
}

class DynamicVerse {
  final int? verseNumber;
  final String text;
  final String transliteration;
  final String translation;
  final String wordMeanings;

  const DynamicVerse({
    this.verseNumber,
    required this.text,
    this.transliteration = '',
    this.translation = '',
    this.wordMeanings = '',
  });

  factory DynamicVerse.fromJson(Map<String, dynamic> j) {
    return DynamicVerse(
      verseNumber: (j['verse_number'] as num? ?? j['number'] as num? ?? 0).toInt(),
      text: j['text'] as String? ?? j['sanskrit'] as String? ?? j['verse'] as String? ?? '',
      transliteration: j['transliteration'] as String? ?? '',
      translation: j['translation'] as String? ?? j['description'] as String? ?? j['meaning'] as String? ?? '',
      wordMeanings: j['word_meanings'] as String? ?? j['word_meaning'] as String? ?? '',
    );
  }
}
