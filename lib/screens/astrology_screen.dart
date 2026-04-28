import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart'; // Ensure kGold, kTextDim, etc., are defined here

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

  // Western Zodiac Calculation with Vedic names
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
    HapticFeedback.mediumImpact();
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

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      helpText: 'Select your date of birth',
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      initialDate: _dob ?? DateTime(2000, 1, 1),
      builder: (context, child) => _buildPickerTheme(child!),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      helpText: 'Select your time of birth',
      initialTime: _tob ?? const TimeOfDay(hour: 6, minute: 0),
      builder: (context, child) => _buildPickerTheme(child!),
    );
    if (picked != null) setState(() => _tob = picked);
  }

  Widget _buildPickerTheme(Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kGold,
          primary: kGold,
          onPrimary: Colors.black,
          surface: Theme.of(context).cardColor,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('ASTROLOGY & INSIGHTS', 
          style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            Text(
              "Know your celestial alignment and daily spiritual focus.",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor, fontSize: 14),
            ),
            const SizedBox(height: 30),
            _buildInputFields(theme),
            const SizedBox(height: 25),
            _buildDateTimeButtons(theme),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              onPressed: _generateKundli,
              child: const Text('GENERATE INSIGHTS', 
                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
            ),
            if (_result != null) ...[
              const SizedBox(height: 40),
              _buildResultDisplay(theme),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields(ThemeData theme) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            labelText: 'Full Name',
            labelStyle: TextStyle(color: kGold.withOpacity(0.8)),
            prefixIcon: const Icon(Icons.person_outline, color: kGold),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: kGold, width: 2)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _birthPlaceController,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            labelText: 'City of Birth',
            labelStyle: TextStyle(color: kGold.withOpacity(0.8)),
            prefixIcon: const Icon(Icons.location_city, color: kGold),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: kGold, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickDob,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _dob == null ? theme.dividerColor : kGold),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            icon: const Icon(Icons.calendar_month, color: kGold, size: 20),
            label: Text(
              _dob == null ? 'Select Date' : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickTime,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _tob == null ? theme.dividerColor : kGold),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            icon: const Icon(Icons.history_toggle_off, color: kGold, size: 20),
            label: Text(
              _tob == null ? 'Select Time' : _tob!.format(context),
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultDisplay(ThemeData theme) {
    return Semantics(
      liveRegion: true,
      label: "Your Kundli Insights generated below",
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGold.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, spreadRadius: 2)
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome, color: kGold, size: 30),
            const SizedBox(height: 15),
            SelectableText(
              _result!,
              textAlign: TextAlign.left,
              style: GoogleFonts.merriweather(
                fontSize: 15,
                height: 1.8,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
