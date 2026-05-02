import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  
  bool _isSending = false;

  // --- EmailJS Credentials (Verified) ---
  final String serviceId = 'service_xl2dqul'; 
  final String templateId = 'template_pvmgb8b'; 
  final String publicKey = 'RcmOLUdDv-w3TCtgb'; // Aapki update ki hui Public Key

  Future<void> _sendEmailJS() async {
    // Basic Validation Check
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSending = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Origin': 'http://localhost', // Flutter web compatibility ke liye
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'user_name': _name.text.trim(),
            'user_email': _email.text.trim(),
            'message': _message.text.trim(),
            'reply_to': _email.text.trim(),
          }
        }),
      );

      if (response.statusCode == 200) {
        _name.clear();
        _email.clear();
        _message.clear();
        _showSuccessDialog();
      } else {
        // Server error detail handle karne ke liye
        debugPrint("EmailJS Error Response: ${response.body}");
        _showSnackBar("Maaf kijiye, server se contact nahi ho paya.");
      }
    } catch (e) {
      debugPrint("Connection Error: $e");
      _showSnackBar("Internet connection ya setup check karein.");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text(
          "Aapka sandesh seedha Kuldeep ke paas pahunch gaya hai! Dhanyawad.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = const Color(0xFFFFD700);

    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Me', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(
                context,
                _name,
                "Aapka Naam",
                Icons.person,
                semanticLabel: 'Name',
                semanticHint: 'Enter your full name',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
              ),
              const SizedBox(height: 16),
              _buildField(context, _email, "Aapka Email", Icons.email, 
                semanticLabel: 'Email',
                semanticHint: 'Enter your email address',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                keyboard: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Kripya email bhariye";
                  if (!v.contains('@')) return "Sahi email format use karein";
                  return null;
                }
              ),
              const SizedBox(height: 16),
              _buildField(
                context,
                _message,
                "Message",
                Icons.message,
                semanticLabel: 'Message',
                semanticHint: 'Type your message',
                textInputAction: TextInputAction.newline,
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Semantics(
                  button: true,
                  enabled: !_isSending,
                  label: 'Send message',
                  excludeSemantics: true,
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _sendEmailJS,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: isDark ? 0 : 4,
                    ),
                    child: _isSending 
                      ? const SizedBox(
                          height: 20, width: 20, 
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                        )
                      : const Text("SEND DIRECT MESSAGE 🕉️", 
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, TextEditingController ctrl, String label, IconData icon, 
      {required String semanticLabel,
      required String semanticHint,
      int maxLines = 1,
      TextInputType? keyboard,
      TextInputAction? textInputAction,
      Iterable<String>? autofillHints,
      String? Function(String?)? validator}) {
    
    final theme = Theme.of(context);
    final goldColor = const Color(0xFFFFD700);

    return Semantics(
      textField: true,
      label: semanticLabel,
      hint: semanticHint,
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        validator: validator ?? (v) => (v == null || v.isEmpty) ? "Ye khali nahi ho sakta" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: goldColor),
          filled: true,
          fillColor: theme.brightness == Brightness.dark 
              ? Colors.white.withOpacity(0.05) 
              : Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: goldColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
