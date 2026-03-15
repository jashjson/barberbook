import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';

class MutableNotif {
  final NotificationModel model;
  bool isRead;
  MutableNotif({required this.model, bool? isRead})
    : isRead = isRead ?? model.isRead;
}

// Global list so customer_main can read unread count
final List<MutableNotif> mutableNotifs = customerNotifications
    .map((n) => MutableNotif(model: n))
    .toList();

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int get _unread => mutableNotifs.where((n) => !n.isRead).length;

  IconData _iconFor(String type) {
    switch (type) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'reminder':
        return Icons.access_time_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'review':
        return Icons.star_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'confirmed':
        return AppTheme.primary;
      case 'reminder':
        return const Color(0xFFEF9F27);
      case 'cancelled':
        return const Color(0xFFE24B4A);
      case 'review':
        return const Color(0xFFEF9F27);
      case 'promo':
        return AppTheme.secondary;
      default:
        return AppTheme.textGrey;
    }
  }

  void _markAllRead() {
    setState(() {
      for (final n in mutableNotifs) {
        n.isRead = true;
      }
    });
  }

  void _markRead(MutableNotif n) {
    setState(() => n.isRead = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
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
                  if (_unread > 0)
                    TextButton(
                      onPressed: _markAllRead,
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

            if (_unread > 0)
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
                      color: const Color(0xFFE24B4A).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_unread unread',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE24B4A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

            mutableNotifs.isEmpty
                ? Expanded(
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
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: mutableNotifs.length,
                      itemBuilder: (_, i) {
                        final n = mutableNotifs[i];
                        final color = _colorFor(n.model.type);
                        return GestureDetector(
                          onTap: () => _markRead(n),
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
                                    _iconFor(n.model.type),
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
                                              n.model.title,
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
                                        n.model.message,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textGrey,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.model.time,
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
        ),
      ),
    );
  }
}
