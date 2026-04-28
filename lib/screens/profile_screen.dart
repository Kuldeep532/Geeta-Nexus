import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Logout Function
  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      await _googleSignIn.signOut();
      final state = Provider.of<AppState>(context, listen: false);
      state.updateGoogleAccount(name: "", email: ""); 
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saffalta purvak logout ho gaya.')),
        );
      }
    } catch (e) {
      debugPrint("Logout Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final accentColor = kGold;

    // AUTOMATIC ROLE LOGIC
    // Yahan apni sahi email ID dalein
    final bool isSuperAdmin = state.userEmail == "aapka-email@gmail.com"; 
    final bool isAdmin = isSuperAdmin || state.userRole == "admin";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile Hub', 
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: accentColor)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // 1. Profile Header with Automatic Badging
          _buildInfoCard(state, accentColor, theme, isSuperAdmin, isAdmin),
          
          const SizedBox(height: 32),

          // 2. Personal Progress
          _buildSectionTitle("YOUR PROGRESS", accentColor),
          _buildStatRow(Icons.bolt, "Level", "${state.level}", accentColor),
          _buildStatRow(Icons.local_fire_department, "Streak", "${state.streak} Days", Colors.orange),

          const SizedBox(height: 32),

          // 3. Admin Command Centre (Sirf Admin/Super Admin ko dikhega)
          if (isAdmin) ...[
            _buildSectionTitle("CONTROL CENTRE", accentColor),
            _buildAdminControls(accentColor, theme, isSuperAdmin),
            const SizedBox(height: 32),
          ],

          // 4. Auth Button
          _buildAuthButton(state, accentColor),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, 
        style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2)),
    );
  }

  Widget _buildAdminControls(Color gold, ThemeData theme, bool isSuper) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          if (isSuper)
            _buildAdminTile(
              icon: Icons.people_alt_outlined,
              iconColor: Colors.blue,
              title: "User Directory",
              subtitle: "Manage roles and permissions",
              onTap: () {},
            ),
          
          if (isSuper) const Divider(height: 1),

          _buildAdminTile(
            icon: Icons.edit_note_rounded,
            iconColor: Colors.green,
            title: "Content Manager",
            subtitle: "Update verses and lessons",
            onTap: () {},
          ),
          
          const Divider(height: 1),

          _buildAdminTile(
            icon: Icons.insights_rounded,
            iconColor: Colors.purple,
            title: "App Analytics",
            subtitle: "Check system health",
            onTap: () {},
          ),

          if (isSuper) ...[
            const Divider(height: 1),
            _buildAdminTile(
              icon: Icons.settings_suggest_outlined,
              iconColor: Colors.orange,
              title: "Global Settings",
              subtitle: "Maintenance Mode",
              onTap: () {},
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildAdminTile({
    required IconData icon, 
    required Color iconColor, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
      onTap: onTap,
    );
  }

  Widget _buildInfoCard(AppState state, Color gold, ThemeData theme, bool isSuper, bool isAdmin) {
    String roleLabel = "SEEKER";
    Color roleColor = Colors.grey;
    
    if (isSuper) {
      roleLabel = "SUPER ADMIN";
      roleColor = Colors.redAccent;
    } else if (isAdmin) {
      roleLabel = "ADMIN";
      roleColor = gold;
    }

    return Container(
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
            child: Text(state.userName.isNotEmpty ? state.userName[0].toUpperCase() : "G", 
              style: TextStyle(color: gold, fontSize: 30, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text(state.userName.isEmpty ? "Guest Seeker" : state.userName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Padding(
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
  }

  Widget _buildAuthButton(AppState state, Color gold) {
    bool isGuest = state.userName.isEmpty;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : (isGuest ? () {} : () => _handleLogout(context)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isGuest ? gold : Colors.redAccent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: isGuest ? gold : Colors.redAccent,
        ),
        icon: _isLoading 
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(isGuest ? Icons.login : Icons.logout),
        label: Text(isGuest ? "Login with Google" : "Logout Account"),
      ),
    );
  }
}
