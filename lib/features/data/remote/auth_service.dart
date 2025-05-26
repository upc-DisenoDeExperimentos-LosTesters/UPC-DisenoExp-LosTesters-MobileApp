import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_service.dart';

class AuthService {
  static String? _token;
  static ProfileModel? _currentUser;

  static String? get token => _token;
  static ProfileModel? get currentUser => _currentUser;

  static Future<bool> login(String email, String password) async {
    final profileService = ProfileService();
    final profile = await profileService.login(email, password);
    
    if (profile != null && profile.token != null) {
      _token = profile.token;
      _currentUser = profile;
      return true;
    }
    return false;
  }

  static void logout() {
    _token = null;
    _currentUser = null;
  }

  static bool get isLoggedIn => _token != null;
}