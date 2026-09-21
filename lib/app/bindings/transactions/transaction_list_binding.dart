import 'package:get/get.dart';

import '../../controllers/shell/shell_controller.dart';
import '../../controllers/transactions/transaction_list_controller.dart';
import '../../repositories/transactions/transaction_repository.dart';

class TransactionListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionListController>(
      () => TransactionListController(
        Get.find<TransactionRepository>(),
        Get.find<ShellController>(),
      ),
    );
  }
}
