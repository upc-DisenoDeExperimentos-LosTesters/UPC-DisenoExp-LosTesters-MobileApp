import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:movigestion_mobile_experimentos_version/features/data/remote/auth_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_Assignment_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/vehicle_service.dart';

class AssignVehicleScreen extends StatefulWidget {
  final int vehicleId;
  final String name;
  final String lastName;

  const AssignVehicleScreen({
    Key? key,
    required this.vehicleId,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _AssignVehicleScreenState createState() => _AssignVehicleScreenState();
}

class _AssignVehicleScreenState extends State<AssignVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehicleService _vehicleService = VehicleService();
  final TextEditingController _transporterIdController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  bool _isLoading = false;

  Future<void> _assignVehicle() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
    
    try {
      // Parsear las fechas a DateTime
      final startDate = _startDateController.text.isNotEmpty
          ? DateTime.parse(_startDateController.text)
          : DateTime.now();
      
      final endDate = _endDateController.text.isNotEmpty
          ? DateTime.parse(_endDateController.text)
          : null;

      final assignment = VehicleAssignment(
        id: 0, // El backend probablemente asignará un ID
        vehicleId: widget.vehicleId,
        transporterId: int.parse(_transporterIdController.text),
        startDate: startDate,
        endDate: endDate,
        route: _routeController.text,
      );

      await _vehicleService.createAssignment(assignment);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asignación creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  
  if (picked != null) {
    controller.text = DateFormat('yyyy-MM-dd').format(picked);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: Row(
          children: [
            const Icon(Icons.assignment, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Asignar Vehículo',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1C1E24),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Vehículo ID: ${widget.vehicleId}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'ID Transportista',
                _transporterIdController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese ID transportista';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Ruta',
                _routeController,
                validator: (value) => value!.isEmpty ? 'Ingrese la ruta' : null,
              ),
              const SizedBox(height: 16),
              _buildDateField('Fecha de inicio', _startDateController),
              const SizedBox(height: 16),
              _buildDateField('Fecha de fin (opcional)', _endDateController),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.amber)
                  : ElevatedButton(
                      onPressed: _assignVehicle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA000),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Asignar Vehículo',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.amber),
          onPressed: () => _selectDate(context, controller),
        ),
      ),
      validator: label.contains('(opcional)') 
          ? null 
          : (value) => value!.isEmpty ? 'Este campo es requerido' : null,
    );
  }
}