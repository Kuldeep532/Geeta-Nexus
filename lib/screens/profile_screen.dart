import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleLogin(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) return;

      bool isAdmin = false;
      bool isSuperAdmin = false;

      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.email)
          .get();

      final superAdminDoc = await FirebaseFirestore.instance
          .collection('superadmins')
          .doc(user.email)
          .get();

      isAdmin = adminDoc.exists;
      isSuperAdmin = superAdminDoc.exists;

      final state =
          Provider.of<AppState>(context, listen: false);

      state.updateGoogleAccount(
        name: user.displayName ?? 'Seeker',
        email: user.email ?? '',
      );

      state.setAdmin(isAdmin);
      state.setSuperAdmin(isSuperAdmin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome ${user.displayName}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await _googleSignIn.signOut();
    await _auth.signOut();

    final state =
        Provider.of<AppState>(context, listen: false);

    state.updateGoogleAccount(
      name: '',
      email: '',
    );

    state.setAdmin(false);
    state.setSuperAdmin(false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
        ),
      );
    }
  }

  Future<void> _editNameDialog(
    BuildContext context,
    AppState state,
  ) async {
    final controller = TextEditingController(
      text: state.userName.isEmpty
          ? 'Seeker'
          : state.userName,
    );

    final updatedName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Display Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
                  controller.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted ||
        updatedName == null ||
        updatedName.isEmpty) {
      return;
    }

    state.setUserName(updatedName);

    if (state.userEmail.isNotEmpty) {
      state.updateGoogleAccount(
        name: updatedName,
        email: state.userEmail,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final theme = Theme.of(context);

    final bool isAdmin = state.isAdmin;
    final bool isSuperAdmin = state.isSuperAdmin;
    final bool isLoggedIn =
        state.userEmail.isNotEmpty;

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,

        title: Semantics(
          header: true,
          child: Text(
            'Profile Hub',
            style: GoogleFonts.cinzel(
              color: kGold,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: FocusTraversalGroup(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),

            children: [
              _buildProfileCard(
                context,
                state,
                isAdmin,
                isSuperAdmin,
              ),

              const SizedBox(height: 32),

              _buildSectionTitle(
                'Your Progress',
              ),

              _buildStatTile(
                icon: Icons.bolt,
                label: 'Level',
                value: '${state.level}',
              ),

              const SizedBox(height: 14),

              _buildStatTile(
                icon:
                    Icons.local_fire_department,
                label: 'Streak',
                value:
                    '${state.streak} Days',
              ),

              if (isAdmin ||
                  isSuperAdmin) ...[
                const SizedBox(height: 32),

                _buildSectionTitle(
                  'Admin Controls',
                ),

                _buildAdminCard(context),
              ],

              const SizedBox(height: 40),

              _buildAuthButton(
                context,
                isLoggedIn,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: GoogleFonts.cinzel(
            color: kGold,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    AppState state,
    bool isAdmin,
    bool isSuperAdmin,
  ) {
    String role = 'SEEKER';

    if (isSuperAdmin) {
      role = 'SUPER ADMIN';
    } else if (isAdmin) {
      role = 'ADMIN';
    }

    final String displayName =
        state.userName.isEmpty
            ? 'Guest Seeker'
            : state.userName;

    return Semantics(
      container: true,
      label:
          'User profile card. Name $displayName. Role $role.',
      child: Container(
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,

          borderRadius:
              BorderRadius.circular(24),

          border: Border.all(
            color: kGold.withOpacity(0.15),
          ),

          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              spreadRadius: 1,
              color: Colors.black.withOpacity(
                0.18,
              ),
            ),
          ],
        ),

        child: Column(
          children: [
            Semantics(
              image: true,
              label:
                  'Profile avatar for $displayName',
              child: CircleAvatar(
                radius: 42,
                backgroundColor:
                    kGold.withOpacity(0.12),

                child: Text(
                  displayName[0]
                      .toUpperCase(),

                  style: TextStyle(
                    color: kGold,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              displayName,
              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(30),

                border: Border.all(
                  color:
                      kGold.withOpacity(0.3),
                ),
              ),

              child: Semantics(
                label: 'Account role $role',
                child: Text(
                  role,

                  style:
                      GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Semantics(
              button: true,
              label: 'Edit profile name',
              hint:
                  'Double tap to change your display name',

              child: OutlinedButton.icon(
                onPressed: () {
                  _editNameDialog(
                    context,
                    state,
                  );
                },

                icon: ExcludeSemantics(
                  child: Icon(
                    Icons.edit,
                    color: kGold,
                  ),
                ),

                label: Text(
                  'Edit Name',
                  style:
                      GoogleFonts.poppins(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                style:
                    OutlinedButton.styleFrom(
                  minimumSize:
                      const Size(
                    double.infinity,
                    56,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),

                  side: BorderSide(
                    color:
                        kGold.withOpacity(
                      0.4,
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

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Semantics(
      label: '$label value is $value',

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: kGold.withOpacity(0.1),
          ),
        ),

        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                color: kGold,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                label,

                style:
                    GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),

            Text(
              value,

              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
      BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open admin dashboard',
      hint:
          'Double tap to manage admin settings',

      child: Card(
        margin: EdgeInsets.zero,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(22),
        ),

        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),

          leading: ExcludeSemantics(
            child: Icon(
              Icons.admin_panel_settings,
              color: kGold,
            ),
          ),

          title: Text(
            'Admin Dashboard',

            style: GoogleFonts.poppins(
              fontWeight:
                  FontWeight.w600,
              height: 1.4,
            ),
          ),

          subtitle: Text(
            'Manage notifications, security and controls',

            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
            ),
          ),

          trailing: const ExcludeSemantics(
            child: Icon(
              Icons.chevron_right,
            ),
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AdminDashboardScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAuthButton(
    BuildContext context,
    bool isLoggedIn,
  ) {
    return Semantics(
      button: true,
      enabled: !_isLoading,

      label: isLoggedIn
          ? 'Logout from account'
          : 'Login using Google account',

      hint: isLoggedIn
          ? 'Double tap to logout'
          : 'Double tap to sign in',

      child: SizedBox(
        width: double.infinity,
        height: 58,

        child: ElevatedButton.icon(
          onPressed: _isLoading
              ? null
              : () {
                  if (isLoggedIn) {
                    _handleLogout(
                      context,
                    );
                  } else {
                    _handleLogin(
                      context,
                    );
                  }
                },

          icon: _isLoading
              ? Semantics(
                  liveRegion: true,
                  label:
                      'Authentication loading',

                  child:
                      const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : ExcludeSemantics(
                  child: Icon(
                    isLoggedIn
                        ? Icons.logout
                        : Icons.login,
                  ),
                ),

          label: Text(
            _isLoading
                ? 'Please wait...'
                : isLoggedIn
                    ? 'Logout'
                    : 'Continue with Google',

            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
              height: 1.3,
            ),
          ),

          style:
              ElevatedButton.styleFrom(
            backgroundColor: kGold,

            foregroundColor: Colors.black,

            elevation: 0,

            minimumSize: const Size(
              double.infinity,
              58,
            ),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
