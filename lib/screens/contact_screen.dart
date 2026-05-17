import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSending = false;

  static const _serviceId = 'service_xl2dqul';
  static const _templateId = 'template_pvmgb8b';
  static const _publicKey = 'RcmOLUdDv-w3TCtgb';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSending = true);
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'user_name': _nameCtrl.text.trim(),
            'user_email': _emailCtrl.text.trim(),
            'message': _messageCtrl.text.trim(),
            'reply_to': _emailCtrl.text.trim(),
          },
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _nameCtrl.clear();
        _emailCtrl.clear();
        _messageCtrl.clear();
        _showSuccess();
      } else {
        _showError('Could not reach server. Please try again.');
      }
    } catch (_) {
      if (mounted) _showError('Check your internet connection and try again.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

  void _showSuccess() => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Semantics(
            header: true,
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
          ),
          content: Text(
            'Your message has been sent!\nWe will get back to you soon.',
            textAlign: TextAlign.center,
            style: GoogleFonts.crimsonText(fontSize: 18, height: 1.5),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kGold,
                        fontSize: 16)),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('Contact Us'),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Screen description for screen readers
                Semantics(
                  label: 'Contact Us form. Fill in your name, email, and message, then press Send Message.',
                  child: ExcludeSemantics(
                    child: Text(
                      'Send us a message and we\'ll get back to you.',
                      style: GoogleFonts.crimsonText(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Field 1: Your Name
                _FieldLabel(label: 'Your Name'),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Your Name text field',
                  textField: true,
                  child: TextFormField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    decoration: _fieldDecoration(
                      isDark: isDark,
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Field 2: Your Email
                _FieldLabel(label: 'Your Email'),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Your Email text field',
                  textField: true,
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: _fieldDecoration(
                      isDark: isDark,
                      hint: 'Enter your email address',
                      icon: Icons.email_outlined,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter your email';
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Field 3: Your Message
                _FieldLabel(label: 'Your Message'),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Your Message text field',
                  textField: true,
                  child: TextFormField(
                    controller: _messageCtrl,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: _fieldDecoration(
                      isDark: isDark,
                      hint: 'Type your message here',
                      icon: Icons.message_outlined,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Please enter your message' : null,
                  ),
                ),
                const SizedBox(height: 36),

                // Single action button — min 48dp tall
                Semantics(
                  button: true,
                  enabled: !_isSending,
                  label: _isSending ? 'Sending message, please wait' : 'Send Message',
                  excludeSemantics: true,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGold,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: kGold.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: isDark ? 0 : 3,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2.5),
                            )
                          : Text(
                              'Send Message',
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required bool isDark,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: kGoldDim, size: 20),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kGold.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kGold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
