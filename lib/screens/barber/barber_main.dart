import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'barber_home.dart';
import 'appointments_screen.dart';
import 'availability_screen.dart';
import 'earnings_screen.dart';
import 'profile_screen.dart';

class BarberMain extends StatefulWidget {
  const BarberMain({super.key});

  @override
  State<BarberMain> createState() => _BarberMainState();
}

class _BarberMainState extends State<BarberMain> {
  int _index = 0;

  final List<Widget> _screens = const [
    BarberHome(),
    AppointmentsScreen(),
    AvailabilityScreen(),
    EarningsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
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
                  color: AppTheme.primary,
                  onTap: (i) => setState(() => _index = i),
                ),
                _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Bookings',
                  index: 1,
                  current: _index,
                  color: AppTheme.primary,
                  onTap: (i) => setState(() => _index = i),
                ),
                _NavItem(
                  icon: Icons.access_time_rounded,
                  label: 'Availability',
                  index: 2,
                  current: _index,
                  color: AppTheme.primary,
                  onTap: (i) => setState(() => _index = i),
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Earnings',
                  index: 3,
                  current: _index,
                  color: AppTheme.primary,
                  onTap: (i) => setState(() => _index = i),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 4,
                  current: _index,
                  color: AppTheme.primary,
                  onTap: (i) => setState(() => _index = i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final Color color;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.color,
    required this.onTap,
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
          color: active ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: active ? color : AppTheme.textGrey),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? color : AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
