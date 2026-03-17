import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../role_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();

  List<ServiceModel> _services = [];
  bool _loading = true;
  bool _saving = false;
  String _phone = '';
  String _initial = 'B';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shopCtrl.dispose();
    _bioCtrl.dispose();
    _addressCtrl.dispose();
    _expCtrl.dispose();
    _specialtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final barber = await FirebaseService.getCurrentBarber();
      final services = await FirebaseService.getBarberServices(
        FirebaseService.currentUid,
      );
      if (mounted && barber != null) {
        setState(() {
          _nameCtrl.text = barber.name;
          _shopCtrl.text = barber.shopName;
          _bioCtrl.text = barber.bio;
          _addressCtrl.text = barber.location;
          _expCtrl.text = barber.experienceYears > 0
              ? '${barber.experienceYears}'
              : '';
          _specialtyCtrl.text = barber.specialty;
          _initial = barber.initial;
          _phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
          _services = services;
          _loading = false;
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await FirebaseService.saveBarberProfile({
        'name': _nameCtrl.text.trim(),
        'shopName': _shopCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'location': _addressCtrl.text.trim(),
        'specialty': _specialtyCtrl.text.trim(),
        'experienceYears': int.tryParse(_expCtrl.text) ?? 0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved ✓'),
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

  void _addService() {
    final nCtrl = TextEditingController();
    final pCtrl = TextEditingController();
    final dCtrl = TextEditingController(text: '30');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nCtrl,
              decoration: const InputDecoration(labelText: 'Service name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Price (₹)',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Duration (min)',
                suffixText: 'min',
              ),
            ),
          ],
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
            onPressed: () async {
              if (nCtrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              await FirebaseService.addService(
                ServiceModel(
                  id: '',
                  name: nCtrl.text.trim(),
                  price: int.tryParse(pCtrl.text) ?? 0,
                  durationMin: int.tryParse(dCtrl.text) ?? 30,
                ),
              );
              _load();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editService(ServiceModel s) {
    final nCtrl = TextEditingController(text: s.name);
    final pCtrl = TextEditingController(text: '${s.price}');
    final dCtrl = TextEditingController(text: '${s.durationMin}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nCtrl,
              decoration: const InputDecoration(labelText: 'Service name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Price (₹)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Duration (min)'),
            ),
          ],
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
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseService.updateService(
                s.id,
                ServiceModel(
                  id: s.id,
                  name: nCtrl.text.trim(),
                  price: int.tryParse(pCtrl.text) ?? s.price,
                  durationMin: int.tryParse(dCtrl.text) ?? s.durationMin,
                ),
              );
              _load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteService(ServiceModel s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Service?'),
        content: Text('Remove "${s.name}"?'),
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
              await FirebaseService.deleteService(s.id);
              _load();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
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
                        'My Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _saving ? null : _saveProfile,
                      icon: _saving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.check_rounded,
                              color: AppTheme.primary,
                              size: 18,
                            ),
                      label: Text(
                        _saving ? 'Saving...' : 'Save',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Avatar
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
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        _initial,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Your name',
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
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shop info',
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
                      label: 'Shop name',
                      ctrl: _shopCtrl,
                      icon: Icons.store_outlined,
                    ),
                    const SizedBox(height: 10),
                    _Field(
                      label: 'Specialty',
                      ctrl: _specialtyCtrl,
                      icon: Icons.star_outline_rounded,
                    ),
                    const SizedBox(height: 10),
                    _Field(
                      label: 'Shop address',
                      ctrl: _addressCtrl,
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 10),
                    _Field(
                      label: 'Years of exp',
                      ctrl: _expCtrl,
                      icon: Icons.workspace_premium_rounded,
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 10),
                    _Field(
                      label: 'About',
                      ctrl: _bioCtrl,
                      icon: Icons.info_outline_rounded,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addService,
                      icon: const Icon(
                        Icons.add_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      label: const Text(
                        'Add',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _services.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.content_cut_rounded,
                              size: 32,
                              color: AppTheme.textGrey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No services yet. Tap Add.',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((_, i) {
                      final s = _services[i];
                      return Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.content_cut_rounded,
                                color: AppTheme.primary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${s.durationMin} min',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${s.price}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _editService(s),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 14,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _deleteService(s),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 14,
                                  color: AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }, childCount: _services.length),
                  ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(color: AppTheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: AppTheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final int maxLines;
  final TextInputType type;
  final List<TextInputFormatter>? formatters;
  const _Field({
    required this.label,
    required this.ctrl,
    required this.icon,
    this.maxLines = 1,
    this.type = TextInputType.text,
    this.formatters,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: type,
    inputFormatters: formatters,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
      prefixIcon: Icon(icon, size: 20, color: AppTheme.textGrey),
    ),
  );
}
