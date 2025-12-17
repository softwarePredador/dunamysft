import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';
import '../../providers/locale_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final user = authService.currentUser;
    final userName = user?.displayName ?? 'Admin';

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_sharp,
            color: AppTheme.adminAccent,
            size: 35,
          ),
          onPressed: () {
            context.go('/home');
          },
        ),
        title: Text(
          'Painel Admin',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              'Sair',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.primaryText,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header com nome do usuário
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Olá $userName',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Menu Items
                _AdminMenuItem(
                  icon: Icons.receipt_long,
                  title: 'Acompanhar Pedidos',
                  onTap: () => context.push('/admin/orders'),
                ),
                _AdminMenuItem(
                  icon: Icons.add_box,
                  title: 'Cadastro de Produtos',
                  onTap: () => context.push('/admin/products'),
                ),
                _AdminMenuItem(
                  icon: Icons.inventory,
                  title: 'Estoque de Produtos',
                  onTap: () => context.push('/admin/stock'),
                ),
                _AdminMenuItem(
                  icon: Icons.photo_library,
                  title: 'Cadastro de fotos/videos',
                  onTap: () => context.push('/admin/media'),
                ),
                _AdminMenuItem(
                  icon: Icons.analytics,
                  title: 'Relatório de Pedidos',
                  onTap: () => context.push('/admin/reports'),
                ),
                _AdminMenuItem(
                  icon: Icons.feedback,
                  title: 'Acompanhar Feedback',
                  onTap: () => context.push('/admin/feedback'),
                ),
                _AdminMenuItem(
                  icon: Icons.category,
                  title: 'Categorias',
                  onTap: () => context.push('/admin/categories'),
                ),
                _AdminMenuItem(
                  icon: Icons.help_outline,
                  title: 'FAQ',
                  onTap: () => context.push('/admin/faq'),
                ),
                
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                
                // Idioma
                _buildLanguageItem(context),

                const SizedBox(height: 30),

                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.adminAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 50,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final flag = _getFlag(localeProvider.locale.languageCode);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InkWell(
            onTap: () => context.push('/settings/language'),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 320,
              height: 70,
              decoration: BoxDecoration(
                color: AppTheme.amarelo.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppTheme.amarelo, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Idioma / Language',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      Text(
                        localeProvider.currentLanguageName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.chevron_right, color: AppTheme.primaryText),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getFlag(String code) {
    switch (code) {
      case 'en': return '🇺🇸';
      case 'es': return '🇪🇸';
      default: return '🇧🇷';
    }
  }
}

class _AdminMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 320,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryText,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(icon, size: 32, color: AppTheme.secondaryBackground),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
