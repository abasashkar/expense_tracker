class ServerException implements Exception {
  ServerException([this.message = 'Server error occurred']);

  final String message;
}

class CacheException implements Exception {
  CacheException([this.message = 'Cache error occurred']);

  final String message;
}

class NetworkException implements Exception {
  NetworkException([this.message = 'No internet connection']);

  final String message;
}
