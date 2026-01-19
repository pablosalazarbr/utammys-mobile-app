# Ejemplos de Integración por Pantalla

Este documento contiene fragmentos de código listos para usar en tus pantallas actuales.

## 1. ProductDetailScreen - Mostrar detalles con nuevos campos

```dart
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/models/product_model.dart';
import 'package:utammys_mobile_app/services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final int clientId;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.clientId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedSizeIndex = 0;
  int quantity = 1;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final selectedSize = product.sizes?.isNotEmpty ?? false 
        ? product.sizes![selectedSizeIndex] 
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name ?? 'Producto'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal
            if (product.media != null && product.media!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[200],
                child: Image.network(
                  product.media!.first.url ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.image_not_supported, 
                          size: 64, color: Colors.grey[400]),
                    );
                  },
                ),
              ),

            // Detalles del producto
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y código
                  Text(
                    product.name ?? 'Producto',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (product.sku != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'SKU: ${product.sku}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Descripción
                  if (product.description != null)
                    Text(
                      product.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                  const SizedBox(height: 24),

                  // Selector de talla
                  if (product.sizes != null && product.sizes!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona Talla',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: List.generate(
                            product.sizes!.length,
                            (index) => GestureDetector(
                              onTap: product.sizes![index].isAvailable ?? true
                                  ? () => setState(() => selectedSizeIndex = index)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedSizeIndex == index
                                        ? Colors.blue
                                        : Colors.grey,
                                    width: selectedSizeIndex == index ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: (product.sizes![index].isAvailable ?? true)
                                      ? Colors.white
                                      : Colors.grey[100],
                                ),
                                child: Text(
                                  product.sizes![index].size ?? 'N/A',
                                  style: TextStyle(
                                    fontWeight: selectedSizeIndex == index
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: (product.sizes![index].isAvailable ?? true)
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Precio
                  if (selectedSize != null)
                    Text(
                      'Q${selectedSize.price?.toStringAsFixed(2) ?? '0.00'}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Cantidad
                  Row(
                    children: [
                      Text(
                        'Cantidad:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        quantity.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Botón agregar al carrito
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedSize == null || isLoading
                          ? null
                          : () => _addToCart(selectedSize!),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Agregar al Carrito'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(ProductSize size) async {
    setState(() => isLoading = true);

    try {
      // Crear item del carrito
      final cartItem = CartItem(
        product: widget.product,
        size: size,
        quantity: quantity,
      );

      // Aquí puedes hacer algo con el item
      // Por ahora, solo mostrar un snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} agregado al carrito'),
          action: SnackBarAction(
            label: 'Ver carrito',
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ),
      );

      // Opcional: Volver a pantalla anterior
      Navigator.pop(context, cartItem);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
```

## 2. HomePage - Grid de productos destacados

```dart
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/models/product_model.dart';
import 'package:utammys_mobile_app/services/product_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    // Obtener productos destacados (random)
    futureProducts = ProductService.getRandomProducts(8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utammys Shop'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner de bienvenida
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Explora nuestros productos'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Botón para buscar colegio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/school-search'),
                icon: const Icon(Icons.school),
                label: const Text('Buscar Colegio'),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Grid de productos destacados
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            futureProducts = ProductService.getRandomProducts(8);
                          }),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay productos disponibles',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a detalle
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              clientId: 1, // ← Ajustar según tu lógica
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: product.getFirstImage() != null
                    ? Image.network(
                        product.getFirstImage()!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Producto',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  if (product.sizes != null && product.sizes!.isNotEmpty)
                    Text(
                      'Q${product.getMinPrice().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 3. CategoriesScreen - Mostrar categorías jerárquicas

```dart
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/models/category_model.dart';
import 'package:utammys_mobile_app/services/product_service.dart';

class CategoriesScreen extends StatefulWidget {
  final int clientId;

  const CategoriesScreen({
    Key? key,
    required this.clientId,
  }) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Category>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories = ProductService.getCategoriesTree();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: FutureBuilder<List<Category>>(
        future: futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      futureCategories = ProductService.getCategoriesTree();
                    }),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data ?? [];

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return CategoryTile(
                category: categories[index],
                clientId: widget.clientId,
              );
            },
          );
        },
      ),
    );
  }
}

class CategoryTile extends StatefulWidget {
  final Category category;
  final int clientId;

  const CategoryTile({
    Key? key,
    required this.category,
    required this.clientId,
  }) : super(key: key);

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.category.children?.isNotEmpty ?? false;

    return Column(
      children: [
        ListTile(
          title: Text(widget.category.name ?? 'Categoría'),
          trailing: hasChildren
              ? Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                )
              : null,
          onTap: () {
            if (hasChildren) {
              setState(() => isExpanded = !isExpanded);
            }
          },
        ),
        if (isExpanded && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: (widget.category.children ?? [])
                  .map(
                    (child) => CategoryTile(
                      category: child,
                      clientId: widget.clientId,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
```

## 4. BarcodeSearchScreen - Buscar por código de barras

```dart
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/services/product_service.dart';
import 'package:utammys_mobile_app/models/product_model.dart';

class BarcodeSearchScreen extends StatefulWidget {
  const BarcodeSearchScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeSearchScreen> createState() => _BarcodeSearchScreenState();
}

class _BarcodeSearchScreenState extends State<BarcodeSearchScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  Product? _foundProduct;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _searchByBarcode() async {
    final barcode = _barcodeController.text.trim();

    if (barcode.isEmpty) {
      setState(() => _errorMessage = 'Ingresa un código de barras');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _foundProduct = null;
    });

    try {
      final product = await ProductService.searchByBarcode(barcode);
      setState(() => _foundProduct = product);
    } catch (e) {
      setState(() => _errorMessage = 'Producto no encontrado: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar por Código')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Código de Barras',
                border: OutlineInputBorder(),
                suffixIcon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchByBarcode,
                      ),
              ),
              onSubmitted: (_) => _searchByBarcode(),
            ),

            const SizedBox(height: 24),

            // Mensaje de error
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),

            // Producto encontrado
            if (_foundProduct != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _foundProduct!.name ?? 'Producto',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (_foundProduct!.sku != null)
                        Text('SKU: ${_foundProduct!.sku}'),
                      const SizedBox(height: 12),
                      if (_foundProduct!.sizes != null)
                        Text(
                          'Precio: Q${_foundProduct!.getMinPrice()}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Navegar a detalle
                        },
                        child: const Text('Ver Detalles'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

## 5. OrderHistoryScreen - Mostrar órdenes previas

```dart
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/services/order_service.dart';
import 'package:utammys_mobile_app/models/order_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Map<String, dynamic>>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = OrderService.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Órdenes')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text('No tienes órdenes aún'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Orden #${order['id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Total: Q${order['total']}'),
                      Text('Estado: ${order['status']}'),
                    ],
                  ),
                  onTap: () {
                    // Ver detalles de orden
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

**Estos ejemplos cubren los casos más comunes. Ajústalos según tu estructura actual de pantallas.**
