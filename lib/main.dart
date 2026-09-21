import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'app/config/environment.dart';
import 'app/helpers/cache_helper.dart';
import 'app/helpers/storage_helper.dart';
import 'app/localization/localization.dart';
import 'app/routes/app_pages.dart';
import 'app/services/api_service.dart';
import 'app/services/sync_service.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([StorageHelper.init(), CacheHelper.init()]);
  ApiService.initialize();
  await SyncService.initialize();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Production crash reporting can be attached here without logging payloads.
  };

  runZonedGuarded(() => runApp(const CocoperApp()), (error, stackTrace) {
    if (kDebugMode) debugPrint('Uncaught error: $error\n$stackTrace');
  });
}

class CocoperApp extends StatelessWidget {
  const CocoperApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        title: Environment.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        translations: Localization(),
        locale: Locale(StorageHelper.languageCode),
        fallbackLocale: const Locale('en'),
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('te'),
          Locale('ta'),
          Locale('kn'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialBinding: AppPages.initialBinding,
        initialRoute: AppPages.initialPage,
        getPages: AppPages.routes,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context)
                .clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3),
          ),
          child: child ?? const SizedBox.shrink(),
        ),
      );
}
