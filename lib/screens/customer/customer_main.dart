import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import 'customer_home.dart';
import 'my_bookings_screen.dart';
import 'notifications_screen.dart';
import 'favourites_screen.dart';
import 'customer_profile_screen.dart';

class CustomerMain extends StatefulWidget {
  const CustomerMain({super.key});
  @override
  State<CustomerMain> createState() => _CustomerMainState();
}

class _CustomerMainState extends State<CustomerMain> {
  int _index = 0;

  final List<Widget> _screens = const [
    CustomerHome(),
    MyBookingsScreen(),
    NotificationsScreen(),
    FavouritesScreen(),
    CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: uid)
            .where('isRead', isEqualTo: false)
            .snapshots(),
        builder: (context, snap) {
          final unread = snap.data?.docs.length ?? 0;
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                      current: _index,
                      onTap: (i) => setState(() => _index = i),
                    ),
                    _NavItem(
                      icon: Icons.calendar_month_rounded,
                      label: 'Bookings',
                      index: 1,
                      current: _index,
                      onTap: (i) => setState(() => _index = i),
                    ),
                    _NavItem(
                      icon: Icons.notifications_outlined,
                      label: 'Alerts',
                      index: 2,
                      current: _index,
                      badge: unread,
                      onTap: (i) => setState(() => _index = i),
                    ),
                    _NavItem(
                      icon: Icons.favorite_border_rounded,
                      label: 'Favourites',
                      index: 3,
                      current: _index,
                      onTap: (i) => setState(() => _index = i),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      index: 4,
                      current: _index,
                      onTap: (i) => setState(() => _index = i),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current, badge;
  final ValueChanged<int> onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
    this.badge = 0,
  });
  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.secondary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: active ? AppTheme.secondary : AppTheme.textGrey,
                ),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppTheme.secondary : AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
