part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthOnboardingCompleted extends AuthEvent {
  const AuthOnboardingCompleted();
}

class AuthSendOtpRequested extends AuthEvent {
  const AuthSendOtpRequested(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class AuthVerifyOtpRequested extends AuthEvent {
  const AuthVerifyOtpRequested(this.otp);

  final String otp;

  @override
  List<Object?> get props => [otp];
}

class AuthCreateAccountRequested extends AuthEvent {
  const AuthCreateAccountRequested(this.nickname);

  final String nickname;

  @override
  List<Object?> get props => [nickname];
}

class AuthBackToPhoneRequested extends AuthEvent {
  const AuthBackToPhoneRequested();
}
