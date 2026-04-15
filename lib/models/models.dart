class Verse {
  final String id;
  final int chapter;
  final int verse;
  final String sanskrit;
  final String transliteration;
  final String translation;
  final String meaning;
  final List<String> keywords;

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

  factory JournalEntry.fromMap(Map<String, dynamic> m) => JournalEntry(
        id: m['id'],
        content: m['content'],
        mood: m['mood'],
        date: DateTime.parse(m['date']),
      );
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
}
