import 'package:movigestion_mobile_experimentos_version/features/data/remote/report_service.dart';
import 'package:movigestion_mobile_experimentos_version/features/data/remote/report_model.dart';

class ReportRepository {
  final ReportService reportService;

  ReportRepository({required this.reportService});

  Future<List<ReportModel>> getAllReports() async {
    return await reportService.getAllReports();
  }

  Future<ReportModel?> getReportById(int id) async {
    return await reportService.getReportById(id);
  }

  Future<ReportModel?> createReport(ReportModel report) async {
    return await reportService.createReport(report);
  }

  Future<bool> deleteReport(int id) async {
    return await reportService.deleteReport(id);
  }
}
