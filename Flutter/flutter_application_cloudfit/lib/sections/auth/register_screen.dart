import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth_service.dart';
import '../../core/user_role.dart';

class _CF {
  static const bg = Color(0xFF0D0D0D);
  static const card = Color(0xFF1A1A1A);
  static const neon = Color(0xFFCCFF00);
  //static const purple = Color(0xFF8B5CF6);
  static const white = Colors.white;
  static const hint = Color(0xFF555555);
  static const border = Color(0xFF2A2A2A);
  static const labelGrey = Color(0xFF888888);
  static const error = Color(0xFFFF4444);
  static const success = Color(0xFF66FF99);
}

class RegisterScreen extends StatefulWidget {
  static const String name = 'register_screen';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _certificatesBucket = 'certificates';
  static const _maxCertificateFiles = 3;
  static const _maxCertificateFileSizeBytes = 5 * 1024 * 1024;
  static const _allowedExtensions = {'png', 'jpg', 'jpeg', 'webp', 'pdf'};

  bool _loading = false;
  String? _errorMessage;
  String? _message;

  String _selectedRole = 'cliente';

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String _objective = 'ganar_masa';
  String _activityLevel = 'medio';
  DateTime? _birthDate;
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _specialty = 'fuerza';
  final _experienceYearsCtrl = TextEditingController();
  final _coachBioCtrl = TextEditingController();
  final _coachLocationCtrl = TextEditingController();

  final _licenseNumberCtrl = TextEditingController();
  String _focus = 'deportivo';

