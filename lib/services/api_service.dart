import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static String getBaseUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'https://api.example.com/api';
  }

  /// Obtiene la URL base sin /api para construir URLs de recursos
  static String getStorageBaseUrl() {
    final baseUrl = getBaseUrl();
    // Remueve /api del final si existe
    if (baseUrl.endsWith('/api')) {
      return baseUrl.substring(0, baseUrl.length - 4);
    }
    return baseUrl;
  }

  /// GET request
  /// [endpoint] - API endpoint (e.g., 'categories' or '/categories')
  /// Returns parsed JSON response
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final baseUrl = getBaseUrl();
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = Uri.parse('$baseUrl/$normalizedEndpoint');
    
    print('[API] GET Request: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('[API] GET Response Status: ${response.statusCode}');
      print('[API] GET Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  /// GET request for lists
  /// [endpoint] - API endpoint (e.g., 'categories' or '/categories')
  /// Returns parsed JSON response as a list
  static Future<List<dynamic>> getList(String endpoint) async {
    final baseUrl = getBaseUrl();
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = Uri.parse('$baseUrl/$normalizedEndpoint');
    
    print('[API] GET List Request: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('[API] GET List Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        final bodyString = decodedBody.toString();
        final preview = bodyString.length > 200 ? bodyString.substring(0, 200) : bodyString;
        print('[API] GET List Decoded Body: $preview');
        
        // Si la API devuelve {data: [...]} retorna la lista dentro de 'data'
        if (decodedBody is Map && decodedBody.containsKey('data')) {
          print('[API] GET List Found data key, returning list');
          final data = decodedBody['data'];
          if (data is List) {
            print('[API] GET List Data is a list with ${data.length} items');
            return data;
          } else if (data == null) {
            print('[API] GET List Data is null, returning empty list');
            return [];
          }
        }
        // Si devuelve un array directamente
        if (decodedBody is List) {
          print('[API] GET List Direct array with ${decodedBody.length} items');
          return decodedBody;
        }
        print('[API] GET List Unexpected format, returning empty list');
        return [];
      } else {
        throw Exception(
          'Failed to load data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('[API] GET List Exception: $e');
      throw Exception('Error fetching data: $e');
    }
  }

  /// POST request
  /// [endpoint] - API endpoint (e.g., 'orders' or '/orders')
  /// [data] - Data to send in the request body
  /// Returns parsed JSON response
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final baseUrl = getBaseUrl();
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = Uri.parse('$baseUrl/$normalizedEndpoint');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to post data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error posting data: $e');
    }
  }
}
