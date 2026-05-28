import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _contentController =
      TextEditingController();

  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _contentFocusNode = FocusNode();

  bool _showForm = false;
  bool _isSearching = false;

  String _selectedMood = '😌';
  String _searchQuery = '';

  late String _currentPrompt;

  static const List<Map<String, String>> _moods = [
    {
      'emoji': '😌',
      'label': 'Calm',
    },
    {
      'emoji': '🙏',
      'label': 'Grateful',
    },
    {
      'emoji': '😊',
      'label': 'Happy',
    },
    {
      'emoji': '✨',
      'label': 'Inspired',
    },
    {
      'emoji': '🤔',
      'label': 'Reflective',
    },
  ];

  static const List<String> _prompts = [
    'What teaching resonated with me today?',
    'What am I grateful for today?',
    'How did I grow emotionally today?',
    'What brought me peace today?',
    'What challenged me today?',
    'How can I improve tomorrow?',
  ];

  @override
  void initState() {
    super.initState();
    _refreshPrompt();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _searchController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _refreshPrompt() {
    final shuffled = [..._prompts]..shuffle();

    setState(() {
      _currentPrompt = shuffled.first;
    });
  }

  void _toggleSearch() {
    HapticFeedback.selectionClick();

    setState(() {
      _isSearching = !_isSearching;

      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _toggleForm() {
    HapticFeedback.lightImpact();

    setState(() {
      _showForm = !_showForm;
    });

    if (_showForm) {
      Future.delayed(
        const Duration(milliseconds: 250),
        () => _contentFocusNode.requestFocus(),
      );
    }
  }

  void _submit(AppState state) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final content = _contentController.text.trim();

    if (content.isEmpty) {
      return;
    }

    HapticFeedback.mediumImpact();

    state.addJournalEntry(
      content: content,
      mood: _selectedMood,
    );

    _contentController.clear();

    FocusScope.of(context).unfocus();

    setState(() {
      _showForm = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reflection saved successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Reflection'),
          content: const Text(
            'Are you sure you want to permanently delete this reflection?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final state = context.watch<AppState>();

    final entries = state.journalEntries.where(
      (entry) {
        final query = _searchQuery.toLowerCase();

        return entry.content.toLowerCase().contains(query) ||
            entry.mood.toLowerCase().contains(query);
      },
    ).toList();

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: _isSearching
              ? Semantics(
                  textField: true,
                  label: 'Search reflections',
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search reflections...',
                      border: InputBorder.none,
                    ),
                  ),
                )
              : Text(
                  'Journal',
                  style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
                  ),
                ),
          actions: [
            Semantics(
              button: true,
              label: _isSearching
                  ? 'Close search'
                  : 'Open search',
              child: IconButton(
                tooltip: _isSearching
                    ? 'Close Search'
                    : 'Search',
                icon: Icon(
                  _isSearching
                      ? Icons.close
                      : Icons.search,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _toggleSearch();
                },
              ),
            ),
            Semantics(
              button: true,
              label: _showForm
                  ? 'Close journal form'
                  : 'Create journal entry',
              child: IconButton(
                tooltip: _showForm
                    ? 'Close Form'
                    : 'New Entry',
                icon: Icon(
                  _showForm
                      ? Icons.expand_less
                      : Icons.add_comment_outlined,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _toggleForm();
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildForm(
                  state,
                  theme,
                ),
                crossFadeState: _showForm
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(
                  milliseconds: 250,
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.separated(
                        padding:
                            const EdgeInsets.all(16),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = entries[index];

                          return _buildEntryCard(
                            entry,
                            state,
                            theme,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    AppState state,
    ThemeData theme,
  ) {
    return Material(
      elevation: 1,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Semantics(
                      label:
                          'Writing prompt: $_currentPrompt',
                      child: Text(
                        _currentPrompt,
                        style: GoogleFonts.lato(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: 'Refresh prompt',
                    child: IconButton(
                      tooltip: 'Refresh Prompt',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _refreshPrompt();
                      },
                      icon: const Icon(
                        Icons.refresh,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Semantics(
                textField: true,
                multiline: true,
                label: 'Journal content input',
                hint:
                    'Write your thoughts and reflections',
                child: TextFormField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  keyboardType:
                      TextInputType.multiline,
                  textInputAction:
                      TextInputAction.newline,
                  minLines: 5,
                  maxLines: 8,
                  maxLength: 1200,
                  autofillHints: const [
                    AutofillHints.nickname,
                  ],
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please write something';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Start writing your reflection...',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildMoodSelector(theme),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Semantics(
                  button: true,
                  label: 'Save reflection',
                  hint:
                      'Double tap to save journal entry',
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _submit(state);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'SAVE REFLECTION',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector(
    ThemeData theme,
  ) {
    return Semantics(
      container: true,
      label: 'Mood selection',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _moods.map(
          (mood) {
            final emoji = mood['emoji']!;
            final label = mood['label']!;

            final isSelected =
                _selectedMood == emoji;

            return Semantics(
              button: true,
              selected: isSelected,
              label: '$label mood',
              hint: isSelected
                  ? 'Currently selected'
                  : 'Double tap to select',
              child: Tooltip(
                message: label,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(100),
                  onTap: () {
                    HapticFeedback.selectionClick();

                    setState(() {
                      _selectedMood = emoji;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 200,
                    ),
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      emoji,
                      style:
                          const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildEntryCard(
    JournalEntry entry,
    AppState state,
    ThemeData theme,
  ) {
    final formattedDate =
        DateFormat(
      'd MMM yyyy • hh:mm a',
    ).format(entry.date);

    return Semantics(
      container: true,
      label:
          'Journal entry from $formattedDate',
      child: Dismissible(
        key: ValueKey(entry.id),
        direction:
            DismissDirection.endToStart,
        confirmDismiss: (_) async {
          return await _confirmDelete();
        },
        onDismissed: (_) {
          state.deleteJournalEntry(entry.id);

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content:
                  Text('Reflection deleted'),
            ),
          );
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding:
              const EdgeInsets.only(right: 24),
          margin:
              const EdgeInsets.symmetric(
            vertical: 2,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.delete_outline,
            size: 32,
          ),
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Semantics(
                      label:
                          'Mood ${entry.mood}',
                      child: Text(
                        entry.mood,
                        style:
                            const TextStyle(
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        formattedDate,
                        textAlign:
                            TextAlign.end,
                        style: theme
                            .textTheme
                            .bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(
                  height: 1,
                  color: theme.dividerColor,
                ),
                const SizedBox(height: 14),
                SelectableText(
                  entry.content,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Semantics(
          container: true,
          label:
              'No journal entries available',
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 88,
                color: theme.iconTheme.color
                    ?.withOpacity(0.4),
              ),
              const SizedBox(height: 20),
              Text(
                'No Reflections Yet',
                style: theme
                    .textTheme
                    .headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Start your first journal reflection and capture your thoughts.',
                style:
                    theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _toggleForm();
                },
                icon: const Icon(Icons.edit),
                label:
                    const Text('Create Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
