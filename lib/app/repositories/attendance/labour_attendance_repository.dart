import '../../models/attendance/labour_attendance_model.dart';
import '../../services/api_service.dart';
import '../../services/endpoints.dart';

class LabourAttendanceRepository {
  Future<List<LabourAttendance>> getAttendance() async {
    final response = await ApiService.get<Object?>(
      EndPoints.mobileLabourAttendance,
    );
    final data = response.data;
    final map = data is Map ? Map<String, dynamic>.from(data) : null;
    final raw = map?['data'] ?? data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map<Object?, Object?>>()
        .map((item) => LabourAttendance.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList(growable: false);
  }

  Future<LabourAttendance> recordAttendance({
    required String labourName,
  }) async {
    final response = await ApiService.post<Object?>(
      EndPoints.mobileLabourAttendance,
      data: {'labour_name': labourName},
    );
    final data = response.data;
    final map =
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final payload = _payload(map);
    return LabourAttendance.fromJson(payload);
  }

  Future<LabourAttendance> checkout(String attendanceId) async {
    final response = await ApiService.patch<Object?>(
      EndPoints.mobileLabourAttendanceCheckout(attendanceId),
    );
    final data = response.data;
    final map =
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final payload = _payload(map);
    return LabourAttendance.fromJson(payload);
  }

  Map<String, dynamic> _payload(Map<String, dynamic> map) {
    final nested = map['data'] ?? map['attendance'] ?? map['record'];
    return nested is Map ? Map<String, dynamic>.from(nested) : map;
  }
}
