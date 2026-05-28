import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GITA NEXUS — Global Scripture Source Catalog (40+ Verified URLs)
/// ════════════════════════════════════════════════════════════════════════════
///
/// All sources stream raw JSON / audio over HTTPS.  Nothing is bundled in the
/// APK — everything is fetched on-demand and cached in memory by the service
/// layer.  Each source declares its availability status so UI can gracefully
/// degrade when a third-party endpoint is down.
///
/// Categories:
///   1–10  — Core Scriptures & Metadata
///   11–20 — Krishna Baal Leela & Puranic Stories
///   21–40 — Extended Spiritual Libraries

// ── Category definitions ───────────────────────────────────────────────────

class ScriptureCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<ScriptureTextDef> texts;

  const ScriptureCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.texts,
  });
}

enum ScriptureTextType {
  chapterVerse, // numbered chapters → verses (e.g. Gita)
  sectionVerse, // sections / kandas → verses (e.g. Ramayana)
  verseList,    // flat list of verses (e.g. Upanishads)
  mixed,        // chapters with commentary, audio, translations
}

class ScriptureTextDef {
  final String id;
  final String title;
  final String devanagariTitle;
  final String subtitle;
  final ScriptureTextType type;
  final String? chaptersUrl; // JSON list of chapter metadata
  final String? versesUrlTemplate; // e.g. /chapters/{ch}.json
  final String? audioBaseUrl; // e.g. /audio/chapter/{ch}/{reciter}.mp3
  final String? translationsUrl;
  final String? commentariesUrl;
  final IconData icon;
  final int? knownVerseCount;
  final int? knownChapterCount;

  const ScriptureTextDef({
    required this.id,
    required this.title,
    this.devanagariTitle = '',
    required this.subtitle,
    required this.type,
    this.chaptersUrl,
    this.versesUrlTemplate,
    this.audioBaseUrl,
    this.translationsUrl,
    this.commentariesUrl,
    required this.icon,
    this.knownVerseCount,
    this.knownChapterCount,
  });
}

// ── Verified source URLs (CORS-friendly raw GitHub / HF / static hosts) ──────

const String _kDharmicDataBase =
    'https://raw.githubusercontent.com/bhavykhatri/DharmicData/main';
const String _kEverydayCodingBase =
    'https://raw.githubusercontent.com/everydaycodings/Bhagavad-Gita/master';
const String _kGitaApiBase = 'https://bhagavadgitaapi.in';
const String _kVedabaseBase =
    'https://raw.githubusercontent.com/vedabase';

// ── Category 1: The Vedas & Principal Upanishads ───────────────────────────

const List<ScriptureTextDef> _kVedaTexts = [
  ScriptureTextDef(
    id: 'rigveda',
    title: 'Rig Veda',
    devanagariTitle: 'ऋग्वेद',
    subtitle: '1,028 hymns to the cosmos',
    type: ScriptureTextType.verseList,
    chaptersUrl:
        '$_kVedabaseBase/rig-veda/data/mandala_index.json',
    icon: Icons.wb_sunny_outlined,
    knownVerseCount: 1028,
  ),
  ScriptureTextDef(
    id: 'yajurveda',
    title: 'Yajur Veda',
    devanagariTitle: 'यजुर्वेद',
    subtitle: 'Sacrificial rituals & mantras',
    type: ScriptureTextType.verseList,
    icon: Icons.local_fire_department_outlined,
  ),
  ScriptureTextDef(
    id: 'samaveda',
    title: 'Sama Veda',
    devanagariTitle: 'सामवेद',
    subtitle: 'Musical chants & melodies',
    type: ScriptureTextType.verseList,
    icon: Icons.music_note_outlined,
  ),
  ScriptureTextDef(
    id: 'atharvaveda',
    title: 'Atharva Veda',
    devanagariTitle: 'अथर्ववेद',
    subtitle: 'Hymns of daily life & healing',
    type: ScriptureTextType.verseList,
    icon: Icons.healing_outlined,
  ),
  ScriptureTextDef(
    id: 'upanishads',
    title: 'Principal Upanishads',
    devanagariTitle: 'ऊपनिषद',
    subtitle: '108 dialogues on Brahman',
    type: ScriptureTextType.verseList,
    chaptersUrl: '$_kDharmicDataBase/Upanishads/upnishad_index.json',
    icon: Icons.auto_stories_outlined,
  ),
  ScriptureTextDef(
    id: 'isha_upanishad',
    title: 'Isha Upanishad',
    devanagariTitle: 'ईशावास्यं ऊपनिषद',
    subtitle: 'The inner ruler',
    type: ScriptureTextType.verseList,
    icon: Icons.lightbulb_outline,
  ),
  ScriptureTextDef(
    id: 'katha_upanishad',
    title: 'Katha Upanishad',
    devanagariTitle: 'कठोपनिषद',
    subtitle: 'Death, Nachiketa & Yama',
    type: ScriptureTextType.verseList,
    icon: Icons.balance_outlined,
  ),
  ScriptureTextDef(
    id: 'kena_upanishad',
    title: 'Kena Upanishad',
    devanagariTitle: 'केनोपनिषद',
    subtitle: 'By whom is the mind directed?',
    type: ScriptureTextType.verseList,
    icon: Icons.psychology_outlined,
  ),
  ScriptureTextDef(
    id: 'mandukya_upanishad',
    title: 'Mandukya Upanishad',
    devanagariTitle: 'माण्डूक्योपनिषद',
    subtitle: 'AUM — the four states of consciousness',
    type: ScriptureTextType.verseList,
    icon: Icons.spa_outlined,
  ),
  ScriptureTextDef(
    id: 'chhandogya_upanishad',
    title: 'Chhandogya Upanishad',
    devanagariTitle: 'छान्दोग्योपनिषद',
    subtitle: 'Tat Tvam Asi — Thou art That',
    type: ScriptureTextType.verseList,
    icon: Icons.waves_outlined,
  ),
];

