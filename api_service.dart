import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, or your machine's LAN IP for a real device.
  static const String baseUrl = 'http://127.0.0.1:8000/api/auth';

  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      await _saveToken(data['token']);
      return {'success': true, 'data': data};
    }
    return {'success': false, 'error': _extractError(data)};
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      await _saveToken(data['token']);
      return {'success': true, 'data': data};
    }
    return {'success': false, 'error': _extractError(data)};
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'error': 'Not logged in'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    }
    return {'success': false, 'error': _extractError(data)};
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static String _extractError(Map<String, dynamic> data) {
    if (data.containsKey('non_field_errors')) {
      return (data['non_field_errors'] as List).join(', ');
    }
    return data.entries.map((e) {
      final val = e.value is List ? (e.value as List).join(', ') : e.value;
      return '${e.key}: $val';
    }).join('\n');
  }
}