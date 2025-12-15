import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final user = authService.currentUser;
    final userName = user?.displayName ?? 'Admin';

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Olá $userName',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.go('/home'),
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
                ),
                const SizedBox(height: 30),

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
                          color: AppTheme.amarelo,
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
              Icon(
                icon,
                size: 32,
                color: AppTheme.secondaryBackground,
              ),
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
