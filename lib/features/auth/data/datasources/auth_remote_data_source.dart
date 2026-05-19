import 'package:expense_tracker/core/constants/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/features/auth/data/models/create_account_response.dart';
import 'package:expense_tracker/features/auth/data/models/send_otp_response.dart';

abstract class AuthRemoteDataSource {
  Future<SendOtpResponse> sendOtp(String phone);

  Future<CreateAccountResponse> createAccount({
    required String phone,
    required String nickname,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<SendOtpResponse> sendOtp(String phone) async {
    try {
      final json = await _apiClient.postForm(
        ApiConstants.sendOtp,
        fields: {'phone': phone},
      );
      final response = SendOtpResponse.fromJson(json);
      if (!response.isSuccess) {
        throw ServerException('Failed to send OTP');
      }
      return response;
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Failed to send OTP');
    }
  }

  @override
  Future<CreateAccountResponse> createAccount({
    required String phone,
    required String nickname,
  }) async {
    try {
      final json = await _apiClient.postForm(
        ApiConstants.createAccount,
        fields: {
          'phone': phone,
          'nickname': nickname,
        },
      );
      final response = CreateAccountResponse.fromJson(json);
      if (!response.isSuccess || response.token.isEmpty) {
        throw ServerException('Failed to create account');
      }
      return response;
    } on ServerException {
      rethrow;
    } catch (_) {
      throw ServerException('Failed to create account');
    }
  }
}
