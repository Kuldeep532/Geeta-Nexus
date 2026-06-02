import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/satsang_post.dart';

class SatsangService extends ChangeNotifier {
  static const String _postsKey = 'satsang_posts_v1';
  final List<SatsangPost> _posts = [];
  final _uuid = const Uuid();

  List<SatsangPost> get posts => List.unmodifiable(_posts);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_postsKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _posts.clear();
        _posts.addAll(
          list.map((e) => SatsangPost.fromJson(e as Map<String, dynamic>)),
        );
        _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (e) {
        debugPrint('SatsangService load error: $e');
      }
    }
    if (_posts.isEmpty) {
      _seedDemoPosts();
    }
    notifyListeners();
  }

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
    await _save();
    notifyListeners();
  }

  Future<void> likePost(String postId, String userId) async {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx < 0) return;
    final post = _posts[idx];
    if (post.likedBy.contains(userId)) return;
    _posts[idx] = post.copyWith(
      likes: post.likes + 1,
      likedBy: [...post.likedBy, userId],
    );
    await _save();
    notifyListeners();
  }

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
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _postsKey,
      jsonEncode(_posts.map((p) => p.toJson()).toList()),
    );
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