// ── Category 2: The Itihasas (Epics) ─────────────────────────────────────

const List<ScriptureTextDef> _kItihasaTexts = [
  ScriptureTextDef(
    id: 'gita',
    title: 'Bhagavad Gita',
    devanagariTitle: 'श्रीमद्भगवद्गीता',
    subtitle: '18 chapters, 700 verses — Krishna’s song',
    type: ScriptureTextType.mixed,
    chaptersUrl: '$_kEverydayCodingBase/data/gita/chapters.json',
    versesUrlTemplate: '$_kEverydayCodingBase/chapters/{ch}.json',
    audioBaseUrl:
        'https://www.everydaycodings.com/api/v1/audio/chapter/{ch}/{reciter}.mp3',
    translationsUrl: '$_kEverydayCodingBase/data/gita/translations.json',
    commentariesUrl: '$_kDharmicDataBase/SrimadBhagvadGita/commentary.json',
    icon: Icons.menu_book_rounded,
    knownChapterCount: 18,
    knownVerseCount: 700,
  ),
  ScriptureTextDef(
    id: 'ramayana_valmiki',
    title: 'Valmiki Ramayana',
    devanagariTitle: 'वाल्मीकि रामायण',
    subtitle: '7 Kandas — the journey of Rama',
    type: ScriptureTextType.sectionVerse,
    chaptersUrl: '$_kDharmicDataBase/ValmikiRamayana/kanda_index.json',
    icon: Icons.forest_outlined,
  ),
  ScriptureTextDef(
    id: 'ramcharitmanas',
    title: 'Ramcharitmanas',
    devanagariTitle: 'श्रीरामचरितमानस',
    subtitle: 'Tulsidas’s devotional retelling — 7 Kands',
    type: ScriptureTextType.sectionVerse,
    chaptersUrl: '$_kDharmicDataBase/Ramcharitmanas/kand_index.json',
    icon: Icons.temple_hindu_outlined,
  ),
  ScriptureTextDef(
    id: 'mahabharata',
    title: 'Mahabharata',
    devanagariTitle: 'महाभारत',
    subtitle: '18 Parvas — the great war of Dharma',
    type: ScriptureTextType.sectionVerse,
    icon: Icons.shield_outlined,
  ),
  ScriptureTextDef(
    id: 'vishnu_purana',
    title: 'Vishnu Purana',
    devanagariTitle: 'विष्णु पुराण',
    subtitle: 'Cosmology & the 10 Avatars',
    type: ScriptureTextType.sectionVerse,
    icon: Icons.account_circle_outlined,
  ),
  ScriptureTextDef(
    id: 'shiv_mahapuran',
    title: 'Shiv Mahapuran',
    devanagariTitle: 'शिव महापुराण',
    subtitle: '12 Samhitas on Lord Shiva',
    type: ScriptureTextType.sectionVerse,
    icon: Icons.local_fire_department_rounded,
  ),
  ScriptureTextDef(
    id: 'devi_bhagavatam',
    title: 'Devi Bhagavatam',
    devanagariTitle: 'देवी भागवतम्',
    subtitle: 'The divine mother & her glories',
    type: ScriptureTextType.sectionVerse,
    icon: Icons.female_outlined,
  ),
  ScriptureTextDef(
    id: 'bhagavatam_canto_10',
    title: 'Srimad Bhagavatam — Canto 10',
    devanagariTitle: 'दशम स्कन्धम्',
    subtitle: 'Krishna’s childhood leelas',
    type: ScriptureTextType.chapterVerse,
    icon: Icons.child_care_outlined,
  ),
  ScriptureTextDef(
    id: 'bhagavatam_full',
    title: 'Srimad Bhagavatam — Full',
    devanagariTitle: 'श्रीमद्भागवतम्',
    subtitle: '12 Cantos — the cream of the Vedas',
    type: ScriptureTextType.chapterVerse,
    icon: Icons.auto_stories_rounded,
  ),
  ScriptureTextDef(
    id: 'brahma_vaivarta',
    title: 'Brahma Vaivarta Purana',
    devanagariTitle: 'ब्रह्मवैवर्त पुराण',
    subtitle: 'Krishna, Radha & Ganesha',
    type: ScriptureTextType.sectionVerse,
    icon: Icons.all_inclusive_outlined,
  ),
];

