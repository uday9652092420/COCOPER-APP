import 'package:get/get.dart';

import '../../models/session/user_session_model.dart';
import '../../models/transactions/transaction_model.dart';
import '../shell/shell_controller.dart';

class TransactionCatalogController extends GetxController {
  TransactionCatalogController(this._shellController);

  final ShellController _shellController;
  final query = ''.obs;

  List<TransactionType> get transactions {
    final allowed = TransactionAccess.forRole(
      _shellController.session.value.role,
    );
    final value = query.value.trim().toLowerCase();
    if (value.isEmpty) return allowed;
    return allowed
        .where((type) => type.label.toLowerCase().contains(value))
        .toList(growable: false);
  }

  String get branchName => _shellController.session.value.branchName;
  String get roleKey => _shellController.session.value.role.translationKey;

  void setQuery(String value) => query.value = value;
}
