import 'package:flutter/material.dart';

import './home/home_page.dart';
import './create_note/create_note_page.dart';
import './common/constants.dart';
import './common/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notion Capture',
      theme: themeData,
      initialRoute: Routes.root,
      routes: {
        Routes.root: (context) => const MyHomePage(),
        Routes.createNote: (context) => const CreateNotePage(),
      },
    );
  }
}
