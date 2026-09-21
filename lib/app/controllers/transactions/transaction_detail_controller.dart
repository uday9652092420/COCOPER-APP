import 'package:get/get.dart';

import '../../models/transactions/transaction_model.dart';
import '../../repositories/transactions/transaction_repository.dart';
import '../shell/shell_controller.dart';

class TransactionDetailController extends GetxController {
  TransactionDetailController(this._repository, this._shellController);

  final TransactionRepository _repository;
  final ShellController _shellController;
  final isLoading = false.obs;
  final record = Rxn<TransactionRecord>();
  final error = Rxn<Object>();
  late final TransactionType type;
  late final String recordId;

  String get branchName => _shellController.session.value.branchName;

  @override
  void onInit() {
    super.onInit();
    type = TransactionType.values.byName(Get.parameters['type']!);
    recordId = Get.parameters['id']!;
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    isLoading.value = true;
    error.value = null;
    try {
      final records = await _repository.getTransactions(
        type: type,
        branchId: _shellController.session.value.branchId,
        forceRefresh: forceRefresh,
      );
      record.value = records.firstWhereOrNull((item) => item.id == recordId);
    } catch (exception) {
      error.value = exception;
    } finally {
      isLoading.value = false;
    }
  }
}
