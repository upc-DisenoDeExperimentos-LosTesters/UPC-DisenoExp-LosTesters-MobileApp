class ReportModel {
  final int? id;
  final int? userId;
  final String type;
  final String description;
  String? driverName;
  final DateTime? createdAt;

  ReportModel({
    this.id,
    this.userId,
    required this.type,
    required this.description,
    this.driverName,
    this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      description: json['description'],
      //driverName: json['driverName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'description': description,
      'driverName': driverName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
