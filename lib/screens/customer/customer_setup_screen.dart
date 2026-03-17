import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import 'customer_main.dart';

class CustomerSetupScreen extends StatefulWidget {
  const CustomerSetupScreen({super.key});
  @override
  State<CustomerSetupScreen> createState() => _CustomerSetupScreenState();
}

class _CustomerSetupScreenState extends State<CustomerSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('customers').doc(uid).update({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'isProfileDone': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CustomerMain()),
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
              color: AppTheme.secondary,
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
                  const Text(
                    'Set up your profile to get started',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppTheme.secondary.withValues(
                              alpha: 0.12,
                            ),
                            child: Text(
                              _nameCtrl.text.isNotEmpty
                                  ? _nameCtrl.text[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Your profile picture',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textGrey,
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                    const Text(
                      'Personal info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This is how barbers will see you',
                      style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameCtrl,
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name *',
                        hintText: 'e.g. Arun Kumar',
                        labelStyle: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email (optional)',
                        hintText: 'e.g. arun@email.com',
                        labelStyle: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.secondary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppTheme.secondary,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your name will be shown to barbers when you book.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.secondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _loading ? null : _finish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Get Started'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
