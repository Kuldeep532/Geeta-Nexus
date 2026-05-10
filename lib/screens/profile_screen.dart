import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      await _googleSignIn.signOut();
      final state = Provider.of<AppState>(context, listen: false);
      state.updateGoogleAccount(name: '', email: '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saffalta purvak logout ho gaya.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editNameDialog(BuildContext context, AppState state) async {
    final ctrl = TextEditingController(text: state.userName.isEmpty ? 'Seeker' : state.userName);
    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );

    if (!mounted || updated == null || updated.isEmpty) return;
    state.setUserName(updated);
    if (state.userEmail.isNotEmpty) {
      state.updateGoogleAccount(name: updated, email: state.userEmail);
    }
  }


  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final accentColor = kGold;
    final bool isSuperAdmin = state.isSuperAdmin;
    final bool isAdmin = state.isAdmin;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile Hub', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: accentColor)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          _buildInfoCard(state, accentColor, theme, isSuperAdmin, isAdmin),
          const SizedBox(height: 32),
          _buildSectionTitle('YOUR PROGRESS', accentColor),
          _buildStatRow(Icons.bolt, 'Level', '${state.level}', accentColor),
          _buildStatRow(Icons.local_fire_department, 'Streak', '${state.streak} Days', Colors.orange),
          const SizedBox(height: 32),
          if (isAdmin) ...[
            const SizedBox(height: 32),
            _buildSectionTitle('ADMIN CONTROLS', accentColor),
            _buildAdminDashboardEntry(context, accentColor),
          ],
          const SizedBox(height: 16),
          _buildAuthButton(state, accentColor),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(title, style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2)),
      );

  Widget _buildInfoCard(AppState state, Color gold, ThemeData theme, bool isSuper, bool isAdmin) {
    String roleLabel = 'SEEKER';
    Color roleColor = Colors.grey;
    if (isSuper) {
      roleLabel = 'SUPER ADMIN';
      roleColor = Colors.redAccent;
    } else if (isAdmin) {
      roleLabel = 'ADMIN';
      roleColor = gold;
    }

    return Semantics(
      container: true,
      label: 'Profile information card',
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: gold.withOpacity(0.1),
              child: Text(state.userName.isNotEmpty ? state.userName[0].toUpperCase() : 'G', style: TextStyle(color: gold, fontSize: 30, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Text(state.userName.isEmpty ? 'Guest Seeker' : state.userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _editNameDialog(context, state),
              icon: const Icon(Icons.edit),
              label: const Text('Edit name'),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: roleColor.withOpacity(0.5))),
              child: Text(roleLabel, style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 15)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  

  Widget _buildAdminDashboardEntry(BuildContext context, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.admin_panel_settings, color: color),
        title: const Text('Open admin dashboard'),
        subtitle: const Text('Manage notifications, security, and lifestyle controls'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        ),
      ),
    );
  }

  Widget _buildAuthButton(AppState state, Color color) => ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _handleLogout(context),
        icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.logout),
        label: Text(_isLoading ? 'Logging out...' : 'Logout'),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, minimumSize: const Size.fromHeight(48)),
      );
}
