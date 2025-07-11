//import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/shipment_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/shipment_service.dart'; // Import the ShipmentService
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/carrier_profile/carrier_profiles.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/reports/reports_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/shipments/assign_shipment_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/vehicle/vehicles_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/login_screen.dart';

class ShipmentsScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final int userId;

  const ShipmentsScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.userId, // Assuming userId is needed for the service
  }) : super(key: key);

  @override
  _ShipmentsScreenState createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  List<ShipmentModel> shipments = [];
  List<ShipmentModel> filteredShipments = [];
  bool isLoading = true;
  String selectedFilter = "Todos";

  final ShipmentService _shipmentService = ShipmentService(); // Instantiate the service

  @override
  void initState() {
    super.initState();
    // *** MODIFICACIÓN CLAVE AQUÍ ***
    // Ahora llamamos a _fetchManagerShipments para obtener solo los envíos del gerente
    _fetchManagerShipments();
  }

  // **** NUEVO MÉTODO: Fetch shipments for the logged-in MANAGER ****
  Future<void> _fetchManagerShipments() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Usamos el método específico del servicio para obtener los envíos del gerente.
      // Se asume que este endpoint ya filtra por el ID del usuario autenticado en el backend.
      final fetchedShipments = await _shipmentService.getManagerShipments();

      setState(() {
        shipments = fetchedShipments;
        filteredShipments = shipments; // Por defecto, mostrar todos los obtenidos
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar envíos del gerente: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // El método de filtro sigue siendo útil para el filtrado de UI (por estado)
  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == "Todos") {
        filteredShipments = shipments;
      } else {
        filteredShipments = shipments.where((shipment) => shipment.status == filter).toList();
      }
    });
  }

  // Ensure this delete method also uses the ShipmentService
  Future<void> _deleteShipment(int id) async {
    try {
      final success = await _shipmentService.deleteShipment(id); // Use the service method

      if (success) {
        setState(() {
          shipments.removeWhere((shipment) => shipment.id == id);
          _applyFilter(selectedFilter); // Reapply filter after deletion
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Envío eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el envío.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el envío: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: Row(
          children: [
            const Icon(Icons.local_shipping, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Envios',
              style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1E1F24),
      drawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA8E00)))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtrar por estado:',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      DropdownButton<String>(
                        dropdownColor: const Color(0xFF2C2F38),
                        value: selectedFilter,
                        items: ["Todos", "En Progreso", "Envio Entregado"]
                            .map((filter) => DropdownMenuItem<String>(
                                  value: filter,
                                  child: Text(
                                    filter,
                                    style: const TextStyle(color: Colors.amber),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _applyFilter(value);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredShipments.length,
                      itemBuilder: (context, index) {
                        final shipment = filteredShipments[index];
                        return Column(
                          children: [
                            _buildShipmentCard(
                              shipment,
                              () => _deleteShipment(1),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // The "Asignar nuevo envío" button is appropriate for a manager
                  ElevatedButton(
                    onPressed: () async {
                      final newShipment = await Navigator.push<Map<String, String>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignShipmentScreen(
                            name: widget.name,
                            lastName: widget.lastName,
                            userId: widget.userId, // Pass the userId if needed
                          ),
                        ),
                      );

                      if (newShipment != null) {
                        // Después de asignar un nuevo envío, recargar la lista de envíos del gerente
                        _fetchManagerShipments();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA8E00),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Asignar nuevo envío',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildShipmentCard(ShipmentModel shipment, VoidCallback onDelete) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFEA8E00),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/box.png',
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This line is problematic if 'driverName' is not in ShipmentModel
                  // or not returned by the backend.
                  // The backend response provided previously had 'transporterId' but not 'driverName'.
                  // You might need to fetch driver's name separately or ensure backend provides it.
                  // For a manager, seeing the assigned transporter's name is crucial.
                  // If the backend doesn't provide it, you'd need another API call to get user details by transporterId.
                  Text(
                    'Conductor: ${shipment.transporterId ?? 'N/A'}', // Using transporterId as placeholder
                    style: const TextStyle(),
                  ),
                  Text(
                    'Dirección: ${shipment.destiny}',
                  ),
                  Text(
                    'Descripción: ${shipment.description}',
                  ),
                  Text(
                    'Estado: ${shipment.status}',
                    style: TextStyle(
                      color: shipment.status == 'Envio Entregado' ? Colors.green : Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Add vehicle info if available and relevant for the UI
                  if (shipment.vehicleModel != null && shipment.vehiclePlate != null)
                    Text(
                      'Vehículo: ${shipment.vehicleModel} (${shipment.vehiclePlate})',
                    ),
                ],
              ),
            ),
            // The delete button is appropriate for a manager's view
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
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
                  // Updated text to reflect potential role if known
                  '${widget.name} ${widget.lastName} - Gerente', // Assuming this is for Manager
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'PERFIL', ProfileScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          // These items (TRANSPORTISTAS, REPORTES, VEHÍCULOS, ENVIOS) are appropriate for a "businessman" or "manager" role.
          _buildDrawerItem(Icons.people, 'TRANSPORTISTAS',
              CarrierProfilesScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.report, 'REPORTES', ReportsScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.directions_car, 'VEHÍCULOS', VehiclesScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.local_shipping, 'ENVIOS', ShipmentsScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          const SizedBox(height: 160),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Ensure AuthService.logout() is called if it handles token clearing
              // If not, you might need to implement it in AuthService
              // AuthService.logout(); // Uncomment if you have this
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