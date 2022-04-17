import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toreminder/app.dart';

Widget createAppWidget(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MyApp(),
  );
}
