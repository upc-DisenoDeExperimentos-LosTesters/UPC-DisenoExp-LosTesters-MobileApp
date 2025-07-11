import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_Assignment_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/carrier_profile/carrier_profiles.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/reports/reports_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/shipments/shipments_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/vehicle/vehicles_screen.dart';
import 'dart:convert';

import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/login_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final VehicleModel vehicle;
  final String name;
  final String lastName;
  final int userId;
  

  const VehicleDetailScreen({
    Key? key,
    required this.vehicle,
    required this.name,
    required this.lastName,
    required this.userId,
  }) : super(key: key);

  @override
  _VehicleDetailScreenState createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> with SingleTickerProviderStateMixin {  late TextEditingController licensePlateController;
  late TextEditingController modelController;
  late TextEditingController serialNumberController;
  late TextEditingController ownerIdController;
  late TextEditingController carrierIdController;
  late double engineValue = 50;
  late double fuelValue = 50;
  late double tiresValue = 50;
  late double electricalSystemValue = 50;
  late double transmissionTempValue = 50;
  late TextEditingController driverNameController;
  late TextEditingController colorController;
  late TextEditingController lastTechnicalInspectionDateController;  // No necesitamos _selectedImage ya que está comentada su funcionalidad
  // No necesitamos el _animationController ya que está comentada su funcionalidad
  final VehicleService vehicleService = VehicleService();
  Future<List<VehicleAssignment>> _assignmentsFuture= Future.value([]);
  int? _currentTransporterId;
  bool _isAssigned = false;
  @override
  void initState() {
    super.initState();
    licensePlateController = TextEditingController(text: widget.vehicle.licensePlate);
    modelController = TextEditingController(text: widget.vehicle.model);
    serialNumberController = TextEditingController(text: widget.vehicle.serialNumber);
    ownerIdController = TextEditingController(text: widget.vehicle.idPropietario.toString());
    carrierIdController = TextEditingController(text: widget.vehicle.idTransportista.toString());
    driverNameController = TextEditingController(text: "");
    colorController = TextEditingController(text: "");
    lastTechnicalInspectionDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _assignmentsFuture = _loadAssignments();
  }


  Future<List<VehicleAssignment>> _loadAssignments() async {
    final assignments = await VehicleService().getAssignments();
    // Filtra asignaciones activas para este vehículo
    final activeAssignments = assignments.where((a) => 
      a.vehicleId == widget.vehicle.id && 
      (a.endDate == null || a.endDate!.isAfter(DateTime.now()))
    ).toList();
    
    if (activeAssignments.isNotEmpty) {
      setState(() {
        _currentTransporterId = activeAssignments.first.transporterId;
        _isAssigned = true;
      });
    }
    return activeAssignments;
  }

  Future<void> _updateVehicle() async {
  try {
    VehicleModel updatedVehicle = VehicleModel(
      id: widget.vehicle.id,
      licensePlate: licensePlateController.text,
      model: modelController.text,
      serialNumber: serialNumberController.text, // Agrega este controlador
      idPropietario: int.tryParse(ownerIdController.text) ?? widget.vehicle.idPropietario,
      idTransportista: int.tryParse(carrierIdController.text) ?? widget.vehicle.idTransportista,
    );

    bool success = await vehicleService.updateVehicle(updatedVehicle.id, updatedVehicle);
    
    if (success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => VehiclesScreen(
            name: widget.name,
            lastName: widget.lastName,
            userId: widget.userId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else {
      _showSnackbar('Error al actualizar el vehículo');
    }
  } catch (error) {
    _showSnackbar('Error al actualizar el vehículo: $error');
  }
}

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  String _encodeImageToBase64(File image) {
    List<int> imageBytes = image.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: const Text(
          'Detalle del Vehículo',
          style: TextStyle(color: Colors.grey),
        ),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1E1F24),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /*AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _selectedImage != null
                  ? _buildVehicleImage(_selectedImage!)
                  : widget.vehicle.vehicleImage.isNotEmpty
                  ? _buildVehicleNetworkImage(widget.vehicle.vehicleImage)
                  : _buildNoImagePlaceholder(),
            ),*/
            const SizedBox(height: 20),
            _buildSectionContainer(_buildTextField('Placa', licensePlateController)),
            _buildSectionContainer(_buildTextField('Modelo', modelController)),
            _buildSectionContainer(_buildSliderField('Motor (%)', engineValue, (value) {
              setState(() {
                engineValue = value;
              });
            })),
            _buildSectionContainer(_buildSliderField('Combustible (%)', fuelValue, (value) {
              setState(() {
                fuelValue = value;
              });
            })),
            _buildSectionContainer(_buildSliderField('Neumáticos (%)', tiresValue, (value) {
              setState(() {
                tiresValue = value;
              });
            })),
            _buildSectionContainer(_buildSliderField('Sistema Eléctrico (%)', electricalSystemValue, (value) {
              setState(() {
                electricalSystemValue = value;
              });
            })),
            _buildSectionContainer(_buildSliderField('Temperatura de Transmisión (%)', transmissionTempValue, (value) {
              setState(() {
                transmissionTempValue = value;
              });
            })),
            _buildSectionContainer(_buildTextField('Conductor', driverNameController)),
            _buildSectionContainer(_buildTextField('Color', colorController)),
            _buildSectionContainer(_buildDateField('Fecha de Última Inspección Técnica', lastTechnicalInspectionDateController)),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA8E00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  elevation: 5,
                ),
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
            _buildDriverInfo()
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
  return FutureBuilder<List<VehicleAssignment>>(
    future: _assignmentsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }
      
      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        return _buildSectionContainer(
          Text(
            'No hay conductor asignado actualmente',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      final assignment = snapshot.data!.first;
      return _buildSectionContainer(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conductor asignado',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ID Transportista: ${assignment.transporterId}',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Ruta: ${assignment.route}',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Desde: ${DateFormat('yyyy-MM-dd').format(assignment.startDate)}',
              style: TextStyle(color: Colors.white70),
            ),
            if (assignment.endDate != null)
              Text(
                'Hasta: ${DateFormat('yyyy-MM-dd').format(assignment.endDate!)}',
                style: TextStyle(color: Colors.white70),
              ),
          ],
        ),
      );
    },
  );
}

  Widget _buildVehicleImage(File image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.file(
        image,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildVehicleNetworkImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildNoImagePlaceholder(),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2E35),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          'Toca para seleccionar imagen',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F353F),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSliderField(String label, double value, ValueChanged<double> onChanged) {
    String getConditionText(double value) {
      if (value > 75) {
        return "En excelente estado";
      } else if (value > 60) {
        return "En buen estado";
      } else if (value > 35) {
        return "Presenta algunas fallas";
      } else {
        return "En mal estado";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toInt()}%',
          style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Text(
          getConditionText(value),
          style: TextStyle(
            fontSize: 14,
            color: value > 75
                ? Colors.green
                : value > 60
                ? Colors.amber
                : value > 35
                ? Colors.orange
                : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${value.toInt()}%',
          onChanged: onChanged,
          activeColor: const Color(0xFFEA8E00),
          inactiveColor: const Color(0xFF2F353F),
        ),
      ],
    );
  }


  Widget _buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF3A414B),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Color(0xFFEA8E00)),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: const Color(0xFFEA8E00),
                      onPrimary: Colors.white,
                      surface: const Color(0xFF2C2F38),
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              });
            }
          },
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF3A414B),
      ),
      style: const TextStyle(color: Colors.white),
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
