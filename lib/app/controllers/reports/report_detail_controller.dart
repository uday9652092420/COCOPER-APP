import 'package:get/get.dart';

import '../../models/reports/report_model.dart';
import '../../repositories/reports/report_repository.dart';
import '../../services/exceptions.dart';
import '../shell/shell_controller.dart';

class ReportDetailController extends GetxController {
  ReportDetailController(this._repository, this._shellController);

  final ReportRepository _repository;
  final ShellController _shellController;
  final isLoading = false.obs;
  final report = Rxn<ReportData>();
  final error = Rxn<Object>();
  final range = ReportRange.last90Days.obs;
  final selectedParty = RxnString();
  final isExporting = false.obs;
  late final ReportType type;

  String get branchName => _shellController.session.value.branchName;

  ReportQuery get query => ReportQuery(
        type: type,
        branchId: _shellController.session.value.branchId,
        range: range.value,
        partyId: selectedParty.value,
      );

  @override
  void onInit() {
    super.onInit();
    type = ReportType.values.byName(Get.parameters['type']!);
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    isLoading.value = true;
    error.value = null;
    try {
      report.value = await _repository.getReport(
        query,
        forceRefresh: forceRefresh,
      );
    } catch (exception) {
      error.value = exception;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setRange(ReportRange value) async {
    range.value = value;
    await load();
  }

  Future<void> setParty(String value) async {
    selectedParty.value = value;
    await load();
  }

  Future<String?> export() async {
    isExporting.value = true;
    try {
      return await _repository.createExport(query);
    } on AppException catch (exception) {
      error.value = exception;
      return null;
    } finally {
      isExporting.value = false;
    }
  }
}
