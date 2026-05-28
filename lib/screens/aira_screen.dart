import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/ai_service.dart';
import '../services/kokoro_tts_service.dart';
import '../theme.dart';

class _AiraMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _AiraMessage({
    required this.text,
    required this.isUser,
    DateTime? time,
  }) : timestamp = time ?? DateTime.now();
}

class AiraScreen extends StatefulWidget {
  final String? contextShloka;
  final String? contextVerse;

  const AiraScreen({
    super.key,
    this.contextShloka,
    this.contextVerse,
  });

  @override
  State<AiraScreen> createState() => _AiraScreenState();
}

class _AiraScreenState extends State<AiraScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  final AIService _ai = AIService();
  final KokoroTTSService _tts = KokoroTTSService();

  final List<_AiraMessage> _messages = [];

  bool _thinking = false;
  bool _aiSpeaking = false;

  static const _greetings = [
    "Namaste! I am Aira, your spiritual support companion.",
    "I can answer questions about Bhagavad Gita, features of this app, or help you on your journey.",
    "You may speak or type your question below.",
  ];

  static const _quickReplies = [
    "How do I use this app?",
    "Explain karma yoga",
    "What is the Antakshari game?",
    "Help me plan my day",
    "Find a verse about peace",
  ];

  @override
  void initState() {
    super.initState();
    _tts.initialize();
    _loadGreeting();
  }

  void _loadGreeting() {
    for (final g in _greetings) {
      _messages.add(_AiraMessage(text: g, isUser: false));
    }
    if (widget.contextShloka != null) {
      _messages.add(_AiraMessage(
        text:
            "I see you're reading: \"${widget.contextShloka!.substring(0, widget.contextShloka!.length.clamp(0, 80))}...\" — What would you like to know about this verse?",
        isUser: false,
      ));
    }
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> _sendMessage() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty || _thinking) return;

    HapticFeedback.mediumImpact();
    _controller.clear();

    setState(() {
      _messages.add(_AiraMessage(text: raw, isUser: true));
      _thinking = true;
    });
    _scrollToBottom();

    try {
      final prompt = widget.contextShloka != null
          ? '[Shloka Context: ${widget.contextShloka}]\n[Verse: ${widget.contextVerse ?? ""}]\n[User Question]: $raw'
          : '[Aira Support] $raw';

      final reply = await _ai.getSmartResponse(prompt);
      if (!mounted) return;
      setState(() => _messages.add(_AiraMessage(text: reply, isUser: false)));
      await _speak(reply);
    } catch (_) {
      if (!mounted) return;
      setState(() => _messages.add(_AiraMessage(
            text: "I'm having trouble responding right now. Please try again.",
            isUser: false,
          )));
    } finally {
      if (mounted) setState(() => _thinking = false);
      _scrollToBottom();
    }
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

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _inputFocus.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_rounded, color: kGold),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [kGold, kSaffron],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.support_agent_rounded,
                  color: Colors.black, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Aira — Support',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                color: kGold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          if (_aiSpeaking)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.volume_up_rounded, color: kGold, size: 22),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickReplies(theme, isDark),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              itemCount: _messages.length + (_thinking ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (_thinking && i == _messages.length) {
                  return _buildThinkingBubble();
                }
                return _buildBubble(_messages[i], isDark);
              },
            ),
          ),
          _buildInputBar(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: _quickReplies.map((q) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                q,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              backgroundColor:
                  isDark ? Colors.white10 : kGold.withOpacity(0.12),
              onPressed: () {
                HapticFeedback.lightImpact();
                _controller.text = q;
                _sendMessage();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBubble(_AiraMessage msg, bool isDark) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _speak(msg.text);
        },
        onLongPress: () async {
          await Clipboard.setData(ClipboardData(text: msg.text));
        },
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
            textScaler: MediaQuery.textScalerOf(context),
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
    );
  }

  Widget _buildThinkingBubble() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: kGold),
            ),
            const SizedBox(width: 8),
            Text('Aira is thinking...',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: kGold, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme, bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: kGold.withOpacity(0.15), width: 1),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _inputFocus,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Ask Aira anything...',
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
            FloatingActionButton.small(
              tooltip: 'Send',
              backgroundColor: kGold,
              heroTag: 'aira_send_fab',
              onPressed: _thinking ? null : () {
                HapticFeedback.lightImpact();
                _sendMessage();
              },
              child: const Icon(Icons.send_rounded, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
