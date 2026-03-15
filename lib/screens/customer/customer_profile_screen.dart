import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../role_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;

  bool _notifBooking = true;
  bool _notifReminder = true;
  bool _notifPromo = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Arun Kumar');
    _phoneCtrl = TextEditingController(text: '+91 98765 00000');
    _emailCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  int get _totalBookings => customerBookings.length;
  int get _completedBookings =>
      customerBookings.where((b) => b.status == 'completed').length;
  int get _favouriteCount => favouriteBarberIds.length;

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated ✓'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _save,
                      icon: const Icon(
                        Icons.check_rounded,
                        color: AppTheme.secondary,
                        size: 18,
                      ),
                      label: const Text(
                        'Save',
                        style: TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Avatar + stats ──
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppTheme.secondary.withValues(
                            alpha: 0.15,
                          ),
                          child: Text(
                            _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : 'A',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameCtrl.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Customer · Chennai',
                      style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(value: '$_totalBookings', label: 'Bookings'),
                        Container(width: 1, height: 30, color: AppTheme.border),
                        _Stat(value: '$_completedBookings', label: 'Completed'),
                        Container(width: 1, height: 30, color: AppTheme.border),
                        _Stat(value: '$_favouriteCount', label: 'Favourites'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Edit fields ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal info',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      label: 'Full name',
                      ctrl: _nameCtrl,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 10),
                    _Field(
                      label: 'Phone number',
                      ctrl: _phoneCtrl,
                      icon: Icons.phone_outlined,
                      type: TextInputType.phone,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    _Field(
                      label: 'Email (optional)',
                      ctrl: _emailCtrl,
                      icon: Icons.email_outlined,
                      type: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),

            // ── Notification prefs ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _NotifToggle(
                      title: 'Booking updates',
                      subtitle: 'Confirmations, cancellations',
                      value: _notifBooking,
                      onChanged: (v) => setState(() => _notifBooking = v),
                    ),
                    _NotifToggle(
                      title: 'Reminders',
                      subtitle: '1 hour before appointment',
                      value: _notifReminder,
                      onChanged: (v) => setState(() => _notifReminder = v),
                    ),
                    _NotifToggle(
                      title: 'Promotions',
                      subtitle: 'Offers and discounts',
                      value: _notifPromo,
                      onChanged: (v) => setState(() => _notifPromo = v),
                    ),
                  ],
                ),
              ),
            ),

            // ── Logout ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Log Out',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'Are you sure you want to log out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppTheme.textGrey),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RoleScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE24B4A),
                            ),
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFE24B4A),
                  ),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(color: Color(0xFFE24B4A)),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: Color(0xFFE24B4A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
      ),
    ],
  );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final TextInputType type;
  final bool readOnly;
  const _Field({
    required this.label,
    required this.ctrl,
    required this.icon,
    this.type = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: type,
    readOnly: readOnly,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
      prefixIcon: Icon(icon, size: 20, color: AppTheme.textGrey),
      filled: true,
      fillColor: readOnly ? AppTheme.background : AppTheme.surface,
    ),
  );
}

class _NotifToggle extends StatelessWidget {
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _NotifToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.secondary,
          activeTrackColor: AppTheme.secondary.withValues(alpha: 0.4),
        ),
      ],
    ),
  );
}
