import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/common/constants.dart';
import 'common/utils.dart';
import 'features/todo/repository.dart';
import 'features/onboarding/providers.dart';
import 'features/todo/providers.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final sharedPreferences = await SharedPreferences.getInstance();

  // ! Android only.
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   // systemNavigationBarColor: Colors.blue,
  //   statusBarColor: Color(0xFF151515),
  // ));

  // Source: https://github.com/jonbhanson/flutter_native_splash/blob/master/example/lib/main.dart
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //     overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  await SentryFlutter.init(
    (options) {
      options.dsn = getSecret(Secrets.sentryDsn);
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(TodoSharedPrefsRepository(sharedPreferences)),
          onBoardingSharedPrefsProvider.overrideWithValue(sharedPreferences),
        ],
        child: DevicePreview(
          enabled: !kReleaseMode,
          builder: (context) => const MyApp(),
        ),
      ),
    ),
  );
}
