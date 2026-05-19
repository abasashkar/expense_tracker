class CreateAccountResponse {
  const CreateAccountResponse({
    required this.status,
    required this.token,
  });

  factory CreateAccountResponse.fromJson(Map<String, dynamic> json) {
    return CreateAccountResponse(
      status: json['status'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  final String status;
  final String token;

  bool get isSuccess => status.toLowerCase() == 'success';
}
