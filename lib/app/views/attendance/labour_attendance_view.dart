import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/attendance/labour_attendance_controller.dart';
import '../../controllers/shell/shell_controller.dart';
import '../../models/attendance/labour_attendance_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';

class LabourAttendanceView extends GetView<LabourAttendanceController> {
  const LabourAttendanceView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Labour attendance'),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: Get.find<ShellController>().signOut,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CocoperLogo(size: 48),
                const SizedBox(height: 26),
                Text(
                  'Record your working time for the active branch.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CocoperColors.muted,
                      ),
                ),
                const SizedBox(height: 24),
                _ContextCard(),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Labour name',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: controller.labourNameController,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Labour Name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          final record = controller.attendance.value;
                          return Column(
                            children: [
                              _AttendanceTime(
                                label: 'Date',
                                value:
                                    _formatDateOnly(record?.attendanceDateTime),
                                icon: Icons.calendar_today_outlined,
                              ),
                              _AttendanceTime(
                                label: 'In time',
                                value: _formatTime(record?.inDateTime),
                                icon: Icons.login_rounded,
                              ),
                              _AttendanceTime(
                                label: 'Out time',
                                value: controller.formatDateTime(
                                  record?.outDateTime,
                                ),
                                icon: Icons.logout_rounded,
                              ),
                              _AttendanceTime(
                                label: 'Total working hours',
                                value: record?.isWorking == true
                                    ? controller.elapsedLabel
                                    : _hoursLabel(record),
                                icon: Icons.schedule_rounded,
                              ),
                              _AttendanceTime(
                                label: 'Status',
                                value: record?.isWorking == true
                                    ? 'Working'
                                    : 'Not working',
                                icon: Icons.info_outline_rounded,
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 18),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.attendance.value?.isWorking ==
                                          true
                                      ? controller.stopWork
                                      : controller.recordAttendance,
                              icon: Icon(
                                controller.attendance.value?.isWorking == true
                                    ? Icons.stop_circle_outlined
                                    : Icons.play_circle_outline,
                              ),
                              label: Text(
                                controller.attendance.value?.isWorking == true
                                    ? 'Stop work'
                                    : 'Start work',
                              ),
                            ),
                          ),
                        ),
                        Obx(
                          () => controller.error.value == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    controller.error.value!,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Obx(
                  () => controller.isLoadingList.value
                      ? const Center(child: CircularProgressIndicator())
                      : controller.completedRecords.isEmpty
                          ? const Card(
                              child: Padding(
                                padding: EdgeInsets.all(18),
                                child: Text(
                                    'No completed attendance records yet.'),
                              ),
                            )
                          : Column(
                              children: controller.completedRecords
                                  .map(
                                    (record) => _AttendanceCard(
                                      record: record,
                                      hours: _hoursLabel(record),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ContextCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _ContextField(
              icon: Icons.business_rounded,
              label: shell.session.value.organizationName,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PopupMenuButton<String>(
              tooltip: 'Select branch',
              onSelected: (branchId) async {
                await shell.selectBranch(branchId);
                await Get.find<LabourAttendanceController>().loadAttendance();
              },
              itemBuilder: (_) {
                if (shell.branches.isEmpty) {
                  return const [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Text('No assigned branches'),
                    ),
                  ];
                }
                return shell.branches
                    .map(
                      (branch) => PopupMenuItem<String>(
                        value: branch.id,
                        child: Text(branch.name),
                      ),
                    )
                    .toList(growable: false);
              },
              child: _ContextField(
                icon: Icons.warehouse_rounded,
                label: shell.session.value.branchName.isEmpty
                    ? 'Select branch'
                    : shell.session.value.branchName,
                showArrow: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextField extends StatelessWidget {
  const _ContextField({
    required this.icon,
    required this.label,
    this.showArrow = false,
  });

  final IconData icon;
  final String label;
  final bool showArrow;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: CocoperColors.mint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: CocoperColors.teal, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (showArrow)
              const Icon(Icons.expand_more_rounded, color: CocoperColors.teal),
          ],
        ),
      );
}

class _AttendanceTime extends StatelessWidget {
  const _AttendanceTime(
      {required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: CocoperColors.teal),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: CocoperColors.muted)),
            const Spacer(),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.record, required this.hours});

  final LabourAttendance record;
  final String hours;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Labour name: ${record.labourName}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    record.isWorking ? 'Working' : 'Completed',
                    style: TextStyle(
                      color: record.isWorking
                          ? CocoperColors.tealSoft
                          : CocoperColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Date: ${_formatDateOnly(record.attendanceDateTime)}'),
              Text('In time: ${_formatTime(record.inDateTime)}'),
              Text('Out time: ${_formatTime(record.outDateTime)}'),
              Text(
                'Total working hours: $hours',
              ),
            ],
          ),
        ),
      );
}

String _formatTime(DateTime? value) =>
    value == null ? '--' : DateFormat('hh:mm a').format(value);

String _formatDateOnly(DateTime? value) =>
    value == null ? '--' : DateFormat('dd MMM yyyy').format(value);

String _hoursLabel(LabourAttendance? record) =>
    record == null || record.totalWorkingHours.isEmpty
        ? '--'
        : record.totalWorkingHours;
