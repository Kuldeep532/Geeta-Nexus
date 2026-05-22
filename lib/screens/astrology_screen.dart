import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:india_states_cities/india_states_cities.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

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

  DateTime? _dob;

  TimeOfDay? _tob;

  String? _selectedState;

  String? _selectedCity;

  String? _result;

  bool _profileAdded = false;

  bool _isGenerating = false;

  List<String> _states = [];

  List<String> _cities = [];

  @override
  void initState() {
    super.initState();

    _states =
        IndiaStates.getStates();

    _loadProfile();
  }

  Future<void> _loadProfile() async {

    final prefs =
        await SharedPreferences.getInstance();

    _nameController.text =
        prefs.getString('name') ?? '';

    _selectedState =
        prefs.getString('state');

    _selectedCity =
        prefs.getString('city');

    final dob =
        prefs.getString('dob');

    if (dob != null) {
      _dob = DateTime.tryParse(
        dob,
      );
    }

    final hour =
        prefs.getInt('hour');

    final minute =
        prefs.getInt('minute');

    if (hour != null &&
        minute != null) {

      _tob = TimeOfDay(
        hour: hour,
        minute: minute,
      );
    }

    if (_selectedState != null) {

      _cities =
          IndiaStates.getCities(
        _selectedState!,
      );
    }

    setState(() {

      _profileAdded =
          _nameController.text
              .trim()
              .isNotEmpty;
    });
  }

  Future<void> _saveProfile() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'name',
      _nameController.text.trim(),
    );

    await prefs.setString(
      'state',
      _selectedState!,
    );

    await prefs.setString(
      'city',
      _selectedCity!,
    );

    await prefs.setString(
      'dob',
      _dob!.toIso8601String(),
    );

    await prefs.setInt(
      'hour',
      _tob!.hour,
    );

    await prefs.setInt(
      'minute',
      _tob!.minute,
    );

    setState(() {
      _profileAdded = true;
    });
  }

  bool get _canGenerate {

    return _nameController.text
            .trim()
            .isNotEmpty &&
        _selectedState != null &&
        _selectedCity != null &&
        _dob != null &&
        _tob != null;
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

  Future<void> _generateKundli() async {

    if (!_canGenerate ||
        _isGenerating) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isGenerating = true;
    });

    HapticFeedback.lightImpact();

    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );

    final zodiac =
        _calculateZodiac(
      _dob!,
    );

    final generatedResult = '''
Kundli Summary

Name
${_nameController.text.trim()}

State
$_selectedState

City
$_selectedCity

Date of Birth
${_dob!.day}/${_dob!.month}/${_dob!.year}

Birth Time
${_tob!.format(context)}

Zodiac Sign
$zodiac

Daily Guidance

• Stay positive
• Focus on self growth
• Avoid unnecessary stress
• Good opportunities may arrive soon
''';

    setState(() {

      _result =
          generatedResult;

      _isGenerating = false;
    });

    SemanticsService.announce(
      'Kundli generated successfully',
      TextDirection.ltr,
    );
  }

  Future<void> _openProfileSheet() async {

    await showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      useSafeArea: true,

      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top:
              Radius.circular(
            28,
          ),
        ),
      ),

      builder: (context) {

        return StatefulBuilder(

          builder: (
            context,
            setBottomState,
          ) {

            return Padding(

              padding:
                  EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(
                          context,
                        )
                        .viewInsets
                        .bottom +
                    20,
              ),

              child:
                  SingleChildScrollView(

                physics:
                    const BouncingScrollPhysics(),

                child: Column(

                  mainAxisSize:
                      MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Center(
                      child: Container(
                        width: 56,
                        height: 5,

                        decoration:
                            BoxDecoration(
                          color:
                              Theme.of(
                            context,
                          ).dividerColor,

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Semantics(

                      header: true,

                      child: Text(

                        _profileAdded
                            ? 'Edit Profile'
                            : 'Add Profile',

                        style:
                            Theme.of(
                          context,
                        )
                                .textTheme
                                .headlineSmall,
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Semantics(

                      label:
                          'Enter your full name',

                      textField: true,

                      child: TextField(

                        controller:
                            _nameController,

                        focusNode:
                            _nameFocusNode,

                        textCapitalization:
                            TextCapitalization
                                .words,

                        decoration:
                            InputDecoration(
                          labelText:
                              'Full Name',

                          hintText:
                              'Enter your full name',

                          prefixIcon:
                              const Icon(
                            Icons.person_outline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _selectionTile(

                      context: context,

                      title:
                          _selectedState ??
                              'Select State',

                      icon:
                          Icons.map_outlined,

                      semanticLabel:
                          'Select state',

                      onTap: () async {

                        final state =
                            await _showSelectionSheet(
                          context:
                              context,

                          title:
                              'Select State',

                          items:
                              _states,
                        );

                        if (state != null) {

                          setBottomState(() {

                            _selectedState =
                                state;

                            _selectedCity =
                                null;

                            _cities =
                                IndiaStates
                                    .getCities(
                              state,
                            );
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _selectionTile(

                      context: context,

                      title:
                          _selectedCity ??
                              'Select City',

                      icon:
                          Icons.location_city_outlined,

                      semanticLabel:
                          'Select city',

                      onTap: () async {

                        if (_selectedState ==
                            null) {

                          SemanticsService
                              .announce(
                            'Please select state first',
                            TextDirection.ltr,
                          );

                          return;
                        }

                        final city =
                            await _showSelectionSheet(
                          context:
                              context,

                          title:
                              'Select City',

                          items:
                              _cities,
                        );

                        if (city != null) {

                          setBottomState(() {
                            _selectedCity =
                                city;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _selectionTile(

                      context: context,

                      title:
                          _dob == null
                              ? 'Select Birth Date'
                              : '${_dob!.day}/${_dob!.month}/${_dob!.year}',

                      icon:
                          Icons.calendar_today_outlined,

                      semanticLabel:
                          'Select birth date',

                      onTap: () async {

                        final picked =
                            await showDatePicker(
                          context:
                              context,

                          firstDate:
                              DateTime(
                            1950,
                          ),

                          lastDate:
                              DateTime.now(),

                          initialDate:
                              _dob ??
                                  DateTime(
                                    2000,
                                  ),
                        );

                        if (picked != null) {

                          setBottomState(() {
                            _dob = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _selectionTile(

                      context: context,

                      title:
                          _tob == null
                              ? 'Select Birth Time'
                              : _tob!.format(
                                  context,
                                ),

                      icon:
                          Icons.access_time_outlined,

                      semanticLabel:
                          'Select birth time',

                      onTap: () async {

                        final picked =
                            await showTimePicker(
                          context:
                              context,

                          initialTime:
                              _tob ??
                                  const TimeOfDay(
                                    hour: 6,
                                    minute: 0,
                                  ),
                        );

                        if (picked != null) {

                          setBottomState(() {
                            _tob = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    SizedBox(

                      width:
                          double.infinity,

                      height: 56,

                      child:
                          FilledButton(

                        onPressed: () async {

                          if (!_canGenerate) {

                            SemanticsService
                                .announce(
                              'Please complete all profile fields',
                              TextDirection.ltr,
                            );

                            return;
                          }

                          await _saveProfile();

                          if (!mounted) {
                            return;
                          }

                          Navigator.pop(
                            context,
                          );

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(

                            SnackBar(

                              behavior:
                                  SnackBarBehavior
                                      .floating,

                              content: Text(

                                _profileAdded
                                    ? 'Profile updated successfully'
                                    : 'Profile added successfully',
                              ),
                            ),
                          );
                        },

                        child: Text(

                          _profileAdded
                              ? 'Update Profile'
                              : 'Save Profile',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _showSelectionSheet({

    required BuildContext context,

    required String title,

    required List<String> items,
  }) async {

    return showModalBottomSheet<String>(

      context: context,

      useSafeArea: true,

      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top:
              Radius.circular(
            28,
          ),
        ),
      ),

      builder: (context) {

        return Column(

          children: [

            const SizedBox(
              height: 16,
            ),

            Container(
              width: 56,
              height: 5,

              decoration:
                  BoxDecoration(
                color:
                    Theme.of(
                  context,
                ).dividerColor,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Semantics(

              header: true,

              child: Text(

                title,

                style:
                    Theme.of(context)
                        .textTheme
                        .titleLarge,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Expanded(

              child:
                  ListView.builder(

                physics:
                    const BouncingScrollPhysics(),

                itemCount:
                    items.length,

                itemBuilder:
                    (context, index) {

                  final item =
                      items[index];

                  return Semantics(

                    button: true,

                    label: item,

                    child: ListTile(

                      title: Text(
                        item,
                      ),

                      onTap: () {

                        HapticFeedback
                            .selectionClick();

                        Navigator.pop(
                          context,
                          item,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _selectionTile({

    required BuildContext context,

    required String title,

    required IconData icon,

    required String semanticLabel,

    required VoidCallback onTap,
  }) {

    return Semantics(

      button: true,

      label:
          semanticLabel,

      child: InkWell(

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        onTap: onTap,

        child: Ink(

          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),

          decoration:
              BoxDecoration(

            color:
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,

            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),

          child: Row(

            children: [

              Icon(icon),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Text(
                  title,
                ),
              ),

              const Icon(
                Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {

    _nameController.dispose();

    _nameFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Astrology',
        ),

        actions: [

          Semantics(

            button: true,

            label:
                _profileAdded
                    ? 'Edit profile'
                    : 'Add profile',

            child: IconButton(

              onPressed:
                  _openProfileSheet,

              icon: Icon(

                _profileAdded
                    ? Icons.edit_outlined
                    : Icons.person_add_alt_1_outlined,
              ),
            ),
          ),
        ],
      ),

      body:
          SafeArea(

        child:
            SingleChildScrollView(

          physics:
              const BouncingScrollPhysics(),

          padding:
              const EdgeInsets.all(
            20,
          ),

          child: Column(

            children: [

              Semantics(

                container: true,

                label:
                    'Profile information card',

                child: Card(

                  elevation: 0,

                  child: Padding(

                    padding:
                        const EdgeInsets.all(
                      20,
                    ),

                    child: Row(

                      children: [

                        CircleAvatar(

                          radius: 28,

                          child: Text(

                            _nameController
                                    .text
                                    .isEmpty
                                ? 'A'
                                : _nameController
                                    .text[0]
                                    .toUpperCase(),
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(

                                _profileAdded
                                    ? _nameController
                                        .text
                                    : 'No Profile Added',

                                style:
                                    theme
                                        .textTheme
                                        .titleMedium,
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(

                                _profileAdded
                                    ? 'Profile ready'
                                    : 'Please add your profile',
                              ),
                            ],
                          ),
                        ),

                        FilledButton(

                          onPressed:
                              _openProfileSheet,

                          child: Text(

                            _profileAdded
                                ? 'Edit'
                                : 'Add',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              Semantics(

                button: true,

                enabled:
                    _canGenerate,

                label:
                    'Generate Kundli',

                child: SizedBox(

                  width:
                      double.infinity,

                  height: 56,

                  child:
                      FilledButton(

                    onPressed:
                        _canGenerate
                            ? _generateKundli
                            : null,

                    child:
                        _isGenerating

                            ? const SizedBox(
                                width: 24,
                                height: 24,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )

                            : const Text(
                                'Generate Kundli',
                              ),
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              if (_result != null)

                Semantics(

                  liveRegion: true,

                  label:
                      'Generated kundli result',

                  child: Card(

                    elevation: 0,

                    child: Padding(

                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      child: SelectableText(

                        _result!,

                        style:
                            theme
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                          height: 1.7,
                        ),
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
}
