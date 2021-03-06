import 'dart:async';

// Becausae `connectivity_plus` doesn't check if the internet is also working,
// we need `internet_con...` for that.
// Source: https://github.com/TezadaConnect/dsb_sample_project/blob/main/lib/service/wifi_connectivity_service.dart
// Source: https://stackoverflow.com/a/68736234/16553764
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// TODO: Add `loading` state.
enum ConnectivityStatus { connected, disconnected }

class WifiConnectivityRepository {
  WifiConnectivityRepository() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult? status) async {
      // print("Result : $status");
      connectivityStreamController
          .add((await _getConnectivityState(status ?? ConnectivityResult.none)));
    });
  }

  final connectivityStreamController = StreamController<ConnectivityStatus>();

  Future<ConnectivityStatus> _getConnectivityState(ConnectivityResult? status) async {
    try {
      if (status == ConnectivityResult.none) {
        return ConnectivityStatus.disconnected;
      } else if (await InternetConnectionChecker().hasConnection) {
        return ConnectivityStatus.connected;
      }

      return ConnectivityStatus.disconnected;
    } on Error catch (_) {
      throw Error();
    }
  }
}
