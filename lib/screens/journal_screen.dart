import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; 
import '../theme.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _uuid = const Uuid();
  
  bool _showForm = false;
  String _selectedMood = '😌';
  late String _currentPrompt;

  static const _moods = [
    {'emoji': '😌', 'label': 'Calm'},
    {'emoji': '🙏', 'label': 'Grateful'},
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '✨', 'label': 'Inspired'},
    {'emoji': '🤔', 'label': 'Reflective'},
  ];

  static const _prompts = [
    'What teaching from the Gita resonated with me today?',
    'Where did I act with detachment today?',
    'How did I practice equanimity today?',
    'What am I grateful for in this moment?',
    'Where can I bring more dharma into my life?',
    'How did I see the Divine in others today?',
  ];

  @override
  void initState() {
    super.initState();
    _currentPrompt = _prompts[DateTime.now().day % _prompts.length];
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submit(AppState state) {
    if (_formKey.currentState!.validate()) {
      final cleanContent = _contentController.text
          .trim()
          .replaceAll(RegExp(r'\n{3,}'), '\n\n'); 

      state.addJournalEntry(
        id: _uuid.v4(),
        content: cleanContent,
        mood: _selectedMood,
      );

      _contentController.clear();
      setState(() => _showForm = false);
      FocusManager.instance.primaryFocus?.unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reflection saved.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entries = state.journalEntries;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('Spiritual Journal', style: GoogleFonts.cinzel()),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add_comment, color: kGold),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm) _buildForm(state),
          Expanded(
            child: entries.isEmpty 
              ? _buildEmptyState() 
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (ctx, i) => _buildEntryCard(entries[i], state),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: kSurface,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(_currentPrompt, style: GoogleFonts.lato(fontStyle: FontStyle.italic, color: kGoldDim)),
            const SizedBox(height: 15),
            TextFormField(
              controller: _contentController,
              autofocus: true,
              maxLines: 4,
              validator: (val) => val == null || val.trim().isEmpty ? "Please write your thoughts" : null,
              decoration: const InputDecoration(
                hintText: "Begin writing...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            _buildMoodSelector(),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _submit(state),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text("Save Entry"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Wrap(
      spacing: 15,
      children: _moods.map((m) {
        final isSelected = _selectedMood == m['emoji'];
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = m['emoji']!),
          child: Semantics(
            label: "Mood: ${m['label']}",
            selected: isSelected,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? kGold.withOpacity(0.2) : Colors.transparent,
                border: Border.all(color: isSelected ? kGold : kDivider),
              ),
              child: Text(m['emoji']!, style: const TextStyle(fontSize: 22)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEntryCard(JournalEntry entry, AppState state) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete entry?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) => state.deleteJournalEntry(entry.id),
      background: Container(
        color: Colors.red.shade900,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.mood, style: const TextStyle(fontSize: 24)),
                  Text(DateFormat('MMM d, h:mm a').format(entry.date), style: const TextStyle(fontSize: 12, color: kTextDim)),
                ],
              ),
              const Divider(height: 20),
              Text(entry.content, style: GoogleFonts.crimsonText(fontSize: 17, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories, size: 60, color: kDivider),
          const SizedBox(height: 10),
          Text("No entries yet", style: GoogleFonts.cinzel()),
        ],
      ),
    );
  }
}
