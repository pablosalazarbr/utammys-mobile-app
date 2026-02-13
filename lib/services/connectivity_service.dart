import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Verificar si hay conexión a internet activa
  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.isNotEmpty && result.first != ConnectivityResult.none;
    } catch (e) {
      print('[ConnectivityService] Error checking internet: $e');
      return false;
    }
  }

  /// Obtener el tipo de conexión actual
  Future<ConnectivityResult> getConnectionType() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // checkConnectivity ahora retorna List<ConnectivityResult>
      if (result.isNotEmpty) {
        return result.first;
      }
      return ConnectivityResult.none;
    } catch (e) {
      print('[ConnectivityService] Error getting connection type: $e');
      return ConnectivityResult.none;
    }
  }

  /// Escuchar cambios en la conectividad
  Stream<List<ConnectivityResult>> onConnectivityChanged() {
    return _connectivity.onConnectivityChanged;
  }

  /// Descripción legible del tipo de conexión
  String getConnectionTypeString(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }
}
