import 'dart:async';

import 'package:cal_nutri_pal/core/services/interfaces/connectivity_service_interface.dart';

/// Implementation of the connectivity service interface
class ConnectivityService implements ConnectivityServiceInterface {
  final StreamController<ConnectivityStatus> _connectionStatusController =
      StreamController<ConnectivityStatus>.broadcast();

  ConnectivityService() {
    // In a real implementation, we would initialize a connectivity plugin here
    // For now, we'll simulate being connected to WiFi
    _connectionStatusController.add(ConnectivityStatus.wifi);
  }

  @override
  Future<bool> isConnected() async {
    final status = await getConnectivityStatus();
    return status != ConnectivityStatus.offline;
  }

  @override
  Future<ConnectivityStatus> getConnectivityStatus() async {
    // In a real implementation, we would check the actual connectivity
    // For now, we'll simulate being connected to WiFi
    return ConnectivityStatus.wifi;
  }

  @override
  Stream<ConnectivityStatus> get onConnectivityChanged =>
      _connectionStatusController.stream;

  /// Clean up resources
  void dispose() {
    _connectionStatusController.close();
  }
}