  List<PlatformFile> _certificateFiles = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _experienceYearsCtrl.dispose();
    _licenseNumberCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _coachBioCtrl.dispose();
    _coachLocationCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _errorMessage = null;
      _message = null;
    });

    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _errorMessage = 'Las contrasenas no coinciden.');
      return;
    }

    if (_passCtrl.text.length < 6) {
      setState(
        () => _errorMessage = 'La contrasena debe tener al menos 6 caracteres.',
      );
      return;
    }

    if (_selectedRole == 'coach' && _experienceYearsCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa el tiempo de experiencia.');
      return;
    }

    if (_selectedRole == 'nutriologo' &&
        _licenseNumberCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu cedula profesional.');
      return;
    }

    /*if ((_selectedRole == 'coach' || _selectedRole == 'nutriologo') &&
        _certificateFiles.isEmpty) {
      setState(() => _errorMessage = 'Agrega al menos un certificado.');
      return;
    }*/

    final metadata = <String, dynamic>{
      'nombre': _nameCtrl.text.trim(),
      'role': _selectedRole,
    };

    if (_selectedRole == 'cliente') {
      metadata['objective'] = _objective;
      metadata['activityLevel'] = _activityLevel;
      if (_birthDate != null) {
        metadata['birthDate'] = _birthDate!.toIso8601String().split('T').first;
      }
      if (_heightCtrl.text.trim().isNotEmpty) {
        metadata['height'] = _heightCtrl.text.trim();
      }
    } else if (_selectedRole == 'coach') {
      metadata['specialty'] = _specialty;
      metadata['experienceYears'] = _experienceYearsCtrl.text.trim();
      if (_coachBioCtrl.text.trim().isNotEmpty) {
        metadata['bio'] = _coachBioCtrl.text.trim();
      }
      if (_coachLocationCtrl.text.trim().isNotEmpty) {
        metadata['location'] = _coachLocationCtrl.text.trim();
      }
    } else if (_selectedRole == 'nutriologo') {
      metadata['licenseNumber'] = _licenseNumberCtrl.text.trim();
      metadata['focus'] = _focus;
    }

    setState(() => _loading = true);

    try {
      final response = await AuthService.register(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        metadata: metadata,
      );

      final profile = <String, dynamic>{
        if (_selectedRole == 'cliente') ...{
          'objective': _objective,
          'activityLevel': _activityLevel,
        },
        if (_selectedRole == 'coach') ...{
          'specialty': _specialty,
          'experienceYears': _experienceYearsCtrl.text.trim(),
        },
        if (_selectedRole == 'nutriologo') ...{
          'licenseNumber': _licenseNumberCtrl.text.trim(),
          'focus': _focus,
        },
      };

      if (_certificateFiles.isNotEmpty) {
        final userId = response.user?.id;
        if (userId == null || userId.isEmpty) {
          throw Exception('No user id available for certificate upload.');
        }

        final uploadedCertificates = await _uploadCertificates(
          userId: userId,
          role: _selectedRole,
          files: _certificateFiles,
        );

        profile['certificateUploads'] = uploadedCertificates;
      }

      // Sync profile to DB — errors here are non-fatal (auth account was created)
      try {
        await AuthService.syncCurrentUser(
          name: _nameCtrl.text.trim(),
          role: _selectedRole,
          profile: profile,
        );
      } catch (_) {
        // Profile sync failed; will be retried automatically on next login
      }

      if (!mounted) return;

      if (response.session == null) {
        setState(() {
          _message =
              'Registro exitoso. Revisa tu correo para verificar la cuenta y luego inicia sesion.';
          _loading = false;
        });
        return;
      }

      final role = parseUserRole(_selectedRole);
      context.go(roleHomeRoute(role));
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = _mapAuthError(e.message);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Error al crear la cuenta.';
        _loading = false;
      });
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('User already registered')) {
      return 'Este correo ya esta registrado.';
    }
    if (message.contains('Password should be')) {
      return 'La contrasena debe tener al menos 6 caracteres.';
    }
    if (message.contains('invalid')) {
      return 'Correo no valido.';
    }
    return 'Error al crear la cuenta.';
  }

  String _submitLabel() {
    switch (_selectedRole) {
      case 'coach':
        return 'REGISTRARME COMO COACH';
      case 'nutriologo':
        return 'REGISTRARME COMO NUTRIOLOGO';
      default:
        return 'REGISTRARME COMO CLIENTE';
    }
  }

  Future<void> _pickCertificateFiles() async {
    setState(() {
      _errorMessage = null;
      _message = null;
    });

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions.toList(),
    );

    if (result == null) return;

    final files = result.files;
    if (files.length > _maxCertificateFiles) {
      setState(() {
        _errorMessage =
            'Solo puedes subir hasta $_maxCertificateFiles certificados.';
      });
      return;
    }

    for (final file in files) {
      final extension = (file.extension ?? '').toLowerCase();
      if (!_allowedExtensions.contains(extension)) {
        setState(() {
          _errorMessage =
              'Formato no permitido: ${file.name}. Usa PNG, JPG, WEBP o PDF.';
        });
        return;
      }

      if (file.size > _maxCertificateFileSizeBytes) {
        setState(() {
          _errorMessage =
              'Archivo demasiado grande: ${file.name} (maximo 5 MB).';
        });
        return;
      }
    }

    setState(() => _certificateFiles = files);
  }

  Future<List<Map<String, dynamic>>> _uploadCertificates({
    required String userId,
    required String role,
    required List<PlatformFile> files,
  }) async {
    final storage = Supabase.instance.client.storage.from(_certificatesBucket);
    final uploadResults = <Map<String, dynamic>>[];

    for (final file in files) {
      final fileBytes = file.bytes;
      if (fileBytes == null) {
        throw Exception('No se pudieron leer los bytes de ${file.name}.');
      }

      final sanitizedName = file.name
          .replaceAll(RegExp(r'\s+'), '-')
          .toLowerCase();
      final filePath =
          '$role/$userId/${DateTime.now().millisecondsSinceEpoch}-$sanitizedName';

      await storage.uploadBinary(
        filePath,
        fileBytes,
        fileOptions: FileOptions(
          upsert: false,
          contentType: _contentTypeForExtension(file.extension),
        ),
      );

      uploadResults.add({
        'name': file.name,
        'path': filePath,
        'type': _contentTypeForExtension(file.extension),
        'size': file.size,
      });
    }

    return uploadResults;
  }

  String _contentTypeForExtension(String? extension) {
    switch ((extension ?? '').toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  Widget _buildCertificatesSection() {
    final hasFiles = _certificateFiles.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('FOTOS DE CERTIFICADOS *'),
        OutlinedButton.icon(
          onPressed: _loading ? null : _pickCertificateFiles,
          icon: const Icon(Icons.upload_file, color: _CF.neon),
          label: Text(
            hasFiles ? 'Cambiar archivos' : 'Seleccionar archivos',
            style: const TextStyle(color: _CF.white),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _CF.border),
            backgroundColor: _CF.card,
            minimumSize: const Size(double.infinity, 48),
            alignment: Alignment.centerLeft,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hasta 3 archivos (PNG, JPG, WEBP, PDF), maximo 5MB cada uno.',
          style: const TextStyle(color: _CF.labelGrey, fontSize: 12),
        ),
        if (hasFiles) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _certificateFiles
                .asMap()
                .entries
                .map((entry) => _buildCertificateThumb(entry.key, entry.value))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCertificateThumb(int index, PlatformFile file) {
    final fileBytes = file.bytes;
    final sizeKb = (file.size / 1024).toStringAsFixed(1);
    final ext = (file.extension ?? '').toLowerCase();
    final isPdf = ext == 'pdf';

    return Container(
      width: 110,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _CF.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _CF.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 98,
              height: 76,
              child: isPdf
                  ? Container(
                      color: const Color(0xFF101010),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf,
                              color: Color(0xFFFF6B6B), size: 32),
                          Text('PDF',
                              style: TextStyle(
                                  color: Color(0xFFFF6B6B), fontSize: 10)),
                        ],
                      ),
                    )
                  : fileBytes != null
                      ? Image.memory(fileBytes, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFF101010),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: _CF.labelGrey,
                            size: 20,
                          ),
                        ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _CF.white, fontSize: 11),
          ),
          Text(
            '$sizeKb KB',
            style: const TextStyle(color: _CF.labelGrey, fontSize: 10),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        _certificateFiles = _certificateFiles
                            .asMap()
                            .entries
                            .where((entry) => entry.key != index)
                            .map((entry) => entry.value)
                            .toList();
                      });
                    },
              style: TextButton.styleFrom(
                foregroundColor: _CF.error,
                padding: const EdgeInsets.symmetric(vertical: 0),
                minimumSize: const Size(0, 26),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Quitar', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CF.bg,
      appBar: AppBar(
        backgroundColor: _CF.bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'CLOUDFIT',
          style: TextStyle(
            color: _CF.neon,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear nueva cuenta',
                style: TextStyle(
                  color: _CF.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('TIPO DE USUARIO *'),
              _buildRoleDropdown(),
              const SizedBox(height: 16),
              const _FieldLabel('NOMBRE COMPLETO *'),
              _CFTextField(controller: _nameCtrl, hint: 'Juan Perez'),
              const SizedBox(height: 12),
              const _FieldLabel('CORREO ELECTRONICO *'),
              _CFTextField(
                controller: _emailCtrl,
                hint: 'ejemplo@correo.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              const _FieldLabel('CONTRASENA *'),
              _CFTextField(
                controller: _passCtrl,
                hint: '********',
                isPassword: true,
              ),
              const SizedBox(height: 12),
              const _FieldLabel('CONFIRMAR CONTRASENA *'),
              _CFTextField(
                controller: _confirmCtrl,
                hint: '********',
                isPassword: true,
              ),
              const SizedBox(height: 14),
              ..._buildRoleFields(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: _CF.error, fontSize: 13),
                ),
              ],
              if (_message != null) ...[
                const SizedBox(height: 14),
                Text(
                  _message!,
                  style: const TextStyle(color: _CF.success, fontSize: 13),
                ),
              ],
              const SizedBox(height: 22),
              _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _CF.neon),
                    )
                  : _CFButton(label: _submitLabel(), onTap: _register),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRoleFields() {
    if (_selectedRole == 'coach') {
      return [
        const _FieldLabel('ESPECIALIDAD *'),
        _buildDropdown(_specialty, const {
          'fuerza': 'Fuerza',
          'funcional': 'Entrenamiento funcional',
          'rehabilitacion': 'Rehabilitacion',
          'alto_rendimiento': 'Alto rendimiento',
        }, (v) => setState(() => _specialty = v!)),
        const SizedBox(height: 12),
        const _FieldLabel('TIEMPO DE EXPERIENCIA *'),
        _CFTextField(
          controller: _experienceYearsCtrl,
          hint: 'Años',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        const _FieldLabel('BIO CORTA'),
        _CFTextField(
          controller: _coachBioCtrl,
          hint: 'Cuéntanos sobre ti...',
        ),
        const SizedBox(height: 12),
        const _FieldLabel('UBICACION'),
        _CFTextField(
          controller: _coachLocationCtrl,
          hint: 'Ciudad, País',
        ),
        const SizedBox(height: 12),
        _buildCertificatesSection(),
      ];
    }

    if (_selectedRole == 'nutriologo') {
      return [
        const _FieldLabel('CEDULA PROFESIONAL *'),
        _CFTextField(controller: _licenseNumberCtrl, hint: 'CED-123456'),
        const SizedBox(height: 12),
        const _FieldLabel('ENFOQUE NUTRICIONAL *'),
        _buildDropdown(_focus, const {
          'deportivo': 'Nutricion deportiva',
          'clinico': 'Nutricion clinica',
          'control_peso': 'Control de peso',
          'bienestar': 'Bienestar integral',
        }, (v) => setState(() => _focus = v!)),
        const SizedBox(height: 12),
        _buildCertificatesSection(),
      ];
    }

    return [
      const _FieldLabel('OBJETIVO PRINCIPAL *'),
      _buildDropdown(_objective, const {
        'perder_peso': 'Perder peso',
        'ganar_masa': 'Ganar masa muscular',
        'mejorar_condicion': 'Mejorar condicion fisica',
        'bienestar_general': 'Bienestar general',
      }, (v) => setState(() => _objective = v!)),
      const SizedBox(height: 12),
      const _FieldLabel('NIVEL DE ACTIVIDAD *'),
      _buildDropdown(_activityLevel, const {
        'bajo': 'Bajo',
        'medio': 'Medio',
        'alto': 'Alto',
      }, (v) => setState(() => _activityLevel = v!)),
      const SizedBox(height: 12),
      const _FieldLabel('FECHA DE NACIMIENTO'),
      _buildDatePicker(),
      const SizedBox(height: 12),
      const _FieldLabel('ESTATURA (cm)'),
      _CFTextField(
        controller: _heightCtrl,
        hint: 'Ej: 170',
        keyboardType: TextInputType.number,
      ),
    ];
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _birthDate ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1940),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
          builder: (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: _CF.neon),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _birthDate = picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _CF.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _CF.border),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined,
              color: _CF.labelGrey, size: 18),
          const SizedBox(width: 12),
          Text(
            _birthDate != null
                ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                : 'Seleccionar fecha',
            style: TextStyle(
              color: _birthDate != null ? _CF.white : _CF.hint,
              fontSize: 14,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildRoleDropdown() => _buildDropdown(
    _selectedRole,
    const {
      'cliente': 'Cliente',
      'coach': 'Coach',
      'nutriologo': 'Nutriologo',
    },
    (v) {
      if (v == null) return;
      setState(() {
        _selectedRole = v;
        _certificateFiles = [];
        _errorMessage = null;
        _message = null;
      });
    },
  );

  Widget _buildDropdown(
    String value,
    Map<String, String> options,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _CF.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _CF.border),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: _CF.card,
        underline: const SizedBox(),
        isExpanded: true,
        style: const TextStyle(color: _CF.white, fontSize: 14),
        items: options.entries
            .map(
              (entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _CF.labelGrey,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _CFTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;

  const _CFTextField({
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: _CF.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _CF.hint),
        filled: true,
        fillColor: _CF.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _CF.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _CF.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _CF.neon),
        ),
      ),
    );
  }
}

class _CFButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CFButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _CF.neon,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
