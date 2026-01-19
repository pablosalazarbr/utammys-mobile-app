/// Modelo de datos para colegios/escuelas (Clientes en la API)
class School {
  final int id;
  final String name;
  final String type; // ESCOLAR, EMPRESARIAL
  final String? city;
  final String? logoUrl;
  final String? email;
  final String? phone;
  final String? address;
  final String? country;
  final String? contactPerson;
  final String? taxId;
  final String? paymentTerms;
  final double? creditLimit;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  School({
    required this.id,
    required this.name,
    required this.type,
    this.city,
    this.logoUrl,
    this.email,
    this.phone,
    this.address,
    this.country,
    this.contactPerson,
    this.taxId,
    this.paymentTerms,
    this.creditLimit,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor para crear un School desde JSON
  factory School.fromJson(Map<String, dynamic> json) {
    // Helper para parsear credit_limit que puede venir como String o num
    double? parseCreditLimit(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('[School.fromJson] Error parsing credit_limit: $value -> $e');
          return null;
        }
      }
      return null;
    }

    return School(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['category'] as String? ?? json['type'] as String? ?? 'ESCOLAR',
      city: json['city'] as String?,
      logoUrl: json['logo_url'] as String? ?? json['imageUrl'] as String? ?? json['logo'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      contactPerson: json['contact_person'] as String?,
      taxId: json['tax_id'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      creditLimit: parseCreditLimit(json['credit_limit']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  /// Convierte el School a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'city': city,
      'logo_url': logoUrl,
      'email': email,
      'phone': phone,
      'address': address,
      'country': country,
      'contact_person': contactPerson,
      'tax_id': taxId,
      'payment_terms': paymentTerms,
      'credit_limit': creditLimit,
      'is_active': isActive,
    };
  }

  /// Getter para compatibilidad con código legacy
  String? get imageUrl => logoUrl;
}
