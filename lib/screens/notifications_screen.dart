import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notifications_provider.dart';
import '../models/notification_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.id ?? '';
      context.read<NotificationsProvider>().loadForUser(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationsProvider>();
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (notifs.unreadCount > 0)
            TextButton(
              onPressed: () => notifs.markAllAsRead(userId),
              child: const Text('Mark all read',
                  style: TextStyle(color: AppColors.primaryGreen)),
            ),
        ],
      ),
      body: notifs.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentMint))
          : notifs.notifications.isEmpty
              ? _EmptyNotifications()
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: notifs.notifications.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final n = notifs.notifications[i];
                    return _NotificationTile(
                      notification: n,
                      onTap: () => notifs.markAsRead(n.id),
                    );
                  },
                ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile(
      {required this.notification, required this.onTap});

  IconData get _icon => switch (notification.type) {
        NotificationType.pickupUpdate => Icons.local_shipping_outlined,
        NotificationType.creditsEarned => Icons.eco_rounded,
        NotificationType.passportReady => Icons.qr_code_rounded,
        NotificationType.rewardRedeemed => Icons.card_giftcard_rounded,
        NotificationType.systemAlert => Icons.info_outline_rounded,
        _ => Icons.notifications_outlined,
      };

  Color get _color => switch (notification.type) {
        NotificationType.pickupUpdate => AppColors.cleanSkyBlue,
        NotificationType.creditsEarned => AppColors.accentMint,
        NotificationType.passportReady => AppColors.primaryGreen,
        NotificationType.rewardRedeemed => AppColors.amberGold,
        NotificationType.systemAlert => AppColors.alertRed,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surfaceLight
              : _color.withAlpha(12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? AppColors.borderLight
                : _color.withAlpha(80),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textDark)),
                  const SizedBox(height: 3),
                  Text(notification.body,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(
                    Formatters.formatRelativeTime(notification.timestamp),
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔔', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text('All caught up!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          SizedBox(height: 8),
          Text('No new notifications.',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
