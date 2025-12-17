import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  Future<http.Response> ping() async {
    return await http.get(Uri.parse('$baseUrl/ping'));
  }

  Future<http.Response> healthCheck() async {
    return await http.get(Uri.parse('$baseUrl/health'));
  }
}

