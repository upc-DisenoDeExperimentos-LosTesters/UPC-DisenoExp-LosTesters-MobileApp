import 'package:flutter/material.dart';
//import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/profile/profile_screen.dart';
//import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/profile/profile_screen2.dart';
//import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/register_screen.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';

class LoginScreen extends StatefulWidget {
  final Function(String, String) onLoginClicked;
  final VoidCallback onRegisterClicked;

  const LoginScreen({
    Key? key,
    required this.onLoginClicked,
    required this.onRegisterClicked,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _handleLogin() async {
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    setState(() => _errorMessage = 'Ingrese email y contraseña');
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final success = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && AuthService.currentUser != null) {
      _navigateBasedOnRole(AuthService.currentUser!);
    } else {
      setState(() => _errorMessage = 'Credenciales incorrectas');
    }
  } catch (e) {
    setState(() => _errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}');
  } finally {
    setState(() => _isLoading = false);
  }
}

  void _navigateBasedOnRole(ProfileModel profile) {
    print('DEBUG: Profile ID for logged in user: ${profile.id}'); // <-- ¡Añade esta línea!
    print('DEBUG: Profile name: ${profile.name}');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => profile.type == 'TRANSPORTISTA'
            ? ProfileScreen2(
                name: profile.name,
                lastName: profile.lastName,
                userId: profile.id,
              )
            : ProfileScreen( // Pantalla alternativa para otros roles
                name: profile.name,
                lastName: profile.lastName,
                userId: profile.id,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1F24),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/images/login_logo.png',
                height: 120,
                errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.red), // Manejo de error de imagen
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: _buildInputDecoration('Email', Icons.email),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: _buildInputDecoration('Contraseña', Icons.lock),
                obscureText: true,
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'INGRESAR',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text(
                  '¿No tienes cuenta? Regístrate aquí',
                  style: TextStyle(
                    color: Colors.amber,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}