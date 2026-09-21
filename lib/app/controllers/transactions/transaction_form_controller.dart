import 'dart:async';

import 'package:get/get.dart';

import '../../helpers/validation_helper.dart';
import '../../models/transactions/transaction_definition.dart';
import '../../models/transactions/transaction_model.dart';
import '../../repositories/transactions/transaction_repository.dart';
import '../../services/exceptions.dart';
import '../shell/shell_controller.dart';

class TransactionFormController extends GetxController {
  TransactionFormController(this._repository, this._shellController);

  final TransactionRepository _repository;
  final ShellController _shellController;
  final currentStep = 0.obs;
  final values = <String, String>{}.obs;
  final lookups = <String, List<String>>{}.obs;
  final fieldErrors = <String, String>{}.obs;
  final isLoadingLookups = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;
  late final TransactionType type;

  TransactionDefinition get definition => transactionDefinition(type);
  TransactionStep get activeStep => definition.steps[currentStep.value];
  bool get isLastStep => currentStep.value == definition.steps.length - 1;
  double get total => TransactionCalculator.total(type, values);
  String get branchName => _shellController.session.value.branchName;

  @override
  void onInit() {
    super.onInit();
    type = TransactionType.values.byName(Get.parameters['type']!);
    final draft = _repository.readDraft(type);
    values.assignAll({
      FieldKey.branch.name: branchName,
      FieldKey.quantity.name: '1200',
      FieldKey.discount.name: '0',
      FieldKey.actualQuantity.name: '1200',
      FieldKey.purchaseRate.name: '28',
      FieldKey.salesRate.name: '35',
      FieldKey.loadingCharge.name: '0',
      FieldKey.marketCess.name: '0',
      FieldKey.bagStickCharge.name: '0',
      FieldKey.freight.name: '0',
      FieldKey.morningOt.name: '0',
      FieldKey.eveningOt.name: '0',
      FieldKey.otRate.name: '150',
      if (draft != null) ...draft.values,
    });
    if (draft != null) {
      currentStep.value =
          draft.step.clamp(0, definition.steps.length - 1).toInt();
    }
    unawaited(loadLookups());
  }

  Future<void> loadLookups({bool forceRefresh = false}) async {
    isLoadingLookups.value = true;
    errorMessage.value = '';
    try {
      lookups.assignAll(
        await _repository.getLookups(
          branchId: _shellController.session.value.branchId,
          forceRefresh: forceRefresh,
        ),
      );
    } catch (error) {
      errorMessage.value = _messageKey(error);
    } finally {
      isLoadingLookups.value = false;
    }
  }

  void updateField(FieldKey key, String value) {
    values[key.name] = value;
    if (key == FieldKey.quantityMode) values[FieldKey.discount.name] = '0';
    if (key == FieldKey.quantity ||
        key == FieldKey.discount ||
        key == FieldKey.quantityMode) {
      final mode = values[FieldKey.quantityMode.name] ?? '';
      final discount =
          double.tryParse(values[FieldKey.discount.name] ?? '') ?? 0;
      values[FieldKey.discount.name] = _plainNumber(
        discount.clamp(0, TransactionCalculator.maxDiscount(mode)).toDouble(),
      );
      values[FieldKey.actualQuantity.name] = _plainNumber(
        TransactionCalculator.actualQuantity(values),
      );
    }
    fieldErrors.remove(key.name);
    errorMessage.value = '';
    unawaited(saveDraft());
  }

  bool next() {
    if (!_validateActiveStep()) return false;
    if (isLastStep) return true;
    currentStep.value++;
    unawaited(saveDraft());
    return true;
  }

  void previous() {
    if (currentStep.value == 0) return;
    currentStep.value--;
    unawaited(saveDraft());
  }

  Future<void> saveDraft() => _repository.saveDraft(
        TransactionDraft(
          type: type,
          values: Map<String, String>.from(values),
          step: currentStep.value,
          updatedAt: DateTime.now(),
        ),
      );

  Future<TransactionRecord?> submit() async {
    if (!_validateActiveStep()) return null;
    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      final record = await _repository.createTransaction(
        TransactionCreateRequest(
          type: type,
          branchId: _shellController.session.value.branchId,
          values: Map<String, String>.from(values),
          clientCreatedAt: DateTime.now(),
        ),
      );
      await _repository.clearDraft(type);
      return record;
    } on ValidationException catch (error) {
      fieldErrors.assignAll(error.fieldErrors);
      errorMessage.value = error.message;
      return null;
    } catch (error) {
      errorMessage.value = _messageKey(error);
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  bool isFieldVisible(FieldKey key) {
    if (key == FieldKey.invoice) {
      return values[FieldKey.invoiceAllocation.name] != 'Cumulative';
    }
    if (key == FieldKey.temporaryWorkerName) {
      return values[FieldKey.workerType.name] == 'Temporary';
    }
    if (key == FieldKey.labour) {
      return values[FieldKey.workerType.name] != 'Temporary';
    }
    return true;
  }

  bool _validateActiveStep() {
    if (activeStep.isReview) return true;
    final errors = <String, String>{};
    for (final field in activeStep.fields) {
      if (!isFieldVisible(field.key)) continue;
      final value = values[field.key.name]?.trim() ?? '';
      if (field.required && value.isEmpty) {
        errors[field.key.name] = 'required_field';
      } else if ((field.kind == FieldKind.decimal ||
              field.kind == FieldKind.money) &&
          value.isNotEmpty &&
          !ValidationHelper.isValidNumber(value)) {
        errors[field.key.name] = 'invalid_number';
      } else if (field.kind == FieldKind.phone &&
          value.isNotEmpty &&
          !ValidationHelper.isValidIndianMobile(value)) {
        errors[field.key.name] = 'invalid_mobile';
      }
    }
    fieldErrors.assignAll(errors);
    return errors.isEmpty;
  }

  String _messageKey(Object error) =>
      error is AppException ? error.message : 'something_went_wrong';

  static String _plainNumber(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}
