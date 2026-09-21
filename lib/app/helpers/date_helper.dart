import 'package:intl/intl.dart';

abstract final class DateHelper {
  static String short(DateTime value) => DateFormat('dd MMM').format(value);
  static String full(DateTime value) => DateFormat('dd MMM yyyy').format(value);
  static String api(DateTime value) => value.toUtc().toIso8601String();
}
