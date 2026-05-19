import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_session.dart';
import 'package:expense_tracker/features/auth/domain/entities/otp_session.dart';

abstract class AuthRepository {
  Future<({OtpSession? data, Failure? failure})> sendOtp(String phone);

  Future<({AuthSession? data, Failure? failure})> createAccount({
    required String phone,
    required String nickname,
  });

  Future<({AuthSession? data, Failure? failure})> saveSession({
    required String token,
    required String nickname,
  });

  Future<({AuthSession? data, Failure? failure})> getSavedSession();

  Future<({bool? data, Failure? failure})> isOnboardingComplete();

  Future<({bool? data, Failure? failure})> setOnboardingComplete();
}
