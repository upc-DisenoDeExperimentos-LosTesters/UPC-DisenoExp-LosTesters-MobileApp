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

  Future<List<VehicleModel>> getVehiclesByCarrierId(int carrierId) async {
    try {
      return await _vehicleService.getVehiclesByCarrierId(carrierId);
    } catch (e) {
      print('Error getting vehicles by carrier: $e');
      rethrow;
    }
  }
}