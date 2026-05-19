import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';

class NicknamePage extends StatefulWidget {
  const NicknamePage({super.key});

  @override
  State<NicknamePage> createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  bool get _isValid => _nicknameController.text.trim().length >= 2;

  void _submit() {
    if (!_isValid) return;
    context.read<AuthBloc>().add(
          AuthCreateAccountRequested(_nicknameController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<AuthBloc, bool>(
      (bloc) => bloc.state.isSubmitting,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                '👋 What should we call you?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a nickname for your account.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nicknameController,
                autofocus: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Eg: Johnnnie',
                  filled: true,
                  fillColor: AppTheme.surface,
                  suffixIcon: _isValid
                      ? const Icon(Icons.check_circle, color: AppTheme.success)
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: (!_isValid || isSubmitting) ? null : _submit,
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
    );
  }
}
