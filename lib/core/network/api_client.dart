import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../error/exceptions.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _jsonHeaders({bool withAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth && _authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Map<String, String> _formHeaders({bool withAuth = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (withAuth && _authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    if (requiresAuth && (_authToken == null || _authToken!.isEmpty)) {
      throw ServerException('Authentication required');
    }
    try {
      return _handleResponse(
        await _client.post(
          Uri.parse('${ApiConstants.baseUrl}$path'),
          headers: _jsonHeaders(withAuth: requiresAuth),
          body: body != null ? jsonEncode(body) : null,
        ),
      );
    } on ServerException {
      rethrow;
    } on SocketException {
      throw NetworkException();
    } catch (_) {
      throw ServerException('Request failed');
    }
  }

  /// Matches Postman `formdata` requests (application/x-www-form-urlencoded).
  Future<Map<String, dynamic>> postForm(
    String path, {
    required Map<String, String> fields,
    bool requiresAuth = false,
  }) async {
    if (requiresAuth && (_authToken == null || _authToken!.isEmpty)) {
      throw ServerException('Authentication required');
    }
    try {
      return _handleResponse(
        await _client.post(
          Uri.parse('${ApiConstants.baseUrl}$path'),
          headers: _formHeaders(withAuth: requiresAuth),
          body: fields,
        ),
      );
    } on ServerException {
      rethrow;
    } on SocketException {
      throw NetworkException();
    } catch (_) {
      throw ServerException('Request failed');
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool requiresAuth = false,
  }) async {
    if (requiresAuth && (_authToken == null || _authToken!.isEmpty)) {
      throw ServerException('Authentication required');
    }
    try {
      return _handleResponse(
        await _client.get(
          Uri.parse('${ApiConstants.baseUrl}$path'),
          headers: _formHeaders(withAuth: requiresAuth),
        ),
      );
    } on ServerException {
      rethrow;
    } on SocketException {
      throw NetworkException();
    } catch (_) {
      throw ServerException('Request failed');
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    if (requiresAuth && (_authToken == null || _authToken!.isEmpty)) {
      throw ServerException('Authentication required');
    }
    try {
      return _handleResponse(
        await _client.delete(
          Uri.parse('${ApiConstants.baseUrl}$path'),
          headers: _jsonHeaders(withAuth: requiresAuth),
          body: body != null ? jsonEncode(body) : null,
        ),
      );
    } on ServerException {
      rethrow;
    } on SocketException {
      throw NetworkException();
    } catch (_) {
      throw ServerException('Request failed');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> decoded;
    try {
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw const FormatException('Expected JSON object');
      }
      decoded = body;
    } catch (_) {
      final snippet = response.body.length > 120
          ? '${response.body.substring(0, 120)}...'
          : response.body;
      throw ServerException(
        response.statusCode >= 400
            ? 'Request failed (${response.statusCode})'
            : 'Invalid response from server: $snippet',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final status = decoded['status']?.toString().toLowerCase();
      if (status == 'error') {
        throw ServerException(
          decoded['message']?.toString() ??
              decoded['messege']?.toString() ??
              'Request failed',
        );
      }
      return decoded;
    }

    final message = decoded['message']?.toString() ??
        decoded['messege']?.toString() ??
        decoded['error']?.toString() ??
        'Request failed (${response.statusCode})';
    throw ServerException(message);
  }

  void dispose() {
    _client.close();
  }
}
