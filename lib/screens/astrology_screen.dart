import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

class AstrologyProfile {
  final String name;
  final String state;
  final String city;
  final DateTime dob;
  final TimeOfDay tob;
  final String zodiac;

  const AstrologyProfile({
    required this.name,
    required this.state,
    required this.city,
    required this.dob,
    required this.tob,
    required this.zodiac,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'state': state,
      'city': city,
      'dob': dob.toIso8601String(),
      'hour': tob.hour,
      'minute': tob.minute,
      'zodiac': zodiac,
    };
  }

  factory AstrologyProfile.fromMap(Map<String, dynamic> map) {
    return AstrologyProfile(
      name: map['name'] ?? '',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      dob: DateTime.parse(map['dob']),
      tob: TimeOfDay(
        hour: map['hour'],
        minute: map['minute'],
      ),
      zodiac: map['zodiac'] ?? '',
    );
  }
}

class AstrologyScreen extends StatefulWidget {
  const AstrologyScreen({super.key});

  @override
  State<AstrologyScreen> createState() => _AstrologyScreenState();
}

class _AstrologyScreenState extends State<AstrologyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final ValueNotifier<bool> _isGeneratingNotifier = ValueNotifier(false);

  AstrologyProfile? _profile;
  DateTime? _dob;
  TimeOfDay? _tob;
  String? _selectedState;
  String? _selectedCity;

  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Delhi', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh',
    'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra',
    'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha',
    'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  ];

  List<String> _cities = [];

  final Map<String, List<String>> _stateCities = {
    'Chhattisgarh': ['Raipur', 'Bilaspur', 'Durg', 'Bhilai', 'Korba'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'],
    'Delhi': ['New Delhi', 'Noida', 'Dwarka', 'Rohini'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota'],
    'Uttar Pradesh': ['Lucknow', 'Varanasi', 'Agra', 'Prayagraj', 'Kanpur'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Hubli', 'Mangaluru'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol'],
    'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur'],
    'Punjab': ['Chandigarh', 'Amritsar', 'Ludhiana', 'Jalandhar'],
    'Haryana': ['Gurugram', 'Faridabad', 'Panipat', 'Ambala'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur'],
    'Bihar': ['Patna', 'Gaya', 'Muzaffarpur', 'Bhagalpur'],
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Tirupati', 'Guntur'],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri'],
    'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro'],
    'Assam': ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat'],
  };

  final List<String> _dailyGuidance = [
    'Stay calm and focused',
    'Good opportunities may arrive today',
    'Take care of your emotional energy',
    'Avoid unnecessary stress',
    'Positive communication will help today',
    'Focus on self growth and balance',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _isGeneratingNotifier.dispose();
    super.dispose();
  }

  bool get _isProfileComplete {
    return _nameController.text.trim().isNotEmpty &&
        _selectedState != null &&
        _selectedCity != null &&
        _dob != null &&
        _tob != null;
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('astrology_profile');
    if (raw == null) return;

    try {
      final profile = AstrologyProfile.fromMap(jsonDecode(raw));
      _profile = profile;
      _nameController.text = profile.name;
      _selectedState = profile.state;
      _selectedCity = profile.city;
      _dob = profile.dob;
      _tob = profile.tob;
      _cities = _stateCities[profile.state] ?? [];
    } catch (_) {}

    if (mounted) setState(() {});
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final zodiac = _calculateZodiac(_dob!);
    final profile = AstrologyProfile(
      name: _nameController.text.trim(),
      state: _selectedState!,
      city: _selectedCity!,
      dob: _dob!,
      tob: _tob!,
      zodiac: zodiac,
    );
    await prefs.setString('astrology_profile', jsonEncode(profile.toMap()));
    _profile = profile;
    if (mounted) setState(() {});
  }

  String _calculateZodiac(DateTime date) {
    final month = date.month;
    final day = date.day;
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

  String _dailyMessage() {
    final weekday = DateTime.now().weekday;
    return _dailyGuidance[weekday % _dailyGuidance.length];
  }

  Future<void> _generateKundli() async {
    if (!_isProfileComplete) {
      
      return;
    }
    FocusScope.of(context).unfocus();
    _isGeneratingNotifier.value = true;
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 500));
    _isGeneratingNotifier.value = false;
    
    if (mounted) setState(() {});
  }

  Future<void> _openProfileSheet() async {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Birth Details',
                    style: GoogleFonts.cinzel(
                      color: kGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(labelText: 'State'),
                    items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      setBottomState(() {
                        _selectedState = val;
                        _selectedCity = null;
                        _cities = _stateCities[val] ?? [];
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(labelText: 'City'),
                    items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setBottomState(() => _selectedCity = val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_dob == null
                              ? 'Date of Birth'
                              : '${_dob!.day}/${_dob!.month}/${_dob!.year}'),
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _dob ?? DateTime(1990),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) setBottomState(() => _dob = date);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(_tob == null
                              ? 'Time of Birth'
                              : _tob!.format(context)),
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _tob ?? TimeOfDay.now(),
                            );
                            if (time != null) setBottomState(() => _tob = time);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGold,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isProfileComplete
                          ? () async {
                              HapticFeedback.lightImpact();
                              await _saveProfile();
                              if (mounted) Navigator.pop(context);
                            }
                          : null,
                      child: const Text('Save Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasProfile = _profile != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Jyotish Kundli', style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, color: kGold),
            onPressed: () {
              HapticFeedback.lightImpact();
              _openProfileSheet();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!hasProfile) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGold.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, color: kGold, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Set Up Your Kundli',
                      style: GoogleFonts.cinzel(color: kGold, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your birth details to generate your personalized Vedic astrology chart.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.crimsonText(color: isDark ? kTextDim : Colors.grey[600], fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Enter Birth Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGold,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
              HapticFeedback.lightImpact();
              _openProfileSheet();
            },
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGold.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: kGold),
                        const SizedBox(width: 8),
                        Text(_profile!.name, style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${_profile!.city}, ${_profile!.state}', style: GoogleFonts.crimsonText(fontSize: 14)),
                    Text(
                      '${_profile!.dob.day}/${_profile!.dob.month}/${_profile!.dob.year}  •  ${_profile!.tob.format(context)}',
                      style: GoogleFonts.crimsonText(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: kGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kGold.withOpacity(0.3)),
                      ),
                      child: Text(
                        '♈ ${_profile!.zodiac}',
                        style: GoogleFonts.cinzel(color: kGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kSaffron.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Guidance', style: GoogleFonts.cinzel(color: kSaffron, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(_dailyMessage(), style: GoogleFonts.crimsonText(fontSize: 16, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: _isGeneratingNotifier,
                builder: (_, isGenerating, __) {
                  return ElevatedButton.icon(
                    icon: isGenerating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.auto_awesome),
                    label: Text(isGenerating ? 'Generating...' : 'Generate Kundli'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGold,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: isGenerating ? null : () {
                      HapticFeedback.lightImpact();
                      _generateKundli();
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
