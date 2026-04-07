import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/auth_service.dart';
import '../../../core/constants.dart';

class NutriologoApi {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token available.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/dashboard'),
      headers: await _headers(),
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> getClientsPage({
    String search = '',
    int page = 1,
    int perPage = 10,
  }) async {
    final query = search.trim();
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/nutriologo/clientes?search=${Uri.encodeQueryComponent(query)}&page=$page&per_page=$perPage',
      ),
      headers: await _headers(),
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> getPlansPage({
    String search = '',
    int page = 1,
    int perPage = 10,
  }) async {
    final query = search.trim();
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/nutriologo/planes?search=${Uri.encodeQueryComponent(query)}&page=$page&per_page=$perPage',
      ),
      headers: await _headers(),
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> getPlanDetail(int planId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/planes/$planId'),
      headers: await _headers(),
    );

    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> createPlan({
    required String title,
    String? description,
    String? goal,
    int? dailyCalories,
    List<Map<String, dynamic>> meals = const [],
  }) async {
    final descriptionTrimmed = description?.trim();
    final goalTrimmed = goal?.trim();
    final payload = <String, dynamic>{
      'title': title,
      'description': descriptionTrimmed,
      'goal': goalTrimmed,
      'daily_calories': dailyCalories,
      if (meals.isNotEmpty) 'meals': meals,
    };
    payload.removeWhere(
      (key, value) => value == null || (value is String && value.isEmpty),
    );

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/planes'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );

    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> assignPlan({
    required int planId,
    required int clientId,
    String? startsAt,
    String? notes,
  }) async {
    final notesTrimmed = notes?.trim();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/planes/$planId/asignar'),
      headers: await _headers(),
      body: jsonEncode({
        'client_id': clientId,
        if (startsAt?.isNotEmpty ?? false) 'starts_at': startsAt,
        if (notesTrimmed?.isNotEmpty ?? false) 'notes': notesTrimmed,
      }),
    );

    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updatePlan({
    required int planId,
    String? title,
    String? description,
    String? goal,
    int? dailyCalories,
    bool? isActive,
  }) async {
    final titleTrimmed = title?.trim();
    final descriptionTrimmed = description?.trim();
    final goalTrimmed = goal?.trim();

    final payload = <String, dynamic>{
      'title': titleTrimmed,
      'description': descriptionTrimmed,
      'goal': goalTrimmed,
      'daily_calories': dailyCalories,
      'is_active': isActive,
    };

    payload.removeWhere(
      (key, value) => value == null || (value is String && value.isEmpty),
    );

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/planes/$planId'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );

    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  static Future<void> deletePlan(int planId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/planes/$planId'),
      headers: await _headers(),
    );

    _decode(response);
  }

  static Future<Map<String, dynamic>> updateAssignmentStatus({
    required int assignmentId,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '${ApiConfig.baseUrl}/nutriologo/asignaciones/$assignmentId/status',
      ),
      headers: await _headers(),
      body: jsonEncode({'status': status}),
    );

    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final json = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw Exception(
        json['error']?.toString() ??
            json['message']?.toString() ??
            'Request failed (${response.statusCode}).',
      );
    }

    return json;
  }
}
