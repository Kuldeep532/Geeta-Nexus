import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_service.dart'; 

enum Persona { krishna, radha, guide }

class _Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  _Message({required this.text, required this.isUser, DateTime? time}) 
      : timestamp = time ?? DateTime.now();
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
  final AIService _aiService = AIService(); 
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

  void _addGreeting() {
    final greetings = {
      Persona.krishna: 'Namaste, dear seeker. I am Krishna, your eternal guide. 🕉️',
      Persona.radha: 'Welcome, dear soul. I am Radha, the embodiment of devotion. 🌸',
      Persona.guide: 'Greetings! I am your Bhagavad Gita Guide. 📖',
    };
    setState(() {
      _messages.add(_Message(text: greetings[_persona]!, isUser: false));
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _thinking) return;
    
    _controller.clear();
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _thinking = true;
    });
    
    _scrollToBottom();
    
    try {
      final response = await _aiService.getSmartResponse(text);
      if (mounted) {
        setState(() {
          _messages.add(_Message(text: response, isUser: false));
          _thinking = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _thinking = false;
          _messages.add(_Message(text: "Something went wrong. Please try again.", isUser: false));
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_personaNames[_persona]!, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPersonaSelector(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length + (_thinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (_thinking && index == _messages.length) {
                  return _buildThinkingBubble();
                }
                return _buildMessageBubble(_messages[index], theme, isDark);
              },
            ),
          ),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_Message msg, ThemeData theme, bool isDark) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        label: "${msg.isUser ? 'Your question' : 'Response from ${_personaNames[_persona]}'}: ${msg.text}",
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
          decoration: BoxDecoration(
            color: msg.isUser 
                ? theme.colorScheme.primary 
                : (isDark ? Colors.grey[900] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(15).copyWith(
              bottomRight: msg.isUser ? const Radius.circular(0) : null,
              bottomLeft: !msg.isUser ? const Radius.circular(0) : null,
            ),
            border: !msg.isUser ? Border.all(color: theme.dividerColor.withOpacity(0.1)) : null,
          ),
          child: Text(
            msg.text, 
            style: TextStyle(
              color: msg.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
              fontSize: 16
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() => const Padding(
    padding: EdgeInsets.all(12.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: "Krishna is reflecting on your question...",
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    ),
  );

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: "Ask your soul's query...",
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: _sendMessage,
              elevation: 0,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: Persona.values.map((p) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            selected: _persona == p,
            label: Text(_personaNames[p]!),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _persona = p;
                  _messages.clear();
                  _addGreeting();
                });
              }
            },
          ),
        )).toList(),
      ),
    );
  }
}
