class LabourAttendance {
  const LabourAttendance({
    required this.id,
    required this.labourName,
    required this.attendanceDate,
    required this.inTime,
    required this.outTime,
    required this.totalWorkingHours,
    required this.isWorking,
  });

  factory LabourAttendance.fromJson(Map<String, dynamic> json) {
    final inTime = _value(json, 'in_time', 'inTime');
    final outTime = _value(json, 'out_time', 'outTime');
    final total = _value(
      json,
      'total_working_hours',
      'totalWorkingHours',
    );
    return LabourAttendance(
      id: _string(json['id'] ?? json['attendance_id']),
      labourName: _string(json['labour_name'] ?? json['labourName']),
      attendanceDate:
          _string(json['attendance_date'] ?? json['attendanceDate']),
      inTime: _string(inTime),
      outTime: _string(outTime),
      totalWorkingHours: _string(total),
      isWorking: json['is_working'] == true ||
          json['isWorking'] == true ||
          (inTime != null && outTime == null),
    );
  }

  final String id;
  final String labourName;
  final String attendanceDate;
  final String inTime;
  final String outTime;
  final String totalWorkingHours;
  final bool isWorking;

  DateTime? get inDateTime => _dateTime(inTime);

  DateTime? get outDateTime => _dateTime(outTime);

  DateTime? get attendanceDateTime => _dateTime(attendanceDate);
}

Object? _value(Map<String, dynamic> json, String snake, String camel) =>
    json[snake] ?? json[camel];

String _string(Object? value) => value?.toString() ?? '';

DateTime? _dateTime(String value) => DateTime.tryParse(value)?.toLocal();
