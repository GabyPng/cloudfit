import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../core/api_client.dart';
import '../../core/auth_service.dart';
import '../../core/constants.dart';

class ProfileScreen extends StatefulWidget {
  static const String name = 'profile_screen';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final response = await ApiClient.get('/me');

    if (response.statusCode >= 400) {
      throw Exception('No se pudo cargar el perfil: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final Map<String, dynamic>? localUser =
        data['local_user'] as Map<String, dynamic>?;
    final Map<String, dynamic>? localRole =
        localUser?['role'] as Map<String, dynamic>?;

    final roleRaw =
        localRole?['name']?.toString() ?? data['role']?.toString() ?? 'cliente';
    final role = roleRaw.toUpperCase();
    final email =
        localUser?['email']?.toString() ??
        data['email']?.toString() ??
        'sin-correo';
    final name = localUser?['name']?.toString() ?? email.split('@').first;
    final avatarUrl = localUser?['avatar_url']?.toString() ?? '';
    final objective = localUser?['objective']?.toString() ?? '';
    final createdAt = localUser?['created_at']?.toString();

    return {
      'name': name,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'objective': objective,
      'memberSince': _memberSince(createdAt),
    };
  }

  String _memberSince(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return 'Reciente';
    }

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return 'Reciente';
    }

    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) context.go('/login');
  }

  Future<void> _openEditProfile(Map<String, dynamic> profile) async {
    final nameCtrl = TextEditingController(
      text: profile['name'] as String? ?? '',
    );
    final objectiveCtrl = TextEditingController(
      text: profile['objective'] as String? ?? '',
    );
    final avatarCtrl = TextEditingController(
      text: profile['avatarUrl'] as String? ?? '',
    );

    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardGrey,
              title: const Text('Editar perfil'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: objectiveCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Objetivo físico',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: avatarCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL de avatar',
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorText!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final payload = {
                      'name': nameCtrl.text.trim(),
                      'objective': objectiveCtrl.text.trim().isEmpty
                          ? null
                          : objectiveCtrl.text.trim(),
                      'avatar_url': avatarCtrl.text.trim().isEmpty
                          ? null
                          : avatarCtrl.text.trim(),
                    };

                    try {
                      final response = await ApiClient.put('/me', payload);
                      if (response.statusCode >= 400) {
                        setDialogState(() {
                          errorText =
                              'No se pudo guardar (${response.statusCode})';
                        });
                        return;
                      }

                      await AuthService.updateUserMetadata({
                        'nombre': nameCtrl.text.trim(),
                        'objective': objectiveCtrl.text.trim(),
                        'avatar_url': avatarCtrl.text.trim(),
                      });

                      if (!mounted) return;
                      Navigator.of(this.context).pop();
                      setState(() => _profileFuture = _loadProfile());
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Perfil actualizado correctamente'),
                        ),
                      );
                    } catch (_) {
                      setDialogState(() {
                        errorText = 'Error de red al actualizar perfil';
                      });
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudo cargar el perfil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _profileFuture = _loadProfile()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                _buildAvatarHeader(profile),
                const SizedBox(height: 30),
                _buildStatsGrid(profile),
                const SizedBox(height: 30),
                _buildSectionTitle("CUENTA"),
                _buildMenuCard([
                  _menuItem(
                    Icons.person_outline,
                    "Información Personal",
                    profile['name'] as String,
                    onTap: () => _openEditProfile(profile),
                  ),
                  _menuItem(
                    Icons.mail_outline,
                    "Correo",
                    profile['email'] as String,
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSectionTitle("SISTEMA"),
                _buildMenuCard([
                  _menuItem(
                    Icons.flag_outlined,
                    "Objetivo",
                    (profile['objective'] as String).isEmpty
                        ? 'No definido'
                        : profile['objective'] as String,
                    onTap: () => _openEditProfile(profile),
                  ),
                  _menuItem(
                    Icons.badge_outlined,
                    "Miembro desde",
                    profile['memberSince'] as String,
                  ),
                  _menuItem(
                    Icons.settings_outlined,
                    "Preferencias Técnicas",
                    null,
                  ),
                ]),
                const SizedBox(height: 30),
                _buildLogoutButton(),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarHeader(Map<String, dynamic> profile) {
    final avatarUrl = profile['avatarUrl'] as String;

    final ImageProvider avatarImage = avatarUrl.isNotEmpty
        ? NetworkImage(avatarUrl)
        : const AssetImage('assets/images/Efra.jpg');

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: AppColors.electricPurple,
              child: CircleAvatar(radius: 52, backgroundImage: avatarImage),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.neonGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          profile['name'] as String,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(profile['email'] as String, style: const TextStyle(color: Colors.white38, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statBox(
            "USUARIO",
            (profile['email'] as String).split('@').first,
            AppColors.electricPurple,
          ),
          const SizedBox(width: 15),
          _statBox(
            "MIEMBRO",
            profile['memberSince'] as String,
            AppColors.neonGreen,
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(children: items),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String? trailingText, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(color: AppColors.neonGreen, fontSize: 12),
            ),
          const Icon(Icons.chevron_right, color: Colors.white12),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: _logout,
      child: const Text(
        "Cerrar Sesión",
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
    );
  }
}
