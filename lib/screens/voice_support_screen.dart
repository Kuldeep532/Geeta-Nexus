import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';

import '../services/puter_tts.dart';
import '../theme.dart';

enum _CallState { idle, listening, processing, speaking }

class VoiceSupportScreen extends StatefulWidget {
  const VoiceSupportScreen({super.key});

  @override
  State<VoiceSupportScreen> createState() => _VoiceSupportScreenState();
}

class _VoiceSupportScreenState extends State<VoiceSupportScreen>
    with TickerProviderStateMixin {
  static const String _backendUrl = String.fromEnvironment(
    'AIRA_BACKEND_URL',
    defaultValue: '',
  );

  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  _CallState _state = _CallState.idle;
  String _transcript = '';
  String _aiReply = '';
  bool _sttAvailable = false;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initStt();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _stt.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initStt() async {
    final ok = await _stt.initialize(
      onError: (_) => _onSttError(),
    );
    if (mounted) setState(() => _sttAvailable = ok);
  }

  void _onSttError() {
    if (mounted) {
      setState(() => _state = _CallState.idle);
      _showSnack('Microphone unavailable. Please grant permission and try again.');
    }
  }

  Future<void> _startVoiceCall() async {
    HapticFeedback.mediumImpact();
    if (!_sttAvailable) {
      _showSnack('Speech recognition not available on this device/browser.');
      return;
    }
    setState(() {
      _state = _CallState.listening;
      _transcript = '';
      _aiReply = '';
    });
    SemanticsService.announce('Listening. Please speak now.', TextDirection.ltr);

    await _stt.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          setState(() => _transcript = result.recognizedWords);
          _stt.stop();
          _sendToBackend(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 4),
      cancelOnError: true,
    );
  }

  Future<void> _sendToBackend(String text) async {
    setState(() => _state = _CallState.processing);
    SemanticsService.announce('Processing your message.', TextDirection.ltr);

    String reply;
    try {
      final url = _backendUrl.isEmpty
          ? null
          : Uri.tryParse('$_backendUrl/api/chat');

      if (url == null) {
        reply = _localFallback(text);
      } else {
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'message': text}),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          reply = (data['reply'] as String? ?? '').trim();
          if (reply.isEmpty) reply = _localFallback(text);
        } else {
          reply = 'I encountered an issue reaching the server. Please try again.';
        }
      }
    } catch (_) {
      reply = 'Connection error. Please check your network and try again.';
    }

    setState(() => _aiReply = reply);
    await _speak(reply);
  }

  Future<void> _speak(String text) async {
    setState(() => _state = _CallState.speaking);
    SemanticsService.announce('Aira is responding.', TextDirection.ltr);

    if (kIsWeb) {
      await puterSpeak(text);
      await Future.delayed(
        Duration(milliseconds: (text.length * 60).clamp(2000, 12000)),
      );
    } else {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.47);
      await _tts.speak(text);
      await _tts.awaitSpeakCompletion(true);
    }

    if (mounted) setState(() => _state = _CallState.idle);
  }

  String _localFallback(String text) {
    final q = text.toLowerCase();
    if (q.contains('meditation') || q.contains('meditat')) {
      return 'Navigate to the Meditation section from the Home tab for guided sessions.';
    }
    if (q.contains('verse') || q.contains('gita') || q.contains('shloka')) {
      return 'You can explore all Bhagavad Gita verses in the Scripture Library on the Home screen.';
    }
    if (q.contains('habit') || q.contains('tracker')) {
      return 'The Habit Tracker is in the AI Ecosystem section on the Home screen. It helps you track daily spiritual resolutions.';
    }
    if (q.contains('planner') || q.contains('karma')) {
      return 'The Karma-Yogi Planner lets you plan your day through Krishna\'s teachings. Find it on the Home screen.';
    }
    return 'Thank you for your question. Explore the app\'s features — Scripture Library, Meditation, and AI tools — for comprehensive spiritual guidance.';
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String get _statusLabel {
    switch (_state) {
      case _CallState.idle:
        return _aiReply.isEmpty
            ? 'Tap "Start Voice Call" to speak with Aira'
            : 'Tap "Speak Again" to continue';
      case _CallState.listening:
        return 'Listening… speak now';
      case _CallState.processing:
        return 'Aira is thinking…';
      case _CallState.speaking:
        return 'Aira is speaking…';
    }
  }

  IconData get _stateIcon {
    switch (_state) {
      case _CallState.idle:
        return Icons.support_agent_rounded;
      case _CallState.listening:
        return Icons.mic_rounded;
      case _CallState.processing:
        return Icons.psychology_rounded;
      case _CallState.speaking:
        return Icons.record_voice_over_rounded;
    }
  }

  Color get _stateColor {
    switch (_state) {
      case _CallState.idle:
        return kGold;
      case _CallState.listening:
        return kSaffron;
      case _CallState.processing:
        return const Color(0xFF4CAF50);
      case _CallState.speaking:
        return const Color(0xFF2196F3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final busy = _state != _CallState.idle;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Semantics(
          header: true,
          child: Text(
            'Customer Support',
            style: GoogleFonts.cinzel(
              color: kGold,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Avatar ──────────────────────────────────────────────────
              Semantics(
                label: 'Aira AI assistant avatar. Status: ${_statusLabel}',
                child: ScaleTransition(
                  scale: _state == _CallState.listening
                      ? _pulseAnim
                      : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _stateColor.withOpacity(0.85),
                          _stateColor.withOpacity(0.45),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 28,
                          color: _stateColor.withOpacity(0.35),
                        ),
                      ],
                    ),
                    child: Icon(
                      _stateIcon,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── Name & Status ────────────────────────────────────────────
              Text(
                'Aira',
                style: GoogleFonts.cinzel(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? kGoldLight : kGoldDim,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Semantics(
                liveRegion: true,
                label: _statusLabel,
                child: Text(
                  _statusLabel,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Transcript card ──────────────────────────────────────────
              if (_transcript.isNotEmpty)
                _ConversationBubble(
                  text: _transcript,
                  isUser: true,
                  isDark: isDark,
                ),

              if (_aiReply.isNotEmpty) ...[
                const SizedBox(height: 10),
                _ConversationBubble(
                  text: _aiReply,
                  isUser: false,
                  isDark: isDark,
                ),
              ],

              // ── Processing indicator ─────────────────────────────────────
              if (_state == _CallState.processing) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kGold),
                  strokeWidth: 2.5,
                ),
              ],

              const Spacer(),

              // ── Action Button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: busy ? null : _startVoiceCall,
                  icon: Icon(
                    _aiReply.isEmpty ? Icons.phone_rounded : Icons.mic_rounded,
                    size: 22,
                  ),
                  label: Text(
                    _aiReply.isEmpty ? 'Start Voice Call' : 'Speak Again',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: busy ? Colors.grey : kGold,
                    foregroundColor: Colors.black87,
                    disabledBackgroundColor: Colors.grey.shade600,
                    disabledForegroundColor: Colors.white54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: busy ? 0 : 4,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── End Call / note ──────────────────────────────────────────
              if (!busy)
                Semantics(
                  button: true,
                  label: 'End call and go back',
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.call_end_rounded,
                        color: Colors.redAccent, size: 18),
                    label: Text(
                      'End Call',
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isDark;

  const _ConversationBubble({
    required this.text,
    required this.isUser,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isUser ? 'You said: $text' : 'Aira replied: $text',
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser
                ? kGold.withOpacity(isDark ? 0.22 : 0.18)
                : (isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.shade100),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 18),
            ),
            border: Border.all(
              color: isUser
                  ? kGold.withOpacity(0.35)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              height: 1.45,
              color: isDark
                  ? Colors.white.withOpacity(0.88)
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
