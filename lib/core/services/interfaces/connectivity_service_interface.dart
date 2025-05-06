/// Represents the current connectivity status
enum ConnectivityStatus {
  /// Connected via WiFi
  wifi,

  /// Connected via mobile data
  mobile,

  /// No connection
  offline,
}

/// Interface for a service that provides connectivity information
abstract class ConnectivityServiceInterface {
  /// Checks if the device is currently connected to the internet
  Future<bool> isConnected();

  /// Gets the current connectivity status
  Future<ConnectivityStatus> getConnectivityStatus();

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get onConnectivityChanged;
}
