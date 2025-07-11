import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart';
import 'profile_model.dart';

class ProfileService {


  Future<ProfileModel?> getProfileByEmail(String email) async {
  try {
    final encodedEmail = Uri.encodeComponent(email);
    final url = Uri.parse('${AppConstrants.baseUrl}/api/v1/profile/email/$encodedEmail');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}', // Usa el token recién obtenido
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        return ProfileModel.fromJson(data);
      }
      throw Exception('Formato de respuesta inválido');
    }
    throw Exception('Error ${response.statusCode}: ${response.body}');
  } catch (e) {
    print('‼️ Error en getProfileByEmail: $e');
    throw Exception('No se pudo obtener el perfil');
  }
}
  
  Future<ProfileModel?> _getCurrentProfile() async {
  try {
    print('Obteniendo perfil actual...');
    print('Email del usuario: ${AuthService.currentUser?.email}');

    // Usar el endpoint que obtiene el perfil por email
    final response = await http.get(
      Uri.parse('${AppConstrants.baseUrl}/api/v1/profile/email/${AuthService.currentUser?.email}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );

    print('Código de respuesta: ${response.statusCode}');
    print('Respuesta del servidor: ${response.body}');

    if (response.statusCode == 200) {
      final profileData = json.decode(response.body);
      final profile = ProfileModel.fromJson(profileData);
      
      print('Perfil obtenido: ${profile.name} ${profile.lastName}');
      return profile;
    } else if (response.statusCode == 404) {
      print('Perfil no encontrado para el email proporcionado');
      return null;
    } else {
      print('Error del servidor al obtener perfil');
      return null;
    }
  } catch (e) {
    print('Excepción al obtener perfil: $e');
    return null;
  }
}

  Future<bool> updateProfileByEmailAndPassword(
    String email, 
    String password,
    Map<String, dynamic> updatedData
  ) async {
    // Versión temporal que no hace nada pero devuelve true para evitar errores
    print('⚠️ Método temporal - updateProfileByEmailAndPassword llamado');
    print('Email: $email');
    print('Datos a actualizar: $updatedData');
    
    return true; // Simula éxito
}

  // Registrar nuevo perfil (POST)
  Future<ProfileModel?> registerProfile(ProfileModel profile) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.profile}');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profile.toJson()),
      );

      if (response.statusCode == 201) {
        return ProfileModel.fromJson(json.decode(response.body));
      } else {
        print('Error en registro. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en registerProfile: $e');
      return null;
    }
  }

  // Login (POST)
  Future<ProfileModel?> login(String email, String password) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.profile}/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final profile = ProfileModel.fromJson(json.decode(response.body));
        print('👤 Perfil obtenido en login: ${profile.toJson()}');
        return profile;
      } else {
        print('Error en login. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // Actualizar perfil (asumiendo que usas ID)
  Future<bool> updateProfile(int id, Map<String, dynamic> updatedData) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.profile}/$id');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al actualizar. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en updateProfile: $e');
      return false;
    }
  }

  // Obtener perfil por ID
  Future<ProfileModel?> getProfileById(int id) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.profile}/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(json.decode(response.body));
      } else {
        print('Error al obtener perfil por ID. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error en getProfileById: $e');
      return null;
    }
  }

  // Nuevo método para obtener todos los perfiles (requerido para CarrierProfilesScreen)
  Future<List<ProfileModel>> getAllProfiles() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstrants.baseUrl}${AppConstrants.profile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> profiles = json.decode(response.body);
        return profiles.map((json) => ProfileModel.fromJson(json)).toList();
      }
      throw Exception('Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('‼️ Error en getAllProfiles: $e');
      throw Exception('Error al cargar perfiles');
    }
  }
}
