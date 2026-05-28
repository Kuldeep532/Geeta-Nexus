import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // Firebase Broadcast bhejane ka logic
  void _sendNotification(AppState state) async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and message')),
      );
      return;
    }

    setState(() => _isSending = true);

    // Ye call seedha Firebase topic 'all_users' ko message bhejega
    await state.sendGlobalNotification(title: title, body: body);

    if (mounted) {
      setState(() => _isSending = false);
      _titleController.clear();
      _bodyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification broadcasted to all devotees!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('NOTIFICATIONS', style: GoogleFonts.cinzel(color: kGold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sirf Admin (kuldeepky538@gmail.com) ko composer dikhega
          if (state.isAdmin) ...[
            _adminComposer(state),
            const SizedBox(height: 24),
          ],
          
          _streamHeader(state.notifications.where((n) => !n.isRead).length),
          const SizedBox(height: 12),
          
          if (state.notifications.isEmpty)
            const _EmptyNotificationState()
          else
            ...state.notifications.map(
              (n) => _NotificationCard(
                notification: n,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<AppState>().markNotificationRead(n.id);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _adminComposer(AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: kGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'ADMIN BROADCAST',
                style: GoogleFonts.cinzel(
                  color: kGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: kText),
            decoration: InputDecoration(
              labelText: 'Announcement Title',
              labelStyle: const TextStyle(color: kTextDim),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kGold)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            minLines: 2,
            maxLines: 4,
            style: const TextStyle(color: kText),
            decoration: InputDecoration(
              labelText: 'Message for Devotees',
              labelStyle: const TextStyle(color: kTextDim),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kGold)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: _isSending ? null : () {
                HapticFeedback.lightImpact();
                _sendNotification(state);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSending 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('SEND TO ALL USERS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _streamHeader(int unread) {
    return Row(
      children: [
        Text(
          'MESSAGE STREAM',
          style: GoogleFonts.cinzel(
            color: kGold,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (unread > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
            child: Text('$unread NEW', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: kCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? Colors.transparent : kGold.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          notification.title,
          style: TextStyle(
            color: kText,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body, style: const TextStyle(color: kTextDim, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              "${notification.createdAt.day}/${notification.createdAt.month} • ${notification.createdAt.hour}:${notification.createdAt.minute}",
              style: const TextStyle(color: kTextDim, fontSize: 10),
            ),
          ],
        ),
        trailing: notification.isRead 
            ? null 
            : const CircleAvatar(radius: 4, backgroundColor: kGold),
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.notifications_none, size: 48, color: kGold.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No announcements yet.\nStay tuned for divine updates.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextDim),
            ),
          ],
        ),
      ),
    );
  }
}
