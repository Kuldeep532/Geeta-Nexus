class Verse {
  final String id;
  final int chapter;
  final int verse;
  final String sanskrit;
  final String transliteration;
  final String translation;
  final String meaning;
  final List<String> keywords;

  // UI Compatibility Getters
  int get number => verse; 
  String get text => translation;
  // Added to fix potential reference errors in UI screens
  int get verseNumber => verse; 

  const Verse({
    required this.id,
    required this.chapter,
    required this.verse,
    required this.sanskrit,
    required this.transliteration,
    required this.translation,
    required this.meaning,
    required this.keywords,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'chapter': chapter,
        'verse': verse,
        'sanskrit': sanskrit,
        'transliteration': transliteration,
        'translation': translation,
        'meaning': meaning,
        'keywords': keywords,
      };

  factory Verse.fromMap(Map<String, dynamic> m) => Verse(
        id: m['id'] ?? '',
        chapter: m['chapter'] ?? 0,
        verse: m['verse'] ?? 0,
        sanskrit: m['sanskrit'] ?? '',
        transliteration: m['transliteration'] ?? '',
        translation: m['translation'] ?? '',
        meaning: m['meaning'] ?? '',
        keywords: m['keywords'] != null ? List<String>.from(m['keywords']) : [],
      );
}

class Chapter {
  final int number;
  final String name;
  final String nameSanskrit;
  final String summary;
  final int verseCount;
  final String theme;
  final List<Verse> verses;

  const Chapter({
    required this.number,
    required this.name,
    required this.nameSanskrit,
    required this.summary,
    required this.verseCount,
    required this.theme,
    required this.verses,
  });

  Map<String, dynamic> toMap() => {
        'number': number,
        'name': name,
        'nameSanskrit': nameSanskrit,
        'summary': summary,
        'verseCount': verseCount,
        'theme': theme,
        'verses': verses.map((v) => v.toMap()).toList(),
      };

  factory Chapter.fromMap(Map<String, dynamic> m) => Chapter(
        number: m['number'] ?? 0,
        name: m['name'] ?? '',
        nameSanskrit: m['nameSanskrit'] ?? '',
        summary: m['summary'] ?? '',
        verseCount: m['verseCount'] ?? 0,
        theme: m['theme'] ?? '',
        verses: (m['verses'] as List? ?? [])
            .map((v) => Verse.fromMap(v as Map<String, dynamic>))
            .toList(),
      );
}

class JournalEntry {
  final String id;
  final String content;
  final String mood;
  final DateTime date;

  JournalEntry({
    required this.id,
    required this.content,
    required this.mood,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'mood': mood,
        'date': date.toIso8601String(),
      };

  factory JournalEntry.fromMap(Map<String, dynamic> m) {
    return JournalEntry(
      id: m['id'] ?? '',
      content: m['content'] ?? '',
      mood: m['mood'] ?? '',
      date: m['date'] != null 
          ? DateTime.tryParse(m['date'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  Map<String, dynamic> toMap() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };

  factory QuizQuestion.fromMap(Map<String, dynamic> m) => QuizQuestion(
        question: m['question'] ?? '',
        options: m['options'] != null ? List<String>.from(m['options']) : [],
        correctIndex: m['correctIndex'] ?? 0,
        explanation: m['explanation'] ?? '',
      );
}
