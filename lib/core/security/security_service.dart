import 'package:safe_device/safe_device.dart';
import '../utils/logger.dart';

class SecurityService {
  Future<SecurityCheckResult> performSecurityCheck() async {
    AppLogger.log('Performing security check', tag: 'SECURITY');
    try {
      final isJailBroken = await SafeDevice.isJailBroken;
      final isDevelopmentMode = await SafeDevice.isDevelopmentModeEnable;
      final isRealDevice = await SafeDevice.isRealDevice;

      final isSecure = !isJailBroken && !isDevelopmentMode && isRealDevice;
      AppLogger.log(
        'Security check: JB=$isJailBroken, Dev=$isDevelopmentMode, Real=$isRealDevice, Secure=$isSecure',
        tag: 'SECURITY',
      );

      return SecurityCheckResult(
        isJailbroken: isJailBroken,
        isDeveloperMode: isDevelopmentMode,
        isSecure: isSecure,
      );
    } catch (e) {
      // If detection fails, allow the app to run but log the issue
      return SecurityCheckResult(
        isJailbroken: false,
        isDeveloperMode: false,
        isSecure: true,
        error: e.toString(),
      );
    }
  }
}

class SecurityCheckResult {
  final bool isJailbroken;
  final bool isDeveloperMode;
  final bool isSecure;
  final String? error;

  SecurityCheckResult({
    required this.isJailbroken,
    required this.isDeveloperMode,
    required this.isSecure,
    this.error,
  });

  String get message {
    if (error != null) {
      return 'Security check failed: $error';
    }

    if (isJailbroken) {
      return 'Device is rooted/jailbroken. App cannot run on compromised devices.';
    }

    if (isDeveloperMode) {
      return 'Developer mode is enabled. Please disable it for security.';
    }

    return 'Device security check passed.';
  }
}
