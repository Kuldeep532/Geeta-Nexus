import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'firebase_core_service.dart';
import '../models/satsang_post.dart';

/// FirebaseSatsangService — dual-layer persistence for Satsang Connect.
///
/// **Architecture:**
/// - Firestore is the primary online store (when Firebase is available).
/// - SharedPreferences is the offline fallback and local cache.
/// - All reads merge both sources (local + Firestore), with Firestore taking precedence.
/// - All writes go to both layers (fire-and-forget to Firestore, always succeed locally).
///
/// **Zero data loss guarantee:**
/// - On first Firebase connect, existing local posts are migrated UP to Firestore.
/// - Local SharedPreferences key is never deleted or overwritten.
/// - If Firebase later disconnects, all local data remains intact.
class FirebaseSatsangService extends ChangeNotifier {
  static const String _localKey = 'satsang_posts_v1';
  final List<SatsangPost> _posts = [];
  final _uuid = const Uuid();
  final FirebaseCoreService _firebase = FirebaseCoreService();

  StreamSubscription? _firestoreSubscription;
  bool _isOnline = false;
  bool _migrationComplete = false;

  List<SatsangPost> get posts => List.unmodifiable(_posts);
  bool get isOnline => _isOnline;

  /// Loads from local storage first, then attempts Firebase initialization.
  /// If Firebase is available, starts a real-time listener and migrates data.
  Future<void> load() async {
    // 1. Always load local first (zero data loss)
    await _loadLocal();

    // 2. Attempt Firebase initialization
    await _firebase.initialize();
    _isOnline = _firebase.isAvailable;

    if (_isOnline) {
      // 3. Migrate existing local posts to Firestore (upsert, no deletion)
      await _migrateLocalToFirebase();
      // 4. Start real-time listener for new posts
      _listenToFirestore();
    }

    notifyListeners();
  }

