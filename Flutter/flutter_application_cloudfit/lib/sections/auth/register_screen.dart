import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _CF {
  static const bg        = Color(0xFF0D0D0D);
  static const card      = Color(0xFF1A1A1A);
  static const neon      = Color(0xFFCCFF00);
  static const white     = Colors.white;
  static const hint      = Color(0xFF555555);
  static const border    = Color(0xFF2A2A2A);
  static const labelGrey = Color(0xFF888888);
}

class RegisterScreen extends StatefulWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CF.bg,
      body: SafeArea(
        child: Column(
          children: [

           Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  MouseRegion(                              
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: _CF.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Headline
                    const Text(
                      'Crea tu\ncuenta',
                      style: TextStyle(
                        color: _CF.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Empieza tu cuenta fitness hoy',
                      style: TextStyle(color: _CF.labelGrey, fontSize: 13),
                    ),

                    const SizedBox(height: 30),

                    const _FieldLabel('NOMBRE COMPLETO'),
                    const _CFTextField(hint: 'Tu nombre'),

                    const SizedBox(height: 16),

                    const _FieldLabel('CORREO ELECTRÓNICO'),
                    const _CFTextField(
                      hint: 'ejemplo@correo.com',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    const _FieldLabel('TELÉFONO'),
                    const _CFTextField(
                      hint: '+52 · Tu número',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    const _FieldLabel('CONTRASEÑA'),
                    _CFTextField(
                      hint: '••••••••',
                      isPassword: _obscurePass,
                      suffix: GestureDetector(
                        onTap: () =>
                            setState(() => _obscurePass = !_obscurePass),
                        child: Icon(
                          _obscurePass
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _CF.hint,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const _FieldLabel('CONFIRMAR CONTRASEÑA'),
                    _CFTextField(
                      hint: '••••••••',
                      isPassword: _obscureConfirm,
                      suffix: GestureDetector(
                        onTap: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        child: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _CF.hint,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(children: [
                      const Text(
                        'Al registrarte aceptas los ',
                        style: TextStyle(color: _CF.labelGrey, fontSize: 11),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'términos de uso',
                          style: TextStyle(
                            color: _CF.neon,
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                            decorationColor: _CF.neon,
                          ),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    _CFButton(label: 'CREAR CUENTA', onTap: () {}),

                    const SizedBox(height: 20),

                   Center(
                      child: RichText(
                        text: TextSpan(
                          text: '¿Ya tienes cuenta? ',
                          style: const TextStyle(
                              color: _CF.labelGrey, fontSize: 13),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: MouseRegion(          
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => context.go('/login'),
                                  child: const Text(
                                    'Inicia sesión',
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

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StepTab extends StatelessWidget {
  final String label;
  final bool active;
  const _StepTab({required this.label, required this.active});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? _CF.neon : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _CF.neon : _CF.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? _CF.neon : _CF.labelGrey,
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          ),
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
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? suffix;

  const _CFTextField({
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) => TextField(
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: _CF.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _CF.hint, fontSize: 14),
          filled: true,
          fillColor: _CF.card,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26)),
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
