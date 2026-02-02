import 'dart:io';

class UserAgentUtils {
  static String get userAgent {
    String os = Platform.operatingSystem;
    // Capitalize first letter
    if (os.isNotEmpty) {
      os = os[0].toUpperCase() + os.substring(1);
    }
    return 'Flux/1.0 ($os)';
  }
}
