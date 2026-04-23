import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Sahi import path
import 'data/gita_data.dart'; 
import 'state/app_state.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/chapters_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/more_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/update_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final appState = AppState();
  
  // AppState load karna aur CSV se data fetch karna
  await Future.wait([
    appState.load(),
    loadGitaData(), 
  ]);

  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MyApp(showOnboarding: !onboardingCompleted),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final baseLight = buildLightTheme();
        final baseDark = buildTheme();
        final lightTheme = state.highContrast
            ? baseLight.copyWith(
                colorScheme: baseLight.colorScheme.copyWith(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              )
            : baseLight;
        final darkTheme = state.highContrast
            ? baseDark.copyWith(
                colorScheme: baseDark.colorScheme.copyWith(
                  primary: Colors.yellowAccent,
                  onPrimary: Colors.black,
                  surface: Colors.black,
                  onSurface: Colors.white,
                ),
              )
            : baseDark;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bhagavad Gita AI',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: state.themeMode,
          themeAnimationDuration: state.reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 250),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final brightness = Theme.of(context).brightness;
            final isDark = brightness == Brightness.dark;
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
                statusBarBrightness:
                    isDark ? Brightness.dark : Brightness.light,
                systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
                systemNavigationBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
              ),
            );
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(state.largeText ? 1.12 : 1.0),
                highContrast: state.highContrast,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: showOnboarding ? const OnboardingScreen() : const MainShell(),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoCheckForUpdates(context);
    });
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    ChaptersScreen(),
    AiScreen(),
    ProgressScreen(),
    MoreScreen(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Agar user kisi aur tab par hai, toh Back button se Home (0) par le jayein
        setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.dividerColor.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: theme.scaffoldBackgroundColor,
            selectedItemColor: const Color(0xFFFFD700), // Pure Gold color
            unselectedItemColor: theme.hintColor,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: GoogleFonts.cinzel(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
                tooltip: 'Home Screen',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'Chapters', // FIXED: Removed leading comma
                tooltip: 'Gita Chapters',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome),
                label: 'Ask Krishna',
                tooltip: 'AI Spiritual Guide',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up_outlined),
                activeIcon: Icon(Icons.trending_up),
                label: 'Progress',
                tooltip: 'Your Learning Journey',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.apps_outlined),
                activeIcon: Icon(Icons.apps),
                label: 'More',
                tooltip: 'Settings and Extras',
              ),
            ],
          ),
        ),
      ),
    );
  } // FIXED: Properly closed build method and class
}
