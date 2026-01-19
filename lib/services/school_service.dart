import 'package:utammys_mobile_app/models/school_model.dart';
import 'package:utammys_mobile_app/services/api_service.dart';

class SchoolService {
  /// Obtiene todos los colegios (clientes) disponibles
  static Future<List<School>> getSchools() async {
    try {
      final response = await ApiService.getList('shop/clients');
      return response
          .map((item) => School.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching schools: $e');
    }
  }

  /// Obtiene los detalles de un colegio específico
  static Future<School> getSchoolById(int id) async {
    try {
      final response = await ApiService.get('shop/clients/$id');
      return School.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching school: $e');
    }
  }

  /// Busca colegios por nombre (búsqueda local)
  static Future<List<School>> searchSchools(String query) async {
    try {
      final schools = await getSchools();
      final lowerQuery = query.toLowerCase();
      return schools
          .where((school) =>
              school.name.toLowerCase().contains(lowerQuery) ||
              (school.city?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();
    } catch (e) {
      throw Exception('Error searching schools: $e');
    }
  }

  /// Obtiene colegios por tipo
  static Future<List<School>> getSchoolsByType(String type) async {
    try {
      final schools = await getSchools();
      return schools
          .where((school) => school.type.toUpperCase() == type.toUpperCase())
          .toList();
    } catch (e) {
      throw Exception('Error fetching schools by type: $e');
    }
  }
}
