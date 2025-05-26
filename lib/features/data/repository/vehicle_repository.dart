import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_model.dart';

class VehicleRepository {
  final VehicleService _vehicleService;

  VehicleRepository({required VehicleService vehicleService}) 
    : _vehicleService = vehicleService;

  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      return await _vehicleService.getAllVehicles();
    } catch (e) {
      print('Error en repository al obtener vehículos: $e');
      rethrow;
    }
  }

  Future<VehicleModel> getVehicleById(int id) async {
    try {
      return await _vehicleService.getVehicleById(id);
    } catch (e) {
      print('Error en repository al obtener vehículo por ID: $e');
      rethrow;
    }
  }
/*
  Future<Vehicle> createVehicle({
    required String licensePlate,
    required String model,
    required String serialNumber,
    required int ownerId,
    required int carrierId,
  }) async {
    try {
      return await _vehicleService.createNewVehicle(
        licensePlate: licensePlate,
        model: model,
        serialNumber: serialNumber,
        ownerId: ownerId,
        carrierId: carrierId,
      );
    } catch (e) {
      print('Error en repository al crear vehículo: $e');
      rethrow;
    }
  }

  // Si necesitas el método que acepta objeto Vehicle
  Future<Vehicle> createVehicleFromModel(Vehicle vehicle) async {
    try {
      return await _vehicleService.createVehicle(vehicle);
    } catch (e) {
      print('Error en repository al crear vehículo desde modelo: $e');
      rethrow;
    }
  }*/
}