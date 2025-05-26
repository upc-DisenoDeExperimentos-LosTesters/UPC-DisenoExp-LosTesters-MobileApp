import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
import 'vehicle_model.dart';

class VehicleService {
  static const String _basePath = '/api/v1/vehicles';

  // Obtener todos los vehículos
  Future<List<VehicleModel>> getAllVehicles() async {
    final url = Uri.parse('${AppConstrants.baseUrl}$_basePath');
    final response = await http.get(url);

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
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vehicle.toJson()),
    );

    return response.statusCode == 200;
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