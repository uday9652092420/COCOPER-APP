import 'package:connectivity_plus/connectivity_plus.dart';

abstract final class InternetHelper {
  static Future<bool> isOnline() async {
    final states = await Connectivity().checkConnectivity();
    return !states.contains(ConnectivityResult.none);
  }
}