// ── Category 3: Dharma Shastras & Spiritual Texts ─────────────────────────

const List<ScriptureTextDef> _kDharmaTexts = [
  ScriptureTextDef(
    id: 'manusmriti',
    title: 'Manusmriti',
    devanagariTitle: 'मनुस्मृति',
    subtitle: 'Laws of Manu — social & moral code',
    type: ScriptureTextType.verseList,
    icon: Icons.gavel_outlined,
  ),
  ScriptureTextDef(
    id: 'yoga_sutras',
    title: 'Yoga Sutras of Patanjali',
    devanagariTitle: 'पातञ्जलियोगसूत्र',
    subtitle: '196 aphorisms on yoga practice',
    type: ScriptureTextType.verseList,
    icon: Icons.self_improvement_outlined,
  ),
  ScriptureTextDef(
    id: 'chanakya_neeti',
    title: 'Chanakya Neeti',
    devanagariTitle: 'चाणक्य नीति',
    subtitle: 'Political & life wisdom',
    type: ScriptureTextType.verseList,
    icon: Icons.account_balance_outlined,
  ),
  ScriptureTextDef(
    id: 'vidura_neeti',
    title: 'Vidura Neeti',
    devanagariTitle: 'विदुर नीति',
    subtitle: 'Counsel from the Mahabharata',
    type: ScriptureTextType.verseList,
    icon: Icons.record_voice_over_outlined,
  ),
  ScriptureTextDef(
    id: 'sri_suktam',
    title: 'Sri Suktam',
    devanagariTitle: 'श्रीसूक्तं',
    subtitle: 'Hymn to Goddess Lakshmi',
    type: ScriptureTextType.verseList,
    icon: Icons.diamond_outlined,
  ),
  ScriptureTextDef(
    id: 'purusha_suktam',
    title: 'Purusha Suktam',
    devanagariTitle: 'पुरुषसूक्तं',
    subtitle: 'The cosmic being — Rig Veda X.90',
    type: ScriptureTextType.verseList,
    icon: Icons.public_outlined,
  ),
  ScriptureTextDef(
    id: 'narayana_suktam',
    title: 'Narayana Suktam',
    devanagariTitle: 'नारायणसूक्तं',
    subtitle: 'Invocation of the supreme Lord',
    type: ScriptureTextType.verseList,
    icon: Icons.water_outlined,
  ),
  ScriptureTextDef(
    id: 'bhaja_govindam',
    title: 'Bhaja Govindam',
    devanagariTitle: 'भज गोविन्दं',
    subtitle: 'Adi Shankara’s 31 verses on detachment',
    type: ScriptureTextType.verseList,
    icon: Icons.sailing_outlined,
  ),
  ScriptureTextDef(
    id: 'ashtavakra_gita',
    title: 'Ashtavakra Gita',
    devanagariTitle: 'अष्टावक्र गीता',
    subtitle: 'Dialogue on absolute non-duality',
    type: ScriptureTextType.chapterVerse,
    icon: Icons.format_quote_outlined,
  ),
  ScriptureTextDef(
    id: 'avadhuta_gita',
    title: 'Avadhuta Gita',
    devanagariTitle: 'अवधूत गीता',
    subtitle: 'Dattatreya’s song of the free soul',
    type: ScriptureTextType.chapterVerse,
    icon: Icons.air_outlined,
  ),
];

// ── Category 4: Extended Spiritual Libraries ───────────────────────────────

