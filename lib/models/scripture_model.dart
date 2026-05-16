import 'package:flutter/foundation.dart';

enum ScriptureSource { gitaDharmicData, ramayanaValmiki, ramcharitmanas }

@immutable
class ScriptureSectionInfo {
  final String label;
  final String subLabel;
  final int sectionIndex;

  const ScriptureSectionInfo({
    required this.label,
    this.subLabel = '',
    required this.sectionIndex,
  });

  String get displayLabel => subLabel.isNotEmpty ? '$label · $subLabel' : label;
}

@immutable
class ScriptureVerse {
  final ScriptureSource source;
  final ScriptureSectionInfo section;
  final int verseIndex;
  final String originalText;
  final Map<String, String> translations;
  final Map<String, String> commentaries;
  final String? verseType;
  final String? audioUrl;

  const ScriptureVerse({
    required this.source,
    required this.section,
    required this.verseIndex,
    required this.originalText,
    this.translations = const {},
    this.commentaries = const {},
    this.verseType,
    this.audioUrl,
  });

  String get sourceLabel {
    switch (source) {
      case ScriptureSource.gitaDharmicData:
        return 'Bhagavad Gita';
      case ScriptureSource.ramayanaValmiki:
        return 'Valmiki Ramayana';
      case ScriptureSource.ramcharitmanas:
        return 'Ramcharitmanas';
    }
  }

  String get semanticsLabel {
    final sb = StringBuffer();
    sb.write('$sourceLabel. ${section.displayLabel}. Verse $verseIndex. ');
    if (verseType != null) sb.write('Type: $verseType. ');
    final cleanText = originalText.replaceAll('\n', ' ');
    sb.write('Text: $cleanText. ');
    if (translations.isNotEmpty) {
      final first = translations.values.first;
      sb.write('Translation: $first. ');
    }
    return sb.toString();
  }

  ScriptureVerse copyWith({String? audioUrl}) {
    return ScriptureVerse(
      source: source,
      section: section,
      verseIndex: verseIndex,
      originalText: originalText,
      translations: translations,
      commentaries: commentaries,
      verseType: verseType,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}

@immutable
class ArchiveAudioResult {
  final String identifier;
  final String title;
  final String streamUrl;

  const ArchiveAudioResult({
    required this.identifier,
    required this.title,
    required this.streamUrl,
  });
}

@immutable
class ScriptureSectionDef {
  final int index;
  final String englishName;
  final String devanagariName;
  final String fileName;

  const ScriptureSectionDef({
    required this.index,
    required this.englishName,
    required this.devanagariName,
    required this.fileName,
  });
}

const List<ScriptureSectionDef> kRamayanaSections = [
  ScriptureSectionDef(index: 1, englishName: 'Balakanda',       devanagariName: 'बालकाण्ड',        fileName: '1_balakanda.json'),
  ScriptureSectionDef(index: 2, englishName: 'Ayodhyakanda',    devanagariName: 'अयोध्याकाण्ड',   fileName: '2_ayodhyakanda.json'),
  ScriptureSectionDef(index: 3, englishName: 'Aranyakanda',     devanagariName: 'अरण्यकाण्ड',     fileName: '3_aranyakanda.json'),
  ScriptureSectionDef(index: 4, englishName: 'Kishkindhakanda', devanagariName: 'किष्किन्धाकाण्ड', fileName: '4_kishkindhakanda.json'),
  ScriptureSectionDef(index: 5, englishName: 'Sundarakanda',    devanagariName: 'सुन्दरकाण्ड',    fileName: '5_sundarakanda.json'),
  ScriptureSectionDef(index: 6, englishName: 'Yudhhakanda',     devanagariName: 'युद्धकाण्ड',     fileName: '6_yudhhakanda.json'),
  ScriptureSectionDef(index: 7, englishName: 'Uttarakanda',     devanagariName: 'उत्तरकाण्ड',     fileName: '7_uttarakanda.json'),
];

const List<ScriptureSectionDef> kRamchariSections = [
  ScriptureSectionDef(index: 1, englishName: 'Balkand',       devanagariName: 'बालकाण्ड',        fileName: '1_बाल_काण्ड_data.json'),
  ScriptureSectionDef(index: 2, englishName: 'Ayodhyakand',   devanagariName: 'अयोध्याकाण्ड',   fileName: '2_अयोध्या_काण्ड_data.json'),
  ScriptureSectionDef(index: 3, englishName: 'Aranyakand',    devanagariName: 'अरण्यकाण्ड',     fileName: '3_अरण्य_काण्ड_data.json'),
  ScriptureSectionDef(index: 4, englishName: 'Kishkindhakand',devanagariName: 'किष्किन्धाकाण्ड',fileName: '4_किष्किन्धा_काण्ड_data.json'),
  ScriptureSectionDef(index: 5, englishName: 'Sundarkand',    devanagariName: 'सुंदरकाण्ड',     fileName: '5_सुंदर_काण्ड_data.json'),
  ScriptureSectionDef(index: 6, englishName: 'Lankakand',     devanagariName: 'लंकाकाण्ड',      fileName: '6_लंका_काण्ड_data.json'),
  ScriptureSectionDef(index: 7, englishName: 'Uttarkand',     devanagariName: 'उत्तरकाण्ड',     fileName: '7_उत्तर_काण्ड_data.json'),
];
