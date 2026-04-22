import 'package:flutter/foundation.dart'; // FIX: Isse debugPrint ka error solve hoga
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/models.dart';

List<Chapter> kChapters = [];
List<Verse> allVerses = []; 

// FIX: Is helper function ko add karne se RandomVerseScreen ka error chala jayega
List<Verse> getAllVerses() {
  return allVerses;
}

Future<void> loadGitaData() async {
  try {
    final String rawData = await rootBundle.loadString("assets/images/Bhagwad_Gita.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

    if (listData.isNotEmpty) {
      listData.removeAt(0);
    }

    Map<int, List<Verse>> chapterVersesMap = {};
    allVerses.clear(); 

    for (var row in listData) {
      if (row.length < 8) continue;

      final int chapterNum = int.parse(row[1].toString());
      
      final verse = Verse(
        id: row[0].toString(),
        chapter: chapterNum,
        verse: int.parse(row[2].toString()),
        sanskrit: row[3].toString(),
        transliteration: row[4].toString(),
        translation: row[6].toString(), 
        meaning: row[5].toString(),     
        keywords: [], 
      );

      chapterVersesMap.putIfAbsent(chapterNum, () => []).add(verse);
      allVerses.add(verse); 
    }

    kChapters = chapterVersesMap.entries.map((entry) {
      return Chapter(
        number: entry.key,
        name: _getChapterName(entry.key),
        nameSanskrit: _getSanskritName(entry.key),
        summary: "Chapter ${entry.key}",
        verseCount: entry.value.length,
        theme: "Spiritual Wisdom",
        verses: entry.value,
      );
    }).toList();

    kChapters.sort((a, b) => a.number.compareTo(b.number));
    
    debugPrint("Gita data loaded: ${allVerses.length} verses"); // Ab error nahi aayega

  } catch (e) {
    debugPrint("Error loading Gita data: $e"); // FIX: foundation.dart ki wajah se ab ye chalega
  }
}

List<Verse> searchVerses(String query) {
  if (query.isEmpty) return [];
  final lowercaseQuery = query.toLowerCase();
  
  return allVerses.where((v) {
    return v.translation.toLowerCase().contains(lowercaseQuery) || 
           v.meaning.toLowerCase().contains(lowercaseQuery) || 
           v.verse.toString() == query;
  }).toList();
}

String _getChapterName(int num) {
  const names = {
    1: "Arjuna's Dilemma",
    2: "The Path of Knowledge",
    3: "Karma Yoga",
    4: "Wisdom of Action",
    5: "Renunciation",
    6: "Meditation",
    7: "Knowledge & Realization",
    8: "The Eternal",
    9: "Royal Secret",
    10: "Divine Splendor",
    11: "Cosmic Form",
    12: "Devotion",
    13: "Field & Knower",
    14: "Three Gunas",
    15: "Ultimate Person",
    16: "Divine & Demonic",
    17: "Three Folds of Faith",
    18: "Liberation"
  };
  return names[num] ?? "Chapter $num";
}

String _getSanskritName(int num) {
  const namesSanskrit = {
    1: "Arjuna Vishada Yoga",
    2: "Sankhya Yoga",
    3: "Karma Yoga",
    4: "Jnana Karma Sanyasa Yoga",
    5: "Karma Sanyasa Yoga",
    6: "Dhyana Yoga",
    7: "Jnana Vijnana Yoga",
    8: "Akshara Brahma Yoga",
    9: "Raja Vidya Raja Guhya Yoga",
    10: "Vibhuti Vistara Yoga",
    11: "Vishwarupa Darshana Yoga",
    12: "Bhakti Yoga",
    13: "Kshetra Kshetrajna Vibhaga Yoga",
    14: "Gunatraya Vibhaga Yoga",
    15: "Purushottama Yoga",
    16: "Daivasura Sampad Vibhaga Yoga",
    17: "Shraddhatraya Vibhaga Yoga",
    18: "Moksha Sanyasa Yoga",
  };
  return namesSanskrit[num] ?? "";
}