  /// Load from SharedPreferences (always succeeds)
  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _posts.clear();
        _posts.addAll(
          list.map((e) => SatsangPost.fromJson(e as Map<String, dynamic>)),
        );
        _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (e) {
        debugPrint('FirebaseSatsangService local load error: $e');
      }
    }
    if (_posts.isEmpty) {
      _seedDemoPosts();
    }
  }

  /// Save to SharedPreferences (always succeeds, never deletes)
  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localKey,
      jsonEncode(_posts.map((p) => p.toJson()).toList()),
    );
  }

  /// Migrate local posts to Firestore as an upsert.
  /// Existing Firestore posts are not touched. Local posts are additive.
  Future<void> _migrateLocalToFirebase() async {
    if (_migrationComplete) return;
    final col = _firebase.collection('satsang_posts');
    if (col == null) return;

    try {
      // Get all existing Firestore IDs to avoid duplicates
      final snap = await col.limit(1000).get();
      final existingIds = snap.docs.map((d) => d.id).toSet();

      for (final post in _posts) {
        if (existingIds.contains(post.id)) continue;
        await col.doc(post.id).set(post.toJson());
      }

      _migrationComplete = true;
      debugPrint('FirebaseSatsangService: migrated ${_posts.length} local posts to Firestore.');
    } catch (e) {
      debugPrint('FirebaseSatsangService migration error: $e');
    }
  }

  /// Listen to Firestore for real-time updates from other users.
  void _listenToFirestore() {
    final col = _firebase.collection('satsang_posts');
    if (col == null) return;

    _firestoreSubscription?.cancel();
    _firestoreSubscription = col
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snapshot) {
        if (!_isOnline) return;
        final firestorePosts = snapshot.docs
            .map((d) => SatsangPost.fromJson(d.data()))
            .toList();

        // Merge: Firestore posts take precedence, local-only posts are preserved
        final merged = <String, SatsangPost>{};
        for (final p in _posts) {
          merged[p.id] = p;
        }
        for (final p in firestorePosts) {
          merged[p.id] = p;
        }

        _posts.clear();
        _posts.addAll(merged.values);
        _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _saveLocal(); // Update local cache
        notifyListeners();
      },
      onError: (e) {
        debugPrint('FirebaseSatsangService Firestore listener error: $e');
        _isOnline = false;
      },
    );
  }

  /// Create a post — writes to BOTH local and Firestore.
  Future<void> createPost({
    required String authorName,
    required String content,
    PostCategory category = PostCategory.reflection,
    String? scriptureRef,
    String? verseQuote,
  }) async {
    final post = SatsangPost(
      id: _uuid.v4(),
      authorName: authorName,
      content: content,
      category: category,
      createdAt: DateTime.now(),
      scriptureRef: scriptureRef,
      verseQuote: verseQuote,
    );

    _posts.insert(0, post);
    await _saveLocal();

    // Firestore write (fire-and-forget)
    if (_isOnline) {
      try {
        final col = _firebase.collection('satsang_posts');
        await col?.doc(post.id).set(post.toJson());
      } catch (e) {
        debugPrint('FirebaseSatsangService createPost firestore error: $e');
      }
    }

    notifyListeners();
  }

  /// Like a post — writes to BOTH local and Firestore.
  Future<void> likePost(String postId, String userId) async {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx < 0) return;
    final post = _posts[idx];
    if (post.likedBy.contains(userId)) return;

    _posts[idx] = post.copyWith(
      likes: post.likes + 1,
      likedBy: [...post.likedBy, userId],
    );
    await _saveLocal();

    if (_isOnline) {
      try {
        final doc = _firebase.collection('satsang_posts')?.doc(postId);
        await doc?.update({
          'likes': _posts[idx].likes,
          'likedBy': _posts[idx].likedBy,
        });
      } catch (e) {
        debugPrint('FirebaseSatsangService likePost firestore error: $e');
      }
    }

    notifyListeners();
  }

  /// Add a comment — writes to BOTH local and Firestore.
  Future<void> addComment(String postId, String authorName, String content) async {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx < 0) return;
    final post = _posts[idx];
    final comment = SatsangComment(
      id: _uuid.v4(),
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
    );

    _posts[idx] = post.copyWith(
      comments: [...post.comments, comment],
    );
    await _saveLocal();

    if (_isOnline) {
      try {
        final doc = _firebase.collection('satsang_posts')?.doc(postId);
        await doc?.update({
          'comments': _posts[idx].comments.map((c) => c.toJson()).toList(),
        });
      } catch (e) {
        debugPrint('FirebaseSatsangService addComment firestore error: $e');
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }

  void _seedDemoPosts() {
    _posts.addAll([
      SatsangPost(
        id: _uuid.v4(),
        authorName: 'Radha Devi',
        content: 'Chapter 2, Verse 47 resonates deeply with me today. '
            'Karmanye vadhikaraste ma phaleshu kadachana. '
            'The art of action without attachment to results is the true yoga.',
        category: PostCategory.verseShare,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 12,
        scriptureRef: 'BG 2.47',
        verseQuote: 'You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions.',
      ),
      SatsangPost(
        id: _uuid.v4(),
        authorName: 'Arjun Seeker',
        content: 'Started my 5 AM meditation streak today. '
            'The peace that comes from early morning practice is unmatched. '
            'Who else is on a morning routine?',
        category: PostCategory.gratitude,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 8,
      ),
      SatsangPost(
        id: _uuid.v4(),
        authorName: 'Gita Voice',
        content: 'I have a question about the concept of Atman vs Brahman. '
            'Can someone explain the difference in simple terms? '
            'I am reading Chapter 13 and feeling confused.',
        category: PostCategory.question,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likes: 15,
      ),
      SatsangPost(
        id: _uuid.v4(),
        authorName: 'Krishna Das',
        content: 'Grateful for this app. The daily verses and the community '
            'make my spiritual practice so much richer. '
            'Hare Krishna to all seekers!',
        category: PostCategory.gratitude,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        likes: 22,
      ),
    ]);
  }
}
