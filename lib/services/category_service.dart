import 'package:utammys_mobile_app/models/category_model.dart';
import 'package:utammys_mobile_app/services/api_service.dart';
import 'package:utammys_mobile_app/services/mock_data_service.dart';

class CategoryService {
  /// Obtiene todas las categorías principales desde la API
  /// Esperado del backend: GET /shop/categories (Pública - Sin autenticación)
  /// Respuesta: List<Category>
  /// En prototipo: Usa MockDataService si hay error
  static Future<List<Category>> getCategories() async {
    try {
      final response = await ApiService.getList('shop/categories');
      return response
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Usar mock data en prototipo
      return MockDataService.getCategories();
    }
  }

  /// Obtiene una categoría específica con sus subcategorías
  /// Esperado del backend: GET /shop/categories/{id} (Pública - Sin autenticación)
  /// Respuesta: Category
  static Future<Category> getCategoryById(int id) async {
    try {
      final response = await ApiService.get('shop/categories/$id');
      return Category.fromJson(response);
    } catch (e) {
      // Usar mock data en prototipo
      final category = await MockDataService.getCategoryById(id);
      if (category != null) {
        return category;
      }
      throw Exception('Error loading category: $e');
    }
  }

  /// Obtiene las subcategorías de una categoría específica
  /// Esperado del backend: GET /shop/categories/{id}/products (Pública - Sin autenticación)
  /// Respuesta: List<Category>
  static Future<List<Category>> getSubCategories(int categoryId) async {
    try {
      final response = await ApiService.getList('shop/categories/$categoryId/products');
      return response
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Usar mock data en prototipo
      return MockDataService.getSubCategories(categoryId);
    }
  }
}
