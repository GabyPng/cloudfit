import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/auth_service.dart';
import '../../../core/constants.dart';

class NutriologoApi {
  // Persistent client — reuses TCP connections across requests (HTTP keep-alive).
  static final http.Client _http = http.Client();

  // Dashboard cache — avoids redundant round-trips when navigating back to home.
  static Map<String, dynamic>? _dashboardCache;
  static DateTime? _dashboardCachedAt;

  static Map<String, String> _headers() {
    final token = AuthService.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No auth token available.');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getDashboard({bool force = false}) async {
    final cachedAt = _dashboardCachedAt;
    if (!force &&
        _dashboardCache != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt).inSeconds < 60) {
      return _dashboardCache!;
    }

    final response = await _http.get(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/dashboard'),
      headers: _headers(),
    );

    final result = _decode(response);
    _dashboardCache = result;
    _dashboardCachedAt = DateTime.now();
    return result;
  }

  static Future<Map<String, dynamic>> getClientsPage({
    String search = '',
    int page = 1,
    int perPage = 10,
  }) async {
    final query = search.trim();
    final response = await _http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/nutriologo/clientes?search=${Uri.encodeQueryComponent(query)}&page=$page&per_page=$perPage',
      ),
      headers: _headers(),
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> getPlansPage({
    String search = '',
    int page = 1,
    int perPage = 10,
  }) async {
    final query = search.trim();
    final response = await _http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/nutriologo/planes?search=${Uri.encodeQueryComponent(query)}&page=$page&per_page=$perPage',
      ),
      headers: _headers(),
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> getPlanDetail(int planId) async {
    final response = await _http.get(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/planes/$planId'),
      headers: _headers(),
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

    final response = await _http.post(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/planes'),
      headers: _headers(),
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

    final response = await _http.post(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/planes/$planId/asignar'),
      headers: _headers(),
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
    List<Map<String, dynamic>>? meals,
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
      if (meals != null) 'meals': meals,
    };

    payload.removeWhere(
      (key, value) => key != 'meals' && (value == null || (value is String && value.isEmpty)),
    );

    final response = await _http.put(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/planes/$planId'),
      headers: _headers(),
      body: jsonEncode(payload),
    );

    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  static Future<void> deletePlan(int planId) async {
    final response = await _http.delete(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/planes/$planId'),
      headers: _headers(),
    );

    _decode(response);
  }

  static Future<Map<String, dynamic>> updateAssignmentStatus({
    required int assignmentId,
    required String status,
  }) async {
    final response = await _http.patch(
      Uri.parse(
        '${ApiConfig.baseUrl}/nutriologo/asignaciones/$assignmentId/status',
      ),
      headers: _headers(),
      body: jsonEncode({'status': status}),
    );

    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  // ── Seguimiento ──────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getSeguimientoPacientes() async {
    final response = await _http.get(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/seguimiento/pacientes'),
      headers: _headers(),
    );
    final body = _decode(response);
    return ((body['data'] as List<dynamic>?) ?? [])
        .cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> getHistorial(int clientId) async {
    final response = await _http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/nutriologo/seguimiento/$clientId/historial'),
      headers: _headers(),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> addProgress({
    required int clientId,
    required String date,
    double? weightKg,
    double? bmi,
    double? bodyFatPct,
    double? muscleMassKg,
    int? caloriesTarget,
    int? adherencePct,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (bmi != null) 'bmi': bmi,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (muscleMassKg != null) 'muscle_mass_kg': muscleMassKg,
      if (caloriesTarget != null) 'calories_target': caloriesTarget,
      if (adherencePct != null) 'adherence_pct': adherencePct,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
    final response = await _http.post(
      Uri.parse(
          '${ApiConfig.baseUrl}/nutriologo/seguimiento/$clientId/progreso'),
      headers: _headers(),
      body: jsonEncode(payload),
    );
    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> addDietChange({
    required int clientId,
    required String changeType,
    required String reason,
    required String date,
    Map<String, dynamic>? previousValue,
    Map<String, dynamic>? newValue,
  }) async {
    final payload = <String, dynamic>{
      'change_type': changeType,
      'reason': reason,
      'date': date,
      if (previousValue != null) 'previous_value': previousValue,
      if (newValue != null) 'new_value': newValue,
    };
    final response = await _http.post(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/seguimiento/$clientId/cambio-dieta'),
      headers: _headers(),
      body: jsonEncode(payload),
    );
    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  // ── Perfil ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getPerfil() async {
    final response = await _http.get(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/perfil'),
      headers: _headers(),
    );
    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updatePerfil(
      Map<String, dynamic> data) async {
    final response = await _http.put(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/perfil'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    final body = _decode(response);
    return body['data'] as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getSolicitudes({
    String status = 'pending',
  }) async {
    final response = await _http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/nutriologo/perfil/solicitudes?status=$status'),
      headers: _headers(),
    );
    final body = _decode(response);
    return ((body['data'] as List<dynamic>?) ?? [])
        .cast<Map<String, dynamic>>();
  }

  static Future<void> responderSolicitud({
    required int id,
    required String status,
    String? response,
  }) async {
    final resp = await _http.patch(
      Uri.parse('${ApiConfig.baseUrl}/nutriologo/perfil/solicitudes/$id'),
      headers: _headers(),
      body: jsonEncode({
        'status': status,
        if (response?.isNotEmpty ?? false) 'response': response,
      }),
    );
    _decode(resp);
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
