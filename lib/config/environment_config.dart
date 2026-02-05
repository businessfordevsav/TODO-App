import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor { dev, staging, qa, production }

class EnvironmentConfig {
  static AppFlavor _currentFlavor = AppFlavor.dev;

  static AppFlavor get flavor => _currentFlavor;

  static String get environmentName =>
      dotenv.env['ENVIRONMENT'] ?? 'development';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get appName => dotenv.env['APP_NAME'] ?? 'TODO App';
  static bool get enableLogging => dotenv.env['ENABLE_LOGGING'] == 'true';

  // Parse flavor from dart-define or default to dev
  static AppFlavor _parseFlavor(String? flavorString) {
    return switch (flavorString?.toLowerCase()) {
      'staging' => AppFlavor.staging,
      'qa' => AppFlavor.qa,
      'production' || 'prod' => AppFlavor.production,
      _ => AppFlavor.dev,
    };
  }

  static Future<void> initialize([String? flavorString]) async {
    _currentFlavor = _parseFlavor(
      flavorString ?? const String.fromEnvironment('FLAVOR'),
    );

    final envFile = switch (_currentFlavor) {
      AppFlavor.dev => '.env.dev',
      AppFlavor.staging => '.env.staging',
      AppFlavor.qa => '.env.qa',
      AppFlavor.production => '.env.prod',
    };

    await dotenv.load(fileName: envFile);
  }

  static bool get isProduction => _currentFlavor == AppFlavor.production;
  static bool get isDevelopment => _currentFlavor == AppFlavor.dev;
}
