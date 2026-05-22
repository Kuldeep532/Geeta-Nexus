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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Admin actions',
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showAdminBottomSheet(context, isSuperAdmin),
          ),
        ],
      ),
      body: SafeArea(
        child: Semantics(
          label: 'Admin dashboard screen',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _DashboardHeader(isSuperAdmin: isSuperAdmin),

              const SizedBox(height: 24),

              Text(
                'Management',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              _AdminCard(
                icon: Icons.notifications_active_rounded,
                title: 'Notifications',
                subtitle: 'Send and manage app announcements',
                semanticLabel: 'Open notifications management',
                destination: const NotificationsScreen(),
              ),

              _AdminCard(
                icon: Icons.security_rounded,
                title: 'Security',
                subtitle: isSuperAdmin
                    ? 'Manage admin access and policies'
                    : 'Restricted to super admin',
                semanticLabel: 'Open security settings',
                destination: const AdminSecurityScreen(),
                enabled: isSuperAdmin,
              ),

              const _AdminCard(
                icon: Icons.self_improvement_rounded,
                title: 'Lifestyle Controls',
                subtitle: 'Routine and in-app control settings',
                semanticLabel: 'Open lifestyle controls',
                destination: AdminLifestyleControlsScreen(),
              ),

              const _AdminCard(
                icon: Icons.people_alt_rounded,
                title: 'User Management',
                subtitle: 'View and control user accounts',
                semanticLabel: 'Open user management',
                destination: AdminUserManagementScreen(),
              ),

              const _AdminCard(
                icon: Icons.analytics_rounded,
                title: 'Analytics',
                subtitle: 'Monitor app usage and engagement',
                semanticLabel: 'Open analytics',
                destination: AdminAnalyticsScreen(),
              ),

              const _AdminCard(
                icon: Icons.backup_rounded,
                title: 'Backup & Restore',
                subtitle: 'Manage secure backups and restore points',
                semanticLabel: 'Open backup and restore',
                destination: AdminBackupScreen(),
              ),

              const _AdminCard(
                icon: Icons.settings_suggest_rounded,
                title: 'System Settings',
                subtitle: 'Configure global app settings',
                semanticLabel: 'Open system settings',
                destination: AdminSystemSettingsScreen(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.admin_panel_settings_rounded),
        label: const Text(
          'Quick Actions',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () => _showAdminBottomSheet(context, isSuperAdmin),
      ),
    );
  }

  static void _showAdminBottomSheet(
    BuildContext context,
    bool isSuperAdmin,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Semantics(
          label: 'Admin quick action menu',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quick Admin Controls',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 20),

                _BottomSheetAction(
                  icon: Icons.notifications,
                  title: 'Push Notification',
                  subtitle: 'Send instant app updates',
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),

                _BottomSheetAction(
                  icon: Icons.person_off_rounded,
                  title: 'Suspend User',
                  subtitle: 'Temporarily restrict account access',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _BottomSheetAction(
                  icon: Icons.restart_alt_rounded,
                  title: 'System Restart',
                  subtitle: 'Restart app services safely',
                  enabled: isSuperAdmin,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _BottomSheetAction(
                  icon: Icons.dark_mode_rounded,
                  title: 'Toggle Theme',
                  subtitle: 'Switch light or dark mode',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _BottomSheetAction(
                  icon: Icons.download_rounded,
                  title: 'Export Reports',
                  subtitle: 'Download analytics and logs',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final bool isSuperAdmin;

  const _DashboardHeader({
    required this.isSuperAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            kGold.withOpacity(0.95),
            kGold.withOpacity(0.72),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: kGold.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSuperAdmin ? 'Super Admin Access' : 'Admin Access',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSuperAdmin
                      ? 'You have full system privileges.'
                      : 'Limited administrative permissions enabled.',
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String semanticLabel;
  final Widget destination;
  final bool enabled;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.semanticLabel,
    required this.destination,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: enabled
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => destination),
                    );
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.black12.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      icon,
                      color: kGold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                enabled ? Colors.black87 : Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color:
                                enabled ? Colors.black54 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color:
                        enabled ? Colors.black45 : Colors.black26,
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

class _BottomSheetAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const _BottomSheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: title,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: kGold.withOpacity(0.12),
          child: Icon(icon, color: kGold),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.black87 : Colors.black38,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               Placeholder Pages                            */
/* -------------------------------------------------------------------------- */

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: const Center(
        child: Text('Manage users here'),
      ),
    );
  }
}

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(
        child: Text('Analytics dashboard'),
      ),
    );
  }
}

class AdminBackupScreen extends StatelessWidget {
  const AdminBackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: const Center(
        child: Text('Backup controls'),
      ),
    );
  }
}

class AdminSystemSettingsScreen extends StatelessWidget {
  const AdminSystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Settings')),
      body: const Center(
        child: Text('Global system settings'),
      ),
    );
  }
}

class AdminSecurityScreen extends StatelessWidget {
  const AdminSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Admin Security'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Semantics(
          label: 'Admin security information',
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.security_rounded),
              title: Text(
                'Admin security policy',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Admin password is controlled by '
                  'ADMIN_LOGIN_PASSWORD environment config.\n\n'
                  'Current admin email: kuldeepky538@gmail.com',
                ),
              ),
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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Lifestyle Controls'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Semantics(
          label: 'Lifestyle control settings',
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.self_improvement_rounded),
              title: Text(
                'Lifestyle & routine controls',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Use Notifications screen for schedule and '
                  'announcement controls.',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
