// ═══════════════════════════════════════════════════════════════════════════
// MULTI-LANGUAGE AUDIO SOURCE MODEL
// Verified streaming endpoints for Bhagavad Gita chapter audio.
// ═══════════════════════════════════════════════════════════════════════════

/// Audio source language enum.
enum AudioLanguage {
  english,
  hindi,
  sanskrit,
  gujarati,
  marathi,
  englishClassic,
}

/// Extension for human-readable labels.
extension AudioLanguageLabel on AudioLanguage {
  String get displayName {
    switch (this) {
      case AudioLanguage.english:
        return 'English (Yatharth Geeta)';
      case AudioLanguage.hindi:
        return 'Hindi (T S Ranganathan)';
      case AudioLanguage.sanskrit:
        return 'Sanskrit (Traditional)';
      case AudioLanguage.gujarati:
        return 'Gujarati (Yatharth Geeta)';
      case AudioLanguage.marathi:
        return 'Marathi (Nitya Path)';
      case AudioLanguage.englishClassic:
        return 'English Classic (LibriVox)';
    }
  }

  String get shortName {
    switch (this) {
      case AudioLanguage.english:
        return 'English';
      case AudioLanguage.hindi:
        return 'Hindi';
      case AudioLanguage.sanskrit:
        return 'Sanskrit';
      case AudioLanguage.gujarati:
        return 'Gujarati';
      case AudioLanguage.marathi:
        return 'Marathi';
      case AudioLanguage.englishClassic:
        return 'English Classic';
    }
  }
}

/// A single audio source definition for one language.
/// Maps a chapter number to a verified streaming URL.
class AudioSource {
  final AudioLanguage language;
  final String name;
  final String accent;
  final String baseUrl;
  final String? fallbackUrl;
  final bool usesChapterNumber;

  const AudioSource({
    required this.language,
    required this.name,
    required this.accent,
    required this.baseUrl,
    this.fallbackUrl,
    this.usesChapterNumber = true,
  });

  /// Human-readable display name combining language and source.
  String get displayName => language.displayName;

  /// Short label for the language.
  String get shortName => language.shortName;

  /// Resolve the streaming URL for a given chapter.
  /// If the source is single-file (e.g. complete Gita), returns the base URL.
  /// If the source is per-chapter, interpolates the chapter number.
  String urlForChapter(int chapter) {
    if (!usesChapterNumber) return baseUrl;
    // Internet Archive download pattern: base/{chapter}.mp3
    // Or everydaycodings API pattern: base/{chapter}/{reciter}.mp3
    return baseUrl.replaceAll('{chapter}', '$chapter');
  }

  /// Try fallback URL if the primary fails.
  String? fallbackUrlForChapter(int chapter) {
    if (fallbackUrl == null) return null;
    if (!usesChapterNumber) return fallbackUrl;
    return fallbackUrl!.replaceAll('{chapter}', '$chapter');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VERIFIED AUDIO SOURCE REGISTRY
// ═══════════════════════════════════════════════════════════════════════════

const List<AudioSource> kAudioSources = [
  // ── English (Yatharth Geeta) — Internet Archive ──
  AudioSource(
    language: AudioLanguage.english,
    name: 'English Narration',
    accent: 'Yatharth Geeta',
    baseUrl:
        'https://archive.org/download/YatharthGeetaEnglishAudio/chapter_{chapter}.mp3',
    fallbackUrl:
        'https://www.everydaycodings.com/api/v1/audio/chapter/{chapter}/english.mp3',
    usesChapterNumber: true,
  ),

  // ── Hindi & Sanskrit (T S Ranganathan) — Internet Archive ──
  // Single-file complete Gita (not chapter-by-chapter)
  AudioSource(
    language: AudioLanguage.hindi,
    name: 'Hindi & Sanskrit',
    accent: 'T S Ranganathan',
    baseUrl:
        'https://archive.org/download/SrimadBhagavadGita_201712/SrimadBhagavadGita.mp3',
    usesChapterNumber: false,
  ),

  // ── Sanskrit (Traditional) — everydaycodings CDN ──
  AudioSource(
    language: AudioLanguage.sanskrit,
    name: 'Sanskrit Original',
    accent: 'Classical',
    baseUrl:
        'https://www.everydaycodings.com/api/v1/audio/chapter/{chapter}/sanskrit.mp3',
    fallbackUrl:
        'https://bhagavadgitaapi.in/audio/chapter/{chapter}.mp3',
    usesChapterNumber: true,
  ),

  // ── Gujarati (Yatharth Geeta) — Internet Archive ──
  AudioSource(
    language: AudioLanguage.gujarati,
    name: 'Gujarati Narration',
    accent: 'Yatharth Geeta',
    baseUrl:
        'https://archive.org/download/YatharthGeetaGujratiAudio/chapter_{chapter}.mp3',
    usesChapterNumber: true,
  ),

  // ── Marathi (Nitya Path) — Internet Archive ──
  AudioSource(
    language: AudioLanguage.marathi,
    name: 'Marathi Narration',
    accent: 'Nitya Path',
    baseUrl:
        'https://archive.org/download/BhagavadGitaMarathi/chapter_{chapter}.mp3',
    usesChapterNumber: true,
  ),

  // ── English Classic (LibriVox) — Internet Archive ──
  // Single-file complete audiobook
  AudioSource(
    language: AudioLanguage.englishClassic,
    name: 'English Classic',
    accent: 'LibriVox',
    baseUrl:
        'https://archive.org/download/bhagavad_gita_0803_librivox/bhagavad_gita_0803_librivox.mp3',
    usesChapterNumber: false,
  ),
];

/// Quick lookup of a source by language.
AudioSource? sourceForLanguage(AudioLanguage lang) {
  for (final s in kAudioSources) {
    if (s.language == lang) return s;
  }
  return null;
}
