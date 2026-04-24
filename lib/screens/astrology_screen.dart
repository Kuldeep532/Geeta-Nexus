import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

class AstrologyScreen extends StatefulWidget {
  const AstrologyScreen({super.key});

  @override
  State<AstrologyScreen> createState() => _AstrologyScreenState();
}

class _AstrologyScreenState extends State<AstrologyScreen> {
  final _nameController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  DateTime? _dob;
  TimeOfDay? _tob;
  String? _result;

  static const Map<String, String> _zodiacInsights = {
    'Aries': 'Initiator energy, strong willpower, and bold action periods ahead.',
    'Taurus': 'Stable growth, wealth planning, and grounded personal progress.',
    'Gemini': 'Communication, learning, and networking opportunities increase.',
    'Cancer': 'Family harmony and emotional healing themes remain strong.',
    'Leo': 'Leadership, creativity, and recognition can accelerate this phase.',
    'Virgo': 'Discipline, health focus, and practical planning bring gains.',
    'Libra': 'Balance in relationships and graceful decision-making is highlighted.',
    'Scorpio': 'Transformation, deep focus, and resilience define this cycle.',
    'Sagittarius': 'Expansion, travel, and dharmic learning pathways open up.',
    'Capricorn': 'Long-term career structure and responsibility bring rewards.',
    'Aquarius': 'Innovation, service to community, and new ideas flourish.',
    'Pisces': 'Intuition, devotion, and spiritual sensitivity stay elevated.',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  String _zodiac(DateTime d) {
    final m = d.month;
    final day = d.day;
    if ((m == 3 && day >= 21) || (m == 4 && day <= 19)) return 'Aries';
    if ((m == 4 && day >= 20) || (m == 5 && day <= 20)) return 'Taurus';
    if ((m == 5 && day >= 21) || (m == 6 && day <= 20)) return 'Gemini';
    if ((m == 6 && day >= 21) || (m == 7 && day <= 22)) return 'Cancer';
    if ((m == 7 && day >= 23) || (m == 8 && day <= 22)) return 'Leo';
    if ((m == 8 && day >= 23) || (m == 9 && day <= 22)) return 'Virgo';
    if ((m == 9 && day >= 23) || (m == 10 && day <= 22)) return 'Libra';
    if ((m == 10 && day >= 23) || (m == 11 && day <= 21)) return 'Scorpio';
    if ((m == 11 && day >= 22) || (m == 12 && day <= 21)) return 'Sagittarius';
    if ((m == 12 && day >= 22) || (m == 1 && day <= 19)) return 'Capricorn';
    if ((m == 1 && day >= 20) || (m == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces';
  }

  void _generateKundli() {
    if (_dob == null || _tob == null) return;
    final sign = _zodiac(_dob!);
    final name = _nameController.text.trim().isEmpty ? 'Seeker' : _nameController.text.trim();
    final city = _birthPlaceController.text.trim().isEmpty ? 'your birthplace' : _birthPlaceController.text.trim();

    setState(() {
      _result = 'Kundli Summary for $name\n\n'
          'Birth: ${_dob!.toLocal().toString().substring(0, 10)} at ${_tob!.format(context)}\n'
          'Place: $city\n'
          'Zodiac: $sign\n\n'
          '${_zodiacInsights[sign]}\n\n'
          'Life Horoscope Guidance:\n'
          '• Career: Focus on consistency and skill deepening this month.\n'
          '• Relationships: Practice calm communication and patience.\n'
          '• Health: Follow regular sleep and mindful breathing discipline.\n'
          '• Spiritual: Read one Gita verse daily for clarity and balance.\n\n'
          'Generated locally without API keys using built-in astrology rules.';
    });
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      lastDate: now,
      initialDate: _dob ?? DateTime(now.year - 20),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _tob ?? const TimeOfDay(hour: 6, minute: 0),
    );
    if (picked != null) setState(() => _tob = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Astrology & Kundli'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Horoscope Generator',
              style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _birthPlaceController,
            decoration: const InputDecoration(labelText: 'Birth place'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickDob,
                  child: Text(_dob == null ? 'Select date of birth' : _dob!.toLocal().toString().substring(0, 10)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickTime,
                  child: Text(_tob == null ? 'Select birth time' : _tob!.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _generateKundli,
            child: const Text('Generate Kundli & Horoscope'),
          ),
          const SizedBox(height: 14),
          if (_result != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kDivider.withOpacity(0.5)),
              ),
              child: SelectableText(
                _result!,
                style: GoogleFonts.crimsonText(color: kText, fontSize: 15, height: 1.4),
              ),
            ),
        ],
      ),
    );
  }
}
