import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/models/school_model.dart';
import 'package:utammys_mobile_app/screens/school_products_screen.dart';
import 'package:utammys_mobile_app/services/school_service.dart';
import 'package:utammys_mobile_app/services/cart_service.dart';
import 'package:utammys_mobile_app/widgets/custom_bottom_nav_bar.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';

class SchoolSearchScreen extends StatefulWidget {
  const SchoolSearchScreen({super.key});

  @override
  State<SchoolSearchScreen> createState() => _SchoolSearchScreenState();
}

class _SchoolSearchScreenState extends State<SchoolSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<School>> _schoolsFuture;
  List<School> _allSchools = [];
  List<School> _filteredSchools = [];
  bool _isSearching = false;
  int _currentNavIndex = 1; // Search tab

  @override
  void initState() {
    super.initState();
    _schoolsFuture = _loadSchools();
  }

  Future<List<School>> _loadSchools() async {
    try {
      final schools = await SchoolService.getSchools();
      setState(() {
        _allSchools = schools;
        _filteredSchools = schools;
      });
      return schools;
    } catch (e) {
      rethrow;
    }
  }

  void _filterSchools(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredSchools = _allSchools;
      } else {
        _filteredSchools = _allSchools
            .where((school) =>
                school.name.toLowerCase().contains(query.toLowerCase()) ||
                (school.city?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  void _handleNavigation(int index) {
    if (index == _currentNavIndex) return;
    
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        break;
      case 1:
        // Already on search
        break;
      case 2:
        Navigator.pushNamed(context, '/cart');
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text(
          'Buscar Colegio',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<School>>(
        future: _schoolsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Cargando colegios...');
          }

          if (snapshot.hasError) {
            return ErrorLoadingWidget(
              message: 'Error al cargar colegios',
              onRetry: () {
                setState(() {
                  _schoolsFuture = _loadSchools();
                });
              },
            );
          }

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: TammysColors.background,
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSchools,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o ciudad...',
                    prefixIcon: const Icon(Icons.search, color: TammysColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: TammysColors.primary),
                            onPressed: () {
                              _searchController.clear();
                              _filterSchools('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              // Schools List
              Expanded(
                child: _filteredSchools.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching
                                  ? 'No se encontraron colegios'
                                  : 'No hay colegios disponibles',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredSchools.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final school = _filteredSchools[index];
                          return SchoolCard(
                            school: school,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SchoolProductsScreen(school: school),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
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

class SchoolCard extends StatelessWidget {
  final School school;
  final VoidCallback onTap;

  const SchoolCard({
    super.key,
    required this.school,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[200],
              ),
              child: school.logoUrl != null && school.logoUrl!.isNotEmpty
                  ? Image.network(
                      school.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (school.city != null)
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          school.city!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  if (school.type != null) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        school.type,
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: school.type.toUpperCase() == 'ESCOLAR'
                          ? Colors.blue
                          : Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Sin imagen',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
