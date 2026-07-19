import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/models/school_model.dart';
import 'package:utammys_mobile_app/screens/school_products_screen.dart';
import 'package:utammys_mobile_app/services/school_service.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';
import 'package:utammys_mobile_app/theme/app_theme.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<School>>(
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
                color: context.tScaffold,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: context.tTextPrimary),
                  onChanged: _filterSchools,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o ciudad...',
                    hintStyle: TextStyle(color: context.tTextSecondary),
                    prefixIcon: Icon(Icons.search, color: context.tTextSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: context.tTextSecondary),
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
                    fillColor: context.tCard,
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
                              color: context.tTextSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching
                                  ? 'No se encontraron colegios'
                                  : 'No hay colegios disponibles',
                              style: TextStyle(
                                fontSize: 16,
                                color: context.tTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredSchools.length,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 110),
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
    final typeColor = school.type.toUpperCase() == 'ESCOLAR'
        ? const Color(0xFF2563EB)
        : const Color(0xFFEA580C);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: context.tSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.tBorder),
            ),
            child: Row(
              children: [
                // Logo circular
                Container(
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.tCard,
                  ),
                  child: school.logoUrl != null && school.logoUrl!.isNotEmpty
                      ? Image.network(
                          school.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                        )
                      : _buildPlaceholder(context),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        school.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.tTextPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (school.city != null && school.city!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13, color: context.tTextSecondary),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                school.city!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: context.tTextSecondary),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (school.type.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            school.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: typeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: context.tTextSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Icon(Icons.school_outlined, size: 28, color: context.tTextSecondary),
    );
  }
}
