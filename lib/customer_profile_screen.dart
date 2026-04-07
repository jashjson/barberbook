import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../role_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});
  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _notifBooking = true;
  bool _notifReminder = true;
  bool _notifPromo = false;
  bool _loading = true;
  bool _saving = false;
  int _totalBookings = 0;
  int _completedBookings = 0;
  int _favouriteCount = 0;
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await FirebaseService.getCustomerProfile();
      final uid = FirebaseService.currentUid;
      final bookings = await FirebaseFirestore.instance
          .collection('appointments')
          .where('customerId', isEqualTo: uid)
          .get();
      final completed = bookings.docs
          .where((d) => d['status'] == 'completed')
          .length;
      final favs = List.from(profile?['favouriteBarberIds'] ?? []).length;
      if (mounted) {
        setState(() {
          _nameCtrl.text = profile?['name'] ?? '';
          _emailCtrl.text = profile?['email'] ?? '';
          _phone =
              profile?['phone'] ??
              FirebaseAuth.instance.currentUser?.phoneNumber ??
              '';
          _totalBookings = bookings.docs.length;
          _completedBookings = completed;
          _favouriteCount = favs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseService.updateCustomerProfile({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated ✓'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) {
      setState(() => _saving = false);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleScreen()),
                (r) => false,
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
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
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
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: AppTheme.secondary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.check_rounded,
                              color: AppTheme.secondary,
                              size: 18,
                            ),
                      label: Text(
                        _saving ? 'Saving...' : 'Save',
                        style: const TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Avatar + stats
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
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppTheme.secondary.withValues(
                        alpha: 0.15,
                      ),
                      child: Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Customer',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGrey,
                      ),
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

            // Fields
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
                      ctrl: TextEditingController(text: _phone),
                      icon: Icons.phone_outlined,
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

            // Notifications
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
                    _Toggle(
                      title: 'Booking updates',
                      subtitle: 'Confirmations, cancellations',
                      value: _notifBooking,
                      onChanged: (v) => setState(() => _notifBooking = v),
                    ),
                    _Toggle(
                      title: 'Reminders',
                      subtitle: '1 hour before appointment',
                      value: _notifReminder,
                      onChanged: (v) => setState(() => _notifReminder = v),
                    ),
                    _Toggle(
                      title: 'Promotions',
                      subtitle: 'Offers and discounts',
                      value: _notifPromo,
                      onChanged: (v) => setState(() => _notifPromo = v),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: OutlinedButton.icon(
                  onPressed: _logout,
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

class _Toggle extends StatelessWidget {
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({
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
