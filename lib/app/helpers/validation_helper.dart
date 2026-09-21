abstract final class ValidationHelper {
  static bool isValidNumber(String value) => double.tryParse(value) != null;

  static bool isValidIndianMobile(String value) =>
      RegExp(r'^[6-9][0-9]{9}$').hasMatch(value);

  static String? required(String value, {required String message}) =>
      value.trim().isEmpty ? message : null;
}
