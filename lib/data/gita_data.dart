import 'package:flutter/foundation.dart'; 
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/models.dart';

List<Chapter> kChapters = [];
List<Verse> allVerses = []; 

/// Sare verses ko fetch karne ka helper function
List<Verse> getAllVerses() {
  return allVerses;
}

Future<void> loadGitaData() async {
  try {
    // 1. CSV Load: Path matched with your requirement
    final String rawData = await rootBundle.loadString("assets/data/Bhagwad_Gita.csv");
    
    // 2. Conversion: Standard CSV mapping
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

    if (listData.isEmpty) {
      debugPrint("CSV File is empty!");
      return;
    }

    // Header row (ID, Chapter, Verse...) ko hatana
    listData.removeAt(0);

    Map<int, List<Verse>> chapterVersesMap = {};
    allVerses.clear(); 

    for (var row in listData) {
      // Safety Check: CSV has 8 columns (Index 0 to 7)
      if (row.length < 7) continue;

      final int chapterNum = int.tryParse(row[1].toString()) ?? 0;
      final int verseNum = int.tryParse(row[2].toString()) ?? 0;
      
      if (chapterNum == 0) continue; 

      final verse = Verse(
        id: row[0].toString(),              // Column 0: ID
        chapter: chapterNum,               // Column 1: Chapter
        verse: verseNum,                   // Column 2: Verse
        sanskrit: row[3]?.toString() ?? "", // Column 3: Shloka
        transliteration: row[4]?.toString() ?? "", // Column 4: Transliteration
        meaning: row[5]?.toString() ?? "",  // Column 5: HinMeaning -> Meaning
        translation: row[6]?.toString() ?? "", // Column 6: EngMeaning -> Translation
        keywords: _generateKeywords(row[6].toString()),
      );

      chapterVersesMap.putIfAbsent(chapterNum, () => []).add(verse);
      allVerses.add(verse); 
    }

    // 3. Mapping Chapters
    kChapters = chapterVersesMap.entries.map((entry) {
      final int chNum = entry.key;
      return Chapter(
        number: chNum,
        name: _getChapterName(chNum),
        nameSanskrit: _getSanskritName(chNum),
        summary: _getChapterSummary(chNum), 
        verseCount: entry.value.length,
        theme: _getChapterTheme(chNum),
        verses: entry.value,
      );
    }).toList();

    kChapters.sort((a, b) => a.number.compareTo(b.number));
    
    debugPrint("✅ Gita Data Matched & Loaded: ${allVerses.length} verses.");

  } catch (e, stacktrace) {
    debugPrint("❌ Fatal Error matching CSV data: $e");
    debugPrint(stacktrace.toString());
  }
}

List<String> _generateKeywords(String text) {
  if (text.isEmpty) return [];
  final commonWords = {'the', 'and', 'is', 'of', 'in', 'it', 'you', 'that'};
  return text.toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), '')
      .split(' ')
      .where((w) => w.length > 3 && !commonWords.contains(w))
      .take(5)
      .toList();
}

List<Verse> searchVerses(String query) {
  if (query.isEmpty) return [];
  final q = query.toLowerCase();
  return allVerses.where((v) {
    return v.translation.toLowerCase().contains(q) || 
           v.meaning.toLowerCase().contains(q) || 
           v.id.toLowerCase() == q;
  }).toList();
}

// --- Metadata Helpers (Fixed Syntax) ---

String _getChapterTheme(int num) {
  if (num <= 6) return "Karma & Selfless Action";
  if (num <= 12) return "Bhakti & Devotion";
  return "Jnana & Liberation";
}

String _getChapterSummary(int num) {
  const summaries = {
    1: "Arjuna faces a moral crisis on the battlefield of Kurukshetra.",
    2: "Krishna teaches the immortality of the soul and the duty of a warrior.",
    3: "The path of selfless action without attachment to results.",
  };
  return summaries[num] ?? "Divine guidance from the Lord in Chapter $num.";
}

String _getChapterName(int num) {
  const names = {
    1: "Arjuna's Dilemma", 2: "Path of Knowledge", 3: "Karma Yoga",
    4: "Wisdom of Action", 5: "Renunciation", 6: "Meditation",
    7: "Realization", 8: "The Eternal", 9: "Royal Secret",
    10: "Divine Splendor", 11: "Cosmic Form", 12: "Devotion",
    13: "Field & Knower", 14: "Three Gunas", 15: "Ultimate Person",
    16: "Divine & Demonic", 17: "Faith", 18: "Liberation"
  };
  return names[num] ?? "Chapter $num";
}

String _getSanskritName(int num) {
  const namesSanskrit = {
    1: "Arjuna Vishada Yoga", 2: "Sankhya Yoga", 3: "Karma Yoga",
    4: "Jnana Karma Sanyasa Yoga", 5: "Karma Sanyasa Yoga", 6: "Dhyana Yoga",
    7: "Jnana Vijnana Yoga", 8: "Akshara Brahma Yoga", 9: "Raja Vidya Yoga",
    10: "Vibhuti Yoga", 11: "Vishwarupa Darshana Yoga", 12: "Bhakti Yoga",
    13: "Kshetra Kshetrajna Yoga", 14: "Gunatraya Vibhaga Yoga", 15: "Purushottama Yoga",
    16: "Daivasura Sampad Yoga", 17: "Shraddhatraya Vibhaga Yoga", 18: "Moksha Sanyasa Yoga",
  };
  return namesSanskrit[num] ?? "";
}
