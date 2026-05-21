import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scripture_model.dart';
import '../services/scripture_service.dart';

class ScriptureRepository {
  // --- Constants & Base URLs ---
  static const _dharmicBase = 'https://raw.githubusercontent.com/bhavykhatri/DharmicData/main';
  static const _everydayCodingsGitaBase = 'https://raw.githubusercontent.com/everydaycodings/Bhagavad-Gita/main';
  static const _timeout = Duration(seconds: 20);

  // --- Core Helper ---
  Future<http.Response> _get(String url) async {
    final uri = Uri.parse(Uri.encodeFull(url));
    return http.get(uri).timeout(_timeout);
  }

  static String _safeUtf8(List<int> bodyBytes) {
    try { return utf8.decode(bodyBytes); } catch (_) { return latin1.decode(bodyBytes); }
  }

  // --- A. Gita Methods ---
  Future<List<ScriptureChapterData>> fetchChapters() async {
    final resp = await _get('$_dharmicBase/SrimadBhagvadGita/chapters.json');
    if (resp.statusCode != 200) return [];
    final list = jsonDecode(_safeUtf8(resp.bodyBytes)) as List;
    return list.map((e) => ScriptureChapterData.fromJson(e)).toList();
  }

  Future<List<ScriptureVerse>> fetchGitaChapter(int chapter) async {
    final resp = await _get('$_dharmicBase/SrimadBhagvadGita/bhagavad_gita_chapter_$chapter.json');
    if (resp.statusCode != 200) throw Exception('Failed to load Gita');
    final root = jsonDecode(_safeUtf8(resp.bodyBytes));
    final entries = (root is Map) ? (root['BhagavadGitaChapter'] as List) : (root as List);
    
    return entries.map<ScriptureVerse>((e) {
      final map = e as Map<String, dynamic>;
      final vNum = (map['verse'] ?? map['verse_number'] ?? 0).toInt();
      return ScriptureVerse(
        source: ScriptureSource.gitaDharmicData,
        section: ScriptureSectionInfo(label: 'Chapter $chapter', sectionIndex: chapter),
        verseIndex: vNum,
        originalText: (map['text'] ?? '').toString().trim(),
        audioUrl: ScriptureService.verseRecitationUrl(chapter, vNum),
      );
    }).toList()..sort((a, b) => a.verseIndex.compareTo(b.verseIndex));
  }

  // --- B. Ramayana & Manas Methods ---
  Future<List<ScriptureVerse>> fetchRamayanaKanda(ScriptureSectionDef def) async {
    final resp = await _get('$_dharmicBase/ValmikiRamayana/${def.fileName}');
    if (resp.statusCode != 200) return [];
    final entries = jsonDecode(_safeUtf8(resp.bodyBytes)) as List;
    return entries.map((e) {
      final map = e as Map<String, dynamic>;
      return ScriptureVerse(
        source: ScriptureSource.ramayanaValmiki,
        section: ScriptureSectionInfo(label: def.englishName, sectionIndex: def.index),
        verseIndex: (map['shloka'] ?? 0).toInt(),
        originalText: (map['text'] ?? '').toString().trim(),
      );
    }).toList();
  }

  Future<List<ScriptureVerse>> fetchRamchariKanda(ScriptureSectionDef def) async {
    final resp = await _get('$_dharmicBase/Ramcharitmanas/${def.fileName}');
    if (resp.statusCode != 200) return [];
    final entries = jsonDecode(_safeUtf8(resp.bodyBytes)) as List;
    int idx = 1;
    return entries.map((e) {
      return ScriptureVerse(
        source: ScriptureSource.ramcharitmanas,
        section: ScriptureSectionInfo(label: def.englishName, sectionIndex: def.index),
        verseIndex: idx++,
        originalText: (e['content'] ?? '').toString().trim(),
      );
    }).toList();
  }

  // --- C. Extra Data Sources ---
  Future<List<ScriptureVerse>> fetchEverydayCodingsGita(int chapter) async {
    final resp = await _get('$_everydayCodingsGitaBase/chapters/$chapter.json');
    if (resp.statusCode != 200) return [];
    final root = jsonDecode(_safeUtf8(resp.bodyBytes)) as List;
    return root.map((e) {
      final map = e as Map<String, dynamic>;
      // FIXED: Extra comma hataya
      final vNum = (map['verse_number'] ?? 0).toInt(); 
      return ScriptureVerse(
        source: ScriptureSource.gitaDharmicData,
        verseIndex: vNum,
        originalText: (map['text'] ?? '').toString(),
      );
    }).toList();
  }

  // --- D. Global Search & Archive Logic ---
  // ... (Baaki methods searchGita, searchRamayana, getStaticArchiveAudioTracks same rahenge)

  Future<ArchiveAudioResult?> searchArchiveAudio(String query) async {
    try {
      final searchUrl = Uri.parse('https://archive.org/advancedsearch.php?q=${Uri.encodeQueryComponent(query)}&fl[]=identifier&fl[]=title&rows=5&output=json');
      final resp = await http.get(searchUrl).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) return null;

      final data = jsonDecode(_safeUtf8(resp.bodyBytes));
      final docs = data['response']?['docs'] as List<dynamic>?;
      if (docs == null || docs.isEmpty) return null;

      for (final doc in docs) {
        final id = doc['identifier'] as String;
        final metaResp = await http.get(Uri.parse('https://archive.org/metadata/$id')).timeout(const Duration(seconds: 10));
        if (metaResp.statusCode != 200) continue;

        final meta = jsonDecode(_safeUtf8(metaResp.bodyBytes));
        final files = meta['files'] as List<dynamic>?;
        final audioFile = files?.firstWhere((f) => (f['name'] as String).toLowerCase().endsWith('.mp3'), orElse: () => null);

        if (audioFile != null) {
          return ArchiveAudioResult(title: doc['title'] ?? 'Audio', url: 'https://archive.org/download/$id/${audioFile['name']}');
        }
      }
    } catch (_) {}
    return null;
  }
}
