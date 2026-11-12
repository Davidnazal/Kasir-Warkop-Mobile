import 'package:flutter/foundation.dart';

/// Konfigurasi endpoint API backend Laravel.
class ApiConstants {
  ApiConstants._();

  /// Otomatis menyesuaikan host:
  /// - Web / Desktop: http://127.0.0.1:8000/api
  /// - Android Emulator: http://10.0.2.2:8000/api
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static String get products => '$baseUrl/products';
  static String get transactions => '$baseUrl/transactions';
  static String get reports => '$baseUrl/reports';
}
