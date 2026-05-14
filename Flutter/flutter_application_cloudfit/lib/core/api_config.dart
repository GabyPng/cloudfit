import 'package:flutter/foundation.dart';

/// Base URL for the CloudFit Laravel API.
class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Browser (Flutter Web) — same host as the dev server
      return 'http://localhost:8000/api';
    }
    // Dispositivo físico: IP local de la PC en la red Wi-Fi
    return 'http://192.168.1.11:8000/api';
  }
}
