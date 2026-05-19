import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/utils/phone_formatter.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  bool _isPhoneFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() => _isPhoneFocused = _phoneFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final phone = PhoneFormatter.toE164(_phoneController.text.trim());
    context.read<AuthBloc>().add(AuthSendOtpRequested(phone));
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<AuthBloc, bool>(
      (bloc) => bloc.state.isSubmitting,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Log In Using Phone & OTP',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isPhoneFocused
                          ? AppTheme.primary
                          : AppTheme.cardBorder,
                      width: _isPhoneFocused ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: AppTheme.surfaceLight,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          onFieldSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                            hintText: 'Phone',
                            hintStyle: TextStyle(color: AppTheme.textSecondary),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            if (!PhoneFormatter.isValidIndianPhone(
                              value.trim(),
                            )) {
                              return 'Enter a valid 10-digit mobile number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
