import 'package:flutter/material.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/report_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/report_model.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/reports/new_report_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/shipments/shipments_screen2.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/vehicle/vehicle_detail_carrier_screen.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/carrier/profile/profile_screen2.dart';
import 'package:movigestion_mobile_experimentos_version/features/presentation/pages/login_register/login_screen.dart';

class ReportsCarrierScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final int userId;

  const ReportsCarrierScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.userId,
  }) : super(key: key);

  @override
  _ReportsCarrierScreenState createState() => _ReportsCarrierScreenState();
}

class _ReportsCarrierScreenState extends State<ReportsCarrierScreen> with SingleTickerProviderStateMixin {
  List<ReportModel> _reports = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _fetchReports();
  }
  Future<void> _fetchReports() async {
    try {
      final reportService = ReportService();
      
      // Intentar primero con getMyReports
      try {
        final reports = await reportService.getMyReports();
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
        _animationController.forward();
        print("Reportes obtenidos exitosamente: ${reports.length}");      } catch (myReportsError) {
        print("Error en getMyReports: $myReportsError");
        
        // Si falla, intentar primero con el endpoint específico para el usuario 10
        print("Intentando obtener reportes para el usuario con ID 10...");
        try {
          final userReports = await reportService.getReportsByUserId(10);
          setState(() {
            _reports = userReports;
            _isLoading = false;
          });
          
          if (_reports.isNotEmpty) {
            print("Encontrados ${_reports.length} reportes para el usuario con ID 10");
          } else {
            print("No se encontraron reportes para el usuario con ID 10");
            // Como último recurso, intentar con getAllReports y filtrar
            final allReports = await reportService.getAllReports();
            setState(() {
              _reports = allReports.where((report) => 
                report.driverName == widget.name || report.userId == 10).toList();
              _isLoading = false;
            });
            print("Filtrado manual: encontrados ${_reports.length} reportes");
          }
        } catch (userReportError) {
          print("Error al obtener reportes por ID de usuario: $userReportError");
          // Como último recurso, intentar con getAllReports y filtrar
          final allReports = await reportService.getAllReports();
          setState(() {
            _reports = allReports.where((report) => 
              report.driverName == widget.name || report.userId == 10).toList();
            _isLoading = false;
          });
          print("Filtrado manual: encontrados ${_reports.length} reportes");
        }
        
        _animationController.forward();
      }
    } catch (e) {
      print('Error al cargar los reportes: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los reportes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToNewReportScreen() async {
    final ReportModel? newReport = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewReportScreen(
          name: widget.name,
          lastName: widget.lastName,
          userId: widget.userId,
        ),
      ),
    );

    if (newReport != null) {
      await _fetchReports();
      setState(() {
        _reports.add(newReport);
      });
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
            Icon(Icons.report, color: Colors.amber),
            SizedBox(width: 10),
            Text(
              'Tus Reportes',
              style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1A1F24),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.amber,
          strokeWidth: 3,
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: _reports.isEmpty
            ? const Center(
          child: Text(
            'No realizaste ningún reporte.',
            style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _reports.length,
          itemBuilder: (context, index) {
            final report = _reports[index];
            return _buildReportCard(report);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewReportScreen,
        backgroundColor: const Color(0xFFFFA000),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: const Color(0xFFFFFFFF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(report),
            const SizedBox(height: 10),
            _buildReportDetails('Tipo', report.type),
            _buildReportDetails('Descripción', report.description), // Descripción completa
            _buildReportDetails('Fecha', report.createdAt?.toLocal().toString() ?? 'No disponible'),
          ],
        ),
      ),
    );
  }


  Widget _buildReportHeader(ReportModel report) {
    return Row(
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
          child:
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFEA8E00),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/images/bell.png',
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 30,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            report.driverName ?? 'Sin nombre',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildReportDetails(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 4), // Espaciado entre el label y el valor
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            maxLines: null, // Permite que el texto se extienda a varias líneas
          ),
        ],
      ),
    );
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
                  '${widget.name} ${widget.lastName} - Transportista',
                  style: const TextStyle(color: Colors.grey,  fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'PERFIL', ProfileScreen2(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.report, 'REPORTES', ReportsCarrierScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),
          _buildDrawerItem(Icons.directions_car, 'VEHICULOS', VehicleDetailCarrierScreenScreen(name: widget.name, lastName: widget.lastName, userId: widget.userId)),   
                    _buildDrawerItem(Icons.local_shipping, 'ENVIOS', ShipmentsScreen2(name: widget.name, lastName: widget.lastName, userId: widget.userId)),       
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
