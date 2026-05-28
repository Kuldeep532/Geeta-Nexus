import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/ai_service.dart';
import '../services/kokoro_tts_service.dart';
import '../theme.dart';

enum _AiraUiState { ready, speaking }

class _ChatMessage {
  final String text;
  final bool fromUser;
  const _ChatMessage({required this.text, required this.fromUser});
}

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});
  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final AIService _aiService = AIService();
  final KokoroTTSService _tts = KokoroTTSService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = <_ChatMessage>[];

  _AiraUiState _uiState = _AiraUiState.ready;
  bool _thinking = false;

  @override
  void initState() {
    super.initState();
    _tts.initialize();
    _messages.add(
      const _ChatMessage(
        text: 'Namaste. I am Aira AI. Ask me anything about the app or Bhagavad Gita.',
        fromUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _tts.dispose();
    super.dispose();
  }

  String get _statusText {
    switch (_uiState) {
      case _AiraUiState.ready:
        return 'Ready';
      case _AiraUiState.speaking:
        return 'Speaking';
    }
  }

  Future<void> _sendText() async {
    final prompt = _textController.text.trim();
    if (prompt.isEmpty || _thinking) return;

    setState(() {
      _thinking = true;
      _messages.add(_ChatMessage(text: prompt, fromUser: true));
      _textController.clear();
    });
    _scrollToBottom();

    final reply = await _aiService.getSmartResponse(prompt);
    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMessage(text: reply, fromUser: false));
      _thinking = false;
    });

    await _tts.speak(reply);
    _scrollToBottom();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aira AI',
          style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.black12,
              child: Text('Status: $_statusText'),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length + (_thinking ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_thinking && i == _messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Aira is thinking...'),
                    );
                  }
                  final msg = _messages[i];
                  return Align(
                    alignment: msg.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.fromUser ? kGold : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg.text),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendText(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Type your message',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _sendText();
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
