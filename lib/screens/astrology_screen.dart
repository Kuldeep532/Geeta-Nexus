import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart'; // Ensure kGold is defined here

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

  // Western Zodiac Calculation (Vedic requires complex APIs, but this is a solid base)
  String _calculateZodiac(DateTime d) {
    final month = d.month;
    final day = d.day;
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries (Mesh)';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus (Vrishabh)';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini (Mithun)';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer (Kark)';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo (Simha)';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo (Kanya)';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra (Tula)';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio (Vrishchik)';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius (Dhanu)';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn (Makar)';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius (Kumbh)';
    return 'Pisces (Meen)';
  }

  String _getDynamicInsight(String sign) {
    final dayOfWeek = DateTime.now().weekday;
    final planetaryRulers = {
      1: 'Moon (Chandra) - Focus on peace and emotional balance.',
      2: 'Mars (Mangal) - High energy; good for physical discipline.',
      3: 'Mercury (Budh) - Excellent for learning and communication.',
      4: 'Jupiter (Guru) - Ideal for spiritual study and wisdom.',
      5: 'Venus (Shukra) - Harmony, creativity, and refinement.',
      6: 'Saturn (Shani) - Focus on patience and karmic duties.',
      7: 'Sun (Surya) - Vitality, leadership, and soul-cleansing.',
    };

    return 'Planetary Ruler: ${planetaryRulers[dayOfWeek] ?? "Balanced"}\n'
        'Insight: Your $sign energy suggests a period of internal grounding.';
  }

  void _generateKundli() {
    if (_dob == null || _tob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both Birth Date and Time')),
      );
      return;
    }

    final sign = _calculateZodiac(_dob!);
    final name = _nameController.text.trim().isEmpty ? 'Seeker' : _nameController.text.trim();
    final city = _birthPlaceController.text.trim().isEmpty ? 'Unknown' : _birthPlaceController.text.trim();

    setState(() {
      _result = 'Kundli Summary for $name\n'
          '----------------------------------\n'
          'Birth: ${_dob!.day}/${_dob!.month}/${_dob!.year} at ${_tob!.format(context)}\n'
          'Place: $city\n'
          'Zodiac: $sign\n\n'
          '${_getDynamicInsight(sign)}\n\n'
          'Daily Guidelines:\n'
          '• Diet: Pure Satvik food for mental clarity.\n'
          '• Practice: Prioritize meditation during Brahma Muhurta or evening.\n'
          '• Focus: Maintain silence (Mauna) for 10 minutes today.';
    });
  }

  // Pickers with improved accessibility labels
  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      helpText: 'Select your date of birth',
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      initialDate: _dob ?? DateTime(2000, 1, 1),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      helpText: 'Select your time of birth',
      initialTime: _tob ?? const TimeOfDay(hour: 6, minute: 0),
    );
    if (picked != null) setState(() => _tob = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Astrology & Insights', style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Semantics(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInputFields(),
            const SizedBox(height: 25),
            _buildDateTimeButtons(),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _generateKundli,
              child: const Text('GENERATE INSIGHTS', style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            ),
            if (_result != null) ...[
              const SizedBox(height: 30),
              _buildResultDisplay(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _birthPlaceController,
          decoration: const InputDecoration(
            labelText: 'City of Birth',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickDob,
            icon: const Icon(Icons.calendar_month),
            label: Text(_dob == null ? 'Select Date' : '${_dob!.day}/${_dob!.month}/${_dob!.year}'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.history_toggle_off),
            label: Text(_tob == null ? 'Select Time' : _tob!.format(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildResultDisplay() {
    return Semantics(
      liveRegion: true, // Screen reader will announce when this appears
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kGold.withOpacity(0.5), width: 1.5),
        ),
        child: SelectableText(
          _result!,
          style: GoogleFonts.merriweather(
            fontSize: 16,
            height: 1.8,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
