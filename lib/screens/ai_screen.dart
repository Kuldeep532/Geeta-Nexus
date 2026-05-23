import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vibration/vibration.dart';

import '../services/ai_service.dart';
import '../theme.dart';

enum Persona { krishna, radha, guide }

class _Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _Message({
    required this.text,
    required this.isUser,
    DateTime? time,
  }) : timestamp = time ?? DateTime.now();
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

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();

  final List<_Message> _messages = [];

  Persona _persona = Persona.krishna;

  bool _thinking = false;
  bool _isListening = false;
  bool _aiSpeaking = false;
  bool _continuousVoiceMode = true;

  static const _personaNames = {
    Persona.krishna: 'Lord Krishna',
    Persona.radha: 'Radha Rani',
    Persona.guide: 'Gita Guide',
  };

  final List<String> _suggestions = [
    "Explain karma",
    "How to meditate?",
    "What is dharma?",
    "Teach me Bhagavad Gita",
    "How to control anger?",
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _addGreeting();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      setState(() => _aiSpeaking = true);

      SemanticsService.announce(
        "AI started speaking",
        TextDirection.ltr,
      );
    });

    _tts.setCompletionHandler(() async {
      setState(() => _aiSpeaking = false);

      SemanticsService.announce(
        "AI finished speaking",
        TextDirection.ltr,
      );

      if (_continuousVoiceMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        _startListening();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();

    _tts.stop();
    _speech.stop();

    super.dispose();
  }

  void _addGreeting() {
    final greetings = {
      Persona.krishna:
          'Namaste, dear seeker. I am Krishna, your eternal guide. 🕉️',
      Persona.radha:
          'Welcome, dear soul. I am Radha, the embodiment of devotion. 🌸',
      Persona.guide:
          'Greetings! I am your Bhagavad Gita Guide. 📖',
    };

    _messages.add(
      _Message(
        text: greetings[_persona]!,
        isUser: false,
      ),
    );
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _startListening() async {
    if (_aiSpeaking) {
      await _tts.stop();
    }

    final available = await _speech.initialize(
      onStatus: (status) async {
        if (status == 'done') {
          setState(() => _isListening = false);

          SemanticsService.announce(
            "Voice input completed",
            TextDirection.ltr,
          );

          if (_controller.text.trim().isNotEmpty) {
            await _sendMessage();
          }
        }
      },
      onError: (error) {
        SemanticsService.announce(
          "Voice recognition error",
          TextDirection.ltr,
        );
      },
    );

    if (!available) return;

    await Vibration.vibrate(duration: 80);

    setState(() => _isListening = true);

    SemanticsService.announce(
      "Listening started",
      TextDirection.ltr,
    );

    _speech.listen(
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(minutes: 1),
      partialResults: true,
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    await Vibration.vibrate(duration: 50);

    setState(() => _isListening = false);

    SemanticsService.announce(
      "Listening stopped",
      TextDirection.ltr,
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _thinking) return;

    HapticFeedback.mediumImpact();

    _controller.clear();

    setState(() {
      _messages.add(
        _Message(
          text: text,
          isUser: true,
        ),
      );

      _thinking = true;
    });

    SemanticsService.announce(
      "Message sent",
      TextDirection.ltr,
    );

    _scrollToBottom();

    try {
      final personaPrompt =
          '[Persona: ${_personaNames[_persona]}] $text';

      final aiReply =
          await _aiService.getSmartResponse(personaPrompt);

      if (!mounted) return;

      setState(() {
        _messages.add(
          _Message(
            text: aiReply,
            isUser: false,
          ),
        );
      });

      await Vibration.vibrate(duration: 100);

      SemanticsService.announce(
        "AI replied",
        TextDirection.ltr,
      );

      await _speak(aiReply);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          _Message(
            text:
                'I could not respond right now. Please try again.',
            isUser: false,
          ),
        );
      });

      SemanticsService.announce(
        "Network error occurred",
        TextDirection.ltr,
      );
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    final disableAnimations =
        MediaQuery.of(context).disableAnimations;

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            _personaNames[_persona]!,
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              color: kGold,
            ),
          ),
          actions: [
            Semantics(
              label: 'Continuous voice mode',
              hint: 'Double tap to toggle',
              toggled: _continuousVoiceMode,
              child: Switch(
                value: _continuousVoiceMode,
                onChanged: (value) {
                  setState(() {
                    _continuousVoiceMode = value;
                  });

                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildPersonaSelector(),

            _buildSuggestionChips(),

            Expanded(
              child: Semantics(
                label: 'Conversation history',
                liveRegion: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount:
                      _messages.length +
                          (_thinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_thinking &&
                        index == _messages.length) {
                      return _buildThinkingBubble();
                    }

                    return _buildMessageBubble(
                      _messages[index],
                      isDark,
                    );
                  },
                ),
              ),
            ),

            if (_aiSpeaking)
              Semantics(
                liveRegion: true,
                label: 'AI is speaking',
                child: ExcludeSemantics(
                  child: AnimatedContainer(
                    duration: disableAnimations
                        ? Duration.zero
                        : const Duration(milliseconds: 400),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 45,
                    width: 140,
                    decoration: BoxDecoration(
                      color: kGold.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(child: Text('AI Speaking…')),
                  ),
                ),
              ),

            _buildInputBar(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    return Semantics(
      label: 'Quick suggestions',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _suggestions.map((suggestion) {
            return Semantics(
              button: true,
              label: 'Suggestion: $suggestion. Double tap to use.',
              child: ExcludeSemantics(
                child: ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    _controller.text = suggestion;
                    SemanticsService.announce(
                      'Suggestion selected: $suggestion',
                      TextDirection.ltr,
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    _Message msg,
    bool isDark,
  ) {
    final speakerLabel = msg.isUser ? 'You said' : 'AI replied';
    return Semantics(
      label: '$speakerLabel: ${msg.text}',
      hint: 'Double tap to hear aloud. Long press to copy.',
      button: true,
      child: ExcludeSemantics(
        child: Align(
          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => _speak(msg.text),
            onLongPress: () async {
              await Clipboard.setData(ClipboardData(text: msg.text));
              SemanticsService.announce('Message copied', TextDirection.ltr);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(14),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? kGold
                    : (isDark ? Colors.grey[900] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                msg.text,
                textScaler: MediaQuery.textScalerOf(context),
                style: TextStyle(
                  color: msg.isUser
                      ? Colors.black
                      : (isDark ? Colors.white : Colors.black87),
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Semantics(
        liveRegion: true,
        label: 'AI is thinking',
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: kGold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(
    ThemeData theme,
    bool isDark,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        color: theme.scaffoldBackgroundColor,
        child: Row(
          children: [
            Semantics(
              button: true,
              label:
                  _isListening
                      ? 'Stop voice input'
                      : 'Start voice input',
              hint:
                  'Double tap to use voice dictation',
              child: IconButton(
                tooltip: 'Voice Dictation',
                onPressed: _toggleListening,
                icon: Icon(
                  _isListening
                      ? Icons.mic
                      : Icons.mic_none,
                  color:
                      _isListening
                          ? Colors.red
                          : kGold,
                ),
              ),
            ),

            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _inputFocus,
                textInputAction:
                    TextInputAction.send,
                onSubmitted: (_) =>
                    _sendMessage(),
                style: TextStyle(
                  color:
                      isDark
                          ? Colors.white
                          : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText:
                      'Ask your question',
                  hintText:
                      'Speak or type here...',
                  filled: true,
                  fillColor:
                      isDark
                          ? Colors.white10
                          : Colors.black
                              .withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Semantics(
              button: true,
              enabled: !_thinking,
              label: 'Send message',
              hint:
                  'Double tap to send your message',
              child: FloatingActionButton.small(
                tooltip: 'Send',
                backgroundColor: kGold,
                onPressed:
                    _thinking
                        ? null
                        : _sendMessage,
                child: const Icon(
                  Icons.send,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaSelector() {
    return Semantics(
      label: 'Choose AI persona',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: Persona.values.map((p) {
            final isSelected = _persona == p;
            return Semantics(
              button: true,
              selected: isSelected,
              label: '${_personaNames[p]}. ${isSelected ? "Currently selected." : "Double tap to select."}',
              child: ExcludeSemantics(
                child: ChoiceChip(
                  selected: isSelected,
                  label: Text(_personaNames[p]!),
                  selectedColor: kGold,
                  onSelected: (selected) async {
                    if (!selected) return;
                    await Vibration.vibrate(duration: 60);
                    setState(() {
                      _persona = p;
                      _messages
                        ..clear()
                        ..add(_Message(
                          text: p == Persona.krishna
                              ? 'Namaste, dear seeker. I am Krishna.'
                              : p == Persona.radha
                                  ? 'Welcome dear soul. I am Radha.'
                                  : 'Greetings! I am your Gita Guide.',
                          isUser: false,
                        ));
                    });
                    SemanticsService.announce(
                      '${_personaNames[p]} selected',
                      TextDirection.ltr,
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
