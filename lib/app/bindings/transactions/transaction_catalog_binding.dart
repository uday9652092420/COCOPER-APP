import 'package:get/get.dart';

import '../../controllers/shell/shell_controller.dart';
import '../../controllers/transactions/transaction_catalog_controller.dart';

class TransactionCatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionCatalogController>(
      () => TransactionCatalogController(Get.find<ShellController>()),
    );
  }
}
