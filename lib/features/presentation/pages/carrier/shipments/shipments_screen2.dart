// lib/features/presentation/pages/carrier/shipments/shipments_screen2.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Importar los servicios y modelos necesarios
import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart'; // Para obtener el token
import 'package:movigestion_mobile_experimentos_version/features/data/remote/shipment_service.dart'; // Tu servicio de envíos
import 'package:movigestion_mobile_experimentos_version/features/data/remote/shipment_model.dart'; // Tu modelo de envío

// Tus otras pantallas de navegación
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/reports/reports_carrier_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/vehicle/vehicle_detail_carrier_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/profile/profile_screen2.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/login_screen.dart';

class ShipmentsScreen2 extends StatefulWidget {
  final String name;
  final String lastName;
  final int userId; // ¡Ahora es requerido!

  const ShipmentsScreen2({
    Key? key,
    required this.name,
    required this.lastName,
    required this.userId, // Hacer el userId requerido
  }) : super(key: key);

  @override
  _ShipmentsScreen2State createState() => _ShipmentsScreen2State();
}

class _ShipmentsScreen2State extends State<ShipmentsScreen2> with SingleTickerProviderStateMixin {
  List<ShipmentModel> _shipments = []; // Usamos ShipmentModel directamente
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final ShipmentService _shipmentService = ShipmentService(); // Instancia del servicio

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fetchShipments(); // Obtiene los envíos usando el servicio
  }

  // **** MODIFICADO: AHORA USA EL ENDPOINT GENERAL Y FILTRA LOCALMENTE ****
  Future<void> _fetchShipments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // 1. Obtener TODOS los envíos utilizando el método getAllShipments()
      // de tu ShipmentService, que apunta al endpoint general.
      final List<ShipmentModel> allFetchedShipments = await _shipmentService.getAllShipments();

      // 2. Filtrar esta lista localmente para mostrar solo los envíos
      // cuyo 'transporterId' coincida con el 'userId' del transportista logeado.
      final List<ShipmentModel> filteredShipments = allFetchedShipments.where((shipment) {
        return shipment.transporterId == widget.userId;
      }).toList();

      setState(() {
        _shipments = filteredShipments; // Actualiza la lista de envíos con los filtrados
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Mostrar un mensaje de error si algo sale mal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar envíos: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _markAsDelivered(int index) async {
    final shipment = _shipments[index];
    final id = shipment.id; // Acceder al ID del ShipmentModel

    // Asegúrate de que el ID no sea nulo antes de pasarlo al servicio
  if (id == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Error: ID de envío no disponible para actualizar.'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
    return; // Salir de la función si el ID es nulo
  }

    try {
          final success = await _shipmentService.updateShipmentStatus(id!, 'Envio Entregado');

      if (success) {
        setState(() {
          // Actualiza el estado en el modelo local para refrescar la UI
          _shipments[index] = ShipmentModel(
            id: shipment.id,
            userId: shipment.userId,
            destiny: shipment.destiny,
            description: shipment.description,
            createdAt: shipment.createdAt,
            status: 'Envio Entregado', // Cambiamos el estado
            vehicleId: shipment.vehicleId,
            vehicleModel: shipment.vehicleModel,
            vehiclePlate: shipment.vehiclePlate,
            transporterId: shipment.transporterId,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Confirmación de entrega enviada.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al marcar como entregado.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error al marcar como entregado: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: const Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.amber),
            SizedBox(width: 10),
            Text(
              'Envios',
              style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1A1F24),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
                strokeWidth: 4,
              ),
            )
          : _shipments.isEmpty
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Text(
                      'No hay envíos asignados a ${widget.name}.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: _shipments.length,
                      itemBuilder: (context, index) {
                        final shipment = _shipments[index];
                        return _buildShipmentCard(
                          shipment.destiny,
                          shipment.description,
                          shipment.createdAt,
                          shipment.status, // Pasa el estado
                          shipment.vehicleModel, // Pasa el modelo
                          shipment.vehiclePlate, // Pasa la placa
                          index,
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildShipmentCard(
    String destiny,
    String description,
    DateTime? createdAt,
    String status,
    String? vehicleModel,
    String? vehiclePlate,
    int index,
  ) {
    final bool isDelivered = status == 'Envio Entregado';

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      color: const Color(0xFFFFFFFF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.amber.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: CircleAvatar(
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destino: $destiny',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Descripción: $description',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      Text(
  'Fecha: ${createdAt != null ? DateFormat.yMMMd().format(createdAt) : 'Fecha desconocida'}',
  style: const TextStyle(
    color: Colors.amber,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  ),
),
                      Text(
                        'Estado: $status',
                        style: TextStyle(
                          color: isDelivered ? Colors.green.shade700 : Colors.orange.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vehicleModel != null && vehiclePlate != null && vehicleModel.isNotEmpty && vehiclePlate.isNotEmpty)
                        Text(
                          'Vehículo: $vehicleModel ($vehiclePlate)',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!isDelivered)
              ElevatedButton(
                onPressed: () => _markAsDelivered(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirmar Entrega ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (isDelivered)
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '¡Envío Entregado!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                  '${widget.name} ${widget.lastName} - Transportista',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'PERFIL', ProfileScreen2(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.report, 'REPORTES', ReportsCarrierScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.directions_car, 'VEHICULOS', VehicleDetailCarrierScreenScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(
            Icons.local_shipping,
            'ENVIOS',
            ShipmentsScreen2(
              name: widget.name,
              lastName: widget.lastName,
              userId: widget.userId,
            ),
          ),
          const SizedBox(height: 160),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white)),
            onTap: () {
              AuthService.logout();
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