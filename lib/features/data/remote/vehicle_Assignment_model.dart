import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_model.dart';

class VehicleAssignment {
  final int id;
  final int vehicleId;
  final VehicleModel? vehicle;
  final int transporterId;
  final DateTime startDate;
  final DateTime? endDate;
  final String route;

  VehicleAssignment({
    required this.id,
    required this.vehicleId,
    this.vehicle,
    required this.transporterId,
    required this.startDate,
    this.endDate,
    required this.route,
  });

  factory VehicleAssignment.fromJson(Map<String, dynamic> json) {
  // Maneja los nombres incorrectos con operadores ?? (null-coalescing)
  final dynamic vehicleId = json['vehicleId'] ?? json['vehicled'];
  final dynamic transporterId = json['transporterId'] ?? json['transporte rid'] ?? json['transporteurId'];

  return VehicleAssignment(
    id: json['id'] as int,
    vehicleId: vehicleId as int, // Conversión explícita a int
    transporterId: transporterId as int,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
    route: json['route'] as String,
    vehicle: null, // Siempre es null en la respuesta POST
  );
}

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'transporterId': transporterId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'route': route,
    };
  }
}