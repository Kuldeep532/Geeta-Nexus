import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/satsang_post.dart';
import '../services/satsang_service.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Satsang Connect — Community space for seekers to share reflections.
class SatsangConnectScreen extends StatefulWidget {
  const SatsangConnectScreen({super.key});

  @override
  State<SatsangConnectScreen> createState() => _SatsangConnectScreenState();
}

class _SatsangConnectScreenState extends State<SatsangConnectScreen> {
  late SatsangService _service;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = SatsangService();
    _load();
  }

  Future<void> _load() async {
    await _service.load();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _createPost() async {
    final appState = context.read<AppState>();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _CreatePostDialog(authorName: appState.userName.isNotEmpty ? appState.userName : 'Seeker'),
    );
    if (result != null && result['content']!.trim().isNotEmpty) {
      await _service.createPost(
        authorName: result['author']!,
        content: result['content']!.trim(),
        category: PostCategory.values.firstWhere(
          (e) => e.name == result['category'],
          orElse: () => PostCategory.reflection,
        ),
        scriptureRef: result['scriptureRef']?.trim(),
      );
    }
  }

  Future<void> _likePost(String postId) async {
    final appState = context.read<AppState>();
    final userId = appState.userEmail.isNotEmpty ? appState.userEmail : 'guest_${appState.userName}';
    await _service.likePost(postId, userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Semantics(
          header: true,
          child: Text(
            'Satsang Connect',
            style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Create a new post to share with the community',
            child: IconButton(
              icon: const Icon(Icons.add_comment, color: kGold),
              tooltip: 'New Post',
              onPressed: _createPost,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kGold))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _service.posts.length,
              itemBuilder: (context, index) {
                final post = _service.posts[index];
                return _buildPostCard(post, isDark, index, _service.posts.length);
              },
            ),
    );
  }

  Widget _buildPostCard(SatsangPost post, bool isDark, int index, int total) {
    final categoryColor = _categoryColor(post.category);
    final categoryLabel = _categoryLabel(post.category);

    return Semantics(
      explicitChildNodes: true,
      label: 'Post ${index + 1} of $total by ${post.authorName}. Category: $categoryLabel. '
          '${post.scriptureRef != null ? "Scripture reference: ${post.scriptureRef}. " : ""}'
          '${post.content.substring(0, post.content.length > 80 ? 80 : post.content.length)}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? kCard : const Color(0xFFFFFAEA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withOpacity(0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: categoryColor.withOpacity(0.2),
                    child: Text(
                      post.authorName[0].toUpperCase(),
                      style: TextStyle(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _timeAgo(post.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      categoryLabel,
                      style: TextStyle(fontSize: 10, color: categoryColor),
                    ),
                    backgroundColor: categoryColor.withOpacity(0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Scripture reference
              if (post.scriptureRef != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.scriptureRef!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: kGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // Content
              Text(
                post.content,
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.87) : Colors.black87,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Actions
              Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Like this post. Currently ${post.likes} likes.',
                    child: TextButton.icon(
                      onPressed: () => _likePost(post.id),
                      icon: const Icon(Icons.favorite_outline, size: 18, color: kGold),
                      label: Text('${post.likes}', style: const TextStyle(color: kGold)),
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    button: true,
                    label: 'Reply to ${post.authorName}\'s post',
                    child: TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                      },
                      icon: const Icon(Icons.reply, size: 18, color: kGold),
                      label: Text('Reply', style: const TextStyle(color: kGold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(PostCategory cat) {
    switch (cat) {
      case PostCategory.reflection: return kSaffron;
      case PostCategory.question: return const Color(0xFF5B8DEF);
      case PostCategory.gratitude: return kSuccess;
      case PostCategory.verseShare: return kGold;
    }
  }

  String _categoryLabel(PostCategory cat) {
    switch (cat) {
      case PostCategory.reflection: return 'Reflection';
      case PostCategory.question: return 'Question';
      case PostCategory.gratitude: return 'Gratitude';
      case PostCategory.verseShare: return 'Verse';
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CreatePostDialog extends StatefulWidget {
  final String authorName;
  const _CreatePostDialog({required this.authorName});

  @override
  State<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<_CreatePostDialog> {
  final _contentCtrl = TextEditingController();
  final _scriptureCtrl = TextEditingController();
  PostCategory _category = PostCategory.reflection;

  @override
  void dispose() {
    _contentCtrl.dispose();
    _scriptureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Semantics(
        header: true,
        child: Text(
          'Share with Satsang',
          style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              textField: true,
              label: 'Write your reflection, question, or gratitude',
              child: TextField(
                controller: _contentCtrl,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Share your spiritual insight or question...',
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              textField: true,
              label: 'Optional scripture reference, for example BG 2.47',
              child: TextField(
                controller: _scriptureCtrl,
                decoration: InputDecoration(
                  hintText: 'Scripture ref (e.g., BG 2.47) — optional',
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Select post category',
              child: DropdownButtonFormField<PostCategory>(
                value: _category,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: PostCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(_catLabel(cat)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        Semantics(
          button: true,
          label: 'Post your reflection to the community',
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context, {
              'author': widget.authorName,
              'content': _contentCtrl.text,
              'category': _category.name,
              'scriptureRef': _scriptureCtrl.text,
            }),
            child: Text('Post', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  String _catLabel(PostCategory cat) {
    switch (cat) {
      case PostCategory.reflection: return 'Reflection';
      case PostCategory.question: return 'Question';
      case PostCategory.gratitude: return 'Gratitude';
      case PostCategory.verseShare: return 'Verse Share';
    }
  }
}
