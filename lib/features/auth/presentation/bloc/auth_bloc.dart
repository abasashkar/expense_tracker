import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/features/auth/domain/entities/auth_session.dart';
import 'package:expense_tracker/features/auth/domain/entities/otp_session.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthOnboardingCompleted>(_onOnboardingCompleted);
    on<AuthSendOtpRequested>(_onSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthCreateAccountRequested>(_onCreateAccountRequested);
    on<AuthBackToPhoneRequested>(_onBackToPhoneRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final sessionResult = await _authRepository.getSavedSession();
    if (sessionResult.failure != null) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: sessionResult.failure!.message,
        ),
      );
      return;
    }

    if (sessionResult.data != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          session: sessionResult.data,
          clearError: true,
        ),
      );
      return;
    }

    final onboardingResult = await _authRepository.isOnboardingComplete();
    if (onboardingResult.data != true) {
      emit(
        state.copyWith(
          status: AuthStatus.onboarding,
          clearError: true,
          clearSession: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearError: true,
        clearSession: true,
      ),
    );
  }

  Future<void> _onOnboardingCompleted(
    AuthOnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.setOnboardingComplete();
    if (result.failure != null) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: result.failure!.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearError: true,
      ),
    );
  }

  Future<void> _onSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final keepOtpScreen = state.status == AuthStatus.otpSent;
    emit(
      state.copyWith(
        status: keepOtpScreen ? AuthStatus.otpSent : AuthStatus.unauthenticated,
        isSubmitting: true,
        clearError: true,
      ),
    );

    final result = await _authRepository.sendOtp(event.phone);
    if (result.failure != null) {
      emit(
        state.copyWith(
          status: keepOtpScreen ? AuthStatus.otpSent : AuthStatus.unauthenticated,
          isSubmitting: false,
          errorMessage: result.failure!.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.otpSent,
        otpSession: result.data,
        isSubmitting: false,
        clearError: true,
      ),
    );
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final otpSession = state.otpSession;
    if (otpSession == null) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Session expired. Please request OTP again.',
        ),
      );
      return;
    }

    if (event.otp.trim() != otpSession.otp) {
      emit(
        state.copyWith(
          status: AuthStatus.otpSent,
          errorMessage: 'Invalid OTP. Please try again.',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    if (otpSession.userExists) {
      final nickname = otpSession.nickname;
      final token = otpSession.token;
      if (nickname == null ||
          nickname.isEmpty ||
          token == null ||
          token.isEmpty) {
        emit(
          state.copyWith(
            status: AuthStatus.otpSent,
            isSubmitting: false,
            errorMessage: 'Invalid server response for existing user.',
          ),
        );
        return;
      }

      final saveResult = await _authRepository.saveSession(
        token: token,
        nickname: nickname,
      );

      if (saveResult.failure != null) {
        emit(
          state.copyWith(
            status: AuthStatus.otpSent,
            isSubmitting: false,
            errorMessage: saveResult.failure!.message,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          session: saveResult.data,
          isSubmitting: false,
          clearOtpSession: true,
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.nicknameRequired,
        isSubmitting: false,
        clearError: true,
      ),
    );
  }

  Future<void> _onCreateAccountRequested(
    AuthCreateAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    final otpSession = state.otpSession;
    if (otpSession == null) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Session expired. Please request OTP again.',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    final result = await _authRepository.createAccount(
      phone: otpSession.phone,
      nickname: event.nickname.trim(),
    );

    if (result.failure != null) {
      emit(
        state.copyWith(
          status: AuthStatus.nicknameRequired,
          isSubmitting: false,
          errorMessage: result.failure!.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        session: result.data,
        isSubmitting: false,
        clearOtpSession: true,
        clearError: true,
      ),
    );
  }

  void _onBackToPhoneRequested(
    AuthBackToPhoneRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearOtpSession: true,
        clearError: true,
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.clearSession();
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
      ),
    );
  }
}
