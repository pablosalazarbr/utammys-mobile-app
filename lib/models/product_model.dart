/// Modelo de datos para productos
class Product {
  final int id;
  final int clientId;
  final int? categoryId;
  final String sku;
  final String name;
  final String? description;
  final String? longDescription;
  final List<String>? media;
  final bool isCustomizable;
  final bool isActive;
  final List<ProductSize>? sizes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Legacy fields for compatibility
  final String? imageUrl;
  final double? price;
  final int? stockQuantity;
  final String? material;
  final String? careInstructions;
  final List<ProductOption>? options;

  Product({
    required this.id,
    required this.clientId,
    this.categoryId,
    required this.sku,
    required this.name,
    this.description,
    this.longDescription,
    this.media,
    this.isCustomizable = false,
    this.isActive = true,
    this.sizes,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.price,
    this.stockQuantity,
    this.material,
    this.careInstructions,
    this.options,
  });

  /// Factory constructor para crear un Product desde JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    // Helper para parsear price que puede venir como String o num
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('[Product.fromJson] Error parsing price: $value -> $e');
          return null;
        }
      }
      return null;
    }

    // Helper para parsear media que puede ser Map o List
    List<String>? parseMedia(dynamic value) {
      if (value == null) return null;
      
      print('[Product.fromJson] Raw media: $value (type: ${value.runtimeType})');
      
      List<String> mediaUrls = [];
      
      // Si es un Map, extraer los valores (las rutas)
      if (value is Map<String, dynamic>) {
        for (var path in value.values) {
          if (path is String && path.isNotEmpty) {
            mediaUrls.add(path);
          }
        }
      }
      // Si es una List, usar directamente
      else if (value is List<dynamic>) {
        try {
          for (var item in value) {
            if (item is String && item.isNotEmpty) {
              mediaUrls.add(item);
            }
          }
        } catch (e) {
          print('[Product.fromJson] Error parsing media list: $e');
          return null;
        }
      }
      
      print('[Product.fromJson] Parsed media URLs: $mediaUrls');
      return mediaUrls.isNotEmpty ? mediaUrls : null;
    }

    print('[Product.fromJson] Parsing product: id=${json['id']}, name=${json['name']}, full json keys=${json.keys.toList()}');
    print('[Product.fromJson] Media value: ${json['media']} (type: ${json['media'].runtimeType})');

    return Product(
      id: json['id'] as int,
      clientId: json['client_id'] as int,
      categoryId: json['category_id'] as int?,
      sku: json['sku'] as String? ?? 'SKU-${json['id']}',
      name: json['name'] as String,
      description: json['description'] as String?,
      longDescription: json['long_description'] as String?,
      media: parseMedia(json['media']),
      isCustomizable: json['is_customizable'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      sizes: (json['sizes'] as List<dynamic>?)
          ?.map((item) => ProductSize.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      price: parsePrice(json['price']),
      stockQuantity: json['stock_quantity'] as int? ?? json['stockQuantity'] as int?,
      material: json['material'] as String?,
      careInstructions: json['care_instructions'] as String? ?? json['careInstructions'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((item) => ProductOption.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convierte el Product a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'category_id': categoryId,
      'sku': sku,
      'name': name,
      'description': description,
      'long_description': longDescription,
      'media': media,
      'is_customizable': isCustomizable,
      'is_active': isActive,
      'sizes': sizes?.map((s) => s.toJson()).toList(),
    };
  }

  /// Obtiene la primera imagen del producto con URL completa
  String? getFirstImage() {
    if (media != null && media!.isNotEmpty) {
      final imagePath = media!.first;
      // Si ya es una URL completa, retornar como está
      if (imagePath.startsWith('http')) {
        return imagePath;
      }
      // Si es una ruta relativa, construir URL completa
      // Importar ApiService dinámicamente para evitar dependencias circulares
      return 'http://10.0.2.2:8000$imagePath';
    }
    return null;
  }

  /// Obtiene el precio mínimo entre todos los tamaños
  double? getMinPrice() {
    if (sizes == null || sizes!.isEmpty) return null;
    return sizes!.map((s) => s.price).reduce((a, b) => a < b ? a : b);
  }

  /// Obtiene el precio máximo entre todos los tamaños
  double? getMaxPrice() {
    if (sizes == null || sizes!.isEmpty) return null;
    return sizes!.map((s) => s.price).reduce((a, b) => a > b ? a : b);
  }
}

/// Modelo para tamaños de productos (variantes)
class ProductSize {
  final int id;
  final int productId;
  final String size;
  final String? sku;
  final String? barcode;
  final double price;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductSize({
    required this.id,
    required this.productId,
    required this.size,
    this.sku,
    this.barcode,
    required this.price,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    // Helper para parsear price que puede venir como String o num
    double parsePrice(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('[ProductSize.fromJson] Error parsing price: $value -> $e');
          return 0.0;
        }
      }
      return 0.0;
    }

    print('[ProductSize.fromJson] Parsing: $json');

    return ProductSize(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      size: (json['size'] as String?) ?? 'N/A',
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      price: parsePrice(json['price']),
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'size': size,
      'sku': sku,
      'barcode': barcode,
      'price': price,
      'is_available': isAvailable,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Modelo de opción de producto (legacy, mantener para compatibilidad)
class ProductOption {
  final int id;
  final String name;
  final String description;
  final double price;
  final List<String> details;

  ProductOption({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.details = const [],
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    // Helper para parsear price que puede venir como String o num
    double parsePrice(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('[ProductOption.fromJson] Error parsing price: $value -> $e');
          return 0.0;
        }
      }
      return 0.0;
    }

    return ProductOption(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: parsePrice(json['price']),
      details: List<String>.from(json['details'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'details': details,
    };
  }
}

/// Modelo de item del carrito
class CartItem {
  final Product product;
  final ProductSize? size;
  final int quantity;
  final String? customizationText;
  final double customizationCost;

  CartItem({
    required this.product,
    this.size,
    required this.quantity,
    this.customizationText,
    this.customizationCost = 0.0,
  });

  double getTotalPrice() {
    final price = size?.price ?? product.getMinPrice() ?? 0.0;
    return (price + customizationCost) * quantity;
  }
}
