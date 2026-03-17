import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _icon(String type) {
    switch (type) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'reminder':
        return Icons.access_time_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'review':
        return Icons.star_rounded;
      case 'new_booking':
        return Icons.calendar_today_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'confirmed':
        return AppTheme.primary;
      case 'reminder':
        return const Color(0xFFEF9F27);
      case 'cancelled':
        return const Color(0xFFE24B4A);
      case 'review':
        return const Color(0xFFEF9F27);
      case 'new_booking':
        return AppTheme.secondary;
      case 'completed':
        return AppTheme.primary;
      default:
        return AppTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: StreamBuilder<List<NotificationModel>>(
          stream: FirebaseService.getNotificationsStream(),
          builder: (context, snap) {
            final notifs = snap.data ?? [];
            final unread = notifs.where((n) => !n.isRead).length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      if (unread > 0)
                        TextButton(
                          onPressed: () =>
                              FirebaseService.markAllNotificationsRead(),
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              color: AppTheme.secondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (unread > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE24B4A,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$unread unread',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE24B4A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (snap.connectionState == ConnectionState.waiting)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (notifs.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 56,
                            color: AppTheme.textGrey.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No notifications yet',
                            style: TextStyle(color: AppTheme.textGrey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: notifs.length,
                      itemBuilder: (_, i) {
                        final n = notifs[i];
                        final color = _color(n.type);
                        return GestureDetector(
                          onTap: () =>
                              FirebaseService.markNotificationRead(n.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: n.isRead
                                  ? AppTheme.surface
                                  : color.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: n.isRead
                                    ? AppTheme.border
                                    : color.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _icon(n.type),
                                    color: color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n.title,
                                              style: TextStyle(
                                                fontWeight: n.isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.bold,
                                                color: AppTheme.textDark,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (!n.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.message,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textGrey,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.time,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
