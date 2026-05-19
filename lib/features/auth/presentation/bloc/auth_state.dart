part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  onboarding,
  unauthenticated,
  otpSent,
  nicknameRequired,
  authenticated,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.session,
    this.otpSession,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final AuthStatus status;
  final AuthSession? session;
  final OtpSession? otpSession;
  final String? errorMessage;
  final bool isSubmitting;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    OtpSession? otpSession,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
    bool clearOtpSession = false,
    bool clearSession = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      otpSession: clearOtpSession ? null : (otpSession ?? this.otpSession),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        status,
        session,
        otpSession,
        errorMessage,
        isSubmitting,
      ];
}
