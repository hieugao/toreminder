import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

import './app.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}
