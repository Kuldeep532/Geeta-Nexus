import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'notifications_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isSuperAdmin = state.isSuperAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminNavTile(
            icon: Icons.notifications_active,
            title: 'Notifications',
            subtitle: 'Send and manage app announcements',
            destination: const NotificationsScreen(),
          ),
          _AdminNavTile(
            icon: Icons.security,
            title: 'Security',
            subtitle: isSuperAdmin ? 'View admin credential policy' : 'Super admin only',
            destination: const AdminSecurityScreen(),
            enabled: isSuperAdmin,
          ),
          const _AdminNavTile(
            icon: Icons.tune,
            title: 'Lifestyle controls',
            subtitle: 'Manage daily routine and in-app control options',
            destination: AdminLifestyleControlsScreen(),
          ),
        ],
      ),
    );
  }
}

class _AdminNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination;
  final bool enabled;

  const _AdminNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: kGold),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        enabled: enabled,
        onTap: !enabled
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => destination),
                ),
      ),
    );
  }
}

class AdminSecurityScreen extends StatelessWidget {
  const AdminSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Security')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: ListTile(
            title: Text('Admin security policy'),
            subtitle: Text(
              'Admin password is controlled by ADMIN_LOGIN_PASSWORD environment config.\n\n'
              'Current admin email: kuldeepky538@gmail.com',
            ),
          ),
        ),
      ),
    );
  }
}

class AdminLifestyleControlsScreen extends StatelessWidget {
  const AdminLifestyleControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lifestyle Controls')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: ListTile(
            title: Text('Lifestyle & routine controls'),
            subtitle: Text('Use Notifications screen for schedule and announcement controls.'),
          ),
        ),
      ),
    );
  }
}
