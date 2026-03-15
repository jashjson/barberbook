import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';
import '../role_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _addressCtrl;
  late List<ServiceModel> _services;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: currentBarber.name);
    _bioCtrl = TextEditingController(text: currentBarber.bio);
    _addressCtrl = TextEditingController(text: currentBarber.location);
    _services = List.from(currentBarber.services);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated ✓'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _editService(int index) {
    final priceCtrl = TextEditingController(
      text: _services[index].price.toString(),
    );
    final nameCtrl = TextEditingController(text: _services[index].name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Service',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Service name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (₹)',
                prefixText: '₹ ',
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
              setState(() {
                _services[index] = ServiceModel(
                  id: _services[index].id,
                  name: nameCtrl.text.trim().isNotEmpty
                      ? nameCtrl.text.trim()
                      : _services[index].name,
                  price: int.tryParse(priceCtrl.text) ?? _services[index].price,
                  durationMin: _services[index].durationMin,
                );
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              decoration: const InputDecoration(
                labelText: 'Price (₹)',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: durCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
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
                setState(() {
                  _services.add(
                    ServiceModel(
                      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      price: int.tryParse(priceCtrl.text) ?? 0,
                      durationMin: int.tryParse(durCtrl.text) ?? 30,
                    ),
                  );
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteService(int index) {
    setState(() => _services.removeAt(index));
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              minimumSize: const Size(80, 36),
            ),
            child: const Text('Log Out'),
          ),
        ],
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
                      onPressed: _saveProfile,
                      icon: const Icon(
                        Icons.check_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      label: const Text(
                        'Save',
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
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppTheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          child: Text(
                            currentBarber.initial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      currentBarber.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentBarber.shopName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(
                          value: '${currentBarber.totalClients}',
                          label: 'Clients',
                        ),
                        Container(width: 1, height: 30, color: AppTheme.border),
                        _Stat(
                          value: '★ ${currentBarber.rating}',
                          label: 'Rating',
                        ),
                        Container(width: 1, height: 30, color: AppTheme.border),
                        _Stat(
                          value: '${currentBarber.experienceYears} yrs',
                          label: 'Experience',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Edit fields
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Personal info'),
                    const SizedBox(height: 12),
                    _Field(
                      label: 'Full name',
                      controller: _nameCtrl,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      label: 'Shop address',
                      controller: _addressCtrl,
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      label: 'Bio',
                      controller: _bioCtrl,
                      icon: Icons.info_outline_rounded,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            // Services
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    const Expanded(child: _SectionTitle('Services & Pricing')),
                    TextButton.icon(
                      onPressed: _addService,
                      icon: const Icon(
                        Icons.add_rounded,
                        color: AppTheme.primary,
                        size: 16,
                      ),
                      label: const Text(
                        'Add',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
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
                              _services[i].name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _services[i].durationLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${_services[i].price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _editService(i),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteService(i),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                childCount: _services.length,
              ),
            ),

            // Logout
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
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppTheme.textDark,
    ),
  );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
      prefixIcon: Icon(icon, size: 20, color: AppTheme.textGrey),
    ),
  );
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
      ),
    ],
  );
}
