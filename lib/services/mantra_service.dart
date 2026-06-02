import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

/// MantraService — offline-first, unified mantra loading.
///
/// Eliminates the duplication in ChantsScreen where online and offline
/// loading were handled by separate methods (`_loadMantras` and
/// `_applyOfflineMantras`). This service provides a single entry point
/// that always returns a mantra list, preferring the remote API when
/// available and falling back to the built-in offline list.
class MantraService {
  static const String _apiUrl =
      'https://havyaka-rest-api-gaonkarbhai.vercel.app/api/v1/mantras?limit=500';

  static const List<Map<String, String>> _offlineMantras = [
    {
      'name': 'Maha Mantra',
      'mantra':
          'Hare Krishna Hare Krishna\nKrishna Krishna Hare Hare\nHare Rama Hare Rama\nRama Rama Hare Hare',
      'meaning': 'Prayer for divine consciousness and liberation',
      'audio':
          'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    },
    {
      'name': 'Gayatri Mantra',
      'mantra':
          'ँ भूर्भुवः स्वः\nतत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि\nधियो यो नः प्रचोदयात्',
      'meaning': 'Prayer to the Sun-God for divine intellect and spiritual light',
      'audio':
          'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    },
    {
      'name': 'Om Namah Shivaya',
      'mantra': 'ँ नमः शिवाय',
      'meaning': 'I bow to Lord Shiva — the auspicious one within all beings',
      'audio':
          'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    },
    {
      'name': 'Om Namo Bhagavate',
      'mantra': 'ँ नमो भगवते\nवासुदेवाय',
      'meaning': 'I bow to Lord Vasudeva — the all-pervading supreme person',
      'audio':
          'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    },
    {
      'name': 'Shanti Mantra',
      'mantra':
          'ँ सर्वे भवन्तु सुखिनः\nसर्वे सन्तु निरामयाः\nसर्वे भद्राणि पश्यन्तु\nमा कश्चिद् दुःखभाग्भवेत्',
      'meaning':
          'May all beings be happy, free from illness, and see auspiciousness',
      'audio':
          'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    },
  ];

  /// Returns a list of mantras. Always succeeds — falls back to offline
  /// data if the network request fails or the device is offline.
  static Future<List<Map<String, dynamic>>> loadMantras() async {
    final online = await _hasConnection();
    if (!online) {
      return _offlineMantras.cast<Map<String, dynamic>>();
    }

    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = (data['mantras'] ?? []) as List<dynamic>;

        if (list.isNotEmpty) {
          final parsed = list
              .map<Map<String, dynamic>>((m) => {
                    'name': (m['name'] ?? 'Unknown').toString(),
                    'mantra': (m['shloka'] ?? '').toString(),
                    'meaning': (m['purpose'] ?? 'Sacred Mantra').toString(),
                    'audio': (m['audio'] ?? '').toString(),
                  })
              .where((m) => m['mantra']!.toString().isNotEmpty)
              .toList();

          if (parsed.isNotEmpty) return parsed;
        }
      }
    } catch (e) {
      debugPrint('MantraService API error: $e');
    }

    return _offlineMantras.cast<Map<String, dynamic>>();
  }

  static Future<bool> _hasConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results is List) {
        return results.isNotEmpty &&
            !results.every((r) => r == ConnectivityResult.none);
      }
      return results != ConnectivityResult.none;
    } catch (_) {
      return true;
    }
  }
}
