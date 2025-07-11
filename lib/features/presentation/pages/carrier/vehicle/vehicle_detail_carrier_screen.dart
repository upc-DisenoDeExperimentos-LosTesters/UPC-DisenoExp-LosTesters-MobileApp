import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart';
//import 'package:movigestion_mobile_experimentos_version/features/data/remote/profile_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_service.dart';
//import 'package:movigestion_mobile_experimentos_version/features/data/repository/profile_repository.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/repository/vehicle_repository.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/profile/profile_screen2.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/reports/reports_carrier_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/shipments/shipments_screen2.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/login_screen.dart';

class VehicleDetailCarrierScreenScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final int userId;

  const VehicleDetailCarrierScreenScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.userId,
  }) : super(key: key);

  @override
  _VehicleDetailCarrierScreenScreenState createState() => _VehicleDetailCarrierScreenScreenState();
}

class _VehicleDetailCarrierScreenScreenState extends State<VehicleDetailCarrierScreenScreen> 
    with SingleTickerProviderStateMixin {
  List<VehicleModel> vehicles = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
  try {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Verificar autenticación
    if (AuthService.currentUser == null || AuthService.token == null) {
      setState(() {
        errorMessage = 'Usuario no autenticado';
        isLoading = false;
      });
      return;
    }

    // USAR EL ID DIRECTAMENTE DEL CURRENT USER (ASUMIENDO QUE TIENE ID)
    final carrierId = AuthService.currentUser!.id; // Asegúrate que ProfileModel tenga idAuthService.currentUser!.id
    
    print('🆔 ID del transportista: $carrierId');
    
    // Obtener todos los vehículos y filtrar localmente
    final vehicleRepository = VehicleRepository(
      vehicleService: VehicleService(),
    );
    
    final allVehicles = await vehicleRepository.getAllVehicles();
    final carrierVehicles = allVehicles.where((v) => v.idTransportista == carrierId).toList();
    
    print('🚗 Vehículos encontrados: ${carrierVehicles.length}');
    
    setState(() {
      vehicles = carrierVehicles;
      isLoading = false;
    });
    
    if (carrierVehicles.isNotEmpty) {
      _animationController.forward();
    }
  } catch (e) {
    print('🔥 Error en _fetchVehicles: $e');
    setState(() {
      errorMessage = 'Error al cargar vehículos: ${e.toString().replaceAll('Exception: ', '')}';
      isLoading = false;
    });
  }
}


  Future<Map<String, dynamic>?> _getCurrentProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstrants.baseUrl}/api/v1/profiles'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> profiles = json.decode(response.body);
        return profiles.firstWhere(
          (p) => p['name'] == widget.name,
          orElse: () => null,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: const Color(0xFF2F353F),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Placa', vehicle.licensePlate),
            _buildInfoRow('Modelo', vehicle.model),
            _buildInfoRow('Número de Serie', vehicle.serialNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPercentage = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70, 
              fontSize: 16, 
              fontWeight: FontWeight.w600
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.amber, fontSize: 16),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF2C2F38),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/login_logo.png',
                  height: 100,
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.name} ${widget.lastName} - Transportista',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('PERFIL', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen2(
                    name: widget.name, 
                    lastName: widget.lastName,
                    userId: widget.userId ,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.report, color: Colors.white),
            title: const Text('REPORTES', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportsCarrierScreen(
                    name: widget.name, 
                    lastName: widget.lastName,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car, color: Colors.white),
            title: const Text('VEHICULOS', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VehicleDetailCarrierScreenScreen(
                    name: widget.name, 
                    lastName: widget.lastName,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping, color: Colors.white),
            title: const Text('ENVIOS', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShipmentsScreen2(
                    name: widget.name, 
                    lastName: widget.lastName,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 160),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    onLoginClicked: (username, password) {
                      print('Usuario: $username, Contraseña: $password');
                    },
                    onRegisterClicked: () {
                      print('Registrarse');
                    },
                  ),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: Row(
          children: [
            const Icon(Icons.directions_car, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Vehículo Asignado',
              style: TextStyle(
                color: Colors.grey, 
                fontSize: 22, 
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1A1F24),
      drawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : vehicles.isEmpty
          ? const Center(
              child: Text(
                'No te asignaron un vehículo',
                style: TextStyle(
                  color: Colors.white70, 
                  fontSize: 18
                ),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return _buildVehicleCard(vehicle);
                },
              ),
            ),
    );
  }
}