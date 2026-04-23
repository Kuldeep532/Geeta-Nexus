import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _sendNotification(AppState state) {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    state.sendAdminNotification(title: title, body: body);
    _titleController.clear();
    _bodyController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent to stream.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.isAdmin) _adminComposer(state),
          if (state.isAdmin) const SizedBox(height: 16),
          _streamHeader(state.unreadNotificationCount),
          const SizedBox(height: 10),
          if (state.notifications.isEmpty)
            const _EmptyNotificationState()
          else
            ...state.notifications.map(
              (n) => _NotificationCard(
                notification: n,
                onTap: () => context.read<AppState>().markNotificationRead(n.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _adminComposer(AppState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDivider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Notification Publisher',
            style: GoogleFonts.cinzel(
              color: kGold,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Only kuldeepky538@gmail.com can send notifications.',
            style: TextStyle(color: kTextDim, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: kText),
            decoration: const InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: kTextDim),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bodyController,
            minLines: 2,
            maxLines: 4,
            style: const TextStyle(color: kText),
            decoration: const InputDecoration(
              labelText: 'Message',
              labelStyle: TextStyle(color: kTextDim),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _sendNotification(state),
              child: const Text('Send Notification'),
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
          'Notification Stream',
          style: GoogleFonts.cinzel(
            color: kGold,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text('Unread: $unread', style: const TextStyle(color: kTextDim)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? kDivider.withOpacity(0.4)
                  : kGoldDim.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.title,
                  style: const TextStyle(
                      color: kText, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(notification.body,
                  style: const TextStyle(color: kTextDim, fontSize: 12)),
              const SizedBox(height: 6),
              Text(
                notification.createdAt.toLocal().toString().substring(0, 16),
                style: const TextStyle(color: kTextDim, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider.withOpacity(0.5)),
      ),
      child: const Text(
        'No notifications yet. Admin broadcasts will appear here automatically.',
        style: TextStyle(color: kTextDim),
      ),
    );
  }
}
