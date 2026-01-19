import 'package:flutter/material.dart';

/// Colors para la identidad visual de Utammy's - High Fidelity Design
class TammysColors {
  static const Color primary = Color(0xFF1A1A1A); // Negro principal
  static const Color accent = Color(0xFFEE1D23); // Rojo vibrante (CTA)
  static const Color lightGrey = Color(0xFFF5F5F5); // Fondo gris claro
  static const Color mediumGrey = Color(0xFFD9D9D9); // Bordes grises
  static const Color darkGrey = Color(0xFF666666); // Texto secundario
  static const Color background = Color(0xFFFFFFFF); // Blanco puro
  static const Color textPrimary = Color(0xFF1A1A1A); // Negro para textos
  static const Color textSecondary = Color(0xFF666666); // Gris para textos secundarios
  static const Color divider = Color(0xFFE8E8E8); // Divisores suaves
  static const Color borderColor = Color(0xFFDDDDDD); // Bordes sutiles
}

/// Dimensiones estándar para la app - High Fidelity
class TammysDimensions {
  static const double borderRadius = 16.0; // Bordes más redondeados
  static const double borderRadiusSmall = 8.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double iconSize = 24.0;
  static const double cardElevation = 2.0;
}

/// Widget para tarjetas de categorías
class CategoryCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? backgroundColor;

  const CategoryCard({
    super.key,
    required this.title,
    this.imageUrl,
    required this.onTap,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TammysDimensions.borderRadius),
          color: backgroundColor ?? Colors.white,
          border: Border.all(
            color: TammysColors.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image o color
            if (imageUrl != null)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(TammysDimensions.borderRadius),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: backgroundColor ?? Colors.grey[100],
                    );
                  },
                ),
              )
            else
              Container(
                color: backgroundColor ?? Colors.grey[100],
              ),
            // Overlay oscuro para mejorar legibilidad
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(TammysDimensions.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // Contenido (icon + título)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 48,
                    color: TammysColors.primary,
                  ),
                const SizedBox(height: TammysDimensions.paddingMedium),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: TammysDimensions.paddingSmall,
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TammysColors.textPrimary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para tarjetas de subcategorías (más compactas)
class SubCategoryCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback onTap;

  const SubCategoryCard({
    super.key,
    required this.title,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TammysDimensions.borderRadius),
          color: Colors.white,
          border: Border.all(
            color: TammysColors.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(TammysDimensions.borderRadius),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                    );
                  },
                ),
              )
            else
              Container(
                color: Colors.grey[100],
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(TammysDimensions.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TammysDimensions.paddingSmall),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft:
                        Radius.circular(TammysDimensions.borderRadius),
                    bottomRight:
                        Radius.circular(TammysDimensions.borderRadius),
                  ),
                  color: Colors.black.withOpacity(0.4),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar estado de carga
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(TammysColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: TammysDimensions.paddingMedium),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para mostrar errores
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: TammysColors.accent,
          ),
          const SizedBox(height: TammysDimensions.paddingMedium),
          Text(
            'Oops!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: TammysDimensions.paddingSmall),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TammysDimensions.paddingLarge,
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: TammysDimensions.paddingLarge),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar de nuevo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TammysColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar errores de carga de datos
class ErrorLoadingWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorLoadingWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_outlined,
            size: 64,
            color: Colors.orange[600],
          ),
          const SizedBox(height: TammysDimensions.paddingMedium),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: TammysDimensions.paddingLarge),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: TammysColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
