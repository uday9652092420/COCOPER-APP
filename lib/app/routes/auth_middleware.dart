import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/shell/shell_controller.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final shell = Get.find<ShellController>();
    if (!shell.isAuthenticated.value) {
      return const RouteSettings(name: Routes.login);
    }
    if (shell.hasLabourAttendanceAccess &&
        !shell.hasMobileHomeAccess &&
        route != Routes.labourAttendance) {
      return const RouteSettings(name: Routes.labourAttendance);
    }
    return null;
  }
}
