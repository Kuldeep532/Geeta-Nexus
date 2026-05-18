import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/scripture_model.dart';
import 'scripture_service.dart' show ScriptureService;

import ScriptureRepository {
  // Existing Base URL
  static const _dharmicBase =
      'https://raw.githubusercontent.com/bhavykhatri/DharmicData/main';
  
  // WARNING FIX: Unused field '_hinduScripturesBase' was completely removed from here.
  
  // New Open-Source GitHub Data Sources
  static const _indianScripturesBase = 
      'https://raw.githubusercontent.com/hrgupta/indian-scriptures/master';
  static const _everydayCodingsGitaBase = 
      'https://raw.githubusercontent.com/everydaycodings/Bhagavad-Gita/main';

  static const _timeout = Duration(seconds: 20);

  // --- URL Builders ---
  String _gitaChapterUrl(int ch) =>
      '$_dharmicBase/SrimadBhagvadGita/bhagavad_gita_chapter_$ch.json';

  String _ramayanaKandaUrl(String fileName) =>
      '$_dharmicBase/ValmikiRamayana/$fileName';

  String _ramchariKandaUrl(String fileName) =>
      '$_dharmicBase/Ramcharitmanas/$fileName';

  // --- Helper Methods ---
  static String _safeUtf8(List<int> bodyBytes) {
    try {
      return utf8.decode(bodyBytes);
    } catch (_) {
      return latin1.decode(bodyBytes);
    }
  }

  Future<http.Response> _get(String url) async {
    final uri = Uri.parse(Uri.encodeFull(url));
    return http.get(uri).timeout(_timeout);
  }

  // --- 1. Existing DharmicData Source Methods ---
  Future<List<ScriptureVerse>> fetchGitaChapter(int chapter) async {
    final resp = await _get(_gitaChapterUrl(chapter));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load Gita chapter $chapter (${resp.statusCode})');
    }
    final body = _safeUtf8(resp.bodyBytes);
    final root = jsonDecode(body);

    List<dynamic> entries;
    if (root is Map && root.containsKey('BhagavadGitaChapter')) {
      entries = root['BhagavadGitaChapter'] as List<dynamic>;
    } else if (root is List) {
      entries = root;
    } else {
      return [];
    }

    final section = ScriptureSectionInfo(
      label: 'Chapter $chapter',
      sectionIndex: chapter,
    );

    return entries.map<ScriptureVerse>((e) {
      final map = e as Map<String, dynamic>;
      final verseNum = (map['verse'] as num? ?? map['verse_number'] as num? ?? 0).toInt();
      final text = (map['text'] as String? ?? '').trim();

      final rawTrans = map['translations'];
      final translations = <String, String>{};
      if (rawTrans is Map) {
        for (final entry in rawTrans.entries) {
          final val = entry.value;
          if (val is String && val.trim().isNotEmpty) {
            translations[entry.key.toString()] = val.trim();
          }
        }
      }

      final rawComm = map['commentaries'];
      final commentaries = <String, String>{};
      if (rawComm is Map) {
        for (final entry in rawComm.entries) {
          final val = entry.value;
          if (val is String && val.trim().isNotEmpty) {
            commentaries[entry.key.toString()] = val.trim();
          }
        }
      }

      final audioUrl = ScriptureService.verseRecitationUrl(chapter, verseNum);

      return ScriptureVerse(
        source: ScriptureSource.gitaDharmicData,
        section: section,
        verseIndex: verseNum,
        originalText: text,
        translations: translations,
        commentaries: commentaries,
        audioUrl: audioUrl,
      );
    }).toList()
      ..sort((a, b) => a.verseIndex.compareTo(b.verseIndex));
  }

  Future<List<ScriptureVerse>> fetchRamayanaKanda(ScriptureSectionDef def) async {
    final resp = await _get(_ramayanaKandaUrl(def.fileName));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load Ramayana ${def.englishName} (${resp.statusCode})');
    }
    final body = _safeUtf8(resp.bodyBytes);
    final root = jsonDecode(body);
    if (root is! List) return [];

    final entries = root as List<dynamic>;
    // ERROR FIX: Removed the stray comma after 'final verses ='
    final verses = <ScriptureVerse>[];
    int seqIndex = 1;

    for (final e in entries) {
      final map = e as Map<String, dynamic>;
      final sarg = (map['sarg'] as num? ?? 0).toInt();
      final shloka = (map['shloka'] as num? ?? seqIndex).toInt();
      final text = (map['text'] as String? ?? '').trim();
      if (text.isEmpty) { seqIndex++; continue; }

      verses.add(ScriptureVerse(
        source: ScriptureSource.ramayanaValmiki,
        section: ScriptureSectionInfo(
          label: def.englishName,
          subLabel: sarg > 0 ? 'Sarga $sarg' : '',
          sectionIndex: def.index,
        ),
        verseIndex: shloka > 0 ? shloka : seqIndex,
        originalText: text,
      ));
      seqIndex++;
    }

    return verses;
  }

  Future<List<ScriptureVerse>> fetchRamchariKanda(ScriptureSectionDef def) async {
    final resp = await _get(_ramchariKandaUrl(def.fileName));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load Ramcharitmanas ${def.englishName} (${resp.statusCode})');
    }
    final body = _safeUtf8(resp.bodyBytes);
    final root = jsonDecode(body);
    if (root is! List) return [];

    final entries = root as List<dynamic>;
    final verses = <ScriptureVerse>[];
    int seqIndex = 1;

    for (final e in entries) {
      final map = e as Map<String, dynamic>;
      final content = (map['content'] as String? ?? '').trim();
      final type = (map['type'] as String? ?? '').trim();
      if (content.isEmpty) { seqIndex++; continue; }

      verses.add(ScriptureVerse(
        source: ScriptureSource.ramcharitmanas,
        section: ScriptureSectionInfo(
          label: def.englishName,
          subLabel: def.devanagariName,
          sectionIndex: def.index,
        ),
        verseIndex: seqIndex,
        originalText: content,
        verseType: type.isNotEmpty ? type : null,
      ));
      seqIndex++;
    }

    return verses;
  }

  // --- 2. New Data Source Methods ---

  /// Fetches chapter data from everydaycodings/Bhagavad-Gita source
  Future<List<ScriptureVerse>> fetchEverydayCodingsGita(int chapter) async {
    final url = '$_everydayCodingsGitaBase/chapters/$chapter.json';
    final resp = await _get(url);
    if (resp.statusCode != 200) throw Exception('Failed everydaycodings fetch');

    final root = jsonDecode(_safeUtf8(resp.bodyBytes));
    if (root is! List) return [];

    final section = ScriptureSectionInfo(label: 'Gita Ch $chapter', sectionIndex: chapter);

    return root.map<ScriptureVerse>((e) {
      final map = e as Map<String, dynamic>;
      return ScriptureVerse(
        source: ScriptureSource.gitaDharmicData, 
        section: section,
        verseIndex: (map['verse_number'] ?? 0).toInt(),
        originalText: (map['text'] ?? '').toString(),
        translations: {'English': (map['translation'] ?? '').toString()},
      );
    }).toList();
  }

  /// Fetches various text payloads from hrgupta/indian-scriptures source
  Future<List<ScriptureVerse>> fetchIndianScripturesPayload(String path, String sectionTitle) async {
    final url = '$_indianScripturesBase/$path';
    final resp = await _get(url);
    if (resp.statusCode != 200) throw Exception('Failed indian-scriptures fetch');

    final root = jsonDecode(_safeUtf8(resp.bodyBytes));
    if (root is! List) return [];

    final section = ScriptureSectionInfo(label: sectionTitle, sectionIndex: 1);
    int index = 1;

    return root.map<ScriptureVerse>((e) {
      final map = e as Map<String, dynamic>;
      return ScriptureVerse(
        source: ScriptureSource.gitaDharmicData,
        section: section,
        verseIndex: index++,
        originalText: (map['text'] ?? map['verse'] ?? '').toString(),
        translations: {'Translation': (map['translation'] ?? '').toString()},
      );
    }).toList();
  }

  /// Map direct track addresses from designated Internet Archive items
  // ERROR FIX: Removed the stray comma before Map<String, String>
  Map<String, String> getStaticArchiveAudioTracks() {
    return {
      'YatharthGeetaEnglish': 'https://archive.org/download/YatharthGeetaEnglishAudio/',
      'GitaBesantMeier': 'https://archive.org/download/bhagavadgita-1-besant-meier/',
      'RamcharitmanasSukhanandaPranam': 'https://archive.org/download/Ramcharitmanas_by_Swami_Sukhananda_in_Hindi/001_Pranam_Mantra_Ramcharitmanas_2018.mp3',
      'ValmikiRamayanaKannadaBala': 'https://archive.org/download/ValmikiRamayanaKannadaSlokaPravachanaCompleteRamayana/Ramayanam_Bala+Swamyji/Ramayanam-Kannada+Day+01/K001-01+Sri+Ganeshaya+Namaha.mp3'
    };
  }

  // --- 3. Dynamic Metadata Audio Search ---
  Future<ArchiveAudioResult?> searchArchiveAudio(String query) async {
    try {
      final searchUrl = Uri.parse(
        'https://archive.org/advancedsearch.php'
        '?q=${Uri.encodeQueryComponent(query)}'
        '&fl[]=identifier&fl[]=title&rows=5&output=json'
        '&sort[]=downloads+desc',
      );
      final searchResp = await http.get(searchUrl).timeout(const Duration(seconds: 12));
      if (searchResp.statusCode != 200) return null;

      final searchData = jsonDecode(_safeUtf8(searchResp.bodyBytes));
      final docs = searchData['response']?['docs'] as List<dynamic>?;
      if (docs == null || docs.isEmpty) return null;

      for (final doc in docs) {
        final identifier = doc['identifier'] as String?;
        if (identifier == null || identifier.isEmpty) continue;

        final metaUrl = Uri.parse('https://archive.org/metadata/$identifier');
        final metaResp = await http.get(metaUrl).timeout(const Duration(seconds: 10));
        if (metaResp.statusCode != 200) continue;

        final meta = jsonDecode(_safeUtf8(metaResp.bodyBytes));
        final files = meta['files'] as List<dynamic>?;
        if (files == null) continue;

        // ERROR FIX: Adhoore code ko sahi syntax ke sath poora kiya gaya hai
        final audioFile = files.firstWhere(
          (f) {
            final name = (f['name'] as String? ?? '').toLowerCase();
            final fmt = (f['format'] as String? ?? '').toLowerCase();
            return fmt.contains('mp3') || name.endsWith('.mp3');
          },
          orElse: () => null,
        );

        if (audioFile != null) {
          return ArchiveAudioResult(
            identifier: identifier,
            title: doc['title'] as String? ?? 'Archive Track',
            fileName: audioFile['name'] as String? ?? '',
          );
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

// Helper Class to support ad-hoc ad-hoc search outputs safely
class ArchiveAudioResult {
  final String identifier;
  final String title;
  final String fileName;

  ArchiveAudioResult({
    required this.identifier,
    required this.title,
    required this.fileName,
  });

  String get downloadUrl => 'https://archive.org/download/$identifier/$fileName';
}
