import 'package:get/get.dart';

import '../../controllers/shell/shell_controller.dart';
import '../../controllers/transactions/transaction_form_controller.dart';
import '../../repositories/transactions/transaction_repository.dart';

class TransactionFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionFormController>(
      () => TransactionFormController(
        Get.find<TransactionRepository>(),
        Get.find<ShellController>(),
      ),
    );
  }
}
