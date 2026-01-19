import 'package:flutter_test/flutter_test.dart';
import 'package:utammys_mobile_app/models/category_model.dart';

void main() {
  group('Category Model Tests', () {
    test('Category.fromJson() deserializa correctamente', () {
      final json = {
        'id': 1,
        'name': 'Uniformes Escolares',
        'description': 'Uniformes para colegios',
        'image_url': 'https://example.com/image.jpg',
        'sub_categories': [
          {
            'id': 1,
            'category_id': 1,
            'name': 'Colegio A',
            'image_url': 'https://example.com/colegio-a.jpg',
          },
          {
            'id': 2,
            'category_id': 1,
            'name': 'Colegio B',
            'image_url': null,
          },
        ],
      };

      final category = Category.fromJson(json);

      expect(category.id, 1);
      expect(category.name, 'Uniformes Escolares');
      expect(category.description, 'Uniformes para colegios');
      expect(category.imageUrl, 'https://example.com/image.jpg');
      expect(category.subCategories.length, 2);
      expect(category.subCategories[0].name, 'Colegio A');
      expect(category.subCategories[1].imageUrl, null);
    });

    test('Category.fromJson() maneja campos faltantes', () {
      final json = {
        'id': 2,
        'name': 'Uniformes Empresariales',
        'sub_categories': [],
      };

      final category = Category.fromJson(json);

      expect(category.id, 2);
      expect(category.name, 'Uniformes Empresariales');
      expect(category.description, ''); // Por defecto vacío
      expect(category.imageUrl, null);
      expect(category.subCategories, []);
    });

    test('Category.toJson() serializa correctamente', () {
      final category = Category(
        id: 1,
        name: 'Uniformes Escolares',
        description: 'Uniformes para colegios',
        imageUrl: 'https://example.com/image.jpg',
        subCategories: [
          SubCategory(
            id: 1,
            categoryId: 1,
            name: 'Colegio A',
            imageUrl: 'https://example.com/colegio-a.jpg',
          ),
        ],
      );

      final json = category.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Uniformes Escolares');
      expect(json['description'], 'Uniformes para colegios');
      expect(json['image_url'], 'https://example.com/image.jpg');
      expect(json['sub_categories'].length, 1);
      expect(json['sub_categories'][0]['name'], 'Colegio A');
    });
  });

  group('SubCategory Model Tests', () {
    test('SubCategory.fromJson() deserializa correctamente', () {
      final json = {
        'id': 1,
        'category_id': 1,
        'name': 'Colegio San José',
        'image_url': 'https://example.com/colegio.jpg',
      };

      final subCategory = SubCategory.fromJson(json);

      expect(subCategory.id, 1);
      expect(subCategory.categoryId, 1);
      expect(subCategory.name, 'Colegio San José');
      expect(subCategory.imageUrl, 'https://example.com/colegio.jpg');
    });

    test('SubCategory.fromJson() maneja image_url nulo', () {
      final json = {
        'id': 2,
        'category_id': 1,
        'name': 'Colegio B',
      };

      final subCategory = SubCategory.fromJson(json);

      expect(subCategory.id, 2);
      expect(subCategory.name, 'Colegio B');
      expect(subCategory.imageUrl, null);
    });

    test('SubCategory.toJson() serializa correctamente', () {
      final subCategory = SubCategory(
        id: 1,
        categoryId: 1,
        name: 'Colegio A',
        imageUrl: 'https://example.com/colegio-a.jpg',
      );

      final json = subCategory.toJson();

      expect(json['id'], 1);
      expect(json['category_id'], 1);
      expect(json['name'], 'Colegio A');
      expect(json['image_url'], 'https://example.com/colegio-a.jpg');
    });
  });

  group('Category Relationships Tests', () {
    test('Category contiene múltiples SubCategories', () {
      final subCategories = [
        SubCategory(
          id: 1,
          categoryId: 1,
          name: 'Colegio A',
        ),
        SubCategory(
          id: 2,
          categoryId: 1,
          name: 'Colegio B',
        ),
        SubCategory(
          id: 3,
          categoryId: 1,
          name: 'Colegio C',
        ),
      ];

      final category = Category(
        id: 1,
        name: 'Uniformes Escolares',
        description: 'Descripción',
        subCategories: subCategories,
      );

      expect(category.subCategories.length, 3);
      expect(category.subCategories.map((sc) => sc.name).toList(),
          ['Colegio A', 'Colegio B', 'Colegio C']);
    });

    test('Todas las SubCategories pertenecen a su Category', () {
      final json = {
        'id': 1,
        'name': 'Uniformes Escolares',
        'description': '',
        'image_url': null,
        'sub_categories': [
          {
            'id': 1,
            'category_id': 1,
            'name': 'Colegio A',
            'image_url': null,
          },
          {
            'id': 2,
            'category_id': 1,
            'name': 'Colegio B',
            'image_url': null,
          },
        ],
      };

      final category = Category.fromJson(json);

      for (var subCategory in category.subCategories) {
        expect(subCategory.categoryId, category.id);
      }
    });
  });

  group('Edge Cases Tests', () {
    test('Category con nombre vacío', () {
      final json = {
        'id': 1,
        'name': '',
        'sub_categories': [],
      };

      final category = Category.fromJson(json);

      expect(category.name, '');
      expect(category.id, 1);
    });

    test('SubCategory con nombres largos', () {
      final longName = 'A' * 100;
      final json = {
        'id': 1,
        'category_id': 1,
        'name': longName,
        'image_url': null,
      };

      final subCategory = SubCategory.fromJson(json);

      expect(subCategory.name, longName);
      expect(subCategory.name.length, 100);
    });

    test('Category round-trip: fromJson -> toJson -> fromJson', () {
      final originalJson = {
        'id': 1,
        'name': 'Uniformes Escolares',
        'description': 'Descripción',
        'image_url': 'https://example.com/image.jpg',
        'sub_categories': [
          {
            'id': 1,
            'category_id': 1,
            'name': 'Colegio A',
            'image_url': 'https://example.com/colegio-a.jpg',
          },
        ],
      };

      final category = Category.fromJson(originalJson);
      final json = category.toJson();
      final categoryFromJson = Category.fromJson(json);

      expect(categoryFromJson.id, category.id);
      expect(categoryFromJson.name, category.name);
      expect(categoryFromJson.description, category.description);
      expect(categoryFromJson.imageUrl, category.imageUrl);
      expect(categoryFromJson.subCategories.length,
          category.subCategories.length);
    });
  });
}
