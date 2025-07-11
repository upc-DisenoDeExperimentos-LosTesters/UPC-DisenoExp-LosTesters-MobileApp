
import 'package:flutter/material.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/login_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/register_screen.dart';

void main() {
  runApp( MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoviGestion',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(
          onLoginClicked: (username, password) {
            // Este callback no es necesario, ya que la lógica de navegación se maneja en la pantalla LoginScreen
          },
          onRegisterClicked: () {
            Navigator.pushNamed(context, '/register');
          },
        ),
        '/register': (context) => RegisterScreen(
          onNextClicked: () {
            // Aquí puedes manejar la lógica de navegación al siguiente paso del registro
          },
        ),
      },
    );
  }
}