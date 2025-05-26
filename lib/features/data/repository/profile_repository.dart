import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository({required ProfileService profileService}) 
    : _profileService = profileService;

  // Para login (usa email y password)
  Future<ProfileModel?> login(String email, String password) async {
    return await _profileService.login(email, password);
  }

  // Para obtener perfil por email (sin password)
  Future<ProfileModel?> getProfileByEmail(String email) async {
    return await _profileService.getProfileByEmail(email);
  }

  // Para registrar nuevo perfil
  Future<ProfileModel?> registerProfile(ProfileModel profile) async {
    return await _profileService.registerProfile(profile);
  }

  // Para obtener perfil por ID
  Future<ProfileModel?> getProfileById(int id) async {
    return await _profileService.getProfileById(id);
  }

  // Para actualizar perfil
  Future<bool> updateProfile(int id, Map<String, dynamic> updatedData) async {
    return await _profileService.updateProfile(id, updatedData);
  }
}
