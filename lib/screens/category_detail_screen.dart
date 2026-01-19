import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/models/category_model.dart';
import 'package:utammys_mobile_app/models/school_model.dart';
import 'package:utammys_mobile_app/screens/school_products_screen.dart';
import 'package:utammys_mobile_app/services/category_service.dart';
import 'package:utammys_mobile_app/services/product_service.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<List<Category>> _subCategoriesFuture;
  late Future<List<School>> _schoolsFuture;
  bool _isSchoolCategory = false;

  @override
  void initState() {
    super.initState();
    // Detectar si es categoría de uniformes escolares
    _isSchoolCategory = widget.category.name.toLowerCase().contains('escolar') ||
        widget.category.name.toLowerCase().contains('colegio');

    if (_isSchoolCategory) {
      _schoolsFuture = ProductService.getSchools();
    } else {
      _subCategoriesFuture =
          CategoryService.getSubCategories(widget.category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TammysColors.background,
        foregroundColor: TammysColors.primary,
        title: Text(
          widget.category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: false,
      ),
      body: _isSchoolCategory
          ? _buildSchoolsView(context)
          : _buildSubCategoriesView(context),
    );
  }

  Widget _buildSchoolsView(BuildContext context) {
    return FutureBuilder<List<School>>(
      future: _schoolsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('[CategoryDetailScreen] Loading schools...');
          return const LoadingWidget(
            message: 'Cargando colegios...',
          );
        }

        if (snapshot.hasError) {
          print('[CategoryDetailScreen] Error loading schools: ${snapshot.error}');
          print('[CategoryDetailScreen] StackTrace: ${snapshot.stackTrace}');
          return ErrorDisplay(
            message: 'No se pudieron cargar los colegios',
            onRetry: () {
              setState(() {
                _schoolsFuture = ProductService.getSchools();
              });
            },
          );
        }

        final schools = snapshot.data ?? [];

        if (schools.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay colegios disponibles',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.category.imageUrl ?? 'assets/images/utamys_white_bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(TammysDimensions.paddingLarge),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.category.description != null && widget.category.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.category.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(TammysDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecciona un colegio',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TammysColors.primary,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: TammysDimensions.paddingMedium),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: TammysDimensions.paddingMedium,
                        mainAxisSpacing: TammysDimensions.paddingMedium,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: schools.length,
                      itemBuilder: (context, index) {
                        final school = schools[index];
                        return _buildSchoolCard(context, school);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubCategoriesView(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _subCategoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(
            message: 'Cargando opciones...',
          );
        }

        if (snapshot.hasError) {
          return ErrorDisplay(
            message: 'No se pudieron cargar las opciones',
            onRetry: () {
              setState(() {
                _subCategoriesFuture =
                    CategoryService.getSubCategories(widget.category.id);
              });
            },
          );
        }

        final subCategories = snapshot.data ?? [];

        if (subCategories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay subcategorías disponibles',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de categoría
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.category.imageUrl ?? 'assets/images/utamys_white_bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(TammysDimensions.paddingLarge),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.category.description != null && widget.category.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.category.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Contenido
              Padding(
                padding: const EdgeInsets.all(TammysDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecciona una opción',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TammysColors.primary,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: TammysDimensions.paddingMedium),
                    // Grid de opciones
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: TammysDimensions.paddingMedium,
                        mainAxisSpacing: TammysDimensions.paddingMedium,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: subCategories.length,
                      itemBuilder: (context, index) {
                        final subCategory = subCategories[index];
                        return _buildSubCategoryCard(
                          context,
                          subCategory,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchoolCard(BuildContext context, School school) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchoolProductsScreen(school: school),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TammysDimensions.borderRadius),
          border: Border.all(
            color: TammysColors.borderColor,
            width: 1.5,
          ),
          color: TammysColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(TammysDimensions.borderRadius),
                    topRight: Radius.circular(TammysDimensions.borderRadius),
                  ),
                  color: Colors.grey[200],
                ),
                child: school.logoUrl != null && school.logoUrl!.isNotEmpty
                    ? Image.network(
                      _getImageUrl(school.logoUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('[SchoolCard] Error loading logo: $error');
                        return Center(
                          child: Icon(
                            Icons.school,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                    : Center(
                      child: Icon(
                        Icons.school,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(TammysDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: TammysColors.primary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: TammysColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Ver productos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TammysColors.accent,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
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

  Widget _buildSubCategoryCard(BuildContext context, Category subCategory) {
    return GestureDetector(
      onTap: () {
        // TODO: Navegar a la pantalla de productos de esta subcategoría
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Productos de: ${subCategory.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TammysDimensions.borderRadius),
          border: Border.all(
            color: TammysColors.borderColor,
            width: 1.5,
          ),
          color: TammysColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(TammysDimensions.borderRadius),
                    topRight: Radius.circular(TammysDimensions.borderRadius),
                  ),
                  image: DecorationImage(
                    image: AssetImage(subCategory.imageUrl ?? 'assets/images/utamys_white_bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(TammysDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subCategory.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: TammysColors.primary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: TammysColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Ver productos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TammysColors.accent,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
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

  /// Procesa URLs del API (reemplaza localhost con 10.0.2.2 para emulador)
  String _getImageUrl(String logoUrl) {
    if (logoUrl.isEmpty) {
      return '';
    }
    
    // Si ya es una URL completa con localhost, reemplazar por 10.0.2.2
    if (logoUrl.startsWith('http://localhost:8000')) {
      print('[SchoolCard] Converting localhost URL to emulator URL');
      return logoUrl.replaceFirst('http://localhost:8000', 'http://10.0.2.2:8000');
    }
    
    // Si ya es una URL completa con 10.0.2.2, devolverla tal cual
    if (logoUrl.startsWith('http://10.0.2.2:8000')) {
      print('[SchoolCard] URL already using emulator address');
      return logoUrl;
    }
    
    // Si es una ruta relativa, construir URL
    if (logoUrl.startsWith('/')) {
      print('[SchoolCard] Converting relative path to full URL');
      return 'http://10.0.2.2:8000$logoUrl';
    }
    
    // Caso por defecto: asumir URL relativa sin /
    print('[SchoolCard] Adding host to relative path');
    return 'http://10.0.2.2:8000/$logoUrl';
  }
}
