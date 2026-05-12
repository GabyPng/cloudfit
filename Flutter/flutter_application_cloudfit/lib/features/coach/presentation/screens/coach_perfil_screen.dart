import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants.dart';
import '../../../../shared/widgets/certificate_upload_widget.dart';

class CoachPerfilScreen extends StatefulWidget {
  static const String name = 'coach_perfil';
  const CoachPerfilScreen({super.key});

  @override
  State<CoachPerfilScreen> createState() => _CoachPerfilScreenState();
}

class _CoachPerfilScreenState extends State<CoachPerfilScreen>
    with SingleTickerProviderStateMixin {
  final _db = Supabase.instance.client;

  bool _loading = true;
  bool _isEditing = false;
  bool _saving = false;

  Map<String, dynamic> _profile = {};
  List<Map<String, dynamic>> _certs = [];
  int? _userId;

  late TabController _tabController;

  final _bioCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _expCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bioCtrl.dispose();
    _specialtyCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _priceCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final authId = _db.auth.currentUser?.id;
      if (authId == null) return;

      final userRow = await _db
          .from('users')
          .select('user_id,name,email,avatar_url')
          .eq('supabase_id', authId)
          .single();

      _userId = userRow['user_id'] as int;

      final coachRow = await _db
          .from('coaches')
          .select(
              'bio,specialty,specialties,experience_years,location,'
              'session_price,profile_visible,social_links,phone,'
              'is_verified,certificate_uploads')
          .eq('user_id', _userId!)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        _profile = {...userRow, ...(coachRow ?? {})};
        _certs = ((coachRow?['certificate_uploads'] as List?) ?? [])
            .cast<Map<String, dynamic>>();
        _loading = false;
        _fillControllers();
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fillControllers() {
    _bioCtrl.text = _profile['bio']?.toString() ?? '';
    _specialtyCtrl.text = _profile['specialty']?.toString() ?? '';
    _locationCtrl.text = _profile['location']?.toString() ?? '';
    _phoneCtrl.text = _profile['phone']?.toString() ?? '';
    _priceCtrl.text = _profile['session_price']?.toString() ?? '';
    _expCtrl.text = _profile['experience_years']?.toString() ?? '';
  }

  Future<void> _save() async {
    if (_userId == null) return;
    setState(() => _saving = true);
    try {
      await _db.from('coaches').update({
        'bio': _bioCtrl.text.trim(),
        'specialty': _specialtyCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'session_price': double.tryParse(_priceCtrl.text.trim()),
        'experience_years': int.tryParse(_expCtrl.text.trim()),
      }).eq('user_id', _userId!);

      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _saving = false;
      });
      _snack('Perfil actualizado.');
      await _load();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _snack('Error: $e');
      }
    }
  }

  Future<void> _saveCerts(List<Map<String, dynamic>> certs) async {
    if (_userId == null) return;
    try {
      await _db
          .from('coaches')
          .update({'certificate_uploads': certs})
          .eq('user_id', _userId!);
    } catch (_) {}
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Mi Perfil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_loading)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) _fillControllers();
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
          tabs: const [Tab(text: 'Perfil'), Tab(text: 'Certificados')],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildCertsTab(),
              ],
            ),
    );
  }

  Widget _buildProfileTab() {
    final name = _profile['name']?.toString() ?? 'Coach';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';
    final isVerified = _profile['is_verified'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.neonGreen.withValues(alpha: 0.2),
              child: Text(initial,
                  style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(_profile['email']?.toString() ?? '',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(children: [
                    if (isVerified)
                      _badge('Verificado', AppColors.neonGreen)
                    else
                      _badge('Pendiente', const Color(0xFFFFBB00)),
                    const SizedBox(width: 6),
                    _badge('Coach', AppColors.neonGreen),
                  ]),
                ],
              ),
            ),
          ]),
        ),

        const SizedBox(height: 20),

        _isEditing ? _buildEditForm() : _buildViewInfo(),

        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _buildViewInfo() {
    final items = [
      if (_profile['specialty'] != null &&
          _profile['specialty'].toString().isNotEmpty)
        _infoRow(Icons.fitness_center, 'Especialidad',
            _profile['specialty'].toString()),
      if (_profile['experience_years'] != null)
        _infoRow(Icons.timeline, 'Experiencia',
            '${_profile['experience_years']} años'),
      if (_profile['bio'] != null &&
          _profile['bio'].toString().isNotEmpty)
        _infoRow(Icons.notes_outlined, 'Bio', _profile['bio'].toString()),
      if (_profile['location'] != null)
        _infoRow(Icons.location_on_outlined, 'Ubicación',
            _profile['location'].toString()),
      if (_profile['phone'] != null)
        _infoRow(Icons.phone_outlined, 'Teléfono',
            _profile['phone'].toString()),
      if (_profile['session_price'] != null)
        _infoRow(Icons.attach_money, 'Precio sesión',
            '\$${_profile['session_price']}'),
    ];

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline, color: Colors.white38, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Completa tu perfil para que los clientes puedan encontrarte.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
        ]),
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(children: items),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.neonGreen, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEditForm() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _field(_specialtyCtrl, 'Especialidad'),
      const SizedBox(height: 10),
      _field(_bioCtrl, 'Biografía', maxLines: 3),
      const SizedBox(height: 10),
      _field(_locationCtrl, 'Ubicación'),
      const SizedBox(height: 10),
      _field(_phoneCtrl, 'Teléfono', keyboardType: TextInputType.phone),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
            child: _field(_expCtrl, 'Años experiencia',
                keyboardType: TextInputType.number)),
        const SizedBox(width: 10),
        Expanded(
            child: _field(_priceCtrl, 'Precio sesión',
                keyboardType: TextInputType.number)),
      ]),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.neonGreen,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    ]);
  }

  Widget _buildCertsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MIS CERTIFICADOS',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1)),
        const SizedBox(height: 12),
        if (_userId != null)
          CertificateUploadWidget(
            initialCertificates: _certs,
            role: 'coach',
            userId: _userId!,
            onUploaded: (certs) {
              setState(() => _certs = certs);
              _saveCerts(certs);
            },
          ),
        const SizedBox(height: 80),
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
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {int maxLines = 1,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: AppColors.cardGrey,
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
}
