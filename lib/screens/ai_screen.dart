import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../services/ai_service.dart';
import '../services/sherpa_tts_service.dart';
import '../theme.dart';

enum _AiraUiState { initializingModels, ready, speaking, listening, error }

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
  final SherpaTtsService _tts = SherpaTtsService();
  final SpeechToText _stt = SpeechToText();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = <_ChatMessage>[];
  StreamSubscription<SherpaTtsStatus>? _ttsStatusSub;

  _AiraUiState _uiState = _AiraUiState.initializingModels;
  bool _thinking = false;
  bool _sttAvailable = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      const _ChatMessage(
        text: 'Namaste 🙏 I am Aira AI. Ask me anything about the app or Bhagavad Gita.',
        fromUser: false,
      ),
    );
    _initializeVoiceStack();
  }

  Future<void> _initializeVoiceStack() async {
    _ttsStatusSub = _tts.statusStream.listen((status) {
      if (!mounted) return;
      setState(() {
        if (status == SherpaTtsStatus.initializing) {
          _uiState = _AiraUiState.initializingModels;
        } else if (status == SherpaTtsStatus.speaking) {
          _uiState = _AiraUiState.speaking;
        } else if (status == SherpaTtsStatus.error) {
          _uiState = _AiraUiState.error;
        } else if (_uiState != _AiraUiState.listening) {
          _uiState = _AiraUiState.ready;
        }
      });
    });

    try {
      await _tts.initialize();
      _sttAvailable = await _stt.initialize(
        onError: (_) {
          if (!mounted) return;
          setState(() => _uiState = _AiraUiState.error);
        },
      );
      if (mounted) setState(() => _uiState = _AiraUiState.ready);
    } catch (_) {
      if (mounted) setState(() => _uiState = _AiraUiState.error);
    }
  }

  @override
  void dispose() {
    _ttsStatusSub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _stt.stop();
    _tts.dispose();
    super.dispose();
  }

  String get _statusText {
    switch (_uiState) {
      case _AiraUiState.initializingModels:
        return 'Initializing models';
      case _AiraUiState.ready:
        return 'Ready';
      case _AiraUiState.speaking:
        return 'Speaking';
      case _AiraUiState.listening:
        return 'Listening';
      case _AiraUiState.error:
        return 'Error';
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

  Future<void> _toggleMic() async {
    if (!_sttAvailable) return;

    if (_uiState == _AiraUiState.listening) {
      await _stt.stop();
      if (mounted) setState(() => _uiState = _AiraUiState.ready);
      return;
    }

    await _tts.stop();
    if (mounted) setState(() => _uiState = _AiraUiState.listening);

    await _stt.listen(
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) async {
        if (!mounted) return;
        setState(() => _textController.text = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          await _stt.stop();
          if (mounted) setState(() => _uiState = _AiraUiState.ready);
          await _sendText();
        }
      },
    );
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
            Semantics(
              liveRegion: true,
              label: 'Voice status: $_statusText',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.black12,
                child: Text('Status: $_statusText'),
              ),
            ),
            Expanded(
              child: Semantics(
                label: 'Conversation history',
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: _uiState == _AiraUiState.listening ? 'Stop microphone' : 'Start microphone',
                    child: IconButton(
                      onPressed: _toggleMic,
                      icon: Icon(
                        _uiState == _AiraUiState.listening ? Icons.mic_off_rounded : Icons.mic_rounded,
                      ),
                    ),
                  ),
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
                  Semantics(
                    button: true,
                    label: 'Send message',
                    child: ElevatedButton(
                      onPressed: _sendText,
                      child: const Text('Send'),
                    ),
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
