import 'package:get/get.dart';

import '../../controllers/shell/shell_controller.dart';
import '../../repositories/reports/report_repository.dart';
import '../../repositories/transactions/transaction_repository.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ShellController>(ShellController(), permanent: true);
    Get.lazyPut<TransactionRepository>(TransactionRepository.new, fenix: true);
    Get.lazyPut<ReportRepository>(ReportRepository.new, fenix: true);
  }
}
