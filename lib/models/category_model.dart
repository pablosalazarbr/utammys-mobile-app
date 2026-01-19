/// Modelo de datos para categorías de productos
class Category {
  final int id;
  final String name;
  final String? description;
  final int? parentId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Category>? children;
  final String? imageUrl;
  final List<Category>? subCategories;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.children,
    this.imageUrl,
    this.subCategories,
  });

  /// Factory constructor para crear una Category desde JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentId: json['parent_id'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      children: (json['children'] as List<dynamic>?)
          ?.map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList(),
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      subCategories: (json['sub_categories'] as List<dynamic>? ?? json['subCategories'] as List<dynamic>?)
          ?.map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convierte la Category a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent_id': parentId,
      'is_active': isActive,
      'image_url': imageUrl,
      'children': children?.map((c) => c.toJson()).toList(),
      'sub_categories': subCategories?.map((c) => c.toJson()).toList(),
    };
  }
}

/// Modelo de datos para subcategorías (legacy, mantener para compatibilidad)
class SubCategory {
  final int id;
  final int categoryId;
  final String name;
  final String? imageUrl;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    this.imageUrl,
  });

  /// Factory constructor para crear un SubCategory desde JSON
  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Convierte el SubCategory a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'image_url': imageUrl,
    };
  }
}
