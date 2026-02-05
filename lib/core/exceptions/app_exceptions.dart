class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException([this.message = '', this.prefix]);

  @override
  String toString() {
    return prefix != null ? '$prefix: $message' : message;
  }
}

class NetworkException extends AppException {
  NetworkException([String message = 'Network error occurred'])
    : super(message, 'Network Error');
}

class ApiException extends AppException {
  ApiException([String message = 'API error occurred'])
    : super(message, 'API Error');
}

class TimeoutException extends AppException {
  TimeoutException([String message = 'Request timeout'])
    : super(message, 'Timeout');
}

class CacheException extends AppException {
  CacheException([String message = 'Cache error occurred'])
    : super(message, 'Cache Error');
}

class DatabaseException extends AppException {
  DatabaseException([String message = 'Database error occurred'])
    : super(message, 'Database Error');
}

class UnknownException extends AppException {
  UnknownException([String message = 'An unexpected error occurred'])
    : super(message, 'Unknown Error');
}
