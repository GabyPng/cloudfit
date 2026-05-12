import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api_config.dart';
import '../../../core/constants.dart';
import 'models/professional_model.dart';

class ProfessionalDetailScreen extends StatefulWidget {
  final ProfessionalModel professional;
  // Passed from list screen so we don't need an extra async lookup here
  final int? clientCoachId;

  const ProfessionalDetailScreen({
    super.key,
    required this.professional,
    this.clientCoachId,
  });

  @override
  State<ProfessionalDetailScreen> createState() =>
      _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState extends State<ProfessionalDetailScreen> {
  // Extended profile (bio, specialties, etc.) — only loaded for nutriólogos
  Map<String, dynamic>? _extendedProfile;
  // Current request status for this client → this nutritionist
  Map<String, dynamic>? _requestData;
  // True when the client already has an accepted relationship with a different nutriólogo
  bool _hasActiveNutritionist = false;

  bool _loadingProfile = false;
  bool _sendingRequest = false;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    if (widget.professional.roleId == 3) {
      _loadNutriProfile();
    }
  }

  Future<String?> _getToken() async {
    return Supabase.instance.client.auth.currentSession?.accessToken;
  }

  Future<void> _loadNutriProfile() async {
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });
    try {
      final token = await _getToken();
      final res = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/cliente/nutriologos/${widget.professional.userId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        setState(() {
          _extendedProfile = data;
          _requestData = data['request'] as Map<String, dynamic>?;
          _hasActiveNutritionist = data['has_active_nutritionist'] == true;
        });
      }
    } catch (_) {
      setState(() => _profileError = 'No se pudo cargar el perfil completo.');
    } finally {
      setState(() => _loadingProfile = false);
    }
  }

  Future<void> _sendRequest(String message) async {
    setState(() => _sendingRequest = true);
    try {
      final token = await _getToken();
      final res = await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}/cliente/nutriologos/${widget.professional.userId}/solicitar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message.trim().isEmpty ? null : message.trim()}),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) {
        setState(() {
          _requestData = body['data'] as Map<String, dynamic>;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message'] ?? 'Solicitud enviada'),
              backgroundColor: AppColors.neonGreen.withOpacity(0.9),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message'] ?? 'Error al enviar solicitud'),
              backgroundColor: Colors.red.shade800,
            ),
          );
        }
        // Reload to get current status
        await _loadNutriProfile();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de conexión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingRequest = false);
    }
  }

  void _showRequestDialog() {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Enviar Solicitud',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envía un mensaje a ${widget.professional.name.split(' ').first} para presentarte.',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: msgCtrl,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Cuéntale brevemente tu objetivo, historial, o cualquier información relevante...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                filled: true,
                fillColor: AppColors.cardGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterStyle: const TextStyle(color: Colors.white30),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _sendRequest(msgCtrl.text);
            },
            child: const Text('Enviar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pro = widget.professional;
    final isNutri = pro.roleId == 3;
    final roleColor = isNutri ? AppColors.electricPurple : AppColors.neonGreen;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // ── Header con avatar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.black,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [roleColor.withOpacity(0.25), Colors.black],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: roleColor.withOpacity(0.2),
                              backgroundImage: (pro.avatarUrl?.isNotEmpty == true)
                                  ? NetworkImage(pro.avatarUrl!)
                                  : null,
                              child: (pro.avatarUrl?.isNotEmpty != true)
                                  ? Text(
                                      pro.name.isNotEmpty
                                          ? pro.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold,
                                        color: roleColor,
                                      ),
                                    )
                                  : null,
                            ),
                            if (pro.isOnline)
                              Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.neonGreen,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          pro.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: roleColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            pro.specialty,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statsRow(pro, roleColor),
                  const SizedBox(height: 24),

                  // Objetivo / descripción breve
                  if (pro.objective?.isNotEmpty == true) ...[
                    _sectionTitle('Objetivo'),
                    const SizedBox(height: 8),
                    _infoCard(
                      child: Text(
                        pro.objective!,
                        style:
                            const TextStyle(color: Colors.white70, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Nutriólogo: perfil extendido ──────────────────────────
                  if (isNutri) ...[
                    if (_loadingProfile)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                              color: AppColors.electricPurple),
                        ),
                      )
                    else ...[
                      _buildNutriProfessionalInfo(pro, roleColor),
                      if ((_extendedProfile?['bio'] as String?)?.isNotEmpty ==
                          true)
                        _buildBio(_extendedProfile!['bio'] as String),
                      _buildSpecialties(roleColor),
                      _buildPriceLocation(roleColor),
                    ],

                    const SizedBox(height: 20),

                    // ── Solicitud ─────────────────────────────────────────────
                    _sectionTitle('Solicitud de consulta'),
                    const SizedBox(height: 12),
                    _buildRequestSection(roleColor),
                  ],

                  // ── Coach: info básica ─────────────────────────────────────
                  if (!isNutri) ...[
                    _sectionTitle('Información del Coach'),
                    const SizedBox(height: 8),
                    _infoCard(
                      child: _infoRow(
                        icon: Icons.fitness_center,
                        label: 'Especialidad',
                        value: 'Entrenamiento personalizado',
                        color: roleColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('Contactar'),
                    const SizedBox(height: 12),
                    _buildCoachContactButtons(roleColor),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Nutriólogo sections ──────────────────────────────────────────────────

  Widget _buildNutriProfessionalInfo(
      ProfessionalModel pro, Color roleColor) {
    final ext = _extendedProfile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Información profesional'),
        const SizedBox(height: 8),
        _infoCard(
          child: Column(
            children: [
              _infoRow(
                icon: Icons.badge_outlined,
                label: 'Cédula profesional',
                value: ext?['license_number'] ?? pro.licenseNumber ?? 'No registrada',
                color: roleColor,
              ),
              if ((ext?['focus'] ?? pro.focus)?.isNotEmpty == true) ...[
                const Divider(color: Colors.white12, height: 24),
                _infoRow(
                  icon: Icons.center_focus_strong_outlined,
                  label: 'Área de enfoque',
                  value: ext?['focus'] ?? pro.focus!,
                  color: roleColor,
                ),
              ],
              if ((ext?['experience_years'] as int?) != null) ...[
                const Divider(color: Colors.white12, height: 24),
                _infoRow(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Años de experiencia',
                  value: '${ext!['experience_years']} años',
                  color: roleColor,
                ),
              ],
              if (pro.certificateUploads != null) ...[
                const Divider(color: Colors.white12, height: 24),
                _infoRow(
                  icon: Icons.verified_outlined,
                  label: 'Certificados',
                  value: 'Documentos verificados',
                  color: roleColor,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBio(String bio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Sobre mí'),
        const SizedBox(height: 8),
        _infoCard(
          child: Text(
            bio,
            style: const TextStyle(
                color: Colors.white70, height: 1.6, fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSpecialties(Color roleColor) {
    final specialties =
        (_extendedProfile?['specialties'] as List?)?.cast<String>() ?? [];
    if (specialties.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Especialidades'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: specialties
              .map((s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: roleColor.withOpacity(0.35)),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                          color: roleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPriceLocation(Color roleColor) {
    final price = _extendedProfile?['consultation_price'];
    final location =
        _extendedProfile?['location'] as String?;
    final phone = _extendedProfile?['phone'] as String?;
    final socialsRaw = _extendedProfile?['social_links'];
    final socials = (socialsRaw is Map<String, dynamic>) ? socialsRaw : <String, dynamic>{};

    final hasInfo = price != null ||
        (location?.isNotEmpty == true) ||
        (phone?.isNotEmpty == true) ||
        socials.values.any((v) => v != null && v.toString().isNotEmpty);

    if (!hasInfo) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Disponibilidad y contacto'),
        const SizedBox(height: 8),
        _infoCard(
          child: Column(
            children: [
              if (price != null)
                _infoRow(
                  icon: Icons.attach_money_rounded,
                  label: 'Consulta desde',
                  value:
                      '\$${double.tryParse(price.toString())?.toStringAsFixed(0) ?? price} MXN',
                  color: AppColors.neonGreen,
                ),
              if (location?.isNotEmpty == true) ...[
                const Divider(color: Colors.white12, height: 24),
                _infoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Ubicación',
                  value: location!,
                  color: roleColor,
                ),
              ],
              if (phone?.isNotEmpty == true) ...[
                const Divider(color: Colors.white12, height: 24),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(url)) launchUrl(url);
                  },
                  child: _infoRow(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: phone!,
                    color: roleColor,
                  ),
                ),
              ],
              if ((socials['instagram'] as String?)?.isNotEmpty == true) ...[
                const Divider(color: Colors.white12, height: 24),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(
                        'https://instagram.com/${socials['instagram']}');
                    if (await canLaunchUrl(url)) {
                      launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: _infoRow(
                    icon: Icons.camera_alt_outlined,
                    label: 'Instagram',
                    value: '@${socials['instagram']}',
                    color: roleColor,
                  ),
                ),
              ],
              if ((socials['website'] as String?)?.isNotEmpty == true) ...[
                const Divider(color: Colors.white12, height: 24),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(socials['website']);
                    if (await canLaunchUrl(url)) {
                      launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: _infoRow(
                    icon: Icons.language_outlined,
                    label: 'Sitio web',
                    value: socials['website'],
                    color: roleColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRequestSection(Color roleColor) {
    final req = _requestData;

    // Client already paired with a different nutriólogo
    if (_hasActiveNutritionist && req == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE047).withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFCE047).withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline_rounded,
                color: Color(0xFFFCE047), size: 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ya tienes un nutriólogo asignado',
                    style: TextStyle(
                      color: Color(0xFFFCE047),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Solo puedes tener un nutriólogo activo a la vez. Finaliza tu relación actual antes de solicitar a otro.',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Already has a request
    if (req != null) {
      final status = req['status'] as String? ?? 'pending';
      final response = req['nutriologo_response'] as String?;

      final (Color statusColor, IconData statusIcon, String statusLabel) =
          switch (status) {
        'accepted' => (
            const Color(0xFF7EF0B3),
            Icons.check_circle_outline,
            'Solicitud aceptada'
          ),
        'rejected' => (
            const Color(0xFFFF7351),
            Icons.cancel_outlined,
            'Solicitud rechazada'
          ),
        _ => (
            const Color(0xFFFCE047),
            Icons.hourglass_empty_rounded,
            'Solicitud pendiente'
          ),
      };

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            if (req['message'] != null) ...[
              const SizedBox(height: 10),
              Text(
                '"${req['message']}"',
                style: const TextStyle(
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                    fontSize: 13),
              ),
            ],
            if (response?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Respuesta del nutriólogo:',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      response!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
            // Allow re-sending after rejection
            if (status == 'rejected') ...[
              const SizedBox(height: 14),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 14),
              _actionButton(
                icon: _sendingRequest
                    ? Icons.hourglass_empty
                    : Icons.send_rounded,
                label: _sendingRequest ? 'Enviando...' : 'Volver a solicitar',
                color: roleColor,
                onTap: _sendingRequest ? null : _showRequestDialog,
                filled: true,
              ),
            ],
          ],
        ),
      );
    }

    // No request yet
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: _sendingRequest
                ? Icons.hourglass_empty
                : Icons.person_add_alt_1_outlined,
            label: _sendingRequest ? 'Enviando...' : 'Solicitar consulta',
            color: roleColor,
            onTap: _sendingRequest ? null : _showRequestDialog,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCoachContactButtons(Color roleColor) {
    final coachId = widget.clientCoachId;
    final isMyCoach = coachId == widget.professional.userId;
    final hasOtherCoach = coachId != null && !isMyCoach;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Relationship banner ──────────────────────────────────────────────
        if (isMyCoach)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: roleColor.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_rounded, color: roleColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Este es tu coach',
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Ya formas parte de su equipo. Contáctalo cuando lo necesites.',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else if (hasOtherCoach)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE047).withOpacity(0.07),
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: const Color(0xFFFCE047).withOpacity(0.3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFFFCE047), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ya tienes un coach asignado',
                        style: TextStyle(
                          color: Color(0xFFFCE047),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Solo puedes trabajar con un coach a la vez, pero puedes contactar a este para obtener información.',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // ── Contact buttons — always visible ────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Mensaje',
                color: roleColor,
                onTap: () async {
                  final url = Uri.parse('https://wa.me/521234567890');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                icon: Icons.calendar_month_outlined,
                label: 'Agendar',
                color: Colors.white,
                filled: false,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Shared widgets ───────────────────────────────────────────────────────

  Widget _statsRow(ProfessionalModel pro, Color roleColor) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.star,
            iconColor: Colors.amber,
            value: pro.rating,
            label: 'Calificación',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.circle,
            iconColor:
                pro.isOnline ? AppColors.neonGreen : Colors.white24,
            value: pro.isOnline ? 'En línea' : 'Fuera',
            label: 'Estado',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: pro.roleId == 2
                ? Icons.fitness_center
                : Icons.restaurant_menu,
            iconColor: roleColor,
            value: pro.roleId == 2 ? 'Coach' : 'Nutri',
            label: 'Rol',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.white38)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool filled = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? (onTap == null ? color.withOpacity(0.5) : color) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: filled ? null : Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: filled ? Colors.black : Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: filled ? Colors.black : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
