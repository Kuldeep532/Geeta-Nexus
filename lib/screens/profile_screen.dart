import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'admin_dashboard_screen.dart';

import ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Login Handle karne ka naya function
  Future<void> _handleLogin(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final state = Provider.of<AppState>(context, listen: false);
        state.updateGoogleAccount(
          name: googleUser.displayName ?? 'Seeker', 
          email: googleUser.email
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Safaltapurvak login ho gaya!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login nahi ho paya: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      await _googleSignIn.signOut();
      final state = Provider.of<AppState>(context, listen: false);
      state.updateGoogleAccount(name: '', email: '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Safaltapurvak logout ho gaya.')),
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
    final bool isLoggedIn = state.userEmail.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // FIXED: Title ko proper Semantic Heading banaya
        title: Semantics(
          header: true,
          label: 'Profile Hub Screen',
          child: Text(
            'Profile Hub', 
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: accentColor)
          ),
        ),
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
          
          if (isAdmin) ...[
            const SizedBox(height: 32),
            _buildSectionTitle('ADMIN CONTROLS', accentColor),
            _buildAdminDashboardEntry(context, accentColor),
          ],
          const SizedBox(height: 32),
          
          // Dynamic Auth Button toggle
          _buildAuthButton(context, isLoggedIn, accentColor),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      // FIXED: Headers ko real heading node banaya taaki screen reader user skip kar sakein
      child: Semantics(
        header: true,
        label: '$title Section',
        excludeSemantics: true,
        child: Text(
          title, 
          style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2)
        ),
      ),
    );
  }

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

    final String nameToDisplay = state.userName.isEmpty ? 'Guest Seeker' : state.userName;

    return Semantics(
      container: true,
      label: 'Profile Info Card. User Name: $nameToDisplay. Account Role: $roleLabel.',
      excludeSemantics: true,
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
              child: Text(
                state.userName.isNotEmpty ? state.userName[0].toUpperCase() : 'G', 
                style: TextStyle(color: gold, fontSize: 30, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 16),
            Text(nameToDisplay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Semantics(
              button: true,
              label: 'Edit Name Button',
              hint: 'Double tap to change your profile name',
              child: OutlinedButton.icon(
                onPressed: () => _editNameDialog(context, state),
                icon: const Icon(Icons.edit),
                label: const Text('Edit name'),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(20), 
                border: Border.all(color: roleColor.withOpacity(0.5))
              ),
              child: Text(roleLabel, style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Semantics(
      label: '$label state is $value',
      excludeSemantics: true,
      child: Padding(
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
      ),
    );
  }

  Widget _buildAdminDashboardEntry(BuildContext context, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      child: Semantics(
        button: true,
        label: 'Admin Controls Dashboard',
        hint: 'Double tap to manage notifications and security settings',
        excludeSemantics: true,
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
      ),
    );
  }

  Widget _buildAuthButton(BuildContext context, bool isLoggedIn, Color color) {
    return Semantics(
      button: true,
      label: _isLoading 
          ? (isLoggedIn ? 'Logging out process active' : 'Logging in process active')
          : (isLoggedIn ? 'Logout Button' : 'Login with Google Button'),
      excludeSemantics: true,
      child: ElevatedButton.icon(
        onPressed: _isLoading 
            ? null 
            : () => isLoggedIn ? _handleLogout(context) : _handleLogin(context),
        icon: _isLoading 
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
            : Icon(isLoggedIn ? Icons.logout : Icons.login),
        label: Text(
          _isLoading 
              ? (isLoggedIn ? 'Logging out...' : 'Logging in...') 
              : (isLoggedIn ? 'Logout' : 'Login with Google')
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, 
          foregroundColor: Colors.black, 
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
      ),
    );
  }
}
