import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import '../../../../shared/widgets/certificate_upload_widget.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../data/nutriologo_api.dart';

class NutriologoPerfilScreen extends StatefulWidget {
  const NutriologoPerfilScreen({super.key});

  @override
  State<NutriologoPerfilScreen> createState() =>
      _NutriologoPerfilScreenState();
}

class _NutriologoPerfilScreenState extends State<NutriologoPerfilScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _saving = false;
  Map<String, dynamic> _profile = {};
  List<Map<String, dynamic>> _solicitudes = [];
  String _solicitudesStatus = 'pending';

  late TabController _tabController;

  // Edit controllers
  final _bioCtrl = TextEditingController();
  final _focusCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _expCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bioCtrl.dispose();
    _focusCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _priceCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        NutriologoApi.getPerfil(),
        NutriologoApi.getSolicitudes(status: _solicitudesStatus),
      ]);
      if (!mounted) return;
      final profile = results[0] as Map<String, dynamic>;
      setState(() {
        _profile = profile;
        _solicitudes =
            (results[1] as List<dynamic>).cast<Map<String, dynamic>>();
        _isLoading = false;
        _fillControllers(profile);
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSolicitudes() async {
    try {
      final data = await NutriologoApi.getSolicitudes(status: _solicitudesStatus);
      if (!mounted) return;
      setState(() => _solicitudes = data);
    } catch (_) {}
  }

  void _fillControllers(Map<String, dynamic> p) {
    _bioCtrl.text = p['bio']?.toString() ?? '';
    _focusCtrl.text = p['focus']?.toString() ?? '';
    _locationCtrl.text = p['location']?.toString() ?? '';
    _phoneCtrl.text = p['phone']?.toString() ?? '';
    _priceCtrl.text = p['consultation_price']?.toString() ?? '';
    _expCtrl.text = p['experience_years']?.toString() ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final updated = await NutriologoApi.updatePerfil({
        'bio': _bioCtrl.text.trim(),
        'focus': _focusCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'consultation_price': double.tryParse(_priceCtrl.text.trim()),
        'experience_years': int.tryParse(_expCtrl.text.trim()),
      });
      if (!mounted) return;
      setState(() {
        _profile = {..._profile, ...updated};
        _isEditing = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Perfil actualizado.')));
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _responderSolicitud(
      int id, String status, String? response) async {
    try {
      await NutriologoApi.responderSolicitud(
          id: id, status: status, response: response);
      _snack(status == 'accepted' ? 'Solicitud aceptada.' : 'Solicitud rechazada.');
      await _loadSolicitudes();
    } catch (e) {
      _snack('Error: $e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _responderDialog(Map<String, dynamic> solicitud) async {
    final responseCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Responder solicitud',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              solicitud['client_name']?.toString() ?? 'Cliente',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              solicitud['message']?.toString() ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: responseCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Mensaje de respuesta (opcional)',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF121212),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.neonGreen),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neonGreen,
                      side: const BorderSide(color: AppColors.neonGreen),
                    ),
                    onPressed: () {
                      final msg = responseCtrl.text.trim();
                      Navigator.pop(ctx);
                      _responderSolicitud(solicitud['id'] as int, 'accepted', msg);
                    },
                    child: const Text('Aceptar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.coralOrange,
                      side: const BorderSide(color: AppColors.coralOrange),
                    ),
                    onPressed: () {
                      final msg = responseCtrl.text.trim();
                      Navigator.pop(ctx);
                      _responderSolicitud(solicitud['id'] as int, 'rejected', msg);
                    },
                    child: const Text('Rechazar'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );

    responseCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) _fillControllers(_profile);
              }),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonGreen,
          labelColor: AppColors.neonGreen,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Perfil'),
            Tab(text: 'Solicitudes'),
            Tab(text: 'Certificados'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildSkeleton()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildSolicitudesTab(),
                _buildCertificatesTab(),
              ],
            ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SkeletonBox(height: 100, width: double.infinity),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 70, width: double.infinity)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 70, width: double.infinity)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 70, width: double.infinity)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 70, width: double.infinity)),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonBox(height: 120, width: double.infinity),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final stats = _profile['stats'] as Map<String, dynamic>? ?? {};
    final name = _profile['name']?.toString() ?? 'Nutriólogo';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'N';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      AppColors.neonGreen.withValues(alpha: 0.2),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _profile['email']?.toString() ?? '',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      if (_profile['focus'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _profile['focus'].toString(),
                            style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _statChip('Pacientes',
                  stats['total_patients']?.toString() ?? '0',
                  AppColors.neonGreen),
              const SizedBox(width: 8),
              _statChip('Activos',
                  stats['active_patients']?.toString() ?? '0',
                  AppColors.electricPurple),
              const SizedBox(width: 8),
              _statChip('Planes',
                  stats['total_plans']?.toString() ?? '0',
                  AppColors.coralOrange),
              const SizedBox(width: 8),
              _statChip('Solicitudes',
                  stats['pending_requests']?.toString() ?? '0',
                  const Color(0xFFFFBB00)),
            ],
          ),

          const SizedBox(height: 20),

          // Edit or view
          _isEditing ? _buildEditForm() : _buildViewInfo(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildViewInfo() {
    final items = [
      if (_profile['bio'] != null && _profile['bio'].toString().isNotEmpty)
        _infoRow(Icons.notes_outlined, 'Bio', _profile['bio'].toString()),
      if (_profile['location'] != null)
        _infoRow(Icons.location_on_outlined, 'Ubicación',
            _profile['location'].toString()),
      if (_profile['phone'] != null)
        _infoRow(Icons.phone_outlined, 'Teléfono',
            _profile['phone'].toString()),
      if (_profile['experience_years'] != null)
        _infoRow(Icons.work_outline, 'Experiencia',
            '${_profile['experience_years']} años'),
      if (_profile['consultation_price'] != null)
        _infoRow(Icons.attach_money, 'Precio consulta',
            '\$${_profile['consultation_price']}'),
      _infoRow(Icons.badge_outlined, 'Cédula',
          _profile['license_number']?.toString() ?? 'PENDIENTE'),
    ];

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline,
                color: Colors.white38, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Completa tu perfil para que los pacientes puedan encontrarte.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: items),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Editar perfil',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
        const SizedBox(height: 12),
        _field(_focusCtrl, 'Especialidad / Enfoque'),
        const SizedBox(height: 10),
        _field(_bioCtrl, 'Biografía', maxLines: 3),
        const SizedBox(height: 10),
        _field(_locationCtrl, 'Ubicación'),
        const SizedBox(height: 10),
        _field(_phoneCtrl, 'Teléfono',
            keyboardType: TextInputType.phone),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _field(_expCtrl, 'Años de experiencia',
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(
                child: _field(_priceCtrl, 'Precio consulta',
                    keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _saveProfile,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : const Text('Guardar cambios',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonGreen),
        ),
      ),
    );
  }

  Widget _buildSolicitudesTab() {
    return Column(
      children: [
        // Status filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['pending', 'accepted', 'rejected', 'all']
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _filterChip(s),
                      ))
                  .toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: _solicitudes.isEmpty
              ? const Center(
                  child: Text(
                    'No hay solicitudes.',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _solicitudes.length,
                  itemBuilder: (_, i) => _solicitudCard(_solicitudes[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildCertificatesTab() {
    final uploads = (_profile['certificate_uploads'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final userId = _profile['user_id'] as int?;
    final isVerified = _profile['is_verified'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MIS CERTIFICADOS',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1)),
                ],
              ),
            ),
            if (isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.neonGreen.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        color: AppColors.neonGreen, size: 14),
                    SizedBox(width: 4),
                    Text('Verificado',
                        style: TextStyle(
                            color: AppColors.neonGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ]),
          const SizedBox(height: 14),
          if (userId != null)
            CertificateUploadWidget(
              initialCertificates: uploads,
              role: 'nutriologo',
              userId: userId,
              onUploaded: (certs) async {
                try {
                  await NutriologoApi.updatePerfil(
                      {'certificate_uploads': certs});
                  setState(() {
                    _profile['certificate_uploads'] = certs;
                  });
                } catch (_) {}
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _filterChip(String status) {
    final isSelected = _solicitudesStatus == status;
    final labels = {
      'pending': 'Pendientes',
      'accepted': 'Aceptadas',
      'rejected': 'Rechazadas',
      'all': 'Todas',
    };
    return GestureDetector(
      onTap: () {
        setState(() => _solicitudesStatus = status);
        _loadSolicitudes();
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonGreen.withValues(alpha: 0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.neonGreen : Colors.transparent,
          ),
        ),
        child: Text(
          labels[status] ?? status,
          style: TextStyle(
            color: isSelected ? AppColors.neonGreen : Colors.white54,
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _solicitudCard(Map<String, dynamic> s) {
    final status = s['status']?.toString() ?? 'pending';
    final isPending = status == 'pending';
    Color statusColor = isPending
        ? const Color(0xFFFFBB00)
        : status == 'accepted'
            ? AppColors.neonGreen
            : AppColors.coralOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: statusColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    AppColors.neonGreen.withValues(alpha: 0.15),
                child: Text(
                  (s['client_name']?.toString().isNotEmpty ?? false)
                      ? s['client_name'].toString()[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['client_name']?.toString() ?? 'Cliente',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                    Text(
                      s['client_email']?.toString() ?? '',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (s['message'] != null &&
              s['message'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              s['message'].toString(),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neonGreen,
                      side: const BorderSide(color: AppColors.neonGreen),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _responderDialog(s),
                    child: const Text('Responder',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
