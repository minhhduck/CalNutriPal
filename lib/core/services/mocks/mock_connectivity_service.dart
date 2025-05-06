import 'dart:async';

import '../interfaces/connectivity_service_interface.dart';

/// Mock implementation of ConnectivityServiceInterface for testing
class MockConnectivityService implements ConnectivityServiceInterface {
  final StreamController<ConnectivityStatus> _controller =
      StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _status = ConnectivityStatus.wifi;

  /// Create a new mock connectivity service with an optional initial status
  MockConnectivityService([ConnectivityStatus? initialStatus]) {
    if (initialStatus != null) {
      _status = initialStatus;
    }
    _controller.add(_status);
  }

  @override
  Future<bool> isConnected() async {
    return _status != ConnectivityStatus.offline;
  }

  @override
  Future<ConnectivityStatus> getConnectivityStatus() async {
    return _status;
  }

  @override
  Stream<ConnectivityStatus> get onConnectivityChanged => _controller.stream;

  /// Simulates a change in connectivity status
  void setConnectivityStatus(ConnectivityStatus status) {
    _status = status;
    _controller.add(status);
  }

  /// Disposes resources
  void dispose() {
    _controller.close();
  }
}
