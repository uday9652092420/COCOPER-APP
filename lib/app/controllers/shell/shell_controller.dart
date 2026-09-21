import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/storage_helper.dart';
import '../../models/session/user_session_model.dart';

class ShellController extends GetxController {
  final session = UserSessionModel.demo.obs;

  Future<void> changeLanguage(String languageCode) async {
    await StorageHelper.setLanguage(languageCode);
    await Get.updateLocale(Locale(languageCode));
  }
}
