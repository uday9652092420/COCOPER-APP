import 'package:flutter/foundation.dart';

void consoleLog(String message) {
  if (kDebugMode) debugPrint(message);
}
