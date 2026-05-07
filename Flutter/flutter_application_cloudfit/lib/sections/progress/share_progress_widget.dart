import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';

class ShareProgressWidget extends StatelessWidget {
  const ShareProgressWidget({super.key});

  Future<void> _share(BuildContext context) async {
    final db = Supabase.instance.client;
    final authId = db.auth.currentUser?.id;
    if (authId == null) return;

    try {
      final userRow = await db
          .from('users')
          .select('name')
          .eq('supabase_id', authId)
          .maybeSingle();

      final name = userRow?['name']?.toString() ?? 'Usuario';

      // Build a simple share text with key stats
      final shareText =
          '¡Mira mi progreso en CloudFit!\n'
          'Nombre: $name\n'
          'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}\n'
          '🏋️ Entrenamiento en CloudFit — ¡Únete!';

      await Clipboard.setData(ClipboardData(text: shareText));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Resumen copiado al portapapeles. Compártelo donde quieras.'),
            backgroundColor: AppColors.surface,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _share(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.neonGreen.withValues(alpha: 0.15),
              AppColors.electricPurple.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.neonGreen.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share_outlined, color: AppColors.neonGreen, size: 20),
            SizedBox(width: 10),
            Text(
              'Compartir mi progreso',
              style: TextStyle(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
