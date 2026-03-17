import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';

class PhoneScreen extends StatefulWidget {
  final String role;
  const PhoneScreen({super.key, required this.role});
  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  Color get _color =>
      widget.role == 'barber' ? AppTheme.primary : AppTheme.secondary;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final number = _ctrl.text.trim();
    if (number.length != 10) {
      _snack('Please enter a valid 10-digit number');
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$number',
        timeout: const Duration(seconds: 60),
        codeSent: (verificationId, _) {
          setState(() => _loading = false);
          if (!mounted) {
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                phone: '+91$number',
                role: widget.role,
                verificationId: verificationId,
              ),
            ),
          );
        },
        verificationCompleted: (credential) {
          setState(() => _loading = false);
        },
        verificationFailed: (e) {
          setState(() => _loading = false);
          String msg = 'Failed to send OTP. Try again.';
          if (e.code == 'invalid-phone-number') {
            msg = 'Invalid phone number.';
          }
          if (e.code == 'too-many-requests') {
            msg = 'Too many attempts. Wait.';
          }
          _snack(msg);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
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
  Widget build(BuildContext context) {
    final isBarber = widget.role == 'barber';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isBarber ? Icons.content_cut_rounded : Icons.person_rounded,
                  color: _color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isBarber ? 'Barber Login' : 'Customer Login',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We'll send a one-time verification code",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppTheme.border),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text('🇮🇳', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 6),
                          Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                          letterSpacing: 1.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: '9876543210',
                          hintStyle: TextStyle(
                            color: AppTheme.textGrey,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0,
                          ),
                          counterText: '',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _loading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(backgroundColor: _color),
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
                          Text('Send OTP'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
