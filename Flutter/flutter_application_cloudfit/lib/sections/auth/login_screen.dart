import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import '../../core/auth_service.dart';

class _CF {
  static const bg = Color(0xFF0D0D0D);
  static const card = Color(0xFF1A1A1A);
  static const neon = Color(0xFFCCFF00);
  static const white = Colors.white;
  static const hint = Color(0xFF555555);
  static const border = Color(0xFF2A2A2A);
  static const labelGrey = Color(0xFF888888);
  static const error = Color(0xFFFF4444);
}

class LoginScreen extends StatefulWidget {
  static const String name = 'login_screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      await AuthService.loadRole();
      if (mounted) context.go(AuthService.homeRouteForCurrentUser);
    } on AuthException catch (e) {
      setState(() => _error = _mensajeError(e.message));
    } catch (e) {
      setState(() => _error = 'Error técnico: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mensajeError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión.';
    }
    if (message.contains('Too many requests')) {
      return 'Demasiados intentos. Intenta más tarde.';
    }
    return 'Error al iniciar sesión.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CF.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36),

              const Center(
                child: Text(
                  'CLOUDFIT',
                  style: TextStyle(
                    color: _CF.neon,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -1,
                  ),
                ),
              ),

              const SizedBox(height: 44),

              const Text(
                'Bienvenido\nde vuelta',
                style: TextStyle(
                  color: _CF.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Inicia sesión para continuar',
                style: TextStyle(color: _CF.labelGrey, fontSize: 13),
              ),

              const SizedBox(height: 36),

              const _FieldLabel('CORREO'),
              _CFTextField(
                controller: _emailCtrl,
                hint: 'ejemplo@correo.com',
                keyboardType: TextInputType.emailAddress,
                suffix: const Icon(
                  Icons.email_outlined,
                  color: _CF.hint,
                  size: 20,
                ),
              ),

              const SizedBox(height: 18),

              const _FieldLabel('CONTRASEÑA'),
              _CFTextField(
                controller: _passwordCtrl,
                hint: '••••••••',
                isPassword: _obscure,
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: _CF.hint,
                    size: 20,
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: _CF.error, fontSize: 13),
                ),
              ],

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: _CF.neon, fontSize: 12),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _CF.neon),
                    )
                  : _CFButton(label: 'INGRESAR', onTap: _login),

              const SizedBox(height: 28),

              Row(
                children: [
                  const Expanded(child: Divider(color: _CF.border)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o continúa con',
                      style: TextStyle(color: _CF.labelGrey, fontSize: 11),
                    ),
                  ),
                  const Expanded(child: Divider(color: _CF.border)),
                ],
              ),

              const SizedBox(height: 20),

              const Row(
                children: [
                  _SocialBtn(label: 'G'),
                  SizedBox(width: 12),
                  _SocialBtn(label: 'f'),
                  SizedBox(width: 12),
                  _SocialBtn(label: 'Apple'),
                ],
              ),

              const SizedBox(height: 32),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: '¿No tienes cuenta? ',
                    style: const TextStyle(color: _CF.labelGrey, fontSize: 13),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => context.push('/register'),
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(
                                color: _CF.neon,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
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
  final Widget? suffix;

  const _CFTextField({
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: isPassword,
    keyboardType: keyboardType,
    style: const TextStyle(color: _CF.white, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _CF.hint, fontSize: 14),
      filled: true,
      fillColor: _CF.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _CF.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _CF.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _CF.neon, width: 1.5),
      ),
      suffixIcon: suffix,
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
        elevation: 0,
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

class _SocialBtn extends StatelessWidget {
  final String label;
  const _SocialBtn({required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          side: const BorderSide(color: _CF.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _CF.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

