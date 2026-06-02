import 'package:flutter/foundation.dart';

enum PostCategory { reflection, question, gratitude, verseShare }

@immutable
class SatsangPost {
  final String id;
  final String authorName;
  final String content;
  final PostCategory category;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;
  final List<SatsangComment> comments;
  final String? scriptureRef;
  final String? verseQuote;

  const SatsangPost({
    required this.id,
    required this.authorName,
    required this.content,
    this.category = PostCategory.reflection,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
    this.comments = const [],
    this.scriptureRef,
    this.verseQuote,
  });

  SatsangPost copyWith({
    int? likes,
    List<String>? likedBy,
    List<SatsangComment>? comments,
  }) {
    return SatsangPost(
      id: id,
      authorName: authorName,
      content: content,
      category: category,
      createdAt: createdAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      comments: comments ?? this.comments,
      scriptureRef: scriptureRef,
      verseQuote: verseQuote,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorName': authorName,
    'content': content,
    'category': category.name,
    'createdAt': createdAt.toIso8601String(),
    'likes': likes,
    'likedBy': likedBy,
    'comments': comments.map((c) => c.toJson()).toList(),
    'scriptureRef': scriptureRef,
    'verseQuote': verseQuote,
  };

  factory SatsangPost.fromJson(Map<String, dynamic> json) => SatsangPost(
    id: json['id'] as String,
    authorName: json['authorName'] as String,
    content: json['content'] as String,
    category: PostCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => PostCategory.reflection,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    likes: json['likes'] as int? ?? 0,
    likedBy: (json['likedBy'] as List<dynamic>?)?.cast<String>() ?? [],
    comments: (json['comments'] as List<dynamic>?)
        ?.map((e) => SatsangComment.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    scriptureRef: json['scriptureRef'] as String?,
    verseQuote: json['verseQuote'] as String?,
  );
}

@immutable
class SatsangComment {
  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;

  const SatsangComment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorName': authorName,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SatsangComment.fromJson(Map<String, dynamic> json) => SatsangComment(
    id: json['id'] as String,
    authorName: json['authorName'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
