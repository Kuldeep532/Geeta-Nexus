import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'audio/audio_state.dart';
import 'data/gita_data.dart';
import 'state/app_state.dart';
import 'services/sadhana_service.dart';
import 'services/firebase_satsang_service.dart';
import 'services/firebase_core_service.dart';
import 'theme.dart';
import 'widgets/mini_audio_player.dart';
import 'screens/home_screen.dart';
import 'screens/chapters_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/more_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/update_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  final audioState = AudioState();
  final sadhanaService = SadhanaService();
  final satsangService = FirebaseSatsangService();
  final firebaseCore = FirebaseCoreService();

  audioState.initialize();

  // Load local data first (zero data loss guarantee)
  await Future.wait([
    appState.load(),
    loadGitaData(),
    sadhanaService.load(),
  ]);

  // Firebase initialization is non-blocking. If it fails, services
  // gracefully fall back to local storage with zero data loss.
  await firebaseCore.initialize();
  await satsangService.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<AudioState>.value(value: audioState),
        ChangeNotifierProvider<SadhanaService>.value(value: sadhanaService),
        ChangeNotifierProvider<FirebaseSatsangService>.value(value: satsangService),
        ChangeNotifierProvider<FirebaseCoreService>.value(value: firebaseCore),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gita Nexus',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: state.themeMode,
          home: state.onboardingComplete
              ? const MainShell()
              : const OnboardingScreen(),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ChaptersScreen(),
    AiScreen(),
    ProgressScreen(),
    MoreScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.menu_book_outlined),
      activeIcon: Icon(Icons.menu_book_rounded),
      label: 'Chapters',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.auto_awesome_outlined),
      activeIcon: Icon(Icons.auto_awesome_rounded),
      label: 'Ask Ira',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.trending_up_outlined),
      activeIcon: Icon(Icons.trending_up_rounded),
      label: 'Progress',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.apps_outlined),
      activeIcon: Icon(Icons.apps_rounded),
      label: 'More',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => autoCheckForUpdates(context));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniAudioPlayer(),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = i);
            },
            backgroundColor: theme.scaffoldBackgroundColor,
            selectedItemColor: isDark ? kGold : kGoldDim,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: _navItems,
          ),
        ],
      ),
    );
  }
}
