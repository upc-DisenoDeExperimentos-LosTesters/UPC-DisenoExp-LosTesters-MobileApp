import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_service.dart';

class AuthService {
  static String? _token;
  static ProfileModel? _currentUser;

  static String? get token => _token;
  static ProfileModel? get currentUser => _currentUser;

  static Future<bool> login(String email, String password) async {
  try {
    final profileService = ProfileService();
    
    // 1. Primero autenticar (login)
    final loginResponse = await profileService.login(email, password);
    
    if (loginResponse == null || loginResponse.token == null) {
      throw Exception('No se obtuvo token de autenticación');
    }
    _token = loginResponse.token;
    
    // 2. Obtener perfil completo por email
    final fullProfile = await profileService.getProfileByEmail(email);
    if (fullProfile == null) {
      throw Exception('Perfil no encontrado');
    }
    
    // 3. Combinar token con perfil completo
    _currentUser = fullProfile..token = _token;
    
    print('✅ Login exitoso. Datos completos: ${_currentUser!.toJson()}');
    return true;
    
  } catch (e) {
    print('❌ Error en AuthService.login: $e');
    _token = null;
    _currentUser = null;
    return false;
  }
}

  static void logout() {
    _token = null;
    _currentUser = null;
  }

  static bool get isLoggedIn => _token != null;

  // Nuevo método opcional para verificar sesión
  static Future<bool> verifySession() async {
    if (_token == null || _currentUser == null) return false;
    
    try {
      final profileService = ProfileService();
      final profile = await profileService.getProfileByEmail(_currentUser!.email);
      return profile != null;
    } catch (e) {
      return false;
    }
  }
}