import 'package:flutter/material.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/carrier_profile/carrier_profiles.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/reports/reports_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/shipments/shipments_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/vehicle/assign_vehicle_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/vehicle/create_vehicle_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/vehicle/vehicle_detail_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/login_screen.dart';

class VehiclesScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final int userId;

  const VehiclesScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.userId,
  }) : super(key: key);

  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final VehicleService vehicleService = VehicleService();
  List<VehicleModel> vehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  void _navigateToCreateVehicle() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateVehicleScreen(
          ownerId: AuthService.currentUser?.id ?? 0,
        ),
      ),
    );
    
    if (result == true) {
      _fetchVehicles(); // Refrescar la lista si se creó un vehículo
    }
  }

  Future<void> _fetchVehicles() async {
  try {
    // Obtener todos los vehículos
    final allVehicles = await vehicleService.getAllVehicles();
    
    // Filtrar vehículos por idTransportista (usando el ID del usuario actual)
    final currentUserId = AuthService.currentUser?.id ?? 0;
    final filteredVehicles = allVehicles.where((vehicle) => vehicle.idPropietario == currentUserId).toList();
    
    setState(() {
      vehicles = filteredVehicles;
    });
    
    print('🚗 Vehículos filtrados para transportista $currentUserId: ${vehicles.length}');
  } catch (e) {
    print('❌ Error al cargar vehículos: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error al cargar vehículos: ${e.toString()}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _addVehicle(Map<String, String> newVehicle) {
    setState(() {
      vehicles.add(
        VehicleModel(
          id: 0, // ID temporal, el backend asignará uno real
      licensePlate: newVehicle['placa'] ?? 'Sin placa', // Valor por defecto si es null
      model: newVehicle['modelo'] ?? 'Modelo desconocido',
      serialNumber: newVehicle['serialNumber'] ?? 'SN0000', // Agrega este campo si es necesario
      idPropietario: int.tryParse(newVehicle['idPropietario']?.toString() ?? '0') ?? 0,
      idTransportista: int.tryParse(newVehicle['idTransportista']?.toString() ?? '0') ?? 0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: Row(
          children: [
            Icon(Icons.directions_car, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Vehículos',
              style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1C1E24),
      drawer: _buildDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: vehicles.isEmpty
                        ? Center(
                      child: Text(
                        'No hay vehículos disponibles',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return _buildVehicleCard(vehicle);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _navigateToCreateVehicle, // Usa el método ya existente
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA000),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                    ),),
                    child: const Text(
                      'Crear nuevo Vehículo', // Cambia el texto
                      style: TextStyle(color: Colors.black),
                    ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
  return Card(
    elevation: 5,
    margin: const EdgeInsets.symmetric(vertical: 10.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailScreen(
              vehicle: vehicle,
              name: widget.name,
              lastName: widget.lastName,
              userId: widget.userId, // Pasa el ID del usuario
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modelo: ${vehicle.model}',
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Placa: ${vehicle.licensePlate}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignVehicleScreen(
                      vehicleId: vehicle.id, // Pasa el ID del vehículo
                      name: widget.name,
                      lastName: widget.lastName,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFA000),
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Asignar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
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
                  '${widget.name} ${widget.lastName} - Gerente',
                  style: const TextStyle(color: Colors.grey,  fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'PERFIL', ProfileScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.people, 'TRANSPORTISTAS',
              CarrierProfilesScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.report, 'REPORTES', ReportsScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.directions_car, 'VEHICULOS', VehiclesScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.local_shipping, 'ENVIOS', ShipmentsScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
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

  Widget _buildDrawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
