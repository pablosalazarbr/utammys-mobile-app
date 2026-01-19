import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:utammys_mobile_app/models/category_model.dart';
import 'package:utammys_mobile_app/screens/category_detail_screen.dart';
import 'package:utammys_mobile_app/screens/school_search_screen.dart';
import 'package:utammys_mobile_app/screens/cart_screen.dart';
import 'package:utammys_mobile_app/services/category_service.dart';
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
      title: "Utammy's Uniforms",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: TammysColors.primary),
        useMaterial3: true,
        fontFamily: 'OpenSans',
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
  late Future<List<Category>> _categoriesFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoryService.getCategories();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TammysColors.background,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Image.asset(
          'assets/images/utamys_horizontal.png',
          height: 40,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: TammysColors.primary),
            onPressed: () {
              Navigator.pushNamed(context, '/school-search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: TammysColors.primary),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Cargando...');
          }

          if (snapshot.hasError) {
            return ErrorDisplay(
              message: 'Error cargando las categorías',
              onRetry: () {
                setState(() {
                  _categoriesFuture = CategoryService.getCategories();
                });
              },
            );
          }

          final categories = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(TammysDimensions.paddingMedium),
                  child: Container(
                    decoration: BoxDecoration(
                      color: TammysColors.lightGrey,
                      borderRadius: BorderRadius.circular(TammysDimensions.borderRadius),
                      border: Border.all(
                        color: TammysColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar uniformes',
                        hintStyle: const TextStyle(
                          color: TammysColors.darkGrey,
                        ),
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: TammysColors.darkGrey,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: TammysDimensions.paddingMedium,
                          vertical: TammysDimensions.paddingSmall,
                        ),
                      ),
                    ),
                  ),
                ),
                // Categorías
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TammysDimensions.paddingMedium,
                  ),
                  child: Text(
                    'Nuestras Categorías',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: TammysColors.primary,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: TammysDimensions.paddingMedium),
                // Grid de categorías
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TammysDimensions.paddingMedium,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: TammysDimensions.paddingMedium,
                      mainAxisSpacing: TammysDimensions.paddingMedium,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(context, category);
                    },
                  ),
                ),
                const SizedBox(height: TammysDimensions.paddingLarge),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: TammysColors.background,
        elevation: 8,
        selectedItemColor: TammysColors.accent,
        unselectedItemColor: TammysColors.darkGrey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(category: category),
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
                    image: AssetImage(category.imageUrl ?? 'assets/images/utamys_white_bg.png'),
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
                    category.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: TammysColors.primary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(category.subCategories?.length ?? category.children?.length ?? 0)} opciones',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TammysColors.darkGrey,
                      fontSize: 12,
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
