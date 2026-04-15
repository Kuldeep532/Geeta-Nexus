import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _showForm = false;
  final _contentController = TextEditingController();
  String _selectedMood = '😌';

  static const _moods = ['😌', '🙏', '😊', '😔', '😤', '🤔', '✨', '💭'];
  static const _prompts = [
    'What teaching from the Gita resonated with me today?',
    'Where did I act with detachment today?',
    'How did I practice equanimity today?',
    'What am I grateful for in this moment?',
    'Where can I bring more dharma into my life?',
    'How did I see the Divine in others today?',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _save(AppState state) {
    if (_contentController.text.trim().isEmpty) return;
    state.addJournalEntry(_contentController.text.trim(), _selectedMood);
    _contentController.clear();
    setState(() => _showForm = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal entry saved! +15 XP')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entries = state.journalEntries;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Spiritual Journal'),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add, color: kGold),
            onPressed: () => setState(() {
              _showForm = !_showForm;
              if (!_showForm) _contentController.clear();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm) _buildForm(state),
          Expanded(
            child: entries.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (ctx, i) => _buildEntry(ctx, entries[i], state),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AppState state) {
    final prompt = _prompts[DateTime.now().second % _prompts.length];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(bottom: BorderSide(color: kDivider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s Reflection',
              style: GoogleFonts.cinzel(
                  color: kGold, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Prompt: $prompt',
              style: const TextStyle(
                  color: kTextDim, fontSize: 12, fontStyle: FontStyle.italic)),
          const SizedBox(height: 10),
          TextField(
            controller: _contentController,
            maxLines: 4,
            style: const TextStyle(color: kText, fontSize: 14, height: 1.5),
            decoration: const InputDecoration(
              hintText: 'Write your reflection here...',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Mood: ',
                  style: const TextStyle(color: kTextDim, fontSize: 13)),
              ..._moods.map((m) => GestureDetector(
                    onTap: () => setState(() => _selectedMood = m),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: m == _selectedMood
                            ? kGold.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: m == _selectedMood ? kGold : Colors.transparent,
                        ),
                      ),
                      child: Text(m, style: const TextStyle(fontSize: 20)),
                    ),
                  )),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _save(state),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntry(BuildContext context, JournalEntry entry, AppState state) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red.withOpacity(0.2),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => state.deleteJournalEntry(entry.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(entry.mood, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(
                  DateFormat('MMMM d, y').format(entry.date),
                  style: GoogleFonts.cinzel(
                      color: kGoldDim, fontSize: 12),
                ),
                const Spacer(),
                Text(DateFormat('h:mm a').format(entry.date),
                    style: const TextStyle(color: kTextDim, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.content,
              style: GoogleFonts.crimsonText(
                  color: kText, fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✍️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Begin Your Spiritual Journal',
              style: GoogleFonts.cinzel(color: kGold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
            'Record your reflections, insights,\nand moments of inner peace.',
            style: TextStyle(color: kTextDim, fontSize: 14, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() => _showForm = true),
            icon: const Icon(Icons.edit),
            label: const Text('Write First Entry'),
          ),
        ],
      ),
    );
  }
}
