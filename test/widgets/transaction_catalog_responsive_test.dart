import 'package:cocoper_operations/app/controllers/shell/shell_controller.dart';
import 'package:cocoper_operations/app/controllers/transactions/transaction_catalog_controller.dart';
import 'package:cocoper_operations/app/localization/localization.dart';
import 'package:cocoper_operations/app/theme/app_theme.dart';
import 'package:cocoper_operations/app/views/transactions/transaction_catalog_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    final shell = Get.put(ShellController());
    Get.put(TransactionCatalogController(shell));
  });

  tearDown(Get.reset);

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        translations: Localization(),
        locale: const Locale('en'),
        home: const TransactionCatalogView(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('phone layout renders without overflow', (tester) async {
    await pumpAt(tester, const Size(390, 844));

    expect(find.text('Transactions'), findsWidgets);
    expect(find.text('Purchase Order'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet layout renders navigation rail without overflow', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1180, 820));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Purchase Invoice'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
