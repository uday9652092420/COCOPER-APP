import 'package:get/get.dart';

import '../../controllers/reports/report_catalog_controller.dart';
import '../../controllers/shell/shell_controller.dart';

class ReportCatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportCatalogController>(
      () => ReportCatalogController(Get.find<ShellController>()),
    );
  }
}
