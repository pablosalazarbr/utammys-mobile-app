import 'package:utammys_mobile_app/models/product_model.dart';
import 'package:utammys_mobile_app/models/category_model.dart';
import 'package:utammys_mobile_app/models/school_model.dart';
import 'package:utammys_mobile_app/services/api_service.dart';

class ProductService {
  /// Obtiene todos los productos de un cliente (colegio) específico
  static Future<List<Product>> getClientProducts(int clientId) async {
    try {
      print('[ProductService] Fetching products for client_id: $clientId');
      final response = await ApiService.getList('shop/products?client_id=$clientId');
      print('[ProductService] Got ${response.length} products for client $clientId');
      
      if (response.isEmpty) {
        print('[ProductService] No products found for client $clientId');
        return [];
      }
      
      return response
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[ProductService] ERROR fetching client products: $e');
      rethrow; // Re-throw the error to be handled in the UI
    }
  }

  /// Obtiene los detalles de un producto específico
  static Future<Product> getProductById(int productId) async {
    try {
      final response = await ApiService.get('shop/products/$productId');
      if (response.containsKey('data')) {
        return Product.fromJson(response['data'] as Map<String, dynamic>);
      }
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  /// Obtiene productos aleatorios para mostrar en el home
  static Future<List<Product>> getRandomProducts({int limit = 4}) async {
    try {
      final response = await ApiService.get('shop/products/random?limit=$limit');
      if (response.containsKey('data')) {
        final data = response['data'] as List<dynamic>;
        return data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Unexpected response format');
    } catch (e) {
      throw Exception('Error fetching random products: $e');
    }
  }

  /// Obtiene todas las categorías
  static Future<List<Category>> getCategories() async {
    try {
      final response = await ApiService.getList('shop/categories');
      return response
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Obtiene categorías con su árbol completo (padre-hijo)
  static Future<List<Category>> getCategoriesTree() async {
    try {
      final response = await ApiService.get('shop/categories/tree/full');
      if (response.containsKey('data')) {
        final data = response['data'] as List<dynamic>;
        return data
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Unexpected response format');
    } catch (e) {
      throw Exception('Error fetching categories tree: $e');
    }
  }

  /// Obtiene categoría con sus productos
  static Future<Category> getCategoryWithProducts(int categoryId) async {
    try {
      final response = await ApiService.get('shop/categories/$categoryId/products');
      if (response.containsKey('data')) {
        return Category.fromJson(response['data'] as Map<String, dynamic>);
      }
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching category with products: $e');
    }
  }

  /// Busca productos por barcode
  static Future<Product> searchByBarcode(String barcode) async {
    try {
      final response = await ApiService.get('shop/products/search/barcode?barcode=$barcode');
      if (response.containsKey('data')) {
        return Product.fromJson(response['data'] as Map<String, dynamic>);
      }
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Error searching product by barcode: $e');
    }
  }

  /// Obtiene stock de un producto por barcode
  static Future<Map<String, dynamic>> getStockByBarcode(String barcode) async {
    try {
      final response = await ApiService.get('shop/inventory/stock?barcode=$barcode');
      if (response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      return response;
    } catch (e) {
      throw Exception('Error fetching stock: $e');
    }
  }

  /// Obtiene lista de colegios/escuelas desde API
  static Future<List<School>> getSchools() async {
    try {
      print('[ProductService] Fetching schools from /shop/clients');
      final response = await ApiService.getList('shop/clients');
      print('[ProductService] Got ${response.length} schools from API');
      final schools = response
          .map((item) {
            print('[ProductService] Parsing school: ${item}');
            return School.fromJson(item as Map<String, dynamic>);
          })
          .toList();
      print('[ProductService] Successfully parsed ${schools.length} schools');
      return schools;
    } catch (e) {
      print('[ProductService] ERROR fetching schools: $e');
      throw Exception('Error fetching schools: $e');
    }
  }
}
