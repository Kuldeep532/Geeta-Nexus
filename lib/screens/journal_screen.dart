import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import '../models/models.dart';
import '../theme.dart'; 

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _searchController = TextEditingController();
  
  bool _showForm = false;
  bool _isSearching = false;
  String _selectedMood = '😌';
  late String _currentPrompt;
  String _searchQuery = '';

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
    _refreshPrompt();
  }

  void _refreshPrompt() {
    setState(() {
      _currentPrompt = (List.from(_prompts)..shuffle()).first;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _submit(AppState state) {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      final cleanContent = _contentController.text.trim();

      // FIX: AppState ke naye simplified method ko call kiya
      state.addJournalEntry(
        content: cleanContent,
        mood: _selectedMood,
      );

      _contentController.clear();
      setState(() => _showForm = false);
      FocusManager.instance.primaryFocus?.unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection saved.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    
    final entries = state.journalEntries.where((e) => 
      e.content.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: kGold),
              decoration: const InputDecoration(hintText: "Search thoughts...", border: InputBorder.none),
              onChanged: (v) => setState(() => _searchQuery = v),
            )
          : Text('Spiritual Journal', style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: kGold),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchQuery = '';
            }),
          ),
          IconButton(
            icon: Icon(_showForm ? Icons.expand_less : Icons.add_comment, color: kGold),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _showForm = !_showForm);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm) _buildForm(state, theme),
          Expanded(
            child: entries.isEmpty 
              ? _buildEmptyState() 
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (ctx, i) => _buildEntryCard(entries[i], state, theme),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AppState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(_currentPrompt, style: GoogleFonts.lato(fontStyle: FontStyle.italic, color: kGold.withOpacity(0.8)))),
                IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _refreshPrompt),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _contentController,
              maxLines: 4,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              validator: (val) => val == null || val.trim().isEmpty ? "Kripya apne vichar likhein" : null,
              decoration: InputDecoration(
                hintText: "Dhyan se likhna shuru karein...",
                fillColor: theme.brightness == Brightness.dark ? Colors.white10 : Colors.black12,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),
            _buildMoodSelector(theme),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submit(state),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("SAVE TO SOUL", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector(ThemeData theme) {
    return Wrap(
      spacing: 12,
      children: _moods.map((m) {
        final isSelected = _selectedMood == m['emoji'];
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedMood = m['emoji']!);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? kGold.withOpacity(0.2) : theme.dividerColor.withOpacity(0.1),
              border: Border.all(color: isSelected ? kGold : Colors.transparent),
            ),
            child: Text(m['emoji']!, style: const TextStyle(fontSize: 24)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEntryCard(JournalEntry entry, AppState state, ThemeData theme) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Reflection?"),
            content: const Text("Kya aap ise hamesha ke liye mita dena chahte hain?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Nahin")),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Haan, Delete", style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) => state.deleteJournalEntry(entry.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
      ),
      child: Card(
        color: theme.cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.mood, style: const TextStyle(fontSize: 26)),
                  Text(DateFormat('d MMM, hh:mm a').format(entry.date), 
                    style: TextStyle(fontSize: 12, color: theme.hintColor)),
                ],
              ),
              const Divider(height: 25),
              Text(entry.content, 
                style: GoogleFonts.lora(fontSize: 16, height: 1.5)),
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
          Icon(Icons.auto_stories, size: 80, color: kGold.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            "Your spiritual journey is waiting...",
            style: GoogleFonts.cinzel(color: kGold, fontSize: 16),
          ),
          Text(
            "Aj ka anubhav likhein.",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
