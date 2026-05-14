import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants.dart';
import '../../data/admin_api.dart';

class AdminProfessionalDetailScreen extends StatefulWidget {
  final Map<String, dynamic> professional;

  const AdminProfessionalDetailScreen({
    super.key,
    required this.professional,
  });

  @override
  State<AdminProfessionalDetailScreen> createState() =>
      _AdminProfessionalDetailScreenState();
}

class _AdminProfessionalDetailScreenState
    extends State<AdminProfessionalDetailScreen> {
  late Map<String, dynamic> _pro;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _pro = widget.professional;
  }

  String get _type => _pro['type']?.toString() ?? 'coach';
  int get _userId => _pro['user_id'] as int;

  Future<void> _verify() async {
    setState(() => _loading = true);
    try {
      await AdminApi.verifyProfessional(_userId, _type);
      if (!mounted) return;
      setState(() {
        _pro['is_verified'] = true;
        _pro['rejection_reason'] = null;
        _loading = false;
      });
      _snack('Profesionista verificado.');
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _snack('Error: $e');
    }
  }

  Future<void> _reject() async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rechazar profesionista',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Motivo de rechazo...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: AppColors.cardGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.coralOrange),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rechazar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    ctrl.dispose();

    if (confirmed != true) return;
    setState(() => _loading = true);
    try {
      await AdminApi.rejectProfessional(_userId, _type, ctrl.text.trim());
      if (!mounted) return;
      setState(() {
        _pro['is_verified'] = false;
        _pro['rejection_reason'] = ctrl.text.trim();
        _loading = false;
      });
      _snack('Profesionista rechazado.');
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _snack('Error: $e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isCoach = _type == 'coach';
    final rc = isCoach ? AppColors.neonGreen : AppColors.electricPurple;
    final name = _pro['name']?.toString() ?? '—';
    final isVerified = _pro['is_verified'] == true;
    final isRejected = _pro['rejection_reason'] != null;
    final certs = (_pro['certificate_uploads'] as List?) ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Detalle Profesionista',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: rc.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: rc.withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                      color: rc,
                      fontWeight: FontWeight.bold,
                      fontSize: 26),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(_pro['email']?.toString() ?? '',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(children: [
                      _badge(isCoach ? 'Coach' : 'Nutriólogo', rc),
                      const SizedBox(width: 6),
                      _badge(
                        isVerified
                            ? 'Verificado'
                            : isRejected
                                ? 'Rechazado'
                                : 'Pendiente',
                        isVerified
                            ? AppColors.neonGreen
                            : isRejected
                                ? AppColors.coralOrange
                                : const Color(0xFFFFBB00),
                      ),
                    ]),
                  ],
                ),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // Info rows
          _infoCard([
            if (_pro['specialty'] != null)
              _row(Icons.work_outline, 'Especialidad', _pro['specialty']!),
            if (_pro['experience_years'] != null)
              _row(Icons.timeline, 'Experiencia',
                  '${_pro['experience_years']} años'),
            if (_pro['bio'] != null && _pro['bio'].toString().isNotEmpty)
              _row(Icons.notes_outlined, 'Bio', _pro['bio']!),
            if (_pro['license_number'] != null)
              _row(Icons.badge_outlined, 'Cédula', _pro['license_number']!),
          ]),

          const SizedBox(height: 16),

          // Certificates
          if (certs.isNotEmpty) ...[
            const Text('CERTIFICADOS',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1)),
            const SizedBox(height: 8),
            _buildCertsList(certs),
            const SizedBox(height: 16),
          ],

          if (isRejected && _pro['rejection_reason'] != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.coralOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.coralOrange.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.coralOrange, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Motivo de rechazo',
                            style: TextStyle(
                                color: AppColors.coralOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(_pro['rejection_reason'].toString(),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Actions
          if (!isVerified || isRejected) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _verify,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.verified),
                label: Text(
                    _loading ? 'Procesando...' : 'Aprobar Verificacion',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (!isRejected) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _reject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.coralOrange,
                  side: const BorderSide(color: AppColors.coralOrange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.block),
                label: const Text('Rechazar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: rows),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.neonGreen, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCertsList(List certs) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: certs.map((c) {
        final cert = c as Map;
        final name = cert['name']?.toString() ?? 'Archivo';
        final type = cert['type']?.toString() ?? '';
        final isPdf = type.contains('pdf') ||
            name.toLowerCase().endsWith('.pdf');

        return GestureDetector(
          onTap: () => _openCertificate(cert['path']?.toString(), isPdf),
          child: Container(
            width: 110,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isPdf
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.picture_as_pdf,
                                color: AppColors.coralOrange, size: 32),
                            Text('PDF',
                                style: TextStyle(
                                    color: AppColors.coralOrange,
                                    fontSize: 10)),
                          ],
                        )
                      : const Icon(Icons.image_outlined,
                          color: Colors.white38, size: 32),
                ),
                const SizedBox(height: 6),
                Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getPublicUrl(String path) {
    return Supabase.instance.client.storage
        .from('certificates')
        .getPublicUrl(path);
  }

  Future<void> _openCertificate(String? path, bool isPdf) async {
    if (path == null) return;
    final url = _getPublicUrl(path);

    if (isPdf) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Mostrar imagen en dialog fullscreen
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 500),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.neonGreen),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image, color: Colors.white38, size: 40),
                          SizedBox(height: 8),
                          Text('No se pudo cargar la imagen',
                              style: TextStyle(color: Colors.white38)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
