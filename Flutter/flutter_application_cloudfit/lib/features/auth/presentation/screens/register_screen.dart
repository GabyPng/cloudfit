import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants.dart';

class RegisterScreen extends StatelessWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 100),
            // Logo Cloudfit
            const Text(
              "CLOUDFIT",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 60),
            
            // Campos de entrada
            _buildTextField("Nombre"),
            const SizedBox(height: 20),
            _buildTextField("Email"),
            const SizedBox(height: 20),
            _buildTextField("Password", isPassword: true),
            
            const SizedBox(height: 80),
            
            // Botón Log In 
            _buildActionButton(
              text: "Log In",
              color: AppColors.electricPurple,
              onPressed: () => context.go('/'),
            ),
            
            const SizedBox(height: 20),
            
            // Botón Sign Up 
            _buildActionButton(
              text: "Sign Up",
              color: AppColors.neonGreen,
              textColor: Colors.black,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword 
                ? const Icon(Icons.visibility_off, color: Colors.white38) 
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text, 
    required Color color, 
    required VoidCallback onPressed,
    Color textColor = Colors.white
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}