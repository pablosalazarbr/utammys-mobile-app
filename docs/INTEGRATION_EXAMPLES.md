# Ejemplos de Integración - Utammys Mobile App

## 1. Actualizar main.dart para incluir nuevas pantallas

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:utammys_mobile_app/screens/school_search_screen.dart';
import 'package:utammys_mobile_app/screens/cart_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Utammys Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/school-search': (context) => const SchoolSearchScreen(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utammys Shop'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/school-search');
              },
              icon: const Icon(Icons.school),
              label: const Text('Buscar Colegio y Comprar'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Mi Carrito'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 2. Usar SchoolService en una pantalla existente

```dart
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/services/school_service.dart';
import 'package:utammys_mobile_app/models/school_model.dart';

class SchoolListExample extends StatefulWidget {
  const SchoolListExample({Key? key}) : super(key: key);

  @override
  State<SchoolListExample> createState() => _SchoolListExampleState();
}

class _SchoolListExampleState extends State<SchoolListExample> {
  late Future<List<School>> _schoolsFuture;

  @override
  void initState() {
    super.initState();
    _schoolsFuture = SchoolService.getSchools();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<School>>(
      future: _schoolsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final schools = snapshot.data ?? [];

        return ListView.builder(
          itemCount: schools.length,
          itemBuilder: (context, index) {
            final school = schools[index];
            return ListTile(
              title: Text(school.name),
              subtitle: Text(school.city ?? 'Sin ciudad'),
              trailing: Chip(label: Text(school.type)),
            );
          },
        );
      },
    );
  }
}
```

## 3. Obtener productos de un cliente y mostrar en grid

```dart
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/services/product_service.dart';
import 'package:utammys_mobile_app/models/product_model.dart';

class ProductsGridExample extends StatefulWidget {
  final int clientId;

  const ProductsGridExample({
    Key? key,
    required this.clientId,
  }) : super(key: key);

  @override
  State<ProductsGridExample> createState() => _ProductsGridExampleState();
}

class _ProductsGridExampleState extends State<ProductsGridExample> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.getClientProducts(widget.clientId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final products = snapshot.data ?? [];

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${product.sku}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        if (product.sizes != null && product.sizes!.isNotEmpty)
                          Text(
                            'Q${product.getMinPrice()?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
```

## 4. Ejemplo de envío de orden con OrderService

```dart
import 'package:utammys_mobile_app/services/order_service.dart';
import 'package:utammys_mobile_app/models/product_model.dart';

class OrderSubmissionExample {
  static Future<void> submitOrder(
    List<CartItem> cartItems,
    String name,
    String email,
    String phone,
    String address,
    int clientId,
  ) async {
    // Construir payload para la API
    final orderData = {
      'client_id': clientId,
      'customer_name': name,
      'customer_email': email,
      'customer_phone': phone,
      'delivery_address': address,
      'items': cartItems.map((item) => {
        'product_id': item.product.id,
        'product_size_id': item.size?.id,
        'quantity': item.quantity,
        'unit_price': item.size?.price ?? item.product.getMinPrice(),
      }).toList(),
      'total': cartItems.fold<double>(0, (sum, item) => sum + item.getTotalPrice()),
    };

    try {
      final result = await OrderService.completeOrder(orderData);
      print('Orden creada: ${result['id']}');
      print('Referencia: ${result['reference']}');
    } catch (e) {
      print('Error al crear orden: $e');
      rethrow;
    }
  }
}
```

## 5. Buscar productos por categoría

```dart
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/services/product_service.dart';
import 'package:utammys_mobile_app/models/category_model.dart';

class CategoriesExample extends StatefulWidget {
  const CategoriesExample({Key? key}) : super(key: key);

  @override
  State<CategoriesExample> createState() => _CategoriesExampleState();
}

class _CategoriesExampleState extends State<CategoriesExample> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ProductService.getCategoriesTree();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final categories = snapshot.data ?? [];

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ExpansionTile(
              title: Text(category.name),
              subtitle: Text(category.description ?? ''),
              children: [
                if (category.children != null)
                  ...category.children!.map((subcat) => ListTile(
                    title: Text('  ${subcat.name}'),
                    onTap: () {
                      // Cargar productos de esta categoría
                    },
                  )),
              ],
            );
          },
        );
      },
    );
  }
}
```

## 6. Manejo de errores mejorado

```dart
class ApiErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString();
      if (errorString.contains('Failed host lookup')) {
        return 'Sin conexión a internet';
      } else if (errorString.contains('Connection refused')) {
        return 'No se puede conectar al servidor';
      } else if (errorString.contains('SocketException')) {
        return 'Error de conexión de red';
      }
      return errorString.replaceAll('Exception: ', '');
    }
    return 'Error desconocido';
  }

  static Widget buildErrorWidget({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
```

## 7. Configuración para diferentes entornos

```dart
// config/api_config.dart
class ApiConfig {
  static String baseUrl = _getBaseUrl();

  static String _getBaseUrl() {
    const String environment = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    
    switch (environment) {
      case 'prod':
        return 'https://api.utammys.com/api';
      case 'staging':
        return 'https://staging-api.utammys.com/api';
      default:
        return 'http://localhost:8000/api';
    }
  }
}

// Usar en ApiService.dart
static String getBaseUrl() {
  return dotenv.env['API_BASE_URL'] ?? ApiConfig.baseUrl;
}
```

## 8. Agregar caching de imágenes (opcional)

En `pubspec.yaml`:
```yaml
dependencies:
  cached_network_image: ^3.3.0
```

En tu código:
```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => Container(
    color: Colors.grey[200],
    child: const CircularProgressIndicator(),
  ),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```
