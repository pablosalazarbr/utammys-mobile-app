import 'package:flutter/foundation.dart';

/// Log de depuración. Solo imprime cuando la app corre en modo debug,
/// evitando filtrar datos (emails, URLs, respuestas del backend) en release.
void logDebug(Object? message) {
  if (kDebugMode) {
    debugPrint(message?.toString());
  }
}
