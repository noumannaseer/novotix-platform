import 'dart:async';
import 'package:connectivity/connectivity.dart';

enum NetworkStatus { Online, Offline }

class NetworkStatusService {
  static Future<NetworkStatus> getNetworkStatus() async {
    final status = await (Connectivity().checkConnectivity());
    if (status == null) return null;
    return status == ConnectivityResult.mobile ||
            status == ConnectivityResult.wifi
        ? NetworkStatus.Online
        : NetworkStatus.Offline;
  }
}
