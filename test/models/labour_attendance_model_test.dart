import 'package:cocoper_operations/app/models/attendance/labour_attendance_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses attendance time fields from snake_case response', () {
    final attendance = LabourAttendance.fromJson({
      'id': 'ATT-1',
      'labour_name': 'Labour Name',
      'in_time': '2026-09-23T09:00:00.000Z',
      'out_time': '2026-09-23T18:00:00.000Z',
      'total_working_hours': '9 hours',
    });

    expect(attendance.labourName, 'Labour Name');
    expect(attendance.inTime, '2026-09-23T09:00:00.000Z');
    expect(attendance.outTime, '2026-09-23T18:00:00.000Z');
    expect(attendance.totalWorkingHours, '9 hours');
    expect(attendance.isWorking, isFalse);
    expect(attendance.inDateTime?.isUtc, isFalse);
  });

  test('recognizes an open attendance record', () {
    final attendance = LabourAttendance.fromJson({
      'labour_name': 'Labour Name',
      'in_time': '09:00',
    });

    expect(attendance.isWorking, isTrue);
    expect(attendance.outTime, isEmpty);
  });
}
