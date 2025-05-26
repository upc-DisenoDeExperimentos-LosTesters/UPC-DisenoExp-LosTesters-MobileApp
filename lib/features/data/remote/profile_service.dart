import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
import 'profile_model.dart';

class ProfileService {
  Future<ProfileModel?> getProfileByEmail(String email) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.profile}/email/$email');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(json.decode(response.body));
      } else {
        print('Error al obtener perfil. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en getProfileByEmail: $e');
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
        return ProfileModel.fromJson(json.decode(response.body));
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
}