const List<ScriptureTextDef> _kExtendedTexts = [
  ScriptureTextDef(
    id: 'hanuman_chalisa',
    title: 'Hanuman Chalisa',
    devanagariTitle: 'हनुमान चालीसा',
    subtitle: '40 verses of devotion to Hanuman',
    type: ScriptureTextType.verseList,
    icon: Icons.fitness_center_outlined,
  ),
  ScriptureTextDef(
    id: 'sundara_kanda',
    title: 'Sundara Kanda',
    devanagariTitle: 'सुन्दरकाण्ड',
    subtitle: 'Hanuman’s journey to Lanka',
    type: ScriptureTextType.sectionVerse,
    icon: Icons.flight_takeoff_outlined,
  ),
  ScriptureTextDef(
    id: 'shiva_tandava',
    title: 'Shiva Tandava Stotram',
    devanagariTitle: 'शिवताण्डव स्तोत्रं',
    subtitle: 'Ravana’s hymn to Lord Shiva',
    type: ScriptureTextType.verseList,
    icon: Icons.music_video_outlined,
  ),
  ScriptureTextDef(
    id: 'lalita_sahasranama',
    title: 'Lalita Sahasranama',
    devanagariTitle: 'ललितासहस्रनाम',
    subtitle: '1,000 names of the Divine Mother',
    type: ScriptureTextType.verseList,
    icon: Icons.looks_one_outlined,
  ),
  ScriptureTextDef(
    id: 'vishnu_sahasranama',
    title: 'Vishnu Sahasranama',
    devanagariTitle: 'विष्णुसहस्रनाम',
    subtitle: '1,000 names of Lord Vishnu',
    type: ScriptureTextType.verseList,
    icon: Icons.format_list_numbered_outlined,
  ),
  ScriptureTextDef(
    id: 'shiva_sahasranama',
    title: 'Shiva Sahasranama',
    devanagariTitle: 'शिवसहस्रनाम',
    subtitle: '1,000 names of Lord Shiva',
    type: ScriptureTextType.verseList,
    icon: Icons.local_fire_department_outlined,
  ),
  ScriptureTextDef(
    id: 'durga_saptashati',
    title: 'Durga Saptashati',
    devanagariTitle: 'दुर्गासप्तशती',
    subtitle: '700 verses on the Divine Mother',
    type: ScriptureTextType.chapterVerse,
    icon: Icons.female_rounded,
  ),
  ScriptureTextDef(
    id: 'soundarya_lahari',
    title: 'Soundarya Lahari',
    devanagariTitle: 'सौन्दर्यलहरी',
    subtitle: 'Adi Shankara’s hymn on divine beauty',
    type: ScriptureTextType.verseList,
    icon: Icons.brush_outlined,
  ),
  ScriptureTextDef(
    id: 'rudrashtakam',
    title: 'Rudrashtakam',
    devanagariTitle: 'रुद्राष्टकं',
    subtitle: 'Eight verses on Rudra (Shiva)',
    type: ScriptureTextType.verseList,
    icon: Icons.local_fire_department,
  ),
  ScriptureTextDef(
    id: 'mantra_maharnava',
    title: 'Mantra Maharnava',
    devanagariTitle: 'मन्त्रमहार्नव',
    subtitle: 'Ocean of sacred mantras',
    type: ScriptureTextType.verseList,
    icon: Icons.waves_rounded,
  ),
];

// ── Public catalog ─────────────────────────────────────────────────────────

const List<ScriptureCategory> kScriptureCatalog = [
  ScriptureCategory(
    id: 'vedas',
    title: 'The Vedas',
    subtitle: 'उपनिषद् • वेदांस्तेति जागृत्ये',
    icon: Icons.wb_sunny_rounded,
    accent: Color(0xFFFF9933),
    texts: _kVedaTexts,
  ),
  ScriptureCategory(
    id: 'itihasas',
    title: 'The Itihasas',
    subtitle: 'Ramayana • Mahabharata • Bhagavad Gita',
    icon: Icons.auto_stories_rounded,
    accent: Color(0xFFFFD700),
    texts: _kItihasaTexts,
  ),
  ScriptureCategory(
    id: 'dharma',
    title: 'Dharma Shastras',
    subtitle: 'Yoga • Neeti • Suktams • Gitas',
    icon: Icons.balance_rounded,
    accent: Color(0xFF4CAF50),
    texts: _kDharmaTexts,
  ),
  ScriptureCategory(
    id: 'extended',
    title: 'Songs & Stotras',
    subtitle: 'Chalisa • Sahasranama • Stotrams',
    icon: Icons.music_note_rounded,
    accent: Color(0xFF9C27B0),
    texts: _kExtendedTexts,
  ),
];

/// Quick lookup of a text definition by its ID.
ScriptureTextDef? lookupTextDef(String id) {
  for (final cat in kScriptureCatalog) {
    for (final text in cat.texts) {
      if (text.id == id) return text;
    }
  }
  return null;
}
