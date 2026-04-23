import 'dart:convert';
import '../../sections/nutrition/models/nutrition_model.dart';
import '../api_client.dart';

class NutritionService {
  /// Retorna el plan nutricional activo asignado al cliente logueado,
  /// o null si no tiene ninguno.
  static Future<NutritionPlanModel?> getAssignedPlan() async {
    final response = await ApiClient.get('/cliente/mi-plan');

    if (response.statusCode == 404) return null;

    if (response.statusCode >= 400) {
      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      throw Exception(
        body['error']?.toString() ??
            body['message']?.toString() ??
            'Error al obtener el plan (${response.statusCode})',
      );
    }

    if (response.body.isEmpty) return null;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) return null;

    return NutritionPlanModel.fromMap(data);
  }
}
