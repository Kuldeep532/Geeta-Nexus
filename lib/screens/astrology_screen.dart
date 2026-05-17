import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

class LocalAstrologyData {
  final String name;
  final String place;
  final DateTime dob;
  final TimeOfDay tob;
  final String zodiacSign;
  final String insights;

  LocalAstrologyData({
    required this.name,
    required this.place,
    required this.dob,
    required this.tob,
    required this.zodiacSign,
    required this.insights,
  });
}

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllStoredData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  Future<void> _loadAllStoredData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('standalone_astro_name') ?? '';
      final savedPlace = prefs.getString('standalone_astro_place') ?? '';
      final savedDobStr = prefs.getString('standalone_astro_dob');
      final savedTobHour = prefs.getInt('standalone_astro_tob_hour');
      final savedTobMin = prefs.getInt('standalone_astro_tob_min');

      if (mounted) {
        setState(() {
          _nameController.text = savedName;
          _birthPlaceController.text = savedPlace;
          if (savedDobStr != null) {
            _dob = DateTime.tryParse(savedDobStr);
          }
          if (savedTobHour != null && savedTobMin != null) {
            _tob = TimeOfDay(hour: savedTobHour, minute: savedTobMin);
          }
        });
      }
    } catch (e) {
      debugPrint('Storage loading error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCurrentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('standalone_astro_name', _nameController.text.trim());
      await prefs.setString('standalone_astro_place', _birthPlaceController.text.trim());
      if (_dob != null) {
        await prefs.setString('standalone_astro_dob', _dob!.toIso8601String());
      }
      if (_tob != null) {
        await prefs.setInt('standalone_astro_tob_hour', _tob!.hour);
        await prefs.setInt('standalone_astro_tob_min', _tob!.minute);
      }
    } catch (e) {
      debugPrint('Storage saving error: $e');
    }
  }

  String _calculateInternalZodiac(DateTime d) {
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

  String _getInternalInsight(String sign) {
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

  void _processSelfSustainedInsights() {
    HapticFeedback.mediumImpact();
    if (_dob == null || _tob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both Birth Date and Time')),
      );
      return;
    }

    final sign = _calculateInternalZodiac(_dob!);
    final name = _nameController.text.trim().isEmpty ? 'Seeker' : _nameController.text.trim();
    final city = _birthPlaceController.text.trim().isEmpty ? 'Unknown' : _birthPlaceController.text.trim();

    final localData = LocalAstrologyData(
      name: name,
      place: city,
      dob: _dob!,
      tob: _tob!,
      zodiacSign: sign,
      insights: _getInternalInsight(sign),
    );

    _saveCurrentData();

    setState(() {
      _result = 'Kundli Summary for ${localData.name}\n'
          '----------------------------------\n'
          'Birth: ${localData.dob.day}/${localData.dob.month}/${localData.dob.year} at ${localData.tob.format(context)}\n'
          'Place: ${localData.place}\n'
          'Zodiac: ${localData.zodiacSign}\n\n'
          '${localData.insights}\n\n'
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Semantics(
          header: true,
          label: 'Astrology and Spiritual Insights Page',
          child: Text(
            'ASTROLOGY & INSIGHTS', 
            style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold, letterSpacing: 1.5)
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: kGold))
          : ListView(
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
                
                Semantics(
                  button: true,
                  label: 'Generate Insights Button',
                  hint: 'Double tap to calculate zodiac sign and save your details locally',
                  excludeSemantics: true,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: _processSelfSustainedInsights,
                    child: const Text('GENERATE INSIGHTS', 
                      style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
                  ),
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
          textInputAction: TextInputAction.next,
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
          textInputAction: TextInputAction.done,
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
    final String dateLabel = _dob == null ? 'Not Selected' : '${_dob!.day}/${_dob!.month}/${_dob!.year}';
    final String timeLabel = _tob == null ? 'Not Selected' : _tob!.format(context);

    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: 'Birth Date Selector. Current value: $dateLabel',
            hint: 'Double tap to open calendar dialog',
            excludeSemantics: true,
            child: OutlinedButton.icon(
              onPressed: _pickDob,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _dob == null ? theme.dividerColor : kGold),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: const Icon(Icons.calendar_month, color: kGold, size: 20),
              label: Text(
                _dob == null ? 'Select Date' : dateLabel,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            button: true,
            label: 'Birth Time Selector. Current value: $timeLabel',
            hint: 'Double tap to open time picker dialog',
            excludeSemantics: true,
            child: OutlinedButton.icon(
              onPressed: _pickTime,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _tob == null ? theme.dividerColor : kGold),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: const Icon(Icons.history_toggle_off, color: kGold, size: 20),
              label: Text(
                _tob == null ? 'Select Time' : timeLabel,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultDisplay(ThemeData theme) {
    return Semantics(
      liveRegion: true,
      label: "Astrology Output Box",
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
                color: theme.textTheme.bodyLarge?.color,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
