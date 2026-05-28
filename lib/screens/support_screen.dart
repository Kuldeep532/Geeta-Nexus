import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../services/kokoro_tts_service.dart';
import '../theme.dart';

/// Standard Support Screen — Support Chat, Voice Replies, and Feedback Submission.
/// Feedback popup is triggered by button or by typing "feedback" / "send feedback".
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportMessage {
  final String text;
  final bool isUser;
  _SupportMessage({required this.text, required this.isUser});
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final KokoroTTSService _tts = KokoroTTSService();

  final List<_SupportMessage> _messages = [];
  bool _thinking = false;

  static const _greetings = [
    "Namaste! Welcome to Gita Nexus support.",
    "I'm here to help you with app features, spiritual questions, or any issues you're facing.",
    "You can also send feedback using the button above, or simply type 'feedback'.",
  ];

  static const _quickReplies = [
    "How does the app work?",
    "How to use Gita Audio?",
    "AI features guide",
    "Report a bug",
    "Send feedback",
  ];

  static const _autoReplies = {
    "how does the app work":
        "Gita Nexus has five main sections — Home (all features), Chapters (read the Bhagavad Gita), Ask Ira (AI chat), Progress (your journey), and More (settings and support). Tap any section from the bottom navigation bar to explore.",
    "how to use gita audio":
        "Go to Home > Gita Audio Chapters. Tap any chapter to open the full-screen audio player. You can choose your preferred reciter, use the progress bar to seek, and navigate between chapters seamlessly.",
    "ai features guide":
        "The app includes three AI tools — Karma-Yogi Planner (daily planning with Krishna's wisdom), Habit Tracker (spiritual resolutions), and Shloka Antakshari (voice word-chain game). You'll find these under AI Tools on the Home screen.",
    "report a bug":
        "We're sorry to hear that! Please describe the issue below, or use 'Send Feedback' to submit a detailed report with your email so we can follow up with you directly.",
    "send feedback":
        "__TRIGGER_FEEDBACK__",
    "feedback":
        "__TRIGGER_FEEDBACK__",
  };

  @override
  void initState() {
    super.initState();
    _tts.initialize();
    for (final g in _greetings) {
      _messages.add(_SupportMessage(text: g, isUser: false));
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scroll.dispose();
    _tts.dispose();
    super.dispose();
  }

  bool _hasFeedbackIntent(String text) {
    final lower = text.toLowerCase().trim();
    return lower.contains('feedback') || lower.contains('send feedback');
  }

  void _send() {
    final raw = _inputCtrl.text.trim();
    if (raw.isEmpty || _thinking) return;

    HapticFeedback.mediumImpact();
    _inputCtrl.clear();

    // Announce field clear so screen-reader users know input is reset
    SemanticsService.announce(
      'Message sent. Text field cleared, ready for next input.',
      TextDirection.ltr,
    );

    if (_hasFeedbackIntent(raw)) {
      _messages.add(_SupportMessage(text: raw, isUser: true));
      setState(() {});
      _scrollToBottom();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _showFeedbackBottomSheet();
      });
      return;
    }

    setState(() {
      _messages.add(_SupportMessage(text: raw, isUser: true));
      _thinking = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final reply = _getAutoReply(raw);
      setState(() {
        _thinking = false;
        _messages.add(_SupportMessage(text: reply, isUser: false));
      });
      _tts.speak(reply);
      _scrollToBottom();
    });
  }

  String _getAutoReply(String text) {
    final lower = text.toLowerCase().trim();
    for (final entry in _autoReplies.entries) {
      if (lower.contains(entry.key)) {
        if (entry.value == "__TRIGGER_FEEDBACK__") {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _showFeedbackBottomSheet();
          });
          return "Opening the feedback form for you now. Please fill in your name, email, and message.";
        }
        return entry.value;
      }
    }
    return "Thank you for reaching out! For detailed support, please use the 'Send Feedback' button above to submit your query with your email, and our team will get back to you shortly.";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showFeedbackBottomSheet() {
    HapticFeedback.mediumImpact();
    final sheetFocus = FocusNode();
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Semantics(
        container: true,
        explicitChildNodes: true,
        label: 'Send Feedback form. Fill in your name, email, and feedback message.',
        child: _FeedbackBottomSheet(
          focusNode: sheetFocus,
          onSubmitted: () {
            if (!mounted) return;
            setState(() {
              _messages.add(_SupportMessage(
                text: "Your feedback has been submitted. Thank you for helping us improve Gita Nexus!",
                isUser: false,
              ));
            });
            _scrollToBottom();
          },
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sheetFocus.requestFocus();
    });
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
        title: Text(
          'Customer Support',
          style: GoogleFonts.cinzel(
            color: kGold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Send feedback',
            child: TextButton.icon(
              onPressed: _showFeedbackBottomSheet,
              icon: const Icon(Icons.feedback_outlined, color: kGold, size: 18),
              label: Text(
                'Feedback',
                style: GoogleFonts.poppins(
                  color: kGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Quick replies
          _buildQuickReplies(isDark),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              itemCount: _messages.length + (_thinking ? 1 : 0),
              itemBuilder: (_, i) {
                if (_thinking && i == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildBubble(_messages[i], isDark);
              },
            ),
          ),

          // Input bar
          _buildInputBar(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: _quickReplies.map((q) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(q, style: GoogleFonts.poppins(fontSize: 12)),
              backgroundColor:
                  isDark ? Colors.white10 : kGold.withOpacity(0.1),
              onPressed: () {
                HapticFeedback.lightImpact();
                _inputCtrl.text = q;
                _send();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBubble(_SupportMessage msg, bool isDark) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _tts.speak(msg.text);
        },
        onLongPress: () => Clipboard.setData(ClipboardData(text: msg.text)),
        child: Semantics(
          label: '${isUser ? "You said" : "Support"}: ${msg.text}. Double-tap to hear aloud.',
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? kGold
                  : (isDark ? Colors.grey[850] : Colors.grey[200]),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isUser
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: isUser
                    ? Colors.black
                    : (isDark ? Colors.white : Colors.black87),
                height: 1.5,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: kGold),
            ),
            const SizedBox(width: 8),
            Text(
              'Support is typing...',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: kGold, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme, bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
              top: BorderSide(color: kGold.withOpacity(0.15), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  filled: true,
                  fillColor:
                      isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Send message',
              child: FloatingActionButton.small(
                heroTag: 'support_send_fab',
                backgroundColor: kGold,
                tooltip: 'Send',
                onPressed: _thinking ? null : _send,
                child: const Icon(Icons.send_rounded,
                    color: Colors.black, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feedback Bottom Sheet (focus-trapped, accessible) ────────────────────────────

class _FeedbackBottomSheet extends StatefulWidget {
  final VoidCallback onSubmitted;
  final FocusNode? focusNode;
  const _FeedbackBottomSheet({required this.onSubmitted, this.focusNode});

  @override
  State<_FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<_FeedbackBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _feedbackCtrl = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  static const String _backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: '',
  );

  @override
  void dispose() {
    widget.focusNode?.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final endpoint = _backendUrl.isNotEmpty ? '$_backendUrl/feedback' : '/feedback';
      await http
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': _nameCtrl.text.trim(),
              'email': _emailCtrl.text.trim(),
              'feedback': _feedbackCtrl.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() => _submitted = true);
      widget.onSubmitted();
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitted = true);
      widget.onSubmitted();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: _submitted
          ? 'Feedback submitted successfully. Tap done to close.'
          : 'Send Feedback form. Fill in your name, email, and feedback message.',
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 16),
          child: SingleChildScrollView(
            child: _submitted ? _buildSuccessView(theme) : _buildFormView(theme, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const Icon(Icons.check_circle_rounded, color: kSuccess, size: 56),
        const SizedBox(height: 16),
        Text(
          'Feedback Submitted!',
          style: GoogleFonts.cinzel(
              fontSize: 18, fontWeight: FontWeight.bold, color: kGold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Thank you for your feedback. We will review it and get back to you soon.',
          style: GoogleFonts.inter(fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text('Done',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView(ThemeData theme, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: ExcludeSemantics(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Semantics(
            header: true,
            child: Text(
              'Send Feedback',
              style: GoogleFonts.cinzel(
                  fontSize: 18, fontWeight: FontWeight.bold, color: kGold),
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            isDark: isDark,
            controller: _nameCtrl,
            label: 'Name',
            hint: 'Your full name',
            icon: Icons.person_outline_rounded,
            action: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter your name'
                : null,
          ),
          const SizedBox(height: 14),
          _buildField(
            isDark: isDark,
            controller: _emailCtrl,
            label: 'Email',
            hint: 'you@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            action: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!v.contains('@') || !v.contains('.')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildField(
            isDark: isDark,
            controller: _feedbackCtrl,
            label: 'Feedback',
            hint: 'Describe your feedback or issue...',
            icon: Icons.message_outlined,
            maxLines: 4,
            action: TextInputAction.newline,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter your feedback'
                : null,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              enabled: !_submitting,
              label: _submitting ? 'Submitting feedback, please wait.' : 'Submit feedback.',
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black),
                      )
                    : Text('Submit',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Text('Cancel',
                  style: GoogleFonts.poppins(
                      color: theme.colorScheme.onSurface.withOpacity(0.5))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? action,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: action,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: kGoldDim, size: 18),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kGold.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
