import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Default empty - will be loaded from SharedPreferences
  static String _baseUrl = '';

  // Get the current base URL
  static Future<String> getBaseUrl() async {
    if (_baseUrl.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString('api_url') ?? '';
    }
    return _baseUrl;
  }

  // Set base URL
  static Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_url', url);
  }

  // Create or get user
  static Future<Map<String, dynamic>> createUser(String username) async {
    try {
      final baseUrl = await getBaseUrl();
      if (baseUrl.isEmpty) {
        throw Exception('API URL not configured. Please go to Settings.');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/users?username=$username'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create new chat
  static Future<Map<String, dynamic>> createChat(int userId, String title) async {
    try {
      final baseUrl = await getBaseUrl();
      if (baseUrl.isEmpty) {
        throw Exception('API URL not configured');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/chats'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'title': title,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create chat');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get user chats
  static Future<List<dynamic>> getUserChats(int userId) async {
    try {
      final baseUrl = await getBaseUrl();
      if (baseUrl.isEmpty) {
        throw Exception('API URL not configured');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/chats/$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get chats');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get chat messages
  static Future<List<dynamic>> getChatMessages(int chatId) async {
    try {
      final baseUrl = await getBaseUrl();
      if (baseUrl.isEmpty) {
        throw Exception('API URL not configured');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/chats/$chatId/messages'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get messages');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Send message and stream response
  static Future<Stream<String>> sendMessage({
    required int userId,
    required int chatId,
    required String username,
    required String content,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      if (baseUrl.isEmpty) {
        throw Exception('API URL not configured');
      }
      
      final request = http.Request(
        'POST',
        Uri.parse('$baseUrl/api/chat'),
      );

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'user_id': userId,
        'chat_id': chatId,
        'username': username,
        'content': content,
      });

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        return streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .where((line) => line.isNotEmpty)
            .map((line) {
          if (line.startsWith('data: ')) {
            try {
              final json = jsonDecode(line.substring(6));
              return json['content'] ?? '';
            } catch (e) {
              return '';
            }
          }
          return '';
        })
            .where((chunk) => chunk.isNotEmpty);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Upload file
  static Future<Map<String, dynamic>> uploadFile({
    required int chatId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      if (baseUrl.isEmpty) {
        throw Exception('API URL not configured');
      }
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload'),
      );

      request.fields['chat_id'] = chatId.toString();
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Health check
  static Future<bool> healthCheck() async {
    try {
      final baseUrl = await getBaseUrl();
      if (baseUrl.isEmpty) {
        return false;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
