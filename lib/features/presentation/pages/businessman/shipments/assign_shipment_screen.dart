import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile_experimentos_version/core/app_constrants.dart'; // Importa AppConstrants
import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart'; // Importa AuthService
import 'package:movigestion_mobile_experimentos_version/features/data/remote/shipment_service.dart'; // Importa ShipmentService
import 'package:movigestion_mobile_experimentos_version/features/data/remote/shipment_model.dart'; // Importa ShipmentModel
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/carrier_profile/carrier_profiles.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/reports/reports_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/shipments/shipments_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/vehicle/vehicles_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/login_screen.dart';


class AssignShipmentScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final int userId;

  const AssignShipmentScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.userId,
  }) : super(key: key);

  @override
  _AssignShipmentScreenState createState() => _AssignShipmentScreenState();
}

class _AssignShipmentScreenState extends State<AssignShipmentScreen> {
  // Eliminamos driverNameController ya que no se usa en el payload de creación
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<dynamic> _vehicles = [];
  int? _selectedVehicleId;
  String? _selectedVehicleInfo; // Para mostrar en el Dropdown (ej: Modelo - Placa)

  bool _isSubmitting = false;
  bool _isLoadingDropdowns = true;

  final ShipmentService _shipmentService = ShipmentService(); // Instancia de tu servicio

  @override
  void initState() {
    super.initState();
    _fetchVehicles(); // Solo necesitamos cargar los vehículos
  }

  Future<void> _fetchVehicles() async {
    setState(() {
      _isLoadingDropdowns = true;
    });
    final String? token = AuthService.token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay token de autenticación disponible. Por favor, inicia sesión.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoadingDropdowns = false;
      });
      return;
    }

    try {
      // Directamente la llamada HTTP ya que ShipmentService no tiene este método
      final url = Uri.parse('${AppConstrants.baseUrl}${AppConstrants.vehicle}');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _vehicles = json.decode(response.body);
        });
      } else {
        throw Exception('Error al cargar vehículos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar vehículos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingDropdowns = false;
      });
    }
  }


  Future<void> _assignShipment() async {
    final String destiny = addressController.text;
    final String description = descriptionController.text;

    if (_selectedVehicleId == null || destiny.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un vehículo y completa todos los campos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Creamos un ShipmentModel con los datos necesarios para el backend
      final ShipmentModel newShipment = ShipmentModel(
        id: 0, // El ID será asignado por el backend
        destiny: destiny,
        description: description,
        userId: widget.userId, // El ID del gerente logueado
        vehicleId: _selectedVehicleId, // El ID del vehículo seleccionado
        status: 'Pending', // Estado inicial, como lo pide el backend
        transporterId: null, // No se envía en la creación según tu JSON, puede ser nulo o 0 si el backend lo requiere así al inicio
        vehicleModel: null, // Estos campos son para la respuesta del backend
        vehiclePlate: null, // No necesarios para la creación
      );

      // Usamos tu servicio para crear el envío
      final success = await _shipmentService.createShipment(newShipment);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Envío asignado con éxito.'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la pantalla de envíos y actualizarla
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShipmentsScreen(
              name: widget.name,
              lastName: widget.lastName,
              userId: widget.userId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al asignar el envío. Revisa la consola para más detalles.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Envío'),
        backgroundColor: const Color(0xFF2C2F38),
      ),
      backgroundColor: const Color(0xFF1A1F24),
      drawer: _buildDrawer(),
      body: _isLoadingDropdowns
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA8E00)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Eliminado el campo "Nombre conductor asignado"
                  _buildDropdownField(
                    'Seleccionar Vehículo',
                    _selectedVehicleInfo,
                    _vehicles.map<DropdownMenuItem<String>>((vehicle) {
                      final info = '${vehicle['model']} - ${vehicle['plate']}';
                      return DropdownMenuItem<String>(
                        value: info,
                        child: Text(
                          info,
                          style: const TextStyle(color: Colors.amber),
                        ),
                        onTap: () {
                          // Al seleccionar, guarda el ID del vehículo
                          setState(() {
                            _selectedVehicleId = vehicle['id'];
                          });
                        },
                      );
                    }).toList(),
                    (String? newValue) {
                      // Cuando el Dropdown cambia, actualiza la información mostrada
                      setState(() {
                        _selectedVehicleInfo = newValue;
                      });
                    },
                  ),
                  _buildInputField('Dirección de Destino', addressController),
                  _buildInputField('Descripción del Envío', descriptionController),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _assignShipment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Asignar Envío',
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF2C2F38),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF2C2F38), width: 1.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFEA8E00), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, String? value, List<DropdownMenuItem<String>> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF2C2F38),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF2C2F38), width: 1.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFEA8E00), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        dropdownColor: const Color(0xFF2C2F38),
        style: const TextStyle(color: Colors.amber),
        value: value,
        items: items,
        onChanged: onChanged,
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
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'PERFIL', ProfileScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
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
              AuthService.logout(); // Limpia el token y el usuario actual
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