import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_service.dart';
import 'report_model.dart';

class ReportService {
    final ProfileService _profileService = ProfileService(); // Instancia de ProfileService


    Future<List<ReportModel>> getAllReports() async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}', // ¡CORRECCIÓN: Añadido token!
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<ReportModel> reports = data.map((json) => ReportModel.fromJson(json)).toList();

        // ¡NUEVA LÓGICA AQUÍ PARA OBTENER NOMBRES DE CONDUCTORES!
        // 1. Recolectar IDs de usuarios únicos
        Set<int> userIds = reports.map((report) => report.userId).whereType<int>().toSet();
        
        // 2. Obtener perfiles para esos IDs
        Map<int, ProfileModel> profilesMap = {};
        for (int userId in userIds) {
          try {
            ProfileModel? profile = await _profileService.getProfileById(userId); // Usa tu getProfileById
            if (profile != null) {
              profilesMap[userId] = profile;
            }
          } catch (e) {
            print('Error al obtener perfil para userId $userId: $e');
            // Continuar incluso si falla un perfil
          }
        }

        // 3. Asignar driverName a cada reporte
        for (var report in reports) {
          if (report.userId != null && profilesMap.containsKey(report.userId!)) {
            final profile = profilesMap[report.userId!];
            report.driverName = '${profile?.name ?? 'Desconocido'} ${profile?.lastName ?? ''}'.trim();
          } else {
            report.driverName = 'N/A'; // Si no se encuentra el perfil o el userId es nulo
          }
        }
        // ¡FIN DE LA NUEVA LÓGICA!

        return reports;
      } else {
        print('Failed to load reports. Status code: ${response.statusCode}');
        throw Exception('Failed to load reports: ${response.body}');
      }
    } catch (e) {
      print('Error fetching reports: $e');
      rethrow;
    }
  }


  // Obtener reportes del usuario actual
  Future<List<ReportModel>> getMyReports() async {
    if (AuthService.token == null) throw Exception('No autenticado');
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}/my');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<ReportModel> reports = data.map((json) => ReportModel.fromJson(json)).toList();

        // ¡NUEVA LÓGICA PARA OBTENER NOMBRES DE CONDUCTORES (similar a getAllReports)!
        Set<int> userIds = reports.map((report) => report.userId).whereType<int>().toSet();
        Map<int, ProfileModel> profilesMap = {};
        for (int userId in userIds) {
          try {
            ProfileModel? profile = await _profileService.getProfileById(userId);
            if (profile != null) {
              profilesMap[userId] = profile;
            }
          } catch (e) {
            print('Error al obtener perfil para userId $userId: $e');
          }
        }
        for (var report in reports) {
          if (report.userId != null && profilesMap.containsKey(report.userId!)) {
            final profile = profilesMap[report.userId!];
            report.driverName = '${profile?.name ?? 'Desconocido'} ${profile?.lastName ?? ''}'.trim();
          } else {
            report.driverName = 'N/A';
          }
        }
        // ¡FIN DE LA NUEVA LÓGICA!

        print('Número de reportes obtenidos: ${reports.length}');
        return reports;
      } else {
        print('Failed to load my reports. Status code: ${response.statusCode}');
        throw Exception('Failed to load my reports: ${response.body}');
      }
    } catch (e) {
      print('Error fetching my reports: $e');
      rethrow;
    }
  }

  Future<ReportModel?> getReportById(int id) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}/$id');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}', // ¡CORRECCIÓN: Añadido token!
        },
      );

      if (response.statusCode == 200) {
        ReportModel report = ReportModel.fromJson(json.decode(response.body));

        // Obtener nombre del conductor para un solo reporte
        if (report.userId != null) {
          try {
            ProfileModel? profile = await _profileService.getProfileById(report.userId!);
            if (profile != null) {
              report.driverName = '${profile.name} ${profile.lastName}'.trim();
            } else {
              report.driverName = 'N/A';
            }
          } catch (e) {
            print('Error al obtener perfil para userId ${report.userId}: $e');
            report.driverName = 'Error al cargar conductor';
          }
        } else {
          report.driverName = 'N/A';
        }
        return report;
      } else {
        print('Failed to load report. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching report by ID: $e');
      return null;
    }
  }

  Future<ReportModel?> createReport(ReportModel report) async {
    if (AuthService.token == null) {
      throw Exception('Usuario no autenticado');
    }
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: json.encode({
          'type': report.type,
          'description': report.description,
          // No incluyas userId o driverName aquí si el backend los asigna
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ReportModel createdReport = ReportModel.fromJson(json.decode(response.body));
        // Después de crear, podemos intentar obtener el nombre del conductor si el ID está disponible
        if (createdReport.userId != null) {
          try {
            ProfileModel? profile = await _profileService.getProfileById(createdReport.userId!);
            if (profile != null) {
              createdReport.driverName = '${profile.name} ${profile.lastName}'.trim();
            }
          } catch (e) {
            print('Error al obtener perfil para el nuevo reporte: $e');
          }
        }
        return createdReport;
      } else {
        throw Exception('Error al crear reporte: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en createReport: $e');
      rethrow;
    }
  }

  Future<bool> deleteReport(int id) async {
    if (AuthService.token == null) { // Agregado: Verificar autenticación para DELETE
      throw Exception('No autenticado para eliminar');
    }
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}', // ¡CORRECCIÓN: Añadido token!
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to delete report. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting report: $e');
      return false;
    }
  }

  // Método para obtener reportes por ID de usuario (solución alternativa)
  Future<List<ReportModel>> getReportsByUserId(int userId) async {
    if (AuthService.token == null) { // Agregado: Verificar autenticación
      throw Exception('No autenticado para obtener reportes por ID de usuario');
    }
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}/user/$userId');
    try {
      print('Intentando obtener reportes para el usuario $userId de: $url');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}', // ¡CORRECCIÓN: Añadido token!
        },
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<ReportModel> reports = data.map((json) => ReportModel.fromJson(json)).toList();

        // ¡NUEVA LÓGICA PARA OBTENER NOMBRES DE CONDUCTORES (similar a getAllReports)!
        Set<int> userIds = reports.map((report) => report.userId).whereType<int>().toSet();
        Map<int, ProfileModel> profilesMap = {};
        for (int currentUserId in userIds) {
          try {
            ProfileModel? profile = await _profileService.getProfileById(currentUserId);
            if (profile != null) {
              profilesMap[currentUserId] = profile;
            }
          } catch (e) {
            print('Error al obtener perfil para userId $currentUserId: $e');
          }
        }
        for (var report in reports) {
          if (report.userId != null && profilesMap.containsKey(report.userId!)) {
            final profile = profilesMap[report.userId!];
            report.driverName = '${profile?.name ?? 'Desconocido'} ${profile?.lastName ?? ''}'.trim();
          } else {
            report.driverName = 'N/A';
          }
        }
        // ¡FIN DE LA NUEVA LÓGICA!

        print('Número de reportes obtenidos: ${reports.length}');
        return reports;
      } else if (response.statusCode == 404) {
        print('El endpoint /user/$userId no existe o no hay reportes');
        return [];
      } else {
        print('Failed to load reports for user. Status code: ${response.statusCode}');
        throw Exception('Failed to load reports for user: ${response.body}');
      }
    } catch (e) {
      print('Error fetching reports by user ID: $e');
      rethrow;
    }
  }
}
