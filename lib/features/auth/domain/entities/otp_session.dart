import 'package:equatable/equatable.dart';

class OtpSession extends Equatable {
  const OtpSession({
    required this.phone,
    required this.otp,
    required this.userExists,
    this.nickname,
    this.token,
  });

  final String phone;
  final String otp;
  final bool userExists;
  final String? nickname;
  final String? token;

  @override
  List<Object?> get props => [phone, otp, userExists, nickname, token];
}
