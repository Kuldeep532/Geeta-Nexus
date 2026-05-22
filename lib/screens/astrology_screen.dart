import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:india_states_cities/india_states_cities.dart';
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

  factory AstrologyProfile.fromMap(
    Map<String, dynamic> map,
  ) {

    return AstrologyProfile(

      name: map['name'] ?? '',

      state: map['state'] ?? '',

      city: map['city'] ?? '',

      dob: DateTime.parse(
        map['dob'],
      ),

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
  State<AstrologyScreen> createState() =>
      _AstrologyScreenState();
}

class _AstrologyScreenState
    extends State<AstrologyScreen> {

  final TextEditingController _nameController =
      TextEditingController();

  final FocusNode _nameFocusNode =
      FocusNode();

  final ValueNotifier<bool>
      _isGeneratingNotifier =
      ValueNotifier(false);

  AstrologyProfile? _profile;

  DateTime? _dob;

  TimeOfDay? _tob;

  String? _selectedState;

  String? _selectedCity;

  List<String> _states = [];

  List<String> _cities = [];

  final List<String>
      _dailyGuidance = [

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

    _states =
        IndiaStates.getStates();

    _loadProfile();
  }

  bool get _isProfileComplete {

    return _nameController.text
            .trim()
            .isNotEmpty &&
        _selectedState != null &&
        _selectedCity != null &&
        _dob != null &&
        _tob != null;
  }

  Future<void> _loadProfile() async {

    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(
      'astrology_profile',
    );

    if (raw == null) {
      return;
    }

    final profile =
        AstrologyProfile.fromMap(
      jsonDecode(raw),
    );

    _profile = profile;

    _nameController.text =
        profile.name;

    _selectedState =
        profile.state;

    _selectedCity =
        profile.city;

    _dob = profile.dob;

    _tob = profile.tob;

    _cities =
        IndiaStates.getCities(
      profile.state,
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveProfile() async {

    final prefs =
        await SharedPreferences.getInstance();

    final zodiac =
        _calculateZodiac(
      _dob!,
    );

    final profile =
        AstrologyProfile(

      name:
          _nameController.text
              .trim(),

      state:
          _selectedState!,

      city:
          _selectedCity!,

      dob: _dob!,

      tob: _tob!,

      zodiac: zodiac,
    );

    await prefs.setString(

      'astrology_profile',

      jsonEncode(
        profile.toMap(),
      ),
    );

    _profile = profile;

    if (mounted) {
      setState(() {});
    }
  }

  String _calculateZodiac(
    DateTime date,
  ) {

    final month = date.month;
    final day = date.day;

    if ((month == 3 && day >= 21) ||
        (month == 4 && day <= 19)) {
      return 'Aries';
    }

    if ((month == 4 && day >= 20) ||
        (month == 5 && day <= 20)) {
      return 'Taurus';
    }

    if ((month == 5 && day >= 21) ||
        (month == 6 && day <= 20)) {
      return 'Gemini';
    }

    if ((month == 6 && day >= 21) ||
        (month == 7 && day <= 22)) {
      return 'Cancer';
    }

    if ((month == 7 && day >= 23) ||
        (month == 8 && day <= 22)) {
      return 'Leo';
    }

    if ((month == 8 && day >= 23) ||
        (month == 9 && day <= 22)) {
      return 'Virgo';
    }

    if ((month == 9 && day >= 23) ||
        (month == 10 && day <= 22)) {
      return 'Libra';
    }

    if ((month == 10 && day >= 23) ||
        (month == 11 && day <= 21)) {
      return 'Scorpio';
    }

    if ((month == 11 && day >= 22) ||
        (month == 12 && day <= 21)) {
      return 'Sagittarius';
    }

    if ((month == 12 && day >= 22) ||
        (month == 1 && day <= 19)) {
      return 'Capricorn';
    }

    if ((month == 1 && day >= 20) ||
        (month == 2 && day <= 18)) {
      return 'Aquarius';
    }

    return 'Pisces';
  }

  String _dailyMessage() {

    final weekday =
        DateTime.now().weekday;

    return _dailyGuidance[
      weekday %
          _dailyGuidance.length
    ];
  }

  Future<void> _generateKundli() async {

    if (!_isProfileComplete) {

      SemanticsService.announce(
        'Please complete your profile first',
        TextDirection.ltr,
      );

      return;
    }

    FocusScope.of(context).unfocus();

    _isGeneratingNotifier.value =
        true;

    HapticFeedback.lightImpact();

    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );

    _isGeneratingNotifier.value =
        false;

    SemanticsService.announce(
      'Kundli generated successfully',
      TextDirection.ltr,
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openProfileSheet() async {

    await showModalBottomSheet(

      context: context,

      useSafeArea: true,

      isScrollControlled: true,

      showDragHandle: true,

      builder: (context) {

        return StatefulBuilder(

          builder: (
            context,
            setBottomState,
          ) {
