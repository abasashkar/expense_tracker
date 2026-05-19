import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/otp_pin_input.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpKey = GlobalKey<OtpPinInputState>();

  String _maskedPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return phone;
    final last4 = digits.substring(digits.length - 4);
    if (digits.length >= 10) {
      final prefix = digits.substring(digits.length - 10, digits.length - 6);
      return '$prefix****$last4';
    }
    return '****$last4';
  }

  void _submit(String otp) {
    context.read<AuthBloc>().add(AuthVerifyOtpRequested(otp));
  }

  void _resendOtp() {
    final phone = context.read<AuthBloc>().state.otpSession?.phone;
    if (phone == null) return;
    context.read<AuthBloc>().add(AuthSendOtpRequested(phone));
    _otpKey.currentState?.clear();
    _otpKey.currentState?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final otpSession = authState.otpSession;
    final isSubmitting = authState.isSubmitting;
    final phone = otpSession?.phone ?? '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: isSubmitting
                    ? null
                    : () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthBackToPhoneRequested());
                      },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.textPrimary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Enter the 6-Digit code sent to ',
                    ),
                    TextSpan(
                      text: _maskedPhone(phone),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: isSubmitting
                    ? null
                    : () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthBackToPhoneRequested());
                      },
                child: const Text(
                  'Change Number',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (otpSession != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    'Test OTP: ${otpSession.otp}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 36),
              OtpPinInput(
                key: _otpKey,
                enabled: !isSubmitting,
                onCompleted: _submit,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          final otp = _otpKey.currentState?.value ?? '';
                          if (otp.length == 6) _submit(otp);
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verify'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: isSubmitting ? null : _resendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
