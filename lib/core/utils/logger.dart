import 'package:flutter/foundation.dart';
import '../../config/environment_config.dart';

class AppLogger {
  static void log(String message, {String? tag}) {
    if (EnvironmentConfig.enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      final logTag = tag ?? 'APP';
      debugPrint('[$timestamp] [$logTag] $message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (EnvironmentConfig.enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$timestamp] [ERROR] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  static void api(String method, String url, {Object? data, int? statusCode}) {
    if (EnvironmentConfig.enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$timestamp] [API] $method $url');
      if (data != null) debugPrint('Data: $data');
      if (statusCode != null) debugPrint('Status: $statusCode');
    }
  }

  static void db(String operation, {String? table, Object? data}) {
    if (EnvironmentConfig.enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$timestamp] [DB] $operation');
      if (table != null) debugPrint('Table: $table');
      if (data != null) debugPrint('Data: $data');
    }
  }

  static void state(String provider, String action, {Object? data}) {
    if (EnvironmentConfig.enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$timestamp] [STATE] $provider.$action');
      if (data != null) debugPrint('Data: $data');
    }
  }
}
