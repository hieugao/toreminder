import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/note/services.dart';
import 'features/todo/repository.dart';
import 'pages/home/view_models.dart';
import 'pages/onboarding/view_models.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final sharedPreferences = await SharedPreferences.getInstance();

  // TODO: Disable this.
  // ! Android only.
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    // systemNavigationBarColor: Colors.blue,
    statusBarColor: Color(0xFF151515),
  ));

  // Source: https://github.com/jonbhanson/flutter_native_splash/blob/master/example/lib/main.dart
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //     overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  runApp(
    ProviderScope(
      overrides: [
        noteServiceProvider.overrideWithValue(NoteService(sharedPreferences)),
        notionDatabaseServiceProvider.overrideWithValue(NotionDatabaseService(sharedPreferences)),
        todoSharedPrefsRepositoryProvider
            .overrideWithValue(TodoSharedPrefsRepository(sharedPreferences)),
        onBoardingSharedPrefsProvider.overrideWithValue(sharedPreferences),
      ],
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}
