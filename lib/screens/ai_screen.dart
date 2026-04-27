import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_service.dart'; // सुनिश्चित करें कि पाथ सही है

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
    Persona.radha: 'Radha',
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
    if (text.isEmpty || _thinking) return; // Error Fix: खाली मैसेज या थिंकिंग के दौरान रोकें
    
    _controller.clear();
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _thinking = true;
    });
    
    _scrollToBottom();
    
    try {
      // AIService से रिस्पांस लेना
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
          _messages.add(_Message(text: "क्षमा करें, कुछ तकनीकी त्रुटि हुई।", isUser: false));
        });
      }
    }
  }

  void _scrollToBottom() {
    // Accessibility Fix: स्क्रीन रीडर को नए मैसेज पर फोकस करने में मदद करता है
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
        title: Text(_personaNames[_persona]!, style: GoogleFonts.cinzel()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPersonaSelector(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              // itemCount Error Fix: यहाँ index आउट ऑफ बाउंड हो सकता था
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
        label: "${msg.isUser ? 'You' : _personaNames[_persona]}: ${msg.text}",
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: msg.isUser 
                ? theme.colorScheme.primary 
                : (isDark ? Colors.grey[850] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(15).copyWith(
              bottomRight: msg.isUser ? const Radius.circular(0) : null,
              bottomLeft: !msg.isUser ? const Radius.circular(0) : null,
            ),
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
        label: "AI is thinking",
        child: SizedBox(
          width: 20, 
          height: 20, 
          child: CircularProgressIndicator(strokeWidth: 2)
        ),
      ),
    ),
  );

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(), // कीबोर्ड से एंटर दबाने पर सेंड होगा
                decoration: InputDecoration(
                  hintText: "पूछिए...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              color: theme.colorScheme.primary,
              onPressed: _sendMessage,
              tooltip: "Send Message",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: Persona.values.map((p) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
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
