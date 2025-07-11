import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_Assignment_model.dart';
import 'vehicle_model.dart';

class VehicleService {
  static const String _basePath = '/api/v1/vehicles';

  // Obtener todos los vehículos
  Future<List<VehicleModel>> getAllVehicles() async {
  try {
    final url = Uri.parse('${AppConstrants.baseUrl}/api/v1/vehicles');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> vehiclesJson = json.decode(response.body);
      return vehiclesJson.map((json) => VehicleModel.fromJson(json)).toList();
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error al obtener vehículos: $e');
  }
}

  Future<List<VehicleModel>> getVehiclesByCarrierId(int carrierId) async {
    final url = Uri.parse('${AppConstrants.baseUrl}$_basePath?carrierId=$carrierId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> vehiclesJson = json.decode(response.body);
      return vehiclesJson.map((json) => VehicleModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vehicles: ${response.statusCode}');
    }
  }

  // Obtener un vehículo por ID
  Future<VehicleModel> getVehicleById(int id) async {
    final url = Uri.parse('${AppConstrants.baseUrl}$_basePath/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return VehicleModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Vehicle not found');
    } else {
      throw Exception('Failed to load vehicle: ${response.statusCode}');
    }
  }

  // Crear un nuevo vehículo
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    final url = Uri.parse('${AppConstrants.baseUrl}$_basePath');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}',},
      body: json.encode(vehicle.toJson()),
    );

    if (response.statusCode == 201) {
      return VehicleModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create vehicle: ${response.statusCode}');
    }
  }
  
  // Actualizar un vehículo existente
  Future<bool> updateVehicle(int id, VehicleModel vehicle) async {
    final url = Uri.parse('${AppConstrants.baseUrl}$_basePath/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}',},
      body: json.encode(vehicle.toJson()),
    );

    return response.statusCode == 200;
  }

    Future<VehicleAssignment> createAssignment(VehicleAssignment assignment) async {
  try {
    final url = Uri.parse('${AppConstrants.baseUrl}/api/v1/vehicles/assignments');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
      body: json.encode(assignment.toJson()),
    );

    // Verificar si la respuesta está vacía
    if (response.body.isEmpty) {
      throw Exception('El servidor respondió con un cuerpo vacío');
    }

    final responseBody = json.decode(response.body);

    // Validación adicional del formato de la respuesta
    if (response.statusCode == 201) {
      try {
        // Limpieza preventiva del JSON (opcional)
        responseBody.removeWhere((key, value) => value == 'null' || value == null);
        
        return VehicleAssignment.fromJson(responseBody);
      } catch (e) {
        throw Exception('Error al parsear la respuesta: $e\nRespuesta del servidor: ${response.body}');
      }
    } else {
      // Manejo detallado de errores HTTP
      String errorMessage = 'Error al crear asignación: ${response.statusCode}';
      if (responseBody is Map && responseBody.containsKey('message')) {
        errorMessage += ' - ${responseBody['message']}';
      } else {
        errorMessage += ' - ${response.body}';
      }
      throw Exception(errorMessage);
    }
  } on FormatException catch (e) {
    throw Exception('Error en el formato de la respuesta JSON: $e');
  } on http.ClientException catch (e) {
    throw Exception('Error de conexión: $e');
  } catch (e) {
    throw Exception('Error inesperado: $e');
  }
}

  // Nuevo método para obtener asignaciones
  Future<List<VehicleAssignment>> getAssignments() async {
    final url = Uri.parse('${AppConstrants.baseUrl}/api/v1/vehicles/assignments');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> assignmentsJson = json.decode(response.body);
      return assignmentsJson.map((json) => VehicleAssignment.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener asignaciones: ${response.statusCode} - ${response.body}');
    }
  }
/*
  // Método adicional útil para crear vehículo con parámetros individuales
  Future<VehicleModel> createNewVehicle({
    required String licensePlate,
    required String model,
    required String serialNumber,
    required int ownerId,
    required int carrierId,
  }) async {
    return createVehicle(
      VehicleModel(
        id: 0, // El ID será asignado por el servidor
        licensePlate: licensePlate,
        model: model,
        serialNumber: serialNumber,
        ownerId: ownerId,
        carrierId: carrierId,
      ),
    );
  }*/
}