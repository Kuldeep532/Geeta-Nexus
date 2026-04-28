import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Provider add kiya state ke liye

import '../state/app_state.dart';
import '../theme.dart'; // Yahan se kGold aur theme functions aayenge

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
    
    // Simulating Response
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _messages.add(_Message(text: "Your devotion is pure. Reflect on the Gita.", isUser: false));
        _thinking = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeOut
      );
    }
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
          _buildPersonaSelector(isDark),
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
          _buildInputBar(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_Message msg, ThemeData theme, bool isDark) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: msg.isUser 
              ? kGold // User ke liye Gold color
              : (isDark ? Colors.grey[900] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(15).copyWith(
            bottomRight: msg.isUser ? const Radius.circular(0) : null,
            bottomLeft: !msg.isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Text(
          msg.text, 
          style: TextStyle(
            color: msg.isUser ? Colors.black : (isDark ? Colors.white : Colors.black87),
            fontSize: 16
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() => const Padding(
    padding: EdgeInsets.all(12.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kGold)),
    ),
  );

  Widget _buildInputBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Ask Krishna...",
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              backgroundColor: kGold,
              onPressed: _sendMessage,
              child: const Icon(Icons.send, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaSelector(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: Persona.values.map((p) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            selected: _persona == p,
            label: Text(_personaNames[p]!),
            selectedColor: kGold,
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
