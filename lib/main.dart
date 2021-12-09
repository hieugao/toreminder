import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import './features/note/services.dart';
import 'app.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        noteServiceProvider.overrideWithValue(NoteService(sharedPreferences)),
        notionDatabaseServiceProvider.overrideWithValue(NotionDatabaseService(sharedPreferences))
      ],
      child: const MyApp(),
    ),
  );
}
