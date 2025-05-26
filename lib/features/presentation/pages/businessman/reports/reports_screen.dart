import 'package:flutter/material.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/report_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/report_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/carrier_profile/carrier_profiles.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/shipments/shipments_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/businessman/vehicle/vehicles_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/login_screen.dart';

class ReportsScreen extends StatefulWidget {
  final String name;
  final String lastName;

  const ReportsScreen({
    Key? key,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final reportService = ReportService();
      final reports = await reportService.getAllReports();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar reportes: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: Row(
          children: [
            Icon(Icons.report, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Reportes',
              style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1E1F24),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA8E00)))
            : _reports.isEmpty
            ? const Center(
          child: Text(
            'No hay reportes disponibles',
            style: TextStyle(color: Colors.white70),
          ),
        )
            : ListView.builder(
          itemCount: _reports.length,
          itemBuilder: (context, index) {
            final report = _reports[index];
            return _buildReportCard(report);
          },
        ),
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  'assets/images/bell.png', // Usa 'assets/images/bell.png'
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
                  Text(
                    'Tipo: ${report.type}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Descripción: ${report.description}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Conductor: ${report.driverName}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  tooltip: 'Marcar como atendido',
                  onPressed: () {
                    _markReportAsHandled(report);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.blue),
                  tooltip: 'Llamar a Emergencias',
                  onPressed: _callEmergencyNumber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _markReportAsHandled(ReportModel report) {
    setState(() {
      _reports.remove(report); // Elimina el reporte de la lista
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reporte marcado como atendido'),
        backgroundColor: Colors.green,
      ),
    );
  }  void _callEmergencyNumber() async {
    // Mostrar mensaje de funcionalidad no implementada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de llamada al número de emergencia 105 no implementada aún.'),
        backgroundColor: Colors.orange,
      ),
    );
    
    // Para implementar completamente esta funcionalidad, necesitarías:
    // 1. Agregar la dependencia url_launcher: ^6.0.0 o posterior al pubspec.yaml
    // 2. Importar el paquete: import 'package:url_launcher/url_launcher.dart';
    // 3. Descomentariar y usar código como:
    //    final Uri url = Uri(scheme: 'tel', path: emergencyNumber);
    //    if (await canLaunchUrl(url)) {
    //      await launchUrl(url);
    //    } else {
    //      ScaffoldMessenger.of(context).showSnackBar(
    //        const SnackBar(
    //          content: Text('No se puede realizar la llamada.'),
    //          backgroundColor: Colors.redAccent,
    //        ),
    //      );
    //    }
  }


  Widget _buildDrawer(BuildContext context) {
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
          _buildDrawerItem(Icons.person, 'PERFIL', ProfileScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.people, 'TRANSPORTISTAS', CarrierProfilesScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.report, 'REPORTES', ReportsScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.directions_car, 'VEHÍCULOS', VehiclesScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.local_shipping, 'ENVIOS', ShipmentsScreen(name: widget.name, lastName: widget.lastName)),
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
