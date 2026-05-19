import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/pages/nickname_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/onboarding_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/phone_login_page.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/home_shell_page.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppTheme.danger,
              ),
            );
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              backgroundColor: AppTheme.background,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          case AuthStatus.onboarding:
            return const OnboardingPage();
          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const PhoneLoginPage();
          case AuthStatus.otpSent:
            return const OtpVerificationPage();
          case AuthStatus.nicknameRequired:
            return const NicknamePage();
          case AuthStatus.authenticated:
            return HomeShellPage(
              nickname: state.session?.nickname ?? '',
            );
        }
      },
    );
  }
}
