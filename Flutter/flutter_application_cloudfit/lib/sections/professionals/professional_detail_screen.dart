import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants.dart';
import 'models/professional_model.dart';

class ProfessionalDetailScreen extends StatelessWidget {
  final ProfessionalModel professional;

  const ProfessionalDetailScreen({super.key, required this.professional});

  @override
  Widget build(BuildContext context) {
    final pro = professional;
    final isCoach = pro.roleId == 2;
    final roleColor = isCoach ? AppColors.neonGreen : Colors.blue;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // ── Header con avatar ──
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
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white),
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
                        colors: [
                          roleColor.withOpacity(0.25),
                          Colors.black,
                        ],
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
                              backgroundImage: (pro.avatarUrl != null &&
                                      pro.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(pro.avatarUrl!)
                                  : null,
                              child: (pro.avatarUrl == null ||
                                      pro.avatarUrl!.isEmpty)
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
                                  border: Border.all(
                                      color: Colors.black, width: 2),
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
                            border: Border.all(
                                color: roleColor.withOpacity(0.5)),
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

          // ── Contenido ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statsRow(pro, roleColor),
                  const SizedBox(height: 24),

                  if (pro.objective != null &&
                      pro.objective!.isNotEmpty) ...[
                    _sectionTitle('Objetivo'),
                    const SizedBox(height: 8),
                    _infoCard(
                      child: Text(
                        pro.objective!,
                        style: const TextStyle(
                            color: Colors.white70, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (!isCoach) ...[
                    _sectionTitle('Información profesional'),
                    const SizedBox(height: 8),
                    _infoCard(
                      child: Column(
                        children: [
                          _infoRow(
                            icon: Icons.badge_outlined,
                            label: 'Cédula profesional',
                            value: pro.licenseNumber ?? 'No registrada',
                            color: roleColor,
                          ),
                          if (pro.focus != null &&
                              pro.focus!.isNotEmpty) ...[
                            const Divider(
                                color: Colors.white12, height: 24),
                            _infoRow(
                              icon: Icons.center_focus_strong_outlined,
                              label: 'Área de enfoque',
                              value: pro.focus!,
                              color: roleColor,
                            ),
                          ],
                          if (pro.certificateUploads != null) ...[
                            const Divider(
                                color: Colors.white12, height: 24),
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

                  if (isCoach) ...[
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
                  ],

                  _sectionTitle('Contactar'),
                  const SizedBox(height: 12),
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
                          onTap: () {
                            
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              style:
                  const TextStyle(fontSize: 11, color: Colors.white38)),
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
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white38)),
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
    required VoidCallback onTap,
    bool filled = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
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