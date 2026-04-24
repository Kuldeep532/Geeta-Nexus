import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// Suggested additional libraries (Ensure these are in your pubspec.yaml)
// import 'package:google_generative_ai/google_generative_ai.dart'; 
// import 'package:flutter_markdown/flutter_markdown.dart';

import '../theme.dart';
import '../state/app_state.dart';
import '../data/gita_data.dart';

enum Persona { krishna, radha, guide }

class _Message {
  final String text;
  final bool isUser;
  final DateTime timestamp; // Added for better tracking
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

  // Improved theme-aware color fetching
  Color _getBubbleColor(bool isUser, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isUser) {
      return Colors.orange.shade800;
    }
    return isDark ? Colors.grey.shade800 : Colors.blueGrey.shade100;
  }

  Color _getTextColor(bool isUser, BuildContext context) {
    if (isUser) return Colors.white;
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
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
    
    // Simulate AI logic or API call
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      setState(() {
        _messages.add(_Message(text: "Peace is found within. (Example Response)", isUser: false));
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

  @override
  Widget build(BuildContext context) {
    // The Material app in main.dart should have:
    // themeMode: ThemeMode.system,
    // theme: AppTheme.lightTheme,
    // darkTheme: AppTheme.darkTheme,

    return Scaffold(
      // Removed hardcoded Colors.black to support system theme
      appBar: AppBar(
        title: Text(_personaNames[_persona]!, style: GoogleFonts.cinzel()),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildPersonaSelector(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: Persona.values.map((p) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              selected: _persona == p,
              label: Text(_personaNames[p]!),
              onSelected: (_) => setState(() {
                _persona = p;
                _messages.clear();
                _addGreeting();
              }),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_Message msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: _getBubbleColor(msg.isUser, context),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
            bottomRight: Radius.circular(msg.isUser ? 0 : 16),
          ),
        ),
        child: Text(
          msg.text, 
          style: TextStyle(color: _getTextColor(msg.isUser, context)),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() => const Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.all(12.0),
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Seek guidance...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: _sendMessage,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
