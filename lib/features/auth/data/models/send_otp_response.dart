class SendOtpResponse {
  const SendOtpResponse({
    required this.status,
    required this.otp,
    required this.userExists,
    this.nickname,
    this.token,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      status: json['status'] as String? ?? '',
      otp: json['otp']?.toString() ?? '',
      userExists: _parseBool(json['user_exists']),
      nickname: json['nickname'] as String?,
      token: json['token'] as String?,
    );
  }

  final String status;
  final String otp;
  final bool userExists;
  final String? nickname;
  final String? token;

  bool get isSuccess => status.toLowerCase() == 'success';

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }
}
