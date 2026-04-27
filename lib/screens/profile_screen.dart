import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    setState(() => _loggingOut = true);
    try {
      await GoogleSignIn(scopes: ['email']).signOut();
    } catch (_) {}

    if (!mounted) return;
    // AppState mein clear logic hona chahiye
    // context.read<AppState>().logout(); 
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saffalta purvak logout ho gaya.')),
    );
    setState(() => _loggingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = isDark ? const Color(0xFFFFD700) : const Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- User Info Card ---
          _buildInfoCard(state, goldColor, theme),
          
          const SizedBox(height: 24),

          // --- ADMIN SECTION (Visible only to Kuldeep) ---
          if (state.isAdmin) _buildAdminSection(state, goldColor, theme),

          const SizedBox(height: 24),

          // --- App Stats ---
          _buildStatRow(Icons.bolt, "Level", "${state.level}", goldColor),
          _buildStatRow(Icons.local_fire_department, "Streak", "${state.streak} Days", Colors.orange),

          const SizedBox(height: 32),

          // --- Logout Button ---
          Semantics(
            label: "App se logout karein",
            child: ElevatedButton.icon(
              onPressed: (state.userName.isNotEmpty) && !_loggingOut ? () => _logout(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                elevation: 0,
              ),
              icon: _loggingOut 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                  : const Icon(Icons.logout),
              label: Text(_loggingOut ? 'Logging out...' : 'Logout Account'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppState state, Color gold, ThemeData theme) {
    return Semantics(
      label: "User account information",
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: gold.withOpacity(0.1),
              child: Text(state.userName.isNotEmpty ? state.userName[0].toUpperCase() : "?", 
                  style: TextStyle(fontSize: 32, color: gold, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Text(state.userName.isEmpty ? 'Guest Seeker' : state.userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(state.userEmail.isEmpty ? 'No email linked' : state.userEmail,
                style: TextStyle(color: theme.hintColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSection(AppState state, Color gold, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.admin_panel_settings, color: gold),
            const SizedBox(width: 8),
            Text("ADMIN CONTROL", style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: gold)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: gold.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: gold.withOpacity(0.5))),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notification_add, color: Colors.blue),
                title: const Text("Send Global Notification"),
                onTap: () => _showNotificationDialog(state),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.green),
                title: const Text("Manage Users (Coming Soon)"),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showNotificationDialog(AppState state) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Broadcast Message"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: "Title")),
            TextField(controller: bodyCtrl, decoration: const InputDecoration(hintText: "Message Body")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              state.sendGlobalNotification(title: titleCtrl.text, body: bodyCtrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notification sent!")));
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}
