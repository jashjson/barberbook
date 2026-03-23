import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'role_screen.dart';
import 'barber/barber_main.dart';
import 'barber/barber_setup_screen.dart';
import 'customer/customer_main.dart';
import 'customer/customer_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { super.initState(); _checkAuth(); }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { _go(const RoleScreen()); return; }

    final barberDoc = await FirebaseFirestore.instance
        .collection('barbers').doc(user.uid).get();
    if (barberDoc.exists) {
      final done = barberDoc.data()?['isProfileDone'] ?? false;
      if (mounted) _go(done ? const BarberMain() : const BarberSetupScreen());
      return;
    }

    final custDoc = await FirebaseFirestore.instance
        .collection('customers').doc(user.uid).get();
    if (custDoc.exists) {
      final done = custDoc.data()?['isProfileDone'] ?? false;
      if (mounted) _go(done ? const CustomerMain() : const CustomerSetupScreen());
      return;
    }
    if (mounted) _go(const RoleScreen());
  }

  void _go(Widget screen) {
    Navigator.pushReplacement(context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.content_cut_rounded, color: Colors.white, size: 56),
        ),
        const SizedBox(height: 20),
        const Text('BarberBook', style: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold,
            color: Colors.white, letterSpacing: 1)),
        const SizedBox(height: 8),
        const Text('Book your perfect cut',
            style: TextStyle(fontSize: 15, color: Colors.white70)),
        const SizedBox(height: 48),
        const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ])),
    );
  }
}