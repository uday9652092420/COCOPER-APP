import 'package:get/get.dart';

import '../../models/transactions/transaction_model.dart';
import '../../repositories/transactions/transaction_repository.dart';
import '../shell/shell_controller.dart';

class TransactionListController extends GetxController {
  TransactionListController(this._repository, this._shellController);

  final TransactionRepository _repository;
  final ShellController _shellController;
  final isLoading = false.obs;
  final records = <TransactionRecord>[].obs;
  final error = Rxn<Object>();
  final search = ''.obs;
  late final TransactionType type;
  Worker? _searchWorker;

  String get branchId => _shellController.session.value.branchId;
  String get branchName => _shellController.session.value.branchName;

  @override
  void onInit() {
    super.onInit();
    type = TransactionType.values.byName(Get.parameters['type']!);
    _searchWorker = debounce(
      search,
      (_) => load(),
      time: const Duration(milliseconds: 300),
    );
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    isLoading.value = true;
    error.value = null;
    try {
      records.assignAll(
        await _repository.getTransactions(
          type: type,
          branchId: branchId,
          search: search.value,
          forceRefresh: forceRefresh,
        ),
      );
    } catch (exception) {
      error.value = exception;
    } finally {
      isLoading.value = false;
    }
  }

  void setSearch(String value) => search.value = value;

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
  }
}
