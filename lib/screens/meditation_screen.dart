// ... (purane imports wahi rahenge)

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  
  // --- NAYA FEATURE: Shanti Music List ---
  final Map<String, String> _shantiMusic = {
    'None': '',
    'Soul Flute': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // Example URL
    'Om Chant': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'Nature Rain': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
  };

  String _selectedMusic = 'None';
  // ---------------------------------------

  final ValueNotifier<int> _secondsLeftNotifier = ValueNotifier<int>(300);
  int _selectedMinutes = 5;
  bool _running = false;
  bool _finished = false;
  
  Timer? _timer;
  DateTime? _endTime;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer(); // Music ke liye alag player
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ... (initState aur dispose wahi rahenge, bas _musicPlayer.dispose() add kar dein)

  void _startStop() async {
    HapticFeedback.mediumImpact();
    if (_running) {
      _timer?.cancel();
      await _musicPlayer.pause(); // Pause music
      WakelockPlus.disable();
      setState(() => _running = false);
    } else {
      WakelockPlus.enable(); 
      
      // Agar music select kiya hai toh play karein
      if (_selectedMusic != 'None') {
        await _musicPlayer.play(UrlSource(_shantiMusic[_selectedMusic]!), volume: 0.5);
        _musicPlayer.setReleaseMode(ReleaseMode.loop); // Music loop mein chalega
      }

      setState(() {
        _running = true;
        _finished = false;
        _endTime = DateTime.now().add(Duration(seconds: _secondsLeftNotifier.value));
      });

      _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (!mounted) return;
        final remaining = _endTime!.difference(DateTime.now()).inSeconds;
        if (remaining <= 0) {
          timer.cancel();
          _onFinish();
        } else {
          _secondsLeftNotifier.value = remaining;
        }
      });
    }
  }

  void _onFinish() async {
    await _musicPlayer.stop(); // Music band
    _playFinishSound(); // Bell bajegi
    WakelockPlus.disable();
    HapticFeedback.heavyImpact();
    
    if (mounted) {
      context.read<AppState>().addMeditationMinutes(_selectedMinutes);
    }
    
    setState(() {
      _running = false;
      _finished = true;
      _secondsLeftNotifier.value = 0;
    });
  }

  // --- UI mein Music Selector add karne ke liye naya widget ---
  Widget _buildMusicSelector(ThemeData theme, Color goldColor) {
    return Column(
      children: [
        Text('SELECT SHANTI MUSIC',
            style: GoogleFonts.cinzel(color: goldColor, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _shantiMusic.keys.map((musicName) {
              final isSelected = _selectedMusic == musicName;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(musicName),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedMusic = musicName);
                  },
                  selectedColor: goldColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: isSelected ? goldColor : theme.hintColor),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goldColor = const Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // ... (AppBar wahi rahega)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // ... (Sanskrit Text wahi rahega)
              const SizedBox(height: 30),
              
              if (!_running && !_finished) ...[
                _buildDurationPicker(theme, goldColor),
                const SizedBox(height: 20),
                _buildMusicSelector(theme, goldColor), // Naya Selector!
              ],
              
              const SizedBox(height: 40),
              if (_finished) _buildFinished(goldColor) else _buildTimerUI(theme, goldColor),
              
              // ... (baaki UI wahi rahega)
            ],
          ),
        ),
      ),
    );
  }
}
