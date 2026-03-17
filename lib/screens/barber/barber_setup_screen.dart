import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import 'barber_main.dart';

class BarberSetupScreen extends StatefulWidget {
  const BarberSetupScreen({super.key});
  @override
  State<BarberSetupScreen> createState() => _BarberSetupScreenState();
}

class _BarberSetupScreenState extends State<BarberSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final List<Map<String, dynamic>> _services = [];
  bool _loading = false;
  int _step = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shopCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    _expCtrl.dispose();
    _specialtyCtrl.dispose();
    super.dispose();
  }

  void _addService() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durCtrl = TextEditingController(text: '30');
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
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Service name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Price (₹)',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: durCtrl,
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
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(
                  () => _services.add({
                    'name': nameCtrl.text.trim(),
                    'price': int.tryParse(priceCtrl.text) ?? 0,
                    'durationMin': int.tryParse(durCtrl.text) ?? 30,
                    'isActive': true,
                  }),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_nameCtrl.text.trim().isEmpty || _shopCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name and shop name')),
      );
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _finish() async {
    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one service')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final db = FirebaseFirestore.instance;
      await db.collection('barbers').doc(uid).update({
        'name': _nameCtrl.text.trim(),
        'shopName': _shopCtrl.text.trim(),
        'location': _addressCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'specialty': _specialtyCtrl.text.trim(),
        'experienceYears': int.tryParse(_expCtrl.text) ?? 0,
        'isProfileDone': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      for (final s in _services) {
        await db.collection('barbers').doc(uid).collection('services').add(s);
      }
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BarberMain()),
        (r) => false,
      );
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to BarberBook! 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _step == 0
                        ? 'Step 1/2 — Set up your profile'
                        : 'Step 2/2 — Add your services',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: _step == 1 ? Colors.white : Colors.white30,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _step == 0 ? _profileStep() : _servicesStep(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _loading ? null : (_step == 0 ? _nextStep : _finish),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(_step == 0 ? 'Next — Add Services' : 'Finish Setup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'This is what customers will see',
          style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 20),
        _Field(
          label: 'Full name *',
          ctrl: _nameCtrl,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Shop name *',
          ctrl: _shopCtrl,
          icon: Icons.store_outlined,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Specialty',
          ctrl: _specialtyCtrl,
          icon: Icons.star_outline_rounded,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Shop address',
          ctrl: _addressCtrl,
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Years of experience',
          ctrl: _expCtrl,
          icon: Icons.workspace_premium_rounded,
          type: TextInputType.number,
          formatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'About your shop',
          ctrl: _bioCtrl,
          icon: Icons.info_outline_rounded,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _servicesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Add services you offer with prices',
                    style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _addService,
              icon: const Icon(Icons.add_rounded, color: AppTheme.primary),
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
        const SizedBox(height: 16),
        if (_services.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
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
                    size: 36,
                    color: AppTheme.textGrey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap "Add" to add your first service',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          ..._services.asMap().entries.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                          e.value['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '${e.value['durationMin']} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${e.value['price']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _services.removeAt(e.key)),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
