// lib/screens/auth/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final UserRole role;
  const OtpScreen({super.key, required this.phone, required this.role});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  int _resendSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
        _startResendTimer();
      }
    });
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    final auth = context.read<AuthProvider>();
    final success =
        await auth.verifyOtp(widget.phone, otp, role: widget.role);
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'OTP verification failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontWeight: FontWeight.w800),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.loginOtp,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              '${AppStrings.loginOtpSub} +91 ${widget.phone}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // OTP Input
            Center(
              child: Pinput(
                controller: _otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border:
                        Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: AppColors.primaryLight,
                    border: Border.all(color: AppColors.primary),
                  ),
                ),
                onCompleted: (_) => _verify(),
              ),
            ),

            const SizedBox(height: 24),

            // Resend
            Center(
              child: _resendSeconds > 0
                  ? Text(
                      'Resend OTP in ${_resendSeconds}s',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textHint),
                    )
                  : TextButton(
                      onPressed: () {
                        setState(() => _resendSeconds = 30);
                        _startResendTimer();
                        context.read<AuthProvider>().sendOtp(widget.phone);
                      },
                      child: const Text('Resend OTP'),
                    ),
            ),

            const Spacer(),

            // ✅ FIX: Consumer<AuthProvider> - correct type now resolves
            Consumer<AuthProvider>(
              builder: (_, auth, __) => ElevatedButton(
                onPressed: auth.isLoading ? null : _verify,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(AppStrings.loginVerify),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}