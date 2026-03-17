import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'barber/barber_main.dart';
import 'barber/barber_setup_screen.dart';
import 'customer/customer_main.dart';
import 'customer/customer_setup_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone, role, verificationId;
  const OtpScreen({
    super.key,
    required this.phone,
    required this.role,
    required this.verificationId,
  });
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _seconds = 60;
  bool _canResend = false;

  Color get _color =>
      widget.role == 'barber' ? AppTheme.primary : AppTheme.secondary;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _nodes[0].requestFocus(),
    );
  }

  void _startTimer() {
    setState(() {
      _seconds = 60;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _seconds--);
      if (_seconds <= 0) {
        if (mounted) setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  void _onChanged(int i, String v) {
    if (v.isNotEmpty && i < 5) {
      _nodes[i + 1].requestFocus();
    }
    if (v.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    final otp = _ctrls.map((c) => c.text).join();
    if (otp.length == 6) {
      FocusScope.of(context).unfocus();
      _verify(otp);
    }
  }

  Future<void> _verify(String otp) async {
    setState(() => _loading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = result.user;
      if (user == null) {
        _snack('Verification failed. Try again.');
        setState(() => _loading = false);
        return;
      }
      final uid = user.uid;
      final db = FirebaseFirestore.instance;
      if (widget.role == 'barber') {
        final doc = await db.collection('barbers').doc(uid).get();
        if (!doc.exists) {
          await db.collection('barbers').doc(uid).set({
            'uid': uid,
            'phone': widget.phone,
            'role': 'barber',
            'name': '',
            'shopName': '',
            'specialty': '',
            'location': '',
            'bio': '',
            'rating': 0.0,
            'reviewCount': 0,
            'totalClients': 0,
            'experienceYears': 0,
            'isOpen': true,
            'status': 'open',
            'isProfileDone': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        if (!mounted) return;
        setState(() => _loading = false);
        final done = doc.exists
            ? (doc.data()?['isProfileDone'] ?? false)
            : false;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                done ? const BarberMain() : const BarberSetupScreen(),
          ),
          (r) => false,
        );
      } else {
        final doc = await db.collection('customers').doc(uid).get();
        bool done = false;
        if (!doc.exists) {
          await db.collection('customers').doc(uid).set({
            'uid': uid,
            'phone': widget.phone,
            'role': 'customer',
            'name': '',
            'email': '',
            'favouriteBarberIds': [],
            'isProfileDone': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          done = doc.data()?['isProfileDone'] ?? false;
        }
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                done ? const CustomerMain() : const CustomerSetupScreen(),
          ),
          (r) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      String msg = 'Wrong OTP. Try again.';
      if (e.code == 'invalid-verification-code') {
        msg = 'Invalid OTP entered.';
      }
      if (e.code == 'session-expired') {
        msg = 'OTP expired. Request a new one.';
      }
      _snack(msg);
      for (final c in _ctrls) {
        c.clear();
      }
      _nodes[0].requestFocus();
    } catch (e) {
      setState(() => _loading = false);
      _snack('Error: ${e.toString()}');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.textDark),
    );
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final f in _nodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Code sent to  '),
                    TextSpan(
                      text: widget.phone,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => _OtpBox(
                    controller: _ctrls[i],
                    focusNode: _nodes[i],
                    onChanged: (v) => _onChanged(i, v),
                    activeColor: _color,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              if (_loading)
                Center(child: CircularProgressIndicator(color: _color))
              else
                ElevatedButton(
                  onPressed: () {
                    final otp = _ctrls.map((c) => c.text).join();
                    if (otp.length == 6) {
                      _verify(otp);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _color),
                  child: const Text('Verify & Continue'),
                ),
              const SizedBox(height: 24),
              Center(
                child: _canResend
                    ? GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14),
                            children: [
                              const TextSpan(
                                text: "Didn't receive the code?  ",
                                style: TextStyle(color: AppTheme.textGrey),
                              ),
                              TextSpan(
                                text: 'Resend OTP',
                                style: TextStyle(
                                  color: _color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(
                        'Resend OTP in  $_seconds s',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final Color activeColor;
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.activeColor,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: activeColor, width: 2.5),
          ),
        ),
      ),
    );
  }
}
