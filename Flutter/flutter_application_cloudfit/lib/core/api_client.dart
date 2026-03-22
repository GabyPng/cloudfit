import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'constants.dart';

class ApiClient {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: await _headers(),
    );
    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return response;
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return response;
  }

  static Future<http.Response> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: await _headers(),
    );
    return response;
  }
}
