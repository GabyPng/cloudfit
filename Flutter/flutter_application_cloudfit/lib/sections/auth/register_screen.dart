import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth_service.dart';

// --- SISTEMA DE DISEÑO CLOUDFIT ---
class _CF {
  static const bg = Color(0xFF0D0D0D);
  static const card = Color(0xFF1A1A1A);
  static const neon = Color(0xFFCCFF00);
  static const purple = Color(0xFF8B5CF6);
  static const white = Colors.white;
  static const hint = Color(0xFF555555);
  static const border = Color(0xFF2A2A2A);
  static const labelGrey = Color(0xFF888888);
  static const error = Color(0xFFFF4444);
}

class RegisterScreen extends StatefulWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 8;
  String? _errorMessage;
  bool _loading = false;

  // --- CONTROLADORES Y ESTADO ---
  // Paso 0: Auth
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Paso 1: Personales
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _medsDetailCtrl = TextEditingController();
  final _waterCtrl = TextEditingController();

  String _occupation = "Sedentaria (Oficina, Estudio, etc)";
  bool _takesMeds = false;
  String _currentPain = "Ninguna";
  bool _usesSupport = false;
  String _experience = "Principiante (0-6 meses)";
  String _cardioType = "Ninguno";
  String _sleepHours = "6-8hrs";
  String _objective = "Hipertrofia (Ganancia de masa muscular)";
  String _daysAvailable = "3";

  @override
  void dispose() {
    _pageController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _medsDetailCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden.');
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.register(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        metadata: {'nombre': _nameCtrl.text.trim(), 'role': 'cliente'},
      );
      await AuthService.syncCurrentUser(
        name: _nameCtrl.text.trim(),
        role: 'cliente',
      );
      if (mounted) context.go('/cliente');
    } on AuthException catch (e) {
      setState(() => _errorMessage = _mensajeError(e.message));
    } catch (_) {
      setState(() => _errorMessage = 'Error al crear la cuenta.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _nextPage() async {
    setState(() => _errorMessage = null);

    if (_currentStep < _totalSteps - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      return;
    }

    await _register();
  }

  String _mensajeError(String message) {
    if (message.contains('User already registered')) {
      return 'Este correo ya está registrado.';
    }
    if (message.contains('Password should be')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (message.contains('invalid')) {
      return 'Correo no válido.';
    }
    return 'Error al crear la cuenta.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CF.bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _stepAuth(),
                _stepPersonalData(),
                _stepMedical(),
                _stepInjuries(),
                _stepInjuriesDetail(),
                _stepFitnessLevel(),
                _stepLifestyle(),
                _stepObjectives(),
              ],
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: _CF.error, fontSize: 12),
              ),
            ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  // --- PASOS DEL FORMULARIO ---

  Widget _stepAuth() => _StepLayout(
    title: "Cuenta",
    subtitle: "Credenciales de acceso",
    children: [
      const _FieldLabel('CORREO *'),
      _CFTextField(controller: _emailCtrl, hint: 'ejemplo@correo.com'),
      const SizedBox(height: 16),
      const _FieldLabel('CONTRASEÑA *'),
      _CFTextField(controller: _passCtrl, hint: '••••••••', isPassword: true),
      const SizedBox(height: 16),
      const _FieldLabel('CONFIRMAR CONTRASEÑA *'),
      _CFTextField(
        controller: _confirmCtrl,
        hint: '••••••••',
        isPassword: true,
      ),
    ],
  );

  Widget _stepPersonalData() => _StepLayout(
    title: "Perfil",
    subtitle: "Datos físicos iniciales",
    children: [
      const _FieldLabel('NOMBRE COMPLETO *'),
      _CFTextField(controller: _nameCtrl, hint: 'Nombre'),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _CFTextField(
              controller: _ageCtrl,
              hint: 'Edad *',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CFTextField(
              controller: _weightCtrl,
              hint: 'Peso (kg) *',
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const _FieldLabel('OCUPACIÓN'),
      _buildDropdown(_occupation, [
        "Sedentaria (Oficina, Estudio, etc)",
        "Actividad Ligera",
        "Actividad Moderada",
        "Actividad Intensa",
      ], (v) => setState(() => _occupation = v!)),
    ],
  );

  Widget _stepMedical() => _StepLayout(
    title: "Salud",
    subtitle: "Antecedentes médicos",
    children: [
      const _FieldLabel('¿TOMA MEDICAMENTOS?'),
      _buildOption("Sí", _takesMeds, () => setState(() => _takesMeds = true)),
      _buildOption("No", !_takesMeds, () => setState(() => _takesMeds = false)),
      if (_takesMeds) ...[
        const SizedBox(height: 10),
        _CFTextField(controller: _medsDetailCtrl, hint: "¿Cuáles?"),
      ],
    ],
  );

  Widget _stepInjuries() => _StepLayout(
    title: "Molestias",
    subtitle: "Lesiones actuales",
    children: [
      const _FieldLabel('ZONA DE DOLOR'),
      _buildDropdown(_currentPain, [
        "Ninguna",
        "Columna (Cervical, lumbar...)",
        "Tren Superior (Hombro...)",
        "Tren Inferior (Rodilla...)",
      ], (v) => setState(() => _currentPain = v!)),
      const SizedBox(height: 16),
      const _FieldLabel('¿USA SOPORTES?'),
      _buildOption(
        "Sí",
        _usesSupport,
        () => setState(() => _usesSupport = true),
      ),
      _buildOption(
        "No",
        !_usesSupport,
        () => setState(() => _usesSupport = false),
      ),
    ],
  );

  Widget _stepInjuriesDetail() => _StepLayout(
    title: "Historial",
    subtitle: "Cirugías previas",
    children: [
      _CFTextField(controller: TextEditingController(), hint: "Fracturas"),
      const SizedBox(height: 16),
      _CFTextField(
        controller: TextEditingController(),
        hint: "Cirugías realizadas",
      ),
    ],
  );

  Widget _stepFitnessLevel() => _StepLayout(
    title: "Nivel",
    subtitle: "Experiencia deportiva",
    children: [
      const _FieldLabel('EXPERIENCIA *'),
      _buildDropdown(_experience, [
        "Principiante (0-6 meses)",
        "Intermedio (6 meses-2 años)",
        "Avanzado (+2 años)",
      ], (v) => setState(() => _experience = v!)),
      const SizedBox(height: 16),
      const _FieldLabel('CARDIO PREFERIDO'),
      _buildDropdown(_cardioType, [
        "Ninguno",
        "LISS (Caminar)",
        "MISS (Correr)",
        "HIIT",
        "Ciclismo",
        "Natación",
      ], (v) => setState(() => _cardioType = v!)),
    ],
  );

  Widget _stepLifestyle() => _StepLayout(
    title: "Hábitos",
    subtitle: "Estilo de vida diario",
    children: [
      const _FieldLabel('HORAS DE SUEÑO'),
      _buildDropdown(_sleepHours, [
        "Menos de 6hrs",
        "6-8hrs",
        "Más de 8hrs",
      ], (v) => setState(() => _sleepHours = v!)),
      const SizedBox(height: 16),
      const _FieldLabel('AGUA AL DÍA (LITROS) *'),
      _CFTextField(
        controller: _waterCtrl,
        hint: "Ej: 2.5",
        keyboardType: TextInputType.number,
      ),
    ],
  );

  Widget _stepObjectives() => _StepLayout(
    title: "Metas",
    subtitle: "Objetivos finales",
    children: [
      const _FieldLabel('OBJETIVO PRINCIPAL *'),
      _buildDropdown(_objective, [
        "Hipertrofia (Ganancia de masa muscular)",
        "Fuerza",
        "Resistencia",
        "Salud/Rehabilitación de una lesión (Tono muscular)",
      ], (v) => setState(() => _objective = v!)),
      const SizedBox(height: 16),
      const _FieldLabel('DÍAS DISPONIBLES'),
      _buildDropdown(_daysAvailable, [
        "2",
        "3",
        "4",
        "5",
        "6",
      ], (v) => setState(() => _daysAvailable = v!)),
    ],
  );

  // --- WIDGETS AUXILIARES ---

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: _CF.bg,
    elevation: 0,
    leading: _currentStep > 0
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () {
              setState(() => _errorMessage = null);
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            },
          )
        : null,
    title: const Text(
      "CLOUDFIT",
      style: TextStyle(
        color: _CF.neon,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ),
    ),
    centerTitle: true,
  );

  Widget _buildProgressBar() => Container(
    height: 4,
    width: double.infinity,
    color: _CF.card,
    child: FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: (_currentStep + 1) / _totalSteps,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [_CF.purple, _CF.neon]),
        ),
      ),
    ),
  );

  Widget _buildBottomActions() => Padding(
    padding: const EdgeInsets.fromLTRB(28, 10, 28, 30),
    child: _loading
        ? const Center(child: CircularProgressIndicator(color: _CF.neon))
        : _CFButton(
            label: _currentStep == _totalSteps - 1 ? 'FINALIZAR' : 'SIGUIENTE',
            onTap: _nextPage,
          ),
  );

  Widget _buildOption(String t, bool s, VoidCallback o) => GestureDetector(
    onTap: o,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s ? _CF.neon.withValues(alpha: 0.1) : _CF.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: s ? _CF.neon : _CF.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t,
            style: TextStyle(
              color: s ? _CF.neon : _CF.white,
              fontWeight: s ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (s) const Icon(Icons.check_circle, color: _CF.neon, size: 20),
        ],
      ),
    ),
  );

  Widget _buildDropdown(String v, List<String> i, Function(String?) c) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _CF.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _CF.border),
        ),
        child: DropdownButton<String>(
          value: v,
          dropdownColor: _CF.card,
          underline: const SizedBox(),
          isExpanded: true,
          style: const TextStyle(color: _CF.white, fontSize: 14),
          items: i
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: c,
        ),
      );
}

// --- COMPONENTES DE INTERFAZ REUTILIZABLES ---

class _StepLayout extends StatelessWidget {
  final String title, subtitle;
  final List<Widget> children;
  const _StepLayout({
    required this.title,
    required this.subtitle,
    required this.children,
  });
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            color: _CF.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: _CF.labelGrey, fontSize: 13),
        ),
        const SizedBox(height: 30),
        ...children,
      ],
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
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
  Widget build(BuildContext context) => TextField(
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

class _CFButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _CFButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _CF.neon,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.8,
        ),
      ),
    ),
  );
}
