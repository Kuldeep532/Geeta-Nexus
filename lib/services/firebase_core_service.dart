import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// FirebaseCoreService — auto-detects Firebase availability and exposes
/// a clean Firestore client. If Firebase is unavailable (no credentials),
/// the service silently falls back to offline-only mode.
///
/// **Zero data loss guarantee:** All existing local SharedPreferences data
/// is preserved untouched. Firebase is an additive layer.
class FirebaseCoreService extends ChangeNotifier {
  static final FirebaseCoreService _instance = FirebaseCoreService._internal();
  factory FirebaseCoreService() => _instance;
  FirebaseCoreService._internal();

  bool _initialized = false;
  bool _available = false;
  FirebaseFirestore? _firestore;

  bool get isAvailable => _available;
  FirebaseFirestore? get firestore => _firestore;

  /// Attempts to initialize Firebase. If credentials are missing or the
  /// platform is unsupported, marks as unavailable and returns false.
  /// Never throws — always safe to call.
  Future<bool> initialize() async {
    if (_initialized) return _available;
    _initialized = true;

    try {
      // On web, Firebase needs explicit configuration. If firebase_options.dart
      // is missing or the configuration is invalid, this will throw.
      final apps = Firebase.apps;
      if (apps.isEmpty) {
        // Try to initialize with default options
        await Firebase.initializeApp();
      }
      _firestore = FirebaseFirestore.instance;
      _available = true;
      debugPrint('FirebaseCoreService: Firebase connected successfully.');
    } catch (e) {
      _available = false;
      _firestore = null;
      debugPrint('FirebaseCoreService: Firebase unavailable — running in offline mode. ($e)');
    }

    notifyListeners();
    return _available;
  }

  /// Returns a Firestore collection reference if Firebase is available.
  /// Returns null if unavailable (caller must check).
  CollectionReference<Map<String, dynamic>>? collection(String path) {
    if (!_available || _firestore == null) return null;
    return _firestore!.collection(path);
  }

  /// Returns a Firestore document reference if Firebase is available.
  DocumentReference<Map<String, dynamic>>? doc(String path) {
    if (!_available || _firestore == null) return null;
    return _firestore!.doc(path);
  }
}
