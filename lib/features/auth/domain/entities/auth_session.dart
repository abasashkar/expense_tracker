import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.token,
    required this.nickname,
  });

  final String token;
  final String nickname;

  @override
  List<Object?> get props => [token, nickname];
}
