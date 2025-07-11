import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart';
import 'shipment_model.dart';

class ShipmentService {
  // 1. GET /api/v1/shipments (Obtener todos los envíos)
  Future<List<ShipmentModel>> getAllShipments() async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.shipment}');
    try {
      final response = await http.get(url,
      headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}', // <-- Añadir esto
    },);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ShipmentModel.fromJson(json)).toList();
      } else {
        print('Failed to load shipments. Status code: ${response.statusCode}');
        throw Exception('Failed to load shipments');
      }
    } catch (e) {
      print('Error fetching shipments: $e');
      rethrow;
    }
  }

  // 2. GET /api/v1/shipments/{id} (Obtener un envío por ID)
  Future<ShipmentModel?> getShipmentById(int id) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.shipment}/$id');
    try {
      final response = await http.get(url,
      headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}', // <-- Añadir esto
    },);

      if (response.statusCode == 200) {
        return ShipmentModel.fromJson(json.decode(response.body));
      } else {
        print('Failed to load shipment. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching shipment by ID: $e');
      return null;
    }
  }

  // 3. POST /api/v1/shipments (Crear un nuevo envío)
  Future<bool> createShipment(ShipmentModel shipment) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.shipment}');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json',
        'Authorization':'Bearer ${AuthService.token}'},
        body: json.encode(shipment.toCreateJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Shipment created successfully!');
        return true;
      } else {
        print('Failed to create shipment. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating shipment: $e');
      return false;
    }
  }

  // 4. DELETE /api/v1/shipments/{id} (Eliminar un envío por ID)
  Future<bool> deleteShipment(int id) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.shipment}/$id');
    try {
      final response = await http.delete(url,
      headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}', // <-- Añadir esto
    },);

      if (response.statusCode == 200) {
        print('Shipment deleted successfully!');
        return true;
      } else {
        print('Failed to delete shipment. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting shipment: $e');
      return false;
    }
  }

  // 5. GET /api/v1/shipments/manager/my (Obtener envíos asignados al manager actual)
  Future<List<ShipmentModel>> getManagerShipments() async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.shipment}/manager/my');
    try {
      final response = await http.get(url,
      headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}', // <-- Añadir esto
    },);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ShipmentModel.fromJson(json)).toList();
      } else {
        print('Failed to load manager shipments. Status code: ${response.statusCode}');
        throw Exception('Failed to load manager shipments');
      }
    } catch (e) {
      print('Error fetching manager shipments: $e');
      rethrow;
    }
  }

  // 6. GET /api/v1/shipments/drivers/my-assigned (Obtener envíos asignados al conductor actual)
  Future<List<ShipmentModel>> getDriverAssignedShipments() async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.shipment}/drivers/my-assigned');
    try {
      final response = await http.get(url,
      headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}', // <-- Añadir esto
    },);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ShipmentModel.fromJson(json)).toList();
      } else {
        print('Failed to load driver assigned shipments. Status code: ${response.statusCode}');
        throw Exception('Failed to load driver assigned shipments');
      }
    } catch (e) {
      print('Error fetching driver assigned shipments: $e');
      rethrow;
    }
  }

  // 7. PATCH /api/v1/shipments/{id}/status (Actualizar el estado de un envío)
  Future<bool> updateShipmentStatus(int id, String status) async {
    final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.shipment}/$id/status');
    try {
      final response = await http.patch( // Usar PATCH en lugar de PUT si el endpoint es PATCH
        url,
        headers: {'Content-Type': 'application/json',
        'Authorization':'Bearer ${AuthService.token}'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        print('Shipment status updated successfully!');
        return true;
      } else {
        print('Failed to update shipment status. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating shipment status: $e');
      return false;
    }
  }
}