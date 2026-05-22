import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

import 'about_screen.dart';
import 'contact_screen.dart';
import 'privacy_policy_screen.dart';
import 'profile_screen.dart';
import 'terms_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _version = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      if (!mounted) return;

      setState(() {
        _version =
            'Version ${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _version = 'Version unavailable';
      });
    }
  }

  void _openThemeSelector(
    BuildContext context,
    AppState appState,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: false,
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _themeTile(
                context,
                title: 'Use System Theme',
                icon: Icons.brightness_auto_rounded,
                onTap: () {
                  appState.updateTheme(
                    ThemeMode.system,
                  );

                  Navigator.pop(context);
                },
              ),
              _themeTile(
                context,
                title: 'Light Theme',
                icon: Icons.light_mode_rounded,
                onTap: () {
                  appState.updateTheme(
                    ThemeMode.light,
                  );

                  Navigator.pop(context);
                },
              ),
              _themeTile(
                context,
                title: 'Dark Theme',
                icon: Icons.dark_mode_rounded,
                onTap: () {
                  appState.updateTheme(
                    ThemeMode.dark,
                  );

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _themeTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        container: true,
        button: true,
        enabled: true,
        label: title,
        hint: 'Double tap to apply theme',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color: kGold.withOpacity(0.14),
                ),
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      icon,
                      color: kGold,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        title,
                        style: GoogleFonts.lato(
                          fontWeight:
                              FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final List<_MenuItem> items = [
      _MenuItem(
        title: 'Profile',
        subtitle:
            'Manage your profile and preferences',
        icon: Icons.person_outline_rounded,
        screen: const ProfileScreen(),
      ),
      _MenuItem(
        title: 'About',
        subtitle:
            'Learn more about this application',
        icon: Icons.info_outline_rounded,
        screen: const AboutUsScreen(),
      ),
      _MenuItem(
        title: 'Privacy Policy',
        subtitle:
            'Read privacy and security information',
        icon: Icons.privacy_tip_outlined,
        screen: const PrivacyPolicyScreen(),
      ),
      _MenuItem(
        title: 'Terms & Conditions',
        subtitle:
            'View terms and conditions of use',
        icon: Icons.description_outlined,
        screen:
            const TermsAndConditionsScreen(),
      ),
      _MenuItem(
        title: 'Contact',
        subtitle:
            'Get support and contact details',
        icon: Icons.mail_outline_rounded,
        screen: const ContactUsScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor:
            colorScheme.background,
        surfaceTintColor: Colors.transparent,
        title: Semantics(
          header: true,
          namesRoute: true,
          child: ExcludeSemantics(
            child: Text(
              'Explore',
              style: GoogleFonts.cinzel(
                color: kGold,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.3,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: 8),
            child: Semantics(
              button: true,
              enabled: true,
              label: 'Theme settings',
              hint:
                  'Double tap to change application theme',
              child: IconButton(
                tooltip: 'Theme Settings',
                splashRadius: 24,
                onPressed: () {
                  _openThemeSelector(
                    context,
                    appState,
                  );
                },
                icon: const Icon(
                  Icons.palette_outlined,
                  color: kGold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics:
              const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding:
                  const EdgeInsets.all(18),
              sliver: SliverList(
                delegate:
                    SliverChildListDelegate(
                  [
                    _buildProfileCard(
                      context,
                      appState,
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    const _SectionHeader(
                      title:
                          'Support & Information',
                    ),

                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              sliver: SliverGrid(
                delegate:
                    SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildMenuCard(
                      context,
                      items[index],
                    );
                  },
                  childCount: items.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.94,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 34,
                ),
                child: Semantics(
                  label: _version,
                  readOnly: true,
                  child: Center(
                    child: ExcludeSemantics(
                      child: Text(
                        _version,
                        style:
                            GoogleFonts.lato(
                          fontSize: 13,
                          color: isDark
                              ? Colors
                                  .white60
                              : Colors
                                  .black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    AppState appState,
  ) {
    final theme = Theme.of(context);

    final userName =
        appState.userName.trim().isEmpty
            ? 'Guest User'
            : appState.userName.trim();

    final userEmail =
        appState.userEmail.trim().isEmpty
            ? 'Welcome to your account'
            : appState.userEmail.trim();

    return RepaintBoundary(
      child: Semantics(
        container: true,
        button: true,
        enabled: true,
        label:
            'Profile section. User name $userName. Email $userEmail',
        hint:
            'Double tap to open profile screen',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ProfileScreen(),
                ),
              );
            },
            borderRadius:
                BorderRadius.circular(28),
            child: Ink(
              padding: const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    BorderRadius.circular(28),
                border: Border.all(
                  color:
                      kGold.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 14,
                    spreadRadius: 0,
                    offset:
                        const Offset(0, 5),
                    color: Colors.black
                        .withOpacity(
                      theme.brightness ==
                              Brightness.dark
                          ? 0.16
                          : 0.04,
                    ),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: kGold,
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      alignment:
                          Alignment.center,
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.black,
                        size: 34,
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child:
                        ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                GoogleFonts
                                    .lato(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize:
                                  18,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            userEmail,
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: theme
                                .textTheme
                                .bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const ExcludeSemantics(
                    child: Icon(
                      Icons
                          .arrow_forward_ios_rounded,
                      color: kGold,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    _MenuItem item,
  ) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Semantics(
        container: true,
        button: true,
        enabled: true,
        label: item.title,
        hint: item.subtitle,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.circular(26),
            onTap: () {
              if (!mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      item.screen,
                ),
              );
            },
            child: Ink(
              padding: const EdgeInsets.all(
                18,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    BorderRadius.circular(26),
                border: Border.all(
                  color: theme
                      .dividerColor
                      .withOpacity(0.08),
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration:
                          BoxDecoration(
                        color: kGold
                            .withOpacity(
                          0.10,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                      alignment:
                          Alignment.center,
                      child: Icon(
                        item.icon,
                        size: 28,
                        color: kGold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  ExcludeSemantics(
                    child: Text(
                      item.title,
                      textAlign:
                          TextAlign.center,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          GoogleFonts.lato(
                        fontWeight:
                            FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader
    extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: ExcludeSemantics(
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.cinzel(
            color: kGold,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.3,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

@immutable
class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget screen;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screen,
  });
}
