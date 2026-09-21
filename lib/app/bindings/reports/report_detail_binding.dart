import 'package:get/get.dart';

import '../../controllers/reports/report_detail_controller.dart';
import '../../controllers/shell/shell_controller.dart';
import '../../repositories/reports/report_repository.dart';

class ReportDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportDetailController>(
      () => ReportDetailController(
        Get.find<ReportRepository>(),
        Get.find<ShellController>(),
      ),
    );
  }
}
