import 'package:flutter/material.dart';
import 'dart:convert'; // Añade esto en la parte superior con los otros imports
import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
//import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_model.dart';
//import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/login_screen.dart';
import 'package:http/http.dart' as http;

class UserRegistrationScreen extends StatefulWidget {
  final String selectedRole;

  const UserRegistrationScreen({
    Key? key,
    required this.selectedRole,
  }) : super(key: key);

  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _termsAccepted = false;
  bool _isLoading = false;
  String _errorMessage = '';

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      setState(() => _errorMessage = 'Debe aceptar los términos y condiciones');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstrants.baseUrl}${AppConstrants.profile}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'type': widget.selectedRole,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              onLoginClicked: (email, password) {},
              onRegisterClicked: () {},
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso!')),
        );
      } else {
        setState(() => _errorMessage = 'Error en el registro: ${response.body}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1F24),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/images/login_logo.png', height: 100),
                const SizedBox(height: 30),
                Text(
                  'Registro de ${widget.selectedRole}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                _buildNameField(),
                const SizedBox(height: 15),
                _buildLastNameField(),
                const SizedBox(height: 15),
                _buildEmailField(),
                const SizedBox(height: 15),
                _buildPasswordField(),
                const SizedBox(height: 15),
                _buildConfirmPasswordField(),
                const SizedBox(height: 20),
                _buildTermsCheckbox(),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                _buildRegisterButton(),
                const SizedBox(height: 15),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nombre',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2A2E35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su nombre';
        }
        return null;
      },
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      decoration: InputDecoration(
        labelText: 'Apellido',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2A2E35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su apellido';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2A2E35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su email';
        }
        if (!_isEmailValid(value)) {
          return 'Ingrese un email válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2A2E35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese una contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Confirmar Contraseña',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2A2E35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _termsAccepted,
          onChanged: (value) {
            setState(() {
              _termsAccepted = value ?? false;
            });
          },
          activeColor: Colors.amber,
        ),
        const Text(
          'Acepto los términos y condiciones',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registerUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
                'REGISTRARSE',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              onLoginClicked: (email, password) {},
              onRegisterClicked: () {},
            ),
          ),
        );
      },
      child: const Text(
        '¿Ya tienes cuenta? Inicia sesión',
        style: TextStyle(color: Colors.amber),
      ),
    );
  }
}