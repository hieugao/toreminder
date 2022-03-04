import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notion_capture/features/todo/repository.dart';
import 'package:notion_capture/pages/home/view_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './features/note/services.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final sharedPreferences = await SharedPreferences.getInstance();

  // ! Android only.
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    // systemNavigationBarColor: Colors.blue,
    statusBarColor: Colors.grey[850],
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
            .overrideWithValue(TodoSharedPrefsRepository(sharedPreferences))
      ],
      child: const MyApp(),
    ),
  );
}
