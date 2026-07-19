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
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
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

/// Campo de texto estándar de la app (mismo estilo en todos los formularios)
class TammysTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? minLines;
  final int maxLines;

  const TammysTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.minLines,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    OutlineInputBorder borderWith(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(TammysDimensions.borderRadiusSmall),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      // El teclado (iOS) sigue el tema, evitando un teclado claro en modo oscuro.
      keyboardAppearance: Theme.of(context).brightness,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.5)),
        border: borderWith(scheme.outline),
        enabledBorder: borderWith(scheme.outline),
        focusedBorder: borderWith(scheme.primary, 1.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// Botón primario full-width (negro de marca)
class TammysPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const TammysPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: TammysColors.mediumGrey,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: scheme.onPrimary, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// Botón secundario full-width (contorno de marca)
class TammysSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const TammysSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: scheme.primary),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: scheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Fila de resumen (etiqueta a la izquierda, valor a la derecha).
/// [emphasized] la resalta como fila de total.
class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: emphasized ? 16 : 13,
            fontWeight: emphasized ? FontWeight.bold : FontWeight.w400,
            color: emphasized
                ? scheme.onSurface
                : scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasized ? 16 : 13,
            fontWeight: emphasized ? FontWeight.bold : FontWeight.w600,
            color: emphasized ? scheme.primary : scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Tarjeta seleccionable para métodos de envío (radio custom de marca)
class ShippingOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailingLabel;
  final bool selected;
  final VoidCallback onTap;

  const ShippingOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 2 : 1,
          ),
          borderRadius:
              BorderRadius.circular(TammysDimensions.borderRadiusSmall),
          color: selected
              ? scheme.primary.withValues(alpha: 0.06)
              : scheme.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? scheme.primary : TammysColors.mediumGrey,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              trailingLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
