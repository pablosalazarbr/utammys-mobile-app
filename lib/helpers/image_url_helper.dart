import 'package:utammys_mobile_app/services/api_service.dart';

/// Helper para construir URLs de imágenes y recursos
class ImageUrlHelper {
  /// Obtener URL base sin /api (desde ApiService que lee del .env)
  static String get apiBaseUrl {
    return ApiService.getStorageBaseUrl();
  }

  /// Obtener URL completa para una imagen o recurso (PRODUCCIÓN)
  static String getFullUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      print('[ImageUrlHelper] ⚠️  relativePath es nulo o vacío');
      return 'https://via.placeholder.com/400x500?text=Sin+Imagen';
    }

    // Si ya es una URL completa, devolverla tal cual
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      print('[ImageUrlHelper] ✅ Ya es URL completa: $relativePath');
      return relativePath;
    }

    // Usar la URL base del .env (sin /api)
    String result;
    if (relativePath.startsWith('/')) {
      result = '$apiBaseUrl$relativePath';
    } else {
      result = '$apiBaseUrl/$relativePath';
    }
    print('[ImageUrlHelper] ✅ URL construida desde .env: $result');
    return result;
  }

  /// Construir URL para emulador (Android) - reemplaza el host por 10.0.2.2:8000
  static String getEmulatorUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      print('[ImageUrlHelper] ⚠️  relativePath es nulo o vacío');
      return 'https://via.placeholder.com/400x500?text=Sin+Imagen';
    }

    print('[ImageUrlHelper] 🔍 getEmulatorUrl() - Input: "$relativePath"');

    // Si ya es una URL completa, convertir el host a 10.0.2.2:8000
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      print('[ImageUrlHelper] ✅ Ya es URL completa, convertiendo host a emulador');
      // Reemplazar cualquier host con 10.0.2.2:8000
      String result = relativePath
          .replaceFirst(RegExp(r'https?://[^/]+'), 'http://10.0.2.2:8000');
      print('[ImageUrlHelper] Convertida a: $result');
      return result;
    }

    // Para rutas relativas, usar 10.0.2.2:8000 como base
    String result;
    if (relativePath.startsWith('/')) {
      result = 'http://10.0.2.2:8000$relativePath';
    } else {
      result = 'http://10.0.2.2:8000/$relativePath';
    }
    print('[ImageUrlHelper] ✅ URL emulador construida: $result');
    return result;
  }

  /// Obtener URL de imagen para usar en Image.network
  /// Por defecto usa la URL desde el .env (producción)
  /// Si [useEmulator] es true, reemplaza el host por 10.0.2.2:8000 para desarrollo local
  static String buildImageUrl(String? relativePath, {bool useEmulator = false}) {
    final url = useEmulator ? getEmulatorUrl(relativePath) : getFullUrl(relativePath);
    print('[ImageUrlHelper] buildImageUrl() - Input: $relativePath, UseEmulator: $useEmulator, Output: $url');
    return url;
  }
}
