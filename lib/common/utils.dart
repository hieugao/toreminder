import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@Deprecated('Use connectivity_service.dart instead')
Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

String getSecret(String key) {
  if (!kReleaseMode) return dotenv.env[key]!;

  return Platform.environment[key]!;
}
