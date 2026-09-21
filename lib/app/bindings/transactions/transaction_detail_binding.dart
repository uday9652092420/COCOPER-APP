import 'package:get/get.dart';

import '../../controllers/shell/shell_controller.dart';
import '../../controllers/transactions/transaction_detail_controller.dart';
import '../../repositories/transactions/transaction_repository.dart';

class TransactionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionDetailController>(
      () => TransactionDetailController(
        Get.find<TransactionRepository>(),
        Get.find<ShellController>(),
      ),
    );
  }
}
