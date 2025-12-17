import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/auth_service.dart';
import '../providers/locale_provider.dart';

class EndDrawerWidget extends StatelessWidget {
  const EndDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Drawer(
      backgroundColor: AppTheme.primaryBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.primaryText,
                  size: 24.0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              
              // Title "Menu"
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: Text(
                  AppLocalizations.tr(context).menu,
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryText,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // Menu Items - Scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              _buildMenuItem(
                context,
                iconPath: 'assets/images/vnimc_1.png',
                label: AppLocalizations.tr(context).get('home_menu'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/home');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/3a9k2_3.png',
                label: AppLocalizations.tr(context).profile,
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/profile');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/49svh_2.png',
                label: AppLocalizations.tr(context).orders,
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigate to orders (shows both cart and order history)
                  context.push('/orders');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/fijek_4.png',
                label: AppLocalizations.tr(context).get('feedback'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/feedback');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/2emqy_5.png',
                label: AppLocalizations.tr(context).get('faq'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/faq');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/dfjsb_6.png',
                label: AppLocalizations.tr(context).get('customer_service'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/sac');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/x7hc1_7.png',
                label: AppLocalizations.tr(context).get('maps_directions'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/maps');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/k7eg7_8.png',
                label: AppLocalizations.tr(context).get('image_gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/gallery');
                },
              ),
              _buildMenuItem(
                context,
                iconPath: 'assets/images/nswz3_9.png',
                label: AppLocalizations.tr(context).get('reservations'),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement redirect to reservation site
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.tr(context).get('coming_soon'))),
                  );
                },
              ),
              _buildLanguageMenuItem(context),

              const Divider(thickness: 2.0),

              // Admin Button - temporariamente habilitado para todos
              // TODO: Restaurar condição: if (currentUserEmail == 'hoteldunamys25@gmail.com' || currentUserEmail == 'rafaelhalder@gmail.com')
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/admin');
                  },
                  child: Container(
                    width: 130.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBackground,
                      borderRadius: BorderRadius.circular(65.0),
                      border: Border.all(
                        color: AppTheme.primaryText,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.tr(context).get('admin'),
                        style: GoogleFonts.inter(
                          color: AppTheme.primaryText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20.0),
              
              // Logout Button
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: InkWell(
                    onTap: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        context.go('/login');
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: AppTheme.error),
                          const SizedBox(width: 8.0),
                          Text(
                            AppLocalizations.tr(context).get('logout'),
                            style: GoogleFonts.poppins(
                              color: AppTheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required String iconPath, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 40.0,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  width: 28.0,
                  height: 28.0,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.menu,
                    size: 24,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryText,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Menu item especial para idioma com indicador do idioma atual
  Widget _buildLanguageMenuItem(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final currentLang = localeProvider.currentLanguageName;
        final flag = _getFlag(localeProvider.locale.languageCode);
        
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
              context.push('/settings/language');
            },
            child: Container(
              width: double.infinity,
              height: 40.0,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Flag emoji
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Center(
                      child: Text(
                        flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                    child: Text(
                      AppLocalizations.tr(context).language,
                      style: GoogleFonts.poppins(
                        color: AppTheme.primaryText,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.amarelo.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentLang,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'pt':
      default:
        return '🇧🇷';
    }
  }
}
