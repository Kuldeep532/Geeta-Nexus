import 'package:flutter/material.dart';
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

  static const _personaIcons = {
    Persona.krishna: '🕉️',
    Persona.radha: '🌸',
    Persona.guide: '📖',
  };

  static const _personaColors = {
    Persona.krishna: Color(0xFF1A3A00),
    Persona.radha: Color(0xFF3A001A),
    Persona.guide: Color(0xFF001A3A),
  };

  static const _greetings = {
    Persona.krishna:
        'Namaste, dear seeker. I am Krishna, your eternal guide. Ask me anything about dharma, duty, the nature of the self, or the path to liberation. I am here to illuminate your path. 🕉️',
    Persona.radha:
        'Welcome, dear soul. I am Radha, the embodiment of pure devotion and divine love. Through the path of Bhakti, every heart can find its way home to the Divine. 🌸',
    Persona.guide:
        'Greetings! I am your Bhagavad Gita Guide. I can help you explore the teachings, find verses, explain concepts, or guide you through your spiritual practice. What would you like to know? 📖',
  };

  @override
  void initState() {
    super.initState();
    _addGreeting();
  }

  void _addGreeting() {
    _messages.add(_Message(text: _greetings[_persona]!, isUser: false));
  }

  String _getLocalResponse(String query) {
    final q = query.toLowerCase();
    final verses = kChapters.expand((c) => c.verses).toList();

    if (q.contains('karma') || q.contains('action') || q.contains('duty')) {
      final verse = verses.firstWhere((v) => v.id == '2.47',
          orElse: () => verses.first);
      return _buildResponse(
          "The essence of karma yoga is acting without attachment to results. As I taught Arjuna:\n\n\"${verse.translation}\"\n— Gita ${verse.id}\n\nPerform your duty with full dedication, but release the fruits to the Divine.",
          verse.id);
    }
    if (q.contains('soul') || q.contains('atman') || q.contains('death') || q.contains('immortal')) {
      final verse = verses.firstWhere((v) => v.id == '2.20',
          orElse: () => verses.first);
      return _buildResponse(
          "The eternal nature of the soul is one of the most profound truths I revealed:\n\n\"${verse.translation}\"\n— Gita ${verse.id}\n\nYou are not the body — you are the eternal, undying Atman.",
          verse.id);
    }
    if (q.contains('mind') || q.contains('meditation') || q.contains('control')) {
      final verse = verses.firstWhere((v) => v.id == '6.5',
          orElse: () => verses.first);
      return _buildResponse(
          "The mind is indeed the greatest challenge on the spiritual path:\n\n\"${verse.translation}\"\n— Gita ${verse.id}\n\nThrough steady practice and detachment, the mind becomes your best friend.",
          verse.id);
    }
    if (q.contains('devotion') || q.contains('bhakti') || q.contains('love') || q.contains('worship')) {
      final verse = verses.firstWhere((v) => v.id == '9.22',
          orElse: () => verses.first);
      return _buildResponse(
          "The path of devotion is the most direct path to the Divine:\n\n\"${verse.translation}\"\n— Gita ${verse.id}\n\nThrough pure love and complete surrender, the Divine provides everything.",
          verse.id);
    }
    if (q.contains('surrender') || q.contains('moksha') || q.contains('liberation')) {
      final verse = verses.firstWhere((v) => v.id == '18.66',
          orElse: () => verses.first);
      return _buildResponse(
          "The supreme secret I revealed at the end of the Gita:\n\n\"${verse.translation}\"\n— Gita ${verse.id}\n\nComplete surrender to the Divine dissolves all burdens and grants eternal freedom.",
          verse.id);
    }
    if (q.contains('dharma') || q.contains('purpose') || q.contains('meaning')) {
      final verse = verses.firstWhere((v) => v.id == '4.7',
          orElse: () => verses.first);
      return _buildResponse(
          "Dharma is the sacred order that sustains all existence:\n\n\"${verse.translation}\"\n— Gita ${verse.id}\n\nYour highest dharma is to discover your true nature and act from that divine center.",
          verse.id);
    }
    if (q.contains('wisdom') || q.contains('knowledge') || q.contains('jnana')) {
      final verse = verses.firstWhere((v) => v.id == '4.38',
          orElse: () => verses.first);
      return _buildResponse(
          "Knowledge is the greatest purifier and liberator:\n\n\"${verse.translation}\"\n— Gita ${verse.id}\n\nThrough sincere practice, the light of wisdom dawns from within.",
          verse.id);
    }
    if (q.contains('equal') || q.contains('equanimity') || q.contains('balance')) {
      final verse = verses.firstWhere((v) => v.id == '2.48',
          orElse: () => verses.first);
      return _buildResponse(
          "True yoga is equanimity in all circumstances:\n\n\"${verse.translation}\"\n— Gita ${verse.id}\n\nWhen you remain steady in joy and sorrow, you have attained true yoga.",
          verse.id);
    }

    // Persona-specific default responses
    switch (_persona) {
      case Persona.krishna:
        return "Dear seeker, your question touches something profound. Remember this: \"Whatever you do, whatever you eat, whatever you offer — do that as an offering to Me.\" (Gita 9.27). Every moment of life can become a meditation when offered to the Divine. Keep seeking, keep surrendering. 🕉️";
      case Persona.radha:
        return "My dear one, in the language of the heart, devotion speaks louder than all philosophy. Love the Divine as I love Krishna — completely, without reservation. When you love in this way, the path opens naturally. Trust your heart — it knows the way home. 🌸";
      case Persona.guide:
        final allVerses = kChapters.expand((c) => c.verses).toList();
        final randomVerse = allVerses[DateTime.now().second % allVerses.length];
        return "Here's a teaching from the Gita that may illuminate your question:\n\n\"${randomVerse.translation}\"\n— Gita ${randomVerse.id}\n\nWould you like me to explain any specific concept or find a verse on a particular topic?";
    }
  }

  String _buildResponse(String text, String verseId) {
    if (_persona == Persona.radha) {
      return "$text\n\nThis is the teaching that guides my devotion to the Divine. May it illuminate your heart as well. 🌸";
    }
    return text;
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
    setState(() {
      _messages.add(_Message(text: response, isUser: false));
      _thinking = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
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
      backgroundColor: kBg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_personaIcons[_persona]!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(_personaNames[_persona]!,
                style: GoogleFonts.cinzel(color: kGold, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPersonaSelector(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kDivider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: Persona.values.map((p) {
          final selected = _persona == p;
          return GestureDetector(
            onTap: () => _changePersona(p),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? _personaColors[p]!
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? kGoldDim : kDivider, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_personaIcons[p]!,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(
                    _personaNames[p]!.split(' ').last,
                    style: TextStyle(
                        color: selected ? kGold : kTextDim,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageBubble(_Message msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: msg.isUser
              ? kGold.withOpacity(0.15)
              : _personaColors[_persona]!.withOpacity(0.6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 18),
          ),
          border: Border.all(
            color: msg.isUser ? kGoldDim.withOpacity(0.5) : kDivider,
          ),
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.crimsonText(
              color: kText, fontSize: 15, height: 1.6),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _personaColors[_persona]!.withOpacity(0.6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: kDivider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${_personaIcons[_persona]!} ',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                  backgroundColor: kDivider, color: kGold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kDivider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: kText),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ask ${_personaNames[_persona]}...',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kGold,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.send, color: kBg, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
