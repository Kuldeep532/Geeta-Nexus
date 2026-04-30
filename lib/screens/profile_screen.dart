import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loggingOut = false;

  Future<void> _logout(BuildContext context) async {
    final appState = context.read<AppState>();
    setState(() => _loggingOut = true);
    if (appState.isGoogleAccountLinked) {
      try {
        await GoogleSignIn(scopes: ['email']).signOut();
      } catch (_) {
        // Ignore sign-out transport/platform errors and continue local cleanup.
      }
    }

    if (!mounted) return;
    appState.clearLinkedAccount();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out from linked account.')),
    );
    setState(() => _loggingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outline.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(state.userName.isEmpty ? 'Guest User' : state.userName,
                    style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  state.userEmail.isEmpty ? 'No email linked' : state.userEmail,
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 6),
                Text(
                  state.isGoogleAccountLinked
                      ? 'Google account linked'
                      : state.isEmailAccountLinked
                          ? 'Email account linked'
                          : 'Local profile only',
                  style: TextStyle(
                    color: state.isGoogleAccountLinked
                        ? Colors.green
                        : state.isEmailAccountLinked
                            ? cs.primary
                            : cs.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: (state.isGoogleAccountLinked || state.isEmailAccountLinked) && !_loggingOut
                ? () => _logout(context)
                : null,
            icon: _loggingOut
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: Text(_loggingOut ? 'Logging out...' : 'Logout Account'),
          ),
        ],
      ),
    );
  }
}
