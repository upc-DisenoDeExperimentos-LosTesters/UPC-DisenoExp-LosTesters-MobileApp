class VehicleModel {
  final int id;
  final String licensePlate;
  final String model;
  final String serialNumber;
  final int idPropietario;
  final int idTransportista;

  VehicleModel({
    required this.id,
    required this.licensePlate,
    required this.model,
    required this.serialNumber,
    required this.idPropietario,
    required this.idTransportista,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int? ?? 0,
      licensePlate: json['licensePlate'] as String? ?? '',
      model: json['model'] as String? ?? '',
      serialNumber: json['serialNumber'] as String? ?? '',
      idPropietario: json['idPropietario'] as int? ?? 0,
      idTransportista: json['idTransportista'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'licensePlate': licensePlate,
      'model': model,
      'serialNumber': serialNumber,
      'idPropietario': idPropietario,
      'idTransportista': idTransportista,
    };
  }
}