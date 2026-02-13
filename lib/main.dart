import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:utammys_mobile_app/models/category_model.dart';
import 'package:utammys_mobile_app/models/school_model.dart';
import 'package:utammys_mobile_app/screens/school_search_screen.dart';
import 'package:utammys_mobile_app/screens/school_products_screen.dart';
import 'package:utammys_mobile_app/screens/cart_screen.dart';
import 'package:utammys_mobile_app/services/school_service.dart';
import 'package:utammys_mobile_app/services/cart_service.dart';
import 'package:utammys_mobile_app/widgets/custom_bottom_nav_bar.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Uniformes Tamys",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: TammysColors.primary),
        useMaterial3: true,
        fontFamily: 'OpenSans',
        scaffoldBackgroundColor: TammysColors.background,
      ),
      home: const HomePage(),
      routes: {
        '/school-search': (context) => const SchoolSearchScreen(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<School>> _popularSchoolsFuture;
  int _selectedBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _popularSchoolsFuture = SchoolService.getRandomSchools(limit: 4);
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
    
    // Navigate based on index
    switch (index) {
      case 0:
        // Home (current)
        break;
      case 1:
        // Search schools
        Navigator.pushNamed(context, '/school-search');
        break;
      case 2:
        // Cart
        Navigator.pushNamed(context, '/cart');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TammysColors.background,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation Bar (Editorial style)
            _buildTopNavBar(),
            
            // Hero Section
            _buildHeroSection(),
            
            // Categories Section
            _buildCategoriesSection(),
            
            // Popular Schools Section
            _buildPopularSchoolsSection(),
            
            // Trust Section
            _buildTrustSection(),
            
            // Bottom padding for navigation bar
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedBottomIndex,
        onTap: _handleNavigation,
        cartItemCount: CartService().totalQuantity,
      ),
    );
  }

  void _handleNavigation(int index) {
    if (index == _selectedBottomIndex) return;
    
    switch (index) {
      case 0:
        // Home (current)
        break;
      case 1:
        Navigator.pushNamed(context, '/school-search');
        break;
      case 2:
        Navigator.pushNamed(context, '/cart');
        break;
    }
  }

  Widget _buildTopNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TammysColors.background,
        border: Border(
          bottom: BorderSide(
            color: TammysColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo/Brand (centered)
          Image.asset(
            'assets/images/utamys_horizontal.png',
            height: 30,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: TammysColors.lightGrey,
        image: DecorationImage(
          image: const AssetImage('assets/images/categorias/school_header.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.grey.withOpacity(0.6),
            BlendMode.multiply,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Uniformes de Calidad Premium',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Diseñados con confort y durabilidad',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/school-search');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: TammysColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Ver Catálogo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    // Categorías hardcodeadas: Solo Escolares y Empresariales
    final categories = [
      Category(
        id: 1,
        name: 'Escolares',
        description: 'Uniformes para estudiantes',
        parentId: null,
        isActive: true,
        imageUrl: 'assets/images/categorias/uniformes_escolares.jpg',
      ),
      Category(
        id: 2,
        name: 'Empresariales',
        description: 'Uniformes corporativos',
        parentId: null,
        isActive: true,
        imageUrl: 'assets/images/categorias/corporativos.jpg',
      ),
    ];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categorías',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: categories
                .map((category) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildCategoryCard(context, category),
                  ),
                ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/school-search');
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: TammysColors.lightGrey,
          border: Border.all(
            color: TammysColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  color: TammysColors.lightGrey,
                  image: category.imageUrl != null
                      ? category.imageUrl!.startsWith('assets/')
                          ? DecorationImage(
                              image: AssetImage(category.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: NetworkImage(category.imageUrl!),
                              fit: BoxFit.cover,
                            )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSchoolsSection() {
    return FutureBuilder<List<School>>(
      future: _popularSchoolsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: LoadingWidget(message: 'Cargando colegios...'),
          );
        }

        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        final schools = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Colegios Populares',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: schools
                      .map((school) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SchoolProductsScreen(school: school),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: TammysColors.lightGrey,
                                  border: Border.all(
                                    color: TammysColors.divider,
                                    width: 1,
                                  ),
                                  image: school.logoUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(school.logoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: school.logoUrl == null
                                    ? Center(
                                        child: Icon(
                                          Icons.school,
                                          color: TammysColors.primary,
                                          size: 32,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  school.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrustSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: TammysColors.lightGrey,
          border: Border.all(
            color: TammysColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, 
                  color: TammysColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Socio Confiable',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Todos nuestros uniformes están fabricados siguiendo las guías oficiales de las instituciones para garantizar el 100% de cumplimiento con los códigos de vestimenta.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: TammysColors.darkGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
