import 'package:utammys_mobile_app/models/category_model.dart';

/// Servicio de datos simulados para prototipo
/// Simula respuestas de API sin necesidad de conexión real
class MockDataService {
  // Simular delay de red
  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 800));
  }

  /// Obtiene lista de categorías principales
  static Future<List<Category>> getCategories() async {
    await _simulateNetworkDelay();
    
    return [
      Category(
        id: 1,
        name: 'Uniformes Escolares',
        description: 'Uniformes de calidad para instituciones educativas',
        imageUrl: 'assets/images/categorias/uniformes_escolares.jpg',
        children: [
          Category(
            id: 11,
            parentId: 1,
            name: 'Epic',
            imageUrl: 'assets/images/colegios/col_epic.png',
          ),
          Category(
            id: 12,
            parentId: 1,
            name: 'La Preparatoria',
            imageUrl: 'assets/images/colegios/col_lapreparatoria.png',
          ),
          Category(
            id: 13,
            parentId: 1,
            name: 'Metropolitano',
            imageUrl: 'assets/images/colegios/col_metropolitano.png',
          ),
          Category(
            id: 14,
            parentId: 1,
            name: 'Interamericano',
            imageUrl: 'assets/images/colegios/interamericano.png',
          ),
        ],
      ),
      Category(
        id: 2,
        name: 'Uniformes Empresariales',
        description: 'Uniformes profesionales para empresas y negocios',
        imageUrl: 'assets/images/categorias/uniformes_empresariales.jpg',
        children: [
          Category(
            id: 21,
            parentId: 2,
            name: 'Administrativo',
            imageUrl: 'assets/images/colegios/col_epic.png',
          ),
          Category(
            id: 22,
            parentId: 2,
            name: 'Operacional',
            imageUrl: 'assets/images/colegios/col_lapreparatoria.png',
          ),
          Category(
            id: 23,
            parentId: 2,
            name: 'Seguridad',
            imageUrl: 'assets/images/colegios/col_metropolitano.png',
          ),
          Category(
            id: 24,
            parentId: 2,
            name: 'Servicios',
            imageUrl: 'assets/images/colegios/interamericano.png',
          ),
          Category(
            id: 25,
            parentId: 2,
            name: 'Personalizado',
            imageUrl: 'assets/images/categorias/uniformes_empresariales.jpg',
          ),
        ],
      ),
    ];
  }

  /// Obtiene una categoría por ID
  static Future<Category?> getCategoryById(int id) async {
    await _simulateNetworkDelay();
    
    try {
      final categories = await getCategories();
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene subcategorías de una categoría
  static Future<List<Category>> getSubCategories(int categoryId) async {
    await _simulateNetworkDelay();
    
    try {
      final category = await getCategoryById(categoryId);
      return category?.children ?? [];
    } catch (e) {
      return [];
    }
  }
}
