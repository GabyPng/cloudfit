import 'package:flutter/foundation.dart';

/// Base URL for the CloudFit Laravel API.
class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Browser (Flutter Web) — same host as the dev server
      return 'http://localhost:8000/api';
    }
    // Android emulator: 10.0.2.2 maps to the host machine
    return 'http://10.0.2.2:8000/api';
  }
}
