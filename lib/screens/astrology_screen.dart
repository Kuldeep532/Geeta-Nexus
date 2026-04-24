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

  @override
  void dispose() {
    _nameController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  String _calculateZodiac(DateTime d) {
    final month = d.month;
    final day = d.day;
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces';
  }

  String _getDynamicInsight(String sign) {
    final dayOfWeek = DateTime.now().weekday;
    final planetaryRulers = {
      1: 'Moon (Somvar) - Focus on emotional clarity.',
      2: 'Mars (Mangalvar) - High energy for physical tasks.',
      3: 'Mercury (Budhvar) - Ideal for communication and tech.',
      4: 'Jupiter (Guruvar) - Expansion and spiritual learning.',
      5: 'Venus (Shukravar) - Creativity and harmony in focus.',
      6: 'Saturn (Shanivar) - Discipline and long-term planning.',
      7: 'Sun (Ravivar) - Vitality and leadership energy.',
    };

    return 'Current Planetary Influence: ${planetaryRulers[dayOfWeek]}\n'
        'Personal Phase: Your $sign energy is interacting with the current lunar cycle. '
        'This is a period for internal reflection and grounding.';
  }

  void _generateKundli() {
    if (_dob == null || _tob == null) return;

    final sign = _calculateZodiac(_dob!);
    final name = _nameController.text.trim().isEmpty ? 'Seeker' : _nameController.text.trim();
    final city = _birthPlaceController.text.trim().isEmpty
        ? 'your birthplace'
        : _birthPlaceController.text.trim();
    final dynamicInsight = _getDynamicInsight(sign);

    setState(() {
      _result = 'Kundli Summary for $name\n'
          '----------------------------------\n'
          'Birth: ${_dob!.day}/${_dob!.month}/${_dob!.year} at ${_tob!.format(context)}\n'
          'Place: $city\n'
          'Zodiac: $sign\n\n'
          '$dynamicInsight\n\n'
          'Daily Guidelines:\n'
          '• Nutrition: Favor fresh, wholesome foods.\n'
          '• Discipline: Maintain your meditation schedule for mental balance.\n'
          '• Career: Look for collaborative growth opportunities.\n\n'
          'Calculated using real-time system algorithms.';
    });
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      initialDate: _dob ?? DateTime(2000, 1, 1),
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
        title: Text('Astrology', style: GoogleFonts.cinzel(color: kGold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInputSection(),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kGold),
            onPressed: _generateKundli,
            child: const Text('Calculate Real-Time Chart', style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 20),
          if (_result != null) _buildResultDisplay(),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _birthPlaceController,
          decoration: const InputDecoration(labelText: 'City of Birth'),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _pickDob,
                child: Text(_dob == null ? 'Date of Birth' : '${_dob!.day}/${_dob!.month}/${_dob!.year}'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _pickTime,
                child: Text(_tob == null ? 'Time of Birth' : _tob!.format(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withOpacity(0.3)),
      ),
      child: SelectableText(
        _result!,
        style: GoogleFonts.crimsonText(color: kText, fontSize: 16, height: 1.5),
      ),
    );
  }
}
