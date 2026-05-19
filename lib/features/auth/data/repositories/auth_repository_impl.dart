import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_session.dart';
import 'package:expense_tracker/features/auth/domain/entities/otp_session.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required ApiClient apiClient,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _apiClient = apiClient;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final ApiClient _apiClient;

  @override
  Future<({OtpSession? data, Failure? failure})> sendOtp(String phone) async {
    try {
      final response = await _remoteDataSource.sendOtp(phone);
      return (
        data: OtpSession(
          phone: phone,
          otp: response.otp,
          userExists: response.userExists,
          nickname: response.nickname,
          token: response.token,
        ),
        failure: null,
      );
    } on ServerException catch (e) {
      return (data: null, failure: ServerFailure(e.message));
    } on NetworkException catch (e) {
      return (data: null, failure: NetworkFailure(e.message));
    } catch (_) {
      return (data: null, failure: const ServerFailure());
    }
  }

  @override
  Future<({AuthSession? data, Failure? failure})> createAccount({
    required String phone,
    required String nickname,
  }) async {
    try {
      final response = await _remoteDataSource.createAccount(
        phone: phone,
        nickname: nickname,
      );
      return saveSession(
        token: response.token,
        nickname: nickname,
      );
    } on ServerException catch (e) {
      return (data: null, failure: ServerFailure(e.message));
    } catch (_) {
      return (data: null, failure: const ServerFailure());
    }
  }

  @override
  Future<({AuthSession? data, Failure? failure})> saveSession({
    required String token,
    required String nickname,
  }) async {
    try {
      await _localDataSource.saveSession(
        token: token,
        nickname: nickname,
      );
      _apiClient.setAuthToken(token);
      return (
        data: AuthSession(token: token, nickname: nickname),
        failure: null,
      );
    } on CacheException catch (e) {
      return (data: null, failure: CacheFailure(e.message));
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({AuthSession? data, Failure? failure})> getSavedSession() async {
    try {
      final session = await _localDataSource.getSession();
      final token = session.token;
      final nickname = session.nickname;

      if (token == null ||
          token.isEmpty ||
          nickname == null ||
          nickname.isEmpty) {
        return (data: null, failure: null);
      }

      _apiClient.setAuthToken(token);
      return (
        data: AuthSession(token: token, nickname: nickname),
        failure: null,
      );
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({bool? data, Failure? failure})> isOnboardingComplete() async {
    try {
      final complete = await _localDataSource.isOnboardingComplete();
      return (data: complete, failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({bool? data, Failure? failure})> setOnboardingComplete() async {
    try {
      await _localDataSource.setOnboardingComplete();
      return (data: true, failure: null);
    } on CacheException catch (e) {
      return (data: null, failure: CacheFailure(e.message));
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<void> clearSession() async {
    await _localDataSource.clearSession();
    _apiClient.setAuthToken(null);
  }
}
