import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/helpers/image_url_helper.dart';
import 'package:utammys_mobile_app/models/product_model.dart';
import 'package:utammys_mobile_app/services/cart_service.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;
  Map<int, bool> _selectedOptions = {};
  double _additionalPrice = 0;
  ProductSize? _selectedSize;
  int _currentImageIndex = 0;
  
  // Personalización
  late TextEditingController _customizationController;
  static const double _baseCustomizationCost = 25.0;
  static const double _additionalWordCost = 12.5;

  @override
  void initState() {
    super.initState();
    _customizationController = TextEditingController();
    // Inicializar opciones desseleccionadas
    if (widget.product.options != null) {
      for (var option in widget.product.options!) {
        _selectedOptions[option.id] = false;
      }
    }
    // Seleccionar la primera talla disponible por defecto
    if (widget.product.sizes != null && widget.product.sizes!.isNotEmpty) {
      _selectedSize = widget.product.sizes!.first;
    }
  }

  @override
  void dispose() {
    _customizationController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    _additionalPrice = 0;
    if (widget.product.options != null) {
      for (var option in widget.product.options!) {
        if (_selectedOptions[option.id] ?? false) {
          _additionalPrice += option.price;
        }
      }
    }
    // Agregar costo de personalización
    if (widget.product.isCustomizable) {
      _additionalPrice += _getCustomizationCost();
    }
  }

  int _getCustomizationWordCount() {
    final text = _customizationController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  double _getCustomizationCost() {
    final wordCount = _getCustomizationWordCount();
    if (wordCount == 0) return 0.0;
    if (wordCount <= 2) return _baseCustomizationCost;
    // Palabras adicionales cobran Q12.50 c/u
    final additionalWords = wordCount - 2;
    return _baseCustomizationCost + (additionalWords * _additionalWordCost);
  }

  double getTotalPrice() {
    final basePrice = _selectedSize?.price ?? widget.product.price ?? widget.product.getMinPrice() ?? 0.0;
    return ((basePrice + _additionalPrice) * _quantity);
  }

  String _getImageUrl(String? mediaPath) {
    final url = ImageUrlHelper.buildImageUrl(mediaPath, useEmulator: false);
    print('[ProductDetailScreen] Building image URL for: $mediaPath => Final URL: $url');
    return url;
  }

  Widget _buildProductImage() {
    // Mostrar imagen del media si existe
    if (widget.product.media != null && widget.product.media!.isNotEmpty) {
      if (_currentImageIndex < widget.product.media!.length) {
        final mediaPath = widget.product.media![_currentImageIndex];
        final imageUrl = _getImageUrl(mediaPath);
        print('[ProductDetailScreen] ============================================');
        print('[ProductDetailScreen] CARGANDO IMAGEN DEL PRODUCTO');
        print('[ProductDetailScreen] Producto: ${widget.product.name} (ID: ${widget.product.id})');
        print('[ProductDetailScreen] Índice de imagen: $_currentImageIndex');
        print('[ProductDetailScreen] Media path: $mediaPath');
        print('[ProductDetailScreen] URL final: $imageUrl');
        print('[ProductDetailScreen] ============================================');
        
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            print('[ProductDetailScreen] Cargando: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('[ProductDetailScreen] ❌ ERROR CARGANDO IMAGEN');
            print('[ProductDetailScreen] Error tipo: ${error.runtimeType}');
            print('[ProductDetailScreen] Error mensaje: $error');
            print('[ProductDetailScreen] Stack trace: $stackTrace');
            return Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey[400],
            );
          },
        );
      }
    }
    
    // Fallback a imageUrl o a icono
    if (widget.product.imageUrl != null) {
      return Image.asset(
        widget.product.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey[400],
          );
        },
      );
    }
    
    return Icon(
      Icons.image_not_supported,
      size: 64,
      color: Colors.grey[400],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: _isFavorite ? TammysColors.primary : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal del producto
            Container(
              width: double.infinity,
              height: 400,
              color: Colors.grey[100],
              child: Stack(
                children: [
                  Center(
                    child: _buildProductImage(),
                  ),
                  // Navigation arrows (opcional)
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_currentImageIndex > 0) {
                              _currentImageIndex--;
                              print('[ProductDetailScreen] ◀️  Imagen anterior: $_currentImageIndex');
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_left, size: 24),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (widget.product.media != null &&
                                _currentImageIndex < widget.product.media!.length - 1) {
                              _currentImageIndex++;
                              print('[ProductDetailScreen] ▶️  Imagen siguiente: $_currentImageIndex');
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_right, size: 24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Indicador de imágenes (1 de 3, etc)
            if (widget.product.media != null && widget.product.media!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    '${_currentImageIndex + 1} de ${widget.product.media!.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Información del producto
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '5.0 (${widget.product.stockQuantity ?? widget.product.sizes?.length ?? 0} opciones)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Precio dinámico según talla
                  if (_selectedSize != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SKU: ${_selectedSize!.sku}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Q${(_selectedSize!.price ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: TammysColors.primary,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Q${(widget.product.price ?? widget.product.getMinPrice() ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: TammysColors.primary,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Descripción corta
                  if (widget.product.description != null)
                    Text(
                      widget.product.description ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Long Description (Detalles)
                  if (widget.product.longDescription != null && widget.product.longDescription!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.longDescription ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Stock status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'In Stock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Material
                  if (widget.product.material != null)
                    _buildInfoSection('Material', widget.product.material),

                  const SizedBox(height: 16),

                  // Cuidados
                  if (widget.product.careInstructions != null)
                    _buildInfoSection('Cuidados', widget.product.careInstructions),

                  const SizedBox(height: 24),

                  // Selección de Tallas
                  if (widget.product.sizes != null && widget.product.sizes!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selecciona una Talla',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: widget.product.sizes!.map((size) {
                            final isSelected = _selectedSize?.id == size.id;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSize = size;
                                  _updateTotal();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? TammysColors.primary : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected ? TammysColors.primary.withOpacity(0.1) : Colors.white,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      size.size,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.black : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Personalización de texto (bordado/grabado)
                  if (widget.product.isCustomizable)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.blue[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info, color: Colors.blue[700], size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Personaliza tu Prenda (${_getCustomizationCost() > 0 ? '+Q${_getCustomizationCost().toStringAsFixed(2)}' : '+Q25.00'})',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Borda 1 Nombre y 1 Apellido ó 2 Apellidos',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                        Text(
                                          'Palabras adicionales: Q12.50 c/u',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _customizationController,
                                onChanged: (value) {
                                  setState(() {
                                    _updateTotal();
                                  });
                                },
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Ej: Juan Salazar',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(color: TammysColors.primary, width: 2),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                              ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Costo adicional: Q${(_getCustomizationCost() - _baseCustomizationCost).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Opciones de personalización
                  if (widget.product.options != null && widget.product.options!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personaliza tu Prenda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...(widget.product.options ?? []).map((option) {
                          return _buildOptionCheckbox(option);
                        }).toList(),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Selector de cantidad
                  Row(
                    children: [
                      const Text(
                        'Cantidad',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () {
                                setState(() {
                                  if (_quantity > 1) _quantity--;
                                });
                              },
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$_quantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Resumen de compra
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_quantity}x ${widget.product.name.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Q${getTotalPrice().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TammysColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_selectedSize == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor selecciona una talla'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                
                // Crear CartItem y agregarlo al carrito
                final customizationText = _customizationController.text.trim();
                final cartItem = CartItem(
                  product: widget.product,
                  size: _selectedSize,
                  quantity: _quantity,
                  customizationText: customizationText.isNotEmpty ? customizationText : null,
                  customizationCost: customizationText.isNotEmpty ? _getCustomizationCost() : 0.0,
                );
                
                // Usar CartService para agregar al carrito
                CartService().addItem(cartItem);
                
                // Mostrar confirmación con personalización si aplica
                String message = 'Añadido al carrito: ${_quantity}x ${widget.product.name} - Talla: ${_selectedSize!.size}';
                if (customizationText.isNotEmpty) {
                  message += '\nPersonalización: $customizationText (+Q${_getCustomizationCost().toStringAsFixed(2)})';
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Añadir al Carrito | Q${getTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String? content) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCheckbox(ProductOption option) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedOptions[option.id] = !(_selectedOptions[option.id] ?? false);
              _updateTotal();
            });
          },
          child: Row(
            children: [
              Checkbox(
                value: _selectedOptions[option.id] ?? false,
                onChanged: (value) {
                  setState(() {
                    _selectedOptions[option.id] = value ?? false;
                    _updateTotal();
                  });
                },
                activeColor: TammysColors.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      option.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '(+Q${option.price.toStringAsFixed(2)})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TammysColors.primary,
                ),
              ),
            ],
          ),
        ),
        if (option.details.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: option.details
                  .map(
                    (detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}
