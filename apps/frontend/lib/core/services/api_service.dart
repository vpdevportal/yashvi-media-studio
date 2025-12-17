import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  // In production web, use relative URLs (nginx proxies /api, /ping, /health)
  // In development, use localhost:8000
  static String get baseUrl {
    if (kIsWeb) {
      // For web, use relative path - works in both dev and prod
      return '';
    }
    return 'http://localhost:8000';
  }

  Future<http.Response> ping() async {
    return await http.get(Uri.parse('$baseUrl/ping'));
  }

  Future<http.Response> healthCheck() async {
    return await http.get(Uri.parse('$baseUrl/health'));
  }
}

