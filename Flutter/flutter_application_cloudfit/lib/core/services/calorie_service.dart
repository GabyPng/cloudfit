import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth_service.dart';

class CalorieService {
  static final _db = Supabase.instance.client;

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<int> getTodayCalories() async {
    final clientId = await AuthService.getNumericUserId();
    if (clientId == null) return 0;

    final row = await _db
        .from('daily_calorie_logs')
        .select('calories_consumed')
        .eq('client_id', clientId)
        .eq('date', _today())
        .maybeSingle();

    return (row?['calories_consumed'] as int?) ?? 0;
  }

  static Future<bool> logCalories(int calories) async {
    final clientId = await AuthService.getNumericUserId();
    if (clientId == null) return false;

    await _db.from('daily_calorie_logs').upsert(
      {
        'client_id': clientId,
        'date': _today(),
        'calories_consumed': calories,
      },
      onConflict: 'client_id,date',
    );
    return true;
  }

  /// Weekly calories for the current week (Mon–Sun), returns list of 7 values.
  static Future<List<int>> getWeeklyCalories() async {
    final clientId = await AuthService.getNumericUserId();
    if (clientId == null) return List.filled(7, 0);

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';

    final rows = await _db
        .from('daily_calorie_logs')
        .select('date, calories_consumed')
        .eq('client_id', clientId)
        .gte('date', start);

    final result = List.filled(7, 0);
    for (final row in rows as List) {
      final d = DateTime.tryParse(row['date'] as String? ?? '');
      if (d == null) continue;
      final idx = (d.weekday - 1) % 7;
      result[idx] = (row['calories_consumed'] as int?) ?? 0;
    }
    return result;
  }
}
