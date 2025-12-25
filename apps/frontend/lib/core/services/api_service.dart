import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/project.dart';
import '../models/episode.dart';
import '../models/story.dart';
import '../models/scene.dart';

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
        return 'http://localhost:6005';
      }
      // In production, use relative URLs
      return '';
    }
    return 'http://localhost:6005';
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

  // Episode endpoints
  Future<List<Episode>> getEpisodesByProject(String projectId) async {
    final response = await http.get(Uri.parse('$baseUrl$apiPrefix/episodes/project/$projectId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Episode.fromJson(json)).toList();
    }
    throw Exception('Failed to load episodes');
  }

  Future<Episode> createEpisode({
    required String projectId,
    required String title,
    String? description,
    required int episodeNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$apiPrefix/episodes/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'project_id': projectId,
        'title': title,
        'description': description,
        'episode_number': episodeNumber,
        'status': 'draft',
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Episode.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create episode');
  }

  Future<void> deleteEpisode(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl$apiPrefix/episodes/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete episode');
    }
  }

  // Story endpoints
  Future<Story> getStoryByEpisode(String episodeId) async {
    final response = await http.get(Uri.parse('$baseUrl$apiPrefix/stories/episode/$episodeId'));
    if (response.statusCode == 200) {
      return Story.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load story');
  }

  Future<Story> updateStory(String episodeId, String content) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$apiPrefix/stories/episode/$episodeId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'content': content,
      }),
    );
    if (response.statusCode == 200) {
      return Story.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update story');
  }

  // Screenplay endpoints
  Future<List<Scene>> getScreenplayScenes(String episodeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl$apiPrefix/screenplays/episode/$episodeId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Scene.fromJson(json)).toList();
    }
    throw Exception('Failed to load screenplay scenes');
  }

  Future<void> clearScreenplays(String episodeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$apiPrefix/screenplays/episode/$episodeId'),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to clear screenplays');
    }
  }

  Future<List<Scene>> generateScreenplay(String episodeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl$apiPrefix/screenplays/episode/$episodeId/generate'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Scene.fromJson(json)).toList();
    }
    throw Exception('Failed to generate screenplay');
  }

  // Video Generation endpoints
  Future<Uint8List> generateVideo({
    required Uint8List imageBytes,
    required String prompt,
    required String serviceType,
  }) async {
    // Create multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$apiPrefix/videos/generate'),
    );
    
    // Add image as bytes with proper content type
    final imageFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: 'image.jpg',
      contentType: MediaType('image', 'jpeg'),
    );
    
    request.fields['prompt'] = prompt;
    request.fields['service_type'] = serviceType;
    request.files.add(imageFile);
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.bodyBytes;
    }
    throw Exception('Failed to generate video: ${response.body}');
  }
}

