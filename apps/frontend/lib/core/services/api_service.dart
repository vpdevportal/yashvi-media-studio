import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/project.dart';

class ApiService {
  // Check if we're in production (served from port 80/443) or dev
  static bool get _isProduction {
    if (!kIsWeb) return false;
    final uri = Uri.base;
    return uri.port == 80 || uri.port == 443 || uri.port == 0;
  }

  static String get baseUrl {
    if (kIsWeb) {
      // In dev, Flutter runs on a different port, need to hit backend directly
      if (!_isProduction) {
        return 'http://localhost:8000';
      }
      // In production, use relative URLs
      return '';
    }
    return 'http://localhost:8000';
  }

  // API prefix: in prod nginx proxies /api/* to backend /*
  // In dev and mobile, call backend directly
  static String get apiPrefix {
    if (kIsWeb && _isProduction) {
      return '/api';
    }
    return '';
  }

  Future<http.Response> ping() async {
    return await http.get(Uri.parse('$baseUrl/ping'));
  }

  Future<http.Response> healthCheck() async {
    return await http.get(Uri.parse('$baseUrl/health'));
  }

  // Project endpoints
  Future<List<Project>> getProjects() async {
    final response = await http.get(Uri.parse('$baseUrl$apiPrefix/projects'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Project.fromJson(json)).toList();
    }
    throw Exception('Failed to load projects');
  }

  Future<Project> createProject(String name, String? description) async {
    final response = await http.post(
      Uri.parse('$baseUrl$apiPrefix/projects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Project.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create project');
  }

  Future<void> deleteProject(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl$apiPrefix/projects/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete project');
    }
  }
}

