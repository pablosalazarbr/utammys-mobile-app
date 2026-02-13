import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/helpers/image_url_helper.dart';
import 'package:utammys_mobile_app/models/product_model.dart';
import 'package:utammys_mobile_app/models/school_model.dart';
import 'package:utammys_mobile_app/screens/product_detail_screen.dart';
import 'package:utammys_mobile_app/services/product_service.dart';
import 'package:utammys_mobile_app/services/cart_service.dart';
import 'package:utammys_mobile_app/widgets/custom_bottom_nav_bar.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';

class SchoolProductsScreen extends StatefulWidget {
  final School school;

  const SchoolProductsScreen({
    super.key,
    required this.school,
  });

  @override
  State<SchoolProductsScreen> createState() => _SchoolProductsScreenState();
}

class _SchoolProductsScreenState extends State<SchoolProductsScreen> {
  late Future<List<Product>> _productsFuture;
  int _currentNavIndex = 1; // Search tab (since we're in school products from search)

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.getClientProducts(widget.school.id);
  }

  void _handleNavigation(int index) {
    if (index == _currentNavIndex) return;
    
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, '/school-search', (route) => false);
        break;
      case 2:
        Navigator.pushNamed(context, '/cart');
        break;
    }
  }

  String _getImageUrl(String? mediaPath) {
    if (mediaPath == null || mediaPath.isEmpty) {
      print('[SchoolProductsScreen] ADVERTENCIA: mediaPath vacío o nulo');
      return 'https://via.placeholder.com/300x400?text=Sin+Imagen';
    }
    
    final url = ImageUrlHelper.buildImageUrl(mediaPath);
    print('[SchoolProductsScreen] URL generada para "$mediaPath" => "$url"');
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: TammysColors.background,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TammysColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.school.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: TammysColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Cargando productos...');
          }

          if (snapshot.hasError) {
            return ErrorLoadingWidget(
              message: 'Error al cargar productos: ${snapshot.error}',
              onRetry: () {
                setState(() {
                  _productsFuture = ProductService.getClientProducts(widget.school.id);
                });
              },
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.6,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                imageUrl: _getImageUrl(products[index].media?.first ?? products[index].getFirstImage()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        product: products[index],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
        cartItemCount: CartService().totalQuantity,
      ),
    );
  }
}

/// Widget para mostrar una tarjeta de producto
class ProductCard extends StatefulWidget {
  final Product product;
  final String imageUrl;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Builder(
                        builder: (context) {
                          final imageUrl = widget.imageUrl;
                          print('[ProductCard] Renderizando imagen: $imageUrl');
                          print('[ProductCard] Producto: ${widget.product.name}, ID: ${widget.product.id}');
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              print('[ProductCard] Cargando imagen... ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('[ProductCard] ERROR cargando imagen: $error');
                              print('[ProductCard] Stack trace: $stackTrace');
                              return Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: 40,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Botón de favorito
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_outline,
                            color: _isFavorite ? TammysColors.primary : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    // Stock badge
                    if (!widget.product.isActive)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Inactivo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Información del producto
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star_half,
                        size: 14,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '5.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${widget.product.sizes?.length ?? 0} tallas)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.product.sizes != null && widget.product.sizes!.isNotEmpty)
                    Text(
                      'Q${widget.product.getMinPrice()?.toStringAsFixed(2) ?? '0.00'} - Q${widget.product.getMaxPrice()?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TammysColors.primary,
                      ),
                    )
                  else
                    Text(
                      'Precio no disponible',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
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
