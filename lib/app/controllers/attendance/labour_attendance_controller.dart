import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/attendance/labour_attendance_model.dart';
import '../../repositories/attendance/labour_attendance_repository.dart';
import '../../services/exceptions.dart';
import '../shell/shell_controller.dart';

class LabourAttendanceController extends GetxController {
  final labourNameController = TextEditingController();
  final attendance = Rxn<LabourAttendance>();
  final records = <LabourAttendance>[].obs;
  final isLoading = false.obs;
  final isLoadingList = false.obs;
  final elapsed = Duration.zero.obs;
  final error = RxnString();
  Timer? _timer;

  List<LabourAttendance> get completedRecords =>
      records.where((record) => !record.isWorking).toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<ShellController>().mobileUser.value;
    labourNameController.text =
        user?.fullName ?? Get.find<ShellController>().session.value.userName;
    loadAttendance();
  }

  @override
  void onClose() {
    _timer?.cancel();
    labourNameController.dispose();
    super.onClose();
  }

  Future<void> recordAttendance() async {
    final shell = Get.find<ShellController>();
    if (shell.session.value.branchId.isEmpty) {
      error.value =
          'Select an assigned active branch before recording attendance.';
      return;
    }
    final labourName = labourNameController.text.trim();
    if (labourName.isEmpty) {
      error.value = 'Enter a labour name.';
      return;
    }
    error.value = null;
    isLoading.value = true;
    try {
      final repository = Get.find<LabourAttendanceRepository>();
      attendance.value =
          await repository.recordAttendance(labourName: labourName);
      await loadAttendance();
      Get.snackbar('Attendance started', 'In time has been recorded.');
    } on SessionExpiredException {
      await Get.find<ShellController>().signOut();
    } catch (exception) {
      _setError(exception, 'Unable to start work. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> stopWork() async {
    final active = attendance.value;
    if (active == null || !active.isWorking || active.id.isEmpty) {
      error.value = 'No active attendance record was found.';
      return;
    }
    error.value = null;
    isLoading.value = true;
    try {
      final updated =
          await Get.find<LabourAttendanceRepository>().checkout(active.id);
      attendance.value = updated;
      await loadAttendance();
      Get.snackbar('Attendance stopped', 'Out time has been recorded.');
    } on SessionExpiredException {
      await Get.find<ShellController>().signOut();
    } catch (exception) {
      _setError(exception, 'Unable to stop work. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _setError(Object exception, String fallback) {
    if (exception is NetworkException) {
      error.value = 'Network error. Check your connection and try again.';
    } else if (exception is AppException) {
      error.value = exception.message;
    } else {
      error.value = fallback;
    }
  }

  Future<void> loadAttendance() async {
    final shell = Get.find<ShellController>();
    if (shell.session.value.branchId.isEmpty) {
      records.clear();
      attendance.value = null;
      return;
    }
    isLoadingList.value = true;
    try {
      final loaded =
          await Get.find<LabourAttendanceRepository>().getAttendance();
      records.assignAll(loaded);
      attendance.value = loaded.firstWhereOrNull(
        (record) => record.isWorking,
      );
      _syncTimer();
    } on SessionExpiredException {
      await shell.signOut();
    } on NetworkException {
      error.value = 'Network error. Check your connection and try again.';
    } on AppException catch (exception) {
      error.value = exception.message;
    } catch (_) {
      error.value = 'Unable to load attendance. Please try again.';
    } finally {
      isLoadingList.value = false;
    }
  }

  String formatDateTime(DateTime? value) =>
      value == null ? '--' : DateFormat('dd MMM yyyy, hh:mm a').format(value);

  String get elapsedLabel {
    final totalSeconds = elapsed.value.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _syncTimer() {
    _timer?.cancel();
    final record = attendance.value;
    final startedAt = record?.inDateTime;
    if (record == null || !record.isWorking || startedAt == null) {
      elapsed.value = Duration.zero;
      return;
    }
    void update() {
      final value = DateTime.now().difference(startedAt);
      elapsed.value = value.isNegative ? Duration.zero : value;
    }

    update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => update());
  }
}
