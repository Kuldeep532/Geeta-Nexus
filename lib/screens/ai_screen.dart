import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/ai_service.dart';
import '../theme.dart';

enum Persona { krishna, radha, guide }

class _Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _Message({required this.text, required this.isUser, DateTime? time}) : timestamp = time ?? DateTime.now();
}

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  final AIService _aiService = AIService();

  final List<_Message> _messages = [];
  Persona _persona = Persona.krishna;
  bool _thinking = false;

  static const _personaNames = {
    Persona.krishna: 'Lord Krishna',
    Persona.radha: 'Radha Rani',
    Persona.guide: 'Gita Guide',
  };

  @override
  void initState() {
    super.initState();
    _addGreeting();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _addGreeting() {
    final greetings = {
      Persona.krishna: 'Namaste, dear seeker. I am Krishna, your eternal guide. 🕉️',
      Persona.radha: 'Welcome, dear soul. I am Radha, the embodiment of devotion. 🌸',
      Persona.guide: 'Greetings! I am your Bhagavad Gita Guide. 📖',
    };
    _messages.add(_Message(text: greetings[_persona]!, isUser: false));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _thinking) return;

    HapticFeedback.selectionClick();
    _controller.clear();
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _thinking = true;
    });
    _scrollToBottom();

    try {
      final personaPrompt = '[Persona: ${_personaNames[_persona]}] $text';
      final aiReply = await _aiService.getSmartResponse(personaPrompt);
      if (!mounted) return;
      setState(() {
        _messages.add(_Message(text: aiReply, isUser: false));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Message(text: 'I could not respond right now. Please try again.', isUser: false));
      });
    } finally {
      if (mounted) {
        setState(() => _thinking = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_personaNames[_persona]!, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: kGold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPersonaSelector(),
          Expanded(
            child: Semantics(
              label: 'Conversation history',
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _messages.length + (_thinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_thinking && index == _messages.length) return _buildThinkingBubble();
                  return _buildMessageBubble(_messages[index], isDark);
                },
              ),
            ),
          ),
          _buildInputBar(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_Message msg, bool isDark) {
    return Semantics(
      label: msg.isUser ? 'Your message' : 'AI message',
      readOnly: true,
      child: Align(
        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
          decoration: BoxDecoration(
            color: msg.isUser ? kGold : (isDark ? Colors.grey[900] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(15).copyWith(
              bottomRight: msg.isUser ? const Radius.circular(0) : null,
              bottomLeft: !msg.isUser ? const Radius.circular(0) : null,
            ),
          ),
          child: Text(
            msg.text,
            style: TextStyle(color: msg.isUser ? Colors.black : (isDark ? Colors.white : Colors.black87), fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() => const Padding(
        padding: EdgeInsets.all(12.0),
        child: Semantics(
          label: 'AI is thinking',
          liveRegion: true,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kGold)),
          ),
        ),
      );

  Widget _buildInputBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: _inputFocus,
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Ask your question',
                  hintText: 'Ask Krishna...',
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              enabled: !_thinking,
              label: 'Send message',
              child: FloatingActionButton.small(
                tooltip: 'Send message',
                backgroundColor: kGold,
                onPressed: _thinking ? null : _sendMessage,
                child: const Icon(Icons.send, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaSelector() {
    return Semantics(
      container: true,
      label: 'Choose AI persona',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: Persona.values
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    selected: _persona == p,
                    label: Text(_personaNames[p]!),
                    selectedColor: kGold,
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() {
                        _persona = p;
                        _messages
                          ..clear()
                          ..add(_Message(
                            text: p == Persona.krishna
                                ? 'Namaste, dear seeker. I am Krishna, your eternal guide. 🕉️'
                                : p == Persona.radha
                                    ? 'Welcome, dear soul. I am Radha, the embodiment of devotion. 🌸'
                                    : 'Greetings! I am your Bhagavad Gita Guide. 📖',
                            isUser: false,
                          ));
                      });
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
