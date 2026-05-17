import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth_service.dart';

class WaterService {
  static final _db = Supabase.instance.client;

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<({int consumed, int target})> getTodayWater() async {
    final clientId = await AuthService.getNumericUserId();
    if (clientId == null) return (consumed: 0, target: 8);

    final row = await _db
        .from('daily_water_logs')
        .select('glasses_consumed, glasses_target')
        .eq('client_id', clientId)
        .eq('date', _today())
        .maybeSingle();

    return (
      consumed: (row?['glasses_consumed'] as int?) ?? 0,
      target: (row?['glasses_target'] as int?) ?? 8,
    );
  }

  static Future<void> logWater(int consumed, {int target = 8}) async {
    final clientId = await AuthService.getNumericUserId();
    if (clientId == null) return;

    await _db.from('daily_water_logs').upsert(
      {
        'client_id': clientId,
        'date': _today(),
        'glasses_consumed': consumed,
        'glasses_target': target,
      },
      onConflict: 'client_id,date',
    );
  }
}
