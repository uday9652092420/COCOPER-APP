import 'package:cocoper_operations/app/localization/app_en.dart';
import 'package:cocoper_operations/app/localization/app_hi.dart';
import 'package:cocoper_operations/app/localization/app_kn.dart';
import 'package:cocoper_operations/app/localization/app_ta.dart';
import 'package:cocoper_operations/app/localization/app_te.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every supported language contains every English UI key', () {
    final languages = {'hi': hi, 'te': te, 'ta': ta, 'kn': kn};
    for (final language in languages.entries) {
      final missing = en.keys
          .where((key) => !language.value.containsKey(key))
          .toList(growable: false);
      expect(missing, isEmpty, reason: '${language.key} is missing $missing');
    }
  });

  test('primary navigation is translated in every language', () {
    for (final map in [hi, te, ta, kn]) {
      expect(map['transactions'], isNot(en['transactions']));
      expect(map['reports'], isNot(en['reports']));
    }
  });
}
