import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';

enum Persona { krishna, radha, guide }

class _Message {
  final String text;
  final bool isUser;
  _Message({required this.text, required this.isUser});
}

class _KnowledgeEntry {
  final String topic;
  final String question;
  final String answer;
  final String source;

  const _KnowledgeEntry({
    required this.topic,
    required this.question,
    required this.answer,
    required this.source,
  });

  factory _KnowledgeEntry.fromMap(Map<String, dynamic> m) => _KnowledgeEntry(
        topic: (m['topic'] ?? '').toString(),
        question: (m['question'] ?? '').toString(),
        answer: (m['answer'] ?? '').toString(),
        source: (m['source'] ?? '').toString(),
      );
}

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [];
  Persona _persona = Persona.krishna;
  bool _thinking = false;
  List<_KnowledgeEntry> _knowledge = const [];

  static const _personaNames = {
    Persona.krishna: 'Lord Krishna',
    Persona.radha: 'Radha',
    Persona.guide: 'Gita Guide',
  };

  static const _personaIcons = {
    Persona.krishna: Icons.self_improvement,
    Persona.radha: Icons.favorite_border,
    Persona.guide: Icons.menu_book,
  };

  static const _greetings = {
    Persona.krishna: 'Namaste, dear seeker. I am Krishna, your eternal guide. 🕉️',
    Persona.radha: 'Welcome, dear soul. I am Radha, the embodiment of devotion. 🌸',
    Persona.guide: 'Greetings! I am your Bhagavad Gita Guide. 📖',
  };

  @override
  void initState() {
    super.initState();
    _loadKnowledgeBase();
    _addGreeting();
  }

  Future<void> _loadKnowledgeBase() async {
    try {
      final raw = await rootBundle.loadString('assets/data/ai_knowledge_base.json');
      final parsed = jsonDecode(raw) as List<dynamic>;
      final entries = parsed
          .map((e) => _KnowledgeEntry.fromMap(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() => _knowledge = entries);
    } catch (_) {
      // Fallback silently to built-in response logic.
    }
  }

  void _addGreeting() {
    setState(() {
      _messages.add(_Message(text: _greetings[_persona]!, isUser: false));
    });
  }

  String _getLocalResponse(String query) {
    final q = query.toLowerCase();
    // Safely expanding verses
    final verses = kChapters.expand((c) => c.verses).toList();

    if (verses.isEmpty) return "Keep seeking truth. (Gita 9.27)";

    final dataResponse = _getDatasetResponse(q);
    if (dataResponse != null) return dataResponse;

    if (q.contains('karma') || q.contains('action') || q.contains('duty')) {
      final verse = verses.firstWhere((v) => v.id == '2.47', orElse: () => verses.first);
      return _buildResponse("The essence of karma yoga is acting without attachment.", verse.id);
    }
    
    if (q.contains('surrender') || q.contains('moksha')) {
      final verse = verses.firstWhere((v) => v.id == '18.66', orElse: () => verses.first);
      return _buildResponse("Complete surrender grants eternal freedom.", verse.id);
    }

    return "Keep seeking truth. (Gita 9.27)";
  }

  String? _getDatasetResponse(String q) {
    if (_knowledge.isEmpty) return null;
    int bestScore = 0;
    _KnowledgeEntry? best;

    final words = q.split(RegExp(r'\\s+')).where((w) => w.length > 2).toSet();
    for (final entry in _knowledge) {
      final haystack = '${entry.topic} ${entry.question} ${entry.answer}'.toLowerCase();
      final score = words.where((w) => haystack.contains(w)).length;
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }

    if (best == null || bestScore == 0) return null;
    return '${best.answer}\\n\\nSource: ${best.source}';
  }

  String _buildResponse(String text, String verseId) {
    return _persona == Persona.radha ? "$text\n\nMay it illuminate your heart. 🌸" : text;
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    _controller.clear();
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _thinking = true;
    });
    
    _scrollToBottom();
    context.read<AppState>().addXp(2);
    
    await Future.delayed(const Duration(milliseconds: 800));
    final response = _getLocalResponse(text);
    
    if (mounted) {
      setState(() {
        _messages.add(_Message(text: response, isUser: false));
        _thinking = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut
        );
      }
    });
  }

  void _changePersona(Persona p) {
    setState(() {
      _persona = p;
      _messages.clear();
      _addGreeting();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_personaNames[_persona]!, style: GoogleFonts.cinzel()),
      ),
      body: Column(
        children: [
          _buildPersonaSelector(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_thinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (_thinking && index == _messages.length) {
                  return _buildThinkingBubble();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildPersonaSelector() {
    return Semantics(
      label: 'AI persona selector',
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: Persona.values
            .map(
              (p) => ChoiceChip(
                selected: _persona == p,
                label: Text(_personaNames[p]!),
                avatar: Icon(_personaIcons[p] as IconData, size: 18),
                onSelected: (_) => _changePersona(p),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMessageBubble(_Message msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: msg.isUser ? Colors.orange.shade800 : Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(msg.text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() => const Padding(
    padding: EdgeInsets.all(8.0),
    child: Text("Thinking...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
  );

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              textField: true,
              label: 'Ask your question to the AI guide',
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Ask your question",
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Send message',
            icon: const Icon(Icons.send, color: Colors.orange),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
