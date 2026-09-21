import 'package:get/get.dart';

import 'app_en.dart';
import 'app_hi.dart';
import 'app_kn.dart';
import 'app_ta.dart';
import 'app_te.dart';

class Localization extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': en,
        'hi': hi,
        'te': te,
        'ta': ta,
        'kn': kn,
      };
}
