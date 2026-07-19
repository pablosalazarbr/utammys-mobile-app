import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:utammys_mobile_app/services/theme_controller.dart';
import 'package:utammys_mobile_app/theme/app_theme.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';
import 'package:utammys_mobile_app/screens/privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = 'Versión ${info.version} (${info.buildNumber})');
      }
    } catch (_) {
      if (mounted) setState(() => _version = 'Versión 1.0.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tScaffold,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          children: [
          // --- Información de la app ---
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.tCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/images/utamys_icon_white.png',
                    height: 56,
                    width: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.checkroom,
                      size: 56,
                      color: context.tTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Uniformes Tamys',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.tTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _version,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.tTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Catálogo en línea para la compra de uniformes escolares '
                    'y empresariales de alta calidad en Guatemala.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: context.tTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- Apariencia ---
          const _SectionLabel('Apariencia'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.instance.mode,
              builder: (context, mode, _) {
                return SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    'Modo oscuro',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.tTextPrimary,
                    ),
                  ),
                  subtitle: Text(
                    mode == ThemeMode.dark ? 'Activado' : 'Desactivado',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.tTextSecondary,
                    ),
                  ),
                  secondary: Icon(
                    mode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: context.tTextPrimary,
                  ),
                  activeThumbColor: TammysColors.accent,
                  value: mode == ThemeMode.dark,
                  onChanged: (v) => ThemeController.instance.setDark(v),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // --- Legal ---
          const _SectionLabel('Legal'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Icon(Icons.privacy_tip_outlined,
                  color: context.tTextPrimary),
              title: Text(
                'Política de Privacidad',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.tTextPrimary,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: context.tTextSecondary),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'privacy'),
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2026 Uniformes Tamys',
              style: TextStyle(
                fontSize: 11,
                color: context.tTextSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: context.tTextSecondary,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.tSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tBorder),
      ),
      child: child,
    );
  }
}
