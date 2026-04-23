import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'social_links.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final subject = Uri.encodeComponent(
        _subject.text.trim().isEmpty ? 'Geeta AI – Contact' : _subject.text.trim());
    final body = Uri.encodeComponent(
      'Name: ${_name.text.trim()}\n'
      'Email: ${_email.text.trim()}\n\n'
      '${_message.text.trim()}\n',
    );
    final mailto = Uri.parse(
        'mailto:$kContactEmail?subject=$subject&body=$body');

    final ok = await launchUrl(mailto, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Opening your email app to send the message…'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Could not open an email app. You can write directly to $kContactEmail'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Contact Us'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Get in touch',
                  style: GoogleFonts.cinzel(
                      color: kGold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                'Have a question, suggestion, or feedback? Send a message and we\'ll get back to you.',
                style: TextStyle(color: kTextDim, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              _infoTile(Icons.email_outlined, kContactEmail,
                  () => openUrl('mailto:$kContactEmail')),
              const SizedBox(height: 20),
              const SocialLinksRow(),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(_name, 'Your Name', validator: _required),
                    const SizedBox(height: 12),
                    _field(_email, 'Your Email',
                        keyboard: TextInputType.emailAddress,
                        validator: _emailValidator),
                    const SizedBox(height: 12),
                    _field(_subject, 'Subject (optional)'),
                    const SizedBox(height: 12),
                    _field(_message, 'Your Message',
                        maxLines: 5, validator: _required),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _send,
                        icon: const Icon(Icons.send),
                        label: Text('Send Message',
                            style: GoogleFonts.cinzel(
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGold,
                          foregroundColor: kBg,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kDivider.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: kGold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: const TextStyle(color: kText, fontSize: 14)),
            ),
            const Icon(Icons.open_in_new, color: kTextDim, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {int maxLines = 1,
      TextInputType? keyboard,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: validator,
      style: const TextStyle(color: kText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kTextDim),
        filled: true,
        fillColor: kCard,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kDivider.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email';
  }
}
