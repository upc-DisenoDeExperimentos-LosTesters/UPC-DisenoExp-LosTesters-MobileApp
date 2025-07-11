
class ShipmentModel {
  final int? id;
  final int? userId;
  final String destiny;
  final String description;
  final DateTime? createdAt;
  final String status;
  // Nuevos campos del RESPONSE del backend:
  final int? vehicleId; // Puede ser opcional si a veces no viene o si lo envías null en el POST
  final String? vehicleModel; // Puede ser null si el backend no lo envía siempre
  final String? vehiclePlate; // Puede ser null si el backend no lo envía siempre
  final int? transporterId; // Puede ser null si el backend no lo envía siempre

  // Eliminado 'driverName' porque no está en el response del backend que mostraste.
  // Si 'driverName' es algo que se obtiene de 'transporterId' mediante otra llamada o lógica frontend,
  // entonces mantén 'driverName' como un campo calculado o búscalo después de recibir el ShipmentModel.

  ShipmentModel({
    this.id,
    required this.userId,
    required this.destiny,
    required this.description,
    this.createdAt,
    required this.status,
    this.vehicleId, // Hacemos estos nullable
    this.vehicleModel,
    this.vehiclePlate,
    this.transporterId,
    // this.driverName, // Eliminar si no viene del backend o es calculado
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      destiny: json['destiny'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null, // Maneja el nulo
      status: json['status'] as String,
      vehicleId: json['vehicleId'] as int?, // Puede ser null
      vehicleModel: json['vehicleModel'] as String?, // Puede ser null
      vehiclePlate: json['vehiclePlate'] as String?, // Puede ser null
      transporterId: json['transporterId'] as int?, // Puede ser null
      // driverName: json['driverName'] as String?, // Si el backend no lo provee, quítalo o maneja su obtención de otra forma
    );
  }

  // Este toJson es para serializar el objeto completo, por ejemplo, para guardar localmente.
  // Para el POST de creación, necesitamos un método toJson específico o construir el body directamente.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'destiny': destiny,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'status': status,
      'vehicleId': vehicleId,
      'vehicleModel': vehicleModel,
      'vehiclePlate': vehiclePlate,
      'transporterId': transporterId,
      // 'driverName': driverName, // Si es un campo calculado, no debería ir en el JSON de serialización
    };
  }

  // --- NUEVO: Método para generar el JSON específico para la creación de un Shipment (POST) ---
  // Este método solo incluye los campos que el backend espera en el POST.
  Map<String, dynamic> toCreateJson() {
    return {
      'destiny': destiny,
      'description': description,
      'userId': userId,
      'vehicleId': vehicleId, // Asegúrate de que este campo esté disponible cuando creas el objeto para el POST
      'status': status,
    };
  }
}