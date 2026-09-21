import 'package:get/get.dart';

import '../../models/reports/report_model.dart';
import '../shell/shell_controller.dart';

class ReportCatalogController extends GetxController {
  ReportCatalogController(this._shellController);

  final ShellController _shellController;

  List<ReportType> get reports =>
      ReportAccess.forRole(_shellController.session.value.role);
}
