import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/shell/shell_controller.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final shell = Get.find<ShellController>();
    return shell.isAuthenticated.value
        ? null
        : const RouteSettings(name: Routes.login);
  }
}
