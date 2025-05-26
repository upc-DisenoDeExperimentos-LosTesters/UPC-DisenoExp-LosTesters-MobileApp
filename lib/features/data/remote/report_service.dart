import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart';
import 'report_model.dart';

class ReportService {
  Future<List<ReportModel>> getAllReports() async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ReportModel.fromJson(json)).toList();
      } else {
        print('Failed to load reports. Status code: ${response.statusCode}');
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      print('Error fetching reports: $e');
      rethrow;
    }
  }  // Obtener reportes del usuario actual
  Future<List<ReportModel>> getMyReports() async {
    if (AuthService.token == null) throw Exception('No autenticado');
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}/my');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Prueba con un token de prueba para ver si el endpoint requiere autenticación
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );
      
      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final reports = data.map((json) => ReportModel.fromJson(json)).toList();
        print('Número de reportes obtenidos: ${reports.length}');
        return reports;
      } else {
        print('Failed to load my reports. Status code: ${response.statusCode}');
        throw Exception('Failed to load my reports: ${response.body}');
      }    } catch (e) {
      print('Error fetching my reports: $e');
      rethrow;
    }
  }

  Future<ReportModel?> getReportById(int id) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}/$id');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return ReportModel.fromJson(json.decode(response.body));
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
        headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
        },
        body: json.encode({
          'type': report.type,
          'description': report.description}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
      return ReportModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear reporte: ${response.statusCode}');
    }
    } catch (e) {
      print('Error en createReport: $e');
    rethrow;
    }
  }

  Future<bool> deleteReport(int id) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}/$id');
    try {
      final response = await http.delete(url);

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
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.report}/user/$userId');
    try {
      print('Intentando obtener reportes para el usuario $userId de: $url');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final reports = data.map((json) => ReportModel.fromJson(json)).toList();
        print('Número de reportes obtenidos: ${reports.length}');
        return reports;
      } else if (response.statusCode == 404) {
        // Si no existe el endpoint, devolvemos una lista vacía
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
